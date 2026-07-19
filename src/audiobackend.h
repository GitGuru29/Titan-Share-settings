#pragma once
#include <QObject>
#include <QTimer>
#include <QProcess>

class AudioBackend : public QObject {
    Q_OBJECT

    Q_PROPERTY(int masterVolume READ masterVolume WRITE setMasterVolume NOTIFY masterVolumeChanged)
    Q_PROPERTY(bool masterMuted READ masterMuted WRITE setMasterMuted NOTIFY masterMutedChanged)
    Q_PROPERTY(int micVolume READ micVolume WRITE setMicVolume NOTIFY micVolumeChanged)
    Q_PROPERTY(bool micMuted READ micMuted WRITE setMicMuted NOTIFY micMutedChanged)
    Q_PROPERTY(QString activeOutput READ activeOutput NOTIFY activeOutputChanged)
    Q_PROPERTY(QVariantList eqLevels READ eqLevels NOTIFY eqLevelsChanged)

public:
    explicit AudioBackend(QObject *parent = nullptr);
    int masterVolume() const;
    void setMasterVolume(int v);
    bool masterMuted() const;
    void setMasterMuted(bool v);
    int micVolume() const;
    void setMicVolume(int v);
    bool micMuted() const;
    void setMicMuted(bool v);
    QString activeOutput() const;
    QVariantList eqLevels() const;
    Q_INVOKABLE void openMixer();

signals:
    void masterVolumeChanged();
    void masterMutedChanged();
    void micVolumeChanged();
    void micMutedChanged();
    void activeOutputChanged();
    void eqLevelsChanged();

private slots:
    void sync();

private:
    QProcess m_monitorProcess;
    QProcess m_cavaProcess;
    QTimer m_debounceTimer;
    int m_masterVolume = 70;
    bool m_masterMuted = false;
    int m_micVolume = 80;
    bool m_micMuted = false;
    QString m_activeOutput;
    QVariantList m_eqLevels;
};
