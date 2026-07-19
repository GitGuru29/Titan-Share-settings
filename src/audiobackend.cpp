#include "audiobackend.h"
#include <QProcess>
#include <QFile>
#include <QTextStream>
#include <QVariant>
#include <QDir>

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
    applyEqProfile(profile);
}

void AudioBackend::applyEqProfile(const QString &profile) {
    // Band definitions: { frequency, gain_dB }
    struct Band { double freq; double gain; };

    QList<Band> bands;

    if (profile == "Flat") {
        bands = { {32,0},{64,0},{125,0},{250,0},{500,0},{1000,0},{2000,0},{4000,0},{8000,0},{16000,0} };
    } else if (profile == "Bass Boost") {
        bands = { {32,6},{64,5},{125,3},{250,1},{500,0},{1000,0},{2000,0},{4000,0},{8000,0},{16000,0} };
    } else if (profile == "Vocal") {
        bands = { {32,-2},{64,-2},{125,0},{250,2},{500,4},{1000,4},{2000,4},{4000,2},{8000,0},{16000,-2} };
    } else if (profile == "Electronic") {
        bands = { {32,4},{64,4},{125,2},{250,0},{500,-2},{1000,-2},{2000,0},{4000,2},{8000,4},{16000,4} };
    } else if (profile == "Acoustic") {
        bands = { {32,0},{64,2},{125,2},{250,0},{500,0},{1000,0},{2000,2},{4000,2},{8000,2},{16000,0} };
    } else {
        return;
    }

    // Build PipeWire filter-chain SPA-JSON config
    QString config;
    QTextStream ts(&config);

    ts << "# ArchTitan EQ — generated by ArchTitan Settings\n";
    ts << "# Profile: " << profile << "\n\n";
    ts << "context.modules = [\n";
    ts << "    { name = libpipewire-module-filter-chain\n";
    ts << "        args = {\n";
    ts << "            node.description = \"ArchTitan Equalizer\"\n";
    ts << "            media.name       = \"ArchTitan Equalizer\"\n";
    ts << "            filter.graph = {\n";
    ts << "                nodes = [\n";

    for (int i = 0; i < bands.size(); ++i) {
        const auto &b = bands[i];
        QString label = (i == 0) ? "bq_lowshelf" : (i == bands.size()-1) ? "bq_highshelf" : "bq_peaking";
        ts << "                    {\n";
        ts << "                        type  = builtin\n";
        ts << QString("                        name  = eq_band_%1\n").arg(i + 1);
        ts << "                        label = " << label << "\n";
        ts << QString("                        control = { \"Freq\" = %1 \"Q\" = 0.707 \"Gain\" = %2 }\n")
              .arg(b.freq, 0, 'f', 1)
              .arg(b.gain, 0, 'f', 1);
        ts << "                    }\n";
    }

    ts << "                ]\n";
    ts << "                links = [\n";
    for (int i = 0; i < bands.size() - 1; ++i) {
        ts << QString("                    { output = \"eq_band_%1:Out\" input = \"eq_band_%2:In\" }\n")
              .arg(i + 1).arg(i + 2);
    }
    ts << "                ]\n";
    ts << "            }\n";
    ts << "            audio.channels = 2\n";
    ts << "            audio.position = [ FL FR ]\n";
    ts << "            capture.props = {\n";
    ts << "                node.name   = \"effect_input.archtitan_eq\"\n";
    ts << "                media.class = Audio/Sink\n";
    ts << "            }\n";
    ts << "            playback.props = {\n";
    ts << "                node.name   = \"effect_output.archtitan_eq\"\n";
    ts << "                node.passive = true\n";
    ts << "            }\n";
    ts << "        }\n";
    ts << "    }\n";
    ts << "]\n";

    // Write to ~/.config/pipewire/filter-chain.conf.d/
    QString confDir = QDir::homePath() + "/.config/pipewire/filter-chain.conf.d";
    QDir().mkpath(confDir);
    QString confPath = confDir + "/archtitan-eq.conf";

    QFile file(confPath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        file.write(config.toUtf8());
        file.close();
    }

    // Reload PipeWire filter-chain and route all audio through the EQ sink
    QProcess::startDetached("bash", {"-c",
        // Step 1: restart filter-chain service to load new config
        "systemctl --user restart filter-chain 2>/dev/null; "
        // Step 2: wait briefly for the virtual sink to appear
        "sleep 0.5; "
        // Step 3: set EQ virtual sink as the default output
        "pactl set-default-sink effect_input.archtitan_eq 2>/dev/null; "
        // Step 4: move all currently playing streams through the EQ
        "pactl list short sink-inputs 2>/dev/null | awk '{print $1}' | "
        "xargs -I{} pactl move-sink-input {} effect_input.archtitan_eq 2>/dev/null; "
        "true"
    });
}

void AudioBackend::openMixer() {
    QProcess::startDetached("bash", {"-c", "pavucontrol &"});
}

void AudioBackend::installEqPresets() {
    // Apply the default Flat profile on startup to ensure filter-chain is loaded
    applyEqProfile(m_activeEqProfile);
}
