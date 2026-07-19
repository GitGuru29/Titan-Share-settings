#include "audiobackend.h"
#include <QProcess>
#include <QFile>
#include <QTextStream>
#include <QVariant>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QDir>
#include <QStandardPaths>

AudioBackend::AudioBackend(QObject *parent) : QObject(parent) {
    m_debounceTimer.setSingleShot(true);
    m_debounceTimer.setInterval(50); // 50ms debounce
    connect(&m_debounceTimer, &QTimer::timeout, this, &AudioBackend::sync);

    installEqPresets();

    connect(&m_monitorProcess, &QProcess::readyReadStandardOutput, this, [this]() {
        m_monitorProcess.readAllStandardOutput(); // Clear buffer
        m_debounceTimer.start(); // Restart debounce timer
    });
    
    // Subscribe to PulseAudio/PipeWire events so we don't have to poll
    m_monitorProcess.start("pactl", {"subscribe"});

    // Start cava for real-time equalizer
    QFile cavaConf("/tmp/archtitan-cava.conf");
    if (cavaConf.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        QTextStream ts(&cavaConf);
        ts << "[general]\nbars = 24\nframerate = 60\n"
           << "[output]\nmethod = raw\nraw_target = /dev/stdout\ndata_format = ascii\nascii_max_range = 100\n";
        cavaConf.close();
    }

    connect(&m_cavaProcess, &QProcess::readyReadStandardOutput, this, [this]() {
        while (m_cavaProcess.canReadLine()) {
            QString line = QString::fromUtf8(m_cavaProcess.readLine()).trimmed();
            if (line.isEmpty()) continue;
            QStringList parts = line.split(';', Qt::SkipEmptyParts);
            QVariantList levels;
            for (const QString &p : parts) {
                levels.append(p.toInt());
            }
            if (levels.size() == 24) {
                m_eqLevels = levels;
                emit eqLevelsChanged();
            }
        }
    });
    m_cavaProcess.start("cava", {"-p", "/tmp/archtitan-cava.conf"});

    // Initialize 24 empty bars
    for (int i=0; i<24; i++) m_eqLevels.append(0);

    sync();
}

void AudioBackend::sync() {
    // Master volume
    QProcess p;
    p.start("bash", {"-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null"});
    p.waitForFinished(1000);
    QString out = p.readAllStandardOutput().trimmed();
    QStringList parts = out.split(' ');
    if (parts.size() >= 2) {
        int vol = (int)(parts[1].toDouble() * 100);
        if (m_masterVolume != vol) { m_masterVolume = vol; emit masterVolumeChanged(); }
    }
    bool muted = out.contains("[MUTED]");
    if (m_masterMuted != muted) { m_masterMuted = muted; emit masterMutedChanged(); }

    // Microphone volume
    QProcess p2;
    p2.start("bash", {"-c", "wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null"});
    p2.waitForFinished(1000);
    QString out2 = p2.readAllStandardOutput().trimmed();
    QStringList parts2 = out2.split(' ');
    if (parts2.size() >= 2) {
        int mvol = (int)(parts2[1].toDouble() * 100);
        if (m_micVolume != mvol) { m_micVolume = mvol; emit micVolumeChanged(); }
    }
    bool mmuted = out2.contains("[MUTED]");
    if (m_micMuted != mmuted) { m_micMuted = mmuted; emit micMutedChanged(); }

    // Active sink name
    QProcess sink;
    sink.start("bash", {"-c", "wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep 'node.nick\\|node.name' | head -1 | awk -F'\"' '{print $2}'"});
    sink.waitForFinished(1000);
    QString act = sink.readAllStandardOutput().trimmed();
    if (act.isEmpty()) act = "Default Output";
    if (m_activeOutput != act) { m_activeOutput = act; emit activeOutputChanged(); }
}

int AudioBackend::masterVolume() const { return m_masterVolume; }
void AudioBackend::setMasterVolume(int v) {
    v = qBound(0, v, 100);
    if (m_masterVolume == v) return;
    m_masterVolume = v;
    QProcess::startDetached("wpctl", {"set-volume", "@DEFAULT_AUDIO_SINK@", QString("%1%").arg(v)});
    emit masterVolumeChanged();
}

bool AudioBackend::masterMuted() const { return m_masterMuted; }
void AudioBackend::setMasterMuted(bool v) {
    if (m_masterMuted == v) return;
    m_masterMuted = v;
    QProcess::startDetached("wpctl", {"set-mute", "@DEFAULT_AUDIO_SINK@", v ? "1" : "0"});
    emit masterMutedChanged();
}

int AudioBackend::micVolume() const { return m_micVolume; }
void AudioBackend::setMicVolume(int v) {
    v = qBound(0, v, 100);
    if (m_micVolume == v) return;
    m_micVolume = v;
    QProcess::startDetached("wpctl", {"set-volume", "@DEFAULT_AUDIO_SOURCE@", QString("%1%").arg(v)});
    emit micVolumeChanged();
}

bool AudioBackend::micMuted() const { return m_micMuted; }
void AudioBackend::setMicMuted(bool v) {
    if (m_micMuted == v) return;
    m_micMuted = v;
    QProcess::startDetached("wpctl", {"set-mute", "@DEFAULT_AUDIO_SOURCE@", v ? "1" : "0"});
    emit micMutedChanged();
}

QString AudioBackend::activeOutput() const { return m_activeOutput; }

QVariantList AudioBackend::eqLevels() const { return m_eqLevels; }

QString AudioBackend::activeEqProfile() const { return m_activeEqProfile; }

void AudioBackend::setActiveEqProfile(const QString &profile) {
    if (m_activeEqProfile == profile) return;
    m_activeEqProfile = profile;
    emit activeEqProfileChanged();

    // Apply via D-Bus — works whether EasyEffects GUI is open or not
    QString cmd;
    if (profile == "Flat") {
        // Bypass all effects
        cmd = "gdbus call --session "
              "--dest com.github.wwmm.easyeffects "
              "--object-path /com/github/wwmm/easyeffects "
              "--method com.github.wwmm.easyeffects.LoadPreset "
              "\"output\" \"Flat\" 2>/dev/null || true";
    } else {
        cmd = QString(
              "gdbus call --session "
              "--dest com.github.wwmm.easyeffects "
              "--object-path /com/github/wwmm/easyeffects "
              "--method com.github.wwmm.easyeffects.LoadPreset "
              "\"output\" \"%1\" 2>/dev/null || true"
        ).arg(profile);
    }
    QProcess::startDetached("bash", {"-c", cmd});
}

void AudioBackend::openMixer() {
    QProcess::startDetached("bash", {"-c", "pavucontrol &"});
}

void AudioBackend::installEqPresets() {
    QString configDir = QDir::homePath() + "/.config/easyeffects/output";
    QString localDir = QDir::homePath() + "/.local/share/easyeffects/output";
    
    QDir().mkpath(configDir);
    QDir().mkpath(localDir);

    auto createPreset = [&](const QString& name, const QList<QPair<double, double>>& bands) {
        QString path1 = configDir + "/" + name + ".json";
        QString path2 = localDir + "/" + name + ".json";
        
        if (QFile::exists(path1) || QFile::exists(path2)) return; // Don't overwrite

        QJsonObject left, right;
        for (int i = 0; i < bands.size(); ++i) {
            QJsonObject band;
            band["frequency"] = bands[i].first;
            band["gain"] = bands[i].second;
            band["mode"] = "RLC (BT)";
            band["muting"] = false;
            band["q"] = 1.0;
            band["type"] = "Bell";
            band["width"] = 4.0;
            left[QString("band%1").arg(i)] = band;
            right[QString("band%1").arg(i)] = band;
        }

        QJsonObject equalizer;
        equalizer["balance"] = 0.0;
        equalizer["bypass"] = false;
        equalizer["input-gain"] = 0.0;
        equalizer["left"] = left;
        equalizer["right"] = right;
        equalizer["num-bands"] = bands.size();
        equalizer["pitch-left"] = 0.0;
        equalizer["pitch-right"] = 0.0;
        equalizer["split-channels"] = false;

        QJsonArray order;
        order.append("equalizer#0");

        QJsonObject output;
        output["equalizer#0"] = equalizer;
        output["plugins_order"] = order;

        QJsonObject root;
        root["output"] = output;

        QFile file1(path1);
        if (file1.open(QIODevice::WriteOnly)) {
            file1.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
            file1.close();
        }
        QFile file2(path2);
        if (file2.open(QIODevice::WriteOnly)) {
            file2.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
            file2.close();
        }
    };

    createPreset("Bass Boost", {
        {32.0, 6.0}, {64.0, 4.0}, {125.0, 2.0}, {250.0, 0.0}, {500.0, 0.0},
        {1000.0, 0.0}, {2000.0, 0.0}, {4000.0, 0.0}, {8000.0, 0.0}, {16000.0, 0.0}
    });

    createPreset("Vocal", {
        {32.0, -2.0}, {64.0, -2.0}, {125.0, 0.0}, {250.0, 2.0}, {500.0, 4.0},
        {1000.0, 4.0}, {2000.0, 4.0}, {4000.0, 2.0}, {8000.0, 0.0}, {16000.0, -2.0}
    });

    createPreset("Electronic", {
        {32.0, 4.0}, {64.0, 4.0}, {125.0, 2.0}, {250.0, 0.0}, {500.0, -2.0},
        {1000.0, -2.0}, {2000.0, 0.0}, {4000.0, 2.0}, {8000.0, 4.0}, {16000.0, 4.0}
    });

    createPreset("Acoustic", {
        {32.0, 0.0}, {64.0, 2.0}, {125.0, 2.0}, {250.0, 0.0}, {500.0, 0.0},
        {1000.0, 0.0}, {2000.0, 2.0}, {4000.0, 2.0}, {8000.0, 2.0}, {16000.0, 0.0}
    });
}
