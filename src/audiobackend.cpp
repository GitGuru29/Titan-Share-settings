#include "audiobackend.h"
#include <QProcess>

AudioBackend::AudioBackend(QObject *parent) : QObject(parent) {
    m_timer.setInterval(2000);
    connect(&m_timer, &QTimer::timeout, this, &AudioBackend::sync);
    m_timer.start();
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

void AudioBackend::openMixer() {
    QProcess::startDetached("bash", {"-c", "pavucontrol &"});
}
