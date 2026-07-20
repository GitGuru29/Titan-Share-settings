#include "audiobackend.h"
#include <QProcess>
#include <QFile>
#include <QTextStream>
#include <QVariant>
#include <QDir>
#include <QSettings>

AudioBackend::AudioBackend(QObject *parent) : QObject(parent) {
    m_debounceTimer.setSingleShot(true);
    m_debounceTimer.setInterval(50); // 50ms debounce
    connect(&m_debounceTimer, &QTimer::timeout, this, &AudioBackend::sync);

    // Load custom gains from QSettings
    QSettings settings("ArchTitan", "archtitan-settings");
    m_customGains = settings.value("audio/customGains").toList();
    if (m_customGains.size() != 10) {
        m_customGains.clear();
        for (int i = 0; i < 10; ++i) {
            m_customGains.append(0.0);
        }
    }

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
    } else if (profile == "Custom") {
        bands = {
            {32, m_customGains[0].toDouble()},
            {64, m_customGains[1].toDouble()},
            {125, m_customGains[2].toDouble()},
            {250, m_customGains[3].toDouble()},
            {500, m_customGains[4].toDouble()},
            {1000, m_customGains[5].toDouble()},
            {2000, m_customGains[6].toDouble()},
            {4000, m_customGains[7].toDouble()},
            {8000, m_customGains[8].toDouble()},
            {16000, m_customGains[9].toDouble()}
        };
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

    // Write config (for persistence on reboot)
    QString confDir = QDir::homePath() + "/.config/pipewire/filter-chain.conf.d";
    QDir().mkpath(confDir);
    QFile file(confDir + "/archtitan-eq.conf");
    if (file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        file.write(config.toUtf8());
        file.close();
    }

    // Build a script that updates the filter-chain's Gains LIVE via pw-cli set-param
    // This avoids restarting the service — no audio gap
    QString paramsList;
    for (int i = 0; i < bands.size(); ++i) {
        paramsList += QString(" \"eq_band_%1:Gain\" %2").arg(i + 1).arg(bands[i].gain, 0, 'f', 1);
    }

    QString liveScript = QString(
        "PW=$(pw-dump 2>/dev/null); "
        "ID=$(echo \"$PW\" | python3 -c \""
        "import sys,json;"
        "d=json.load(sys.stdin);"
        "[print(n[\\\"id\\\"]) for n in d if n.get(\\\"info\\\",{}).get(\\\"props\\\",{}).get(\\\"node.name\\\")==\\\"effect_input.archtitan_eq\\\"]"
        "\" 2>/dev/null | head -1); "
        "if [ -n \"$ID\" ]; then "
        "  pw-cli set-param $ID Props '{ params: [%1 ] }' 2>/dev/null; "
        "else "
        "  systemctl --user start filter-chain 2>/dev/null; "
        "  sleep 0.8; "
        "  pactl set-default-sink effect_input.archtitan_eq 2>/dev/null; "
        "  pactl list short sink-inputs 2>/dev/null | awk '{print $1}' | "
        "  xargs -I{} pactl move-sink-input {} effect_input.archtitan_eq 2>/dev/null; "
        "fi; "
        "true"
    ).arg(paramsList);

    QProcess::startDetached("bash", {"-c", liveScript});
}

void AudioBackend::openMixer() {
    QProcess::startDetached("bash", {"-c", "pavucontrol &"});
}

void AudioBackend::installEqPresets() {
    // Try to load the previously active profile from the written config file
    QString confPath = QDir::homePath() + "/.config/pipewire/filter-chain.conf.d/archtitan-eq.conf";
    QFile file(confPath);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        while (!in.atEnd()) {
            QString line = in.readLine();
            if (line.startsWith("# Profile: ")) {
                QString profile = line.mid(11).trimmed();
                if (profile == "Flat" || profile == "Bass Boost" || profile == "Vocal" || profile == "Electronic" || profile == "Acoustic" || profile == "Custom") {
                    m_activeEqProfile = profile;
                }
                break;
            }
        }
        file.close();
    }

    // Apply the profile on startup to ensure filter-chain is loaded
    applyEqProfile(m_activeEqProfile);
}

QVariantList AudioBackend::customGains() const {
    return m_customGains;
}

void AudioBackend::setCustomGains(const QVariantList &v) {
    if (m_customGains == v) return;
    m_customGains = v;
    emit customGainsChanged();
    if (m_activeEqProfile == "Custom") {
        applyEqProfile("Custom");
    }
}

void AudioBackend::setCustomBandGain(int index, double gain) {
    if (index < 0 || index >= m_customGains.size()) return;
    if (qFuzzyCompare(m_customGains[index].toDouble(), gain)) return;
    
    m_customGains[index] = gain;
    emit customGainsChanged();
    
    // Save to settings
    QSettings settings("ArchTitan", "archtitan-settings");
    settings.setValue("audio/customGains", m_customGains);
    settings.sync();

    // If custom is selected, apply it live
    if (m_activeEqProfile == "Custom") {
        applyEqProfile("Custom");
    }
}

void AudioBackend::resetCustomGains() {
    bool changed = false;
    for (int i = 0; i < m_customGains.size(); ++i) {
        if (!qFuzzyCompare(m_customGains[i].toDouble(), 0.0)) {
            m_customGains[i] = 0.0;
            changed = true;
        }
    }
    
    if (changed) {
        emit customGainsChanged();
        
        QSettings settings("ArchTitan", "archtitan-settings");
        settings.setValue("audio/customGains", m_customGains);
        settings.sync();

        if (m_activeEqProfile == "Custom") {
            applyEqProfile("Custom");
        }
    }
}
