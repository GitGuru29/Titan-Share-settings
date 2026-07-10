#pragma once
#include <QObject>
#include <QString>
#include <QTimer>

class SystemInfo : public QObject {
    Q_OBJECT

    Q_PROPERTY(QString hostname READ hostname NOTIFY hostnameChanged)
    Q_PROPERTY(QString kernelVersion READ kernelVersion CONSTANT)
    Q_PROPERTY(QString osVersion READ osVersion CONSTANT)
    Q_PROPERTY(QString cpuModel READ cpuModel CONSTANT)
    Q_PROPERTY(QString gpuModel READ gpuModel CONSTANT)
    Q_PROPERTY(int totalRam READ totalRam CONSTANT)
    Q_PROPERTY(int usedRam READ usedRam NOTIFY usedRamChanged)
    Q_PROPERTY(double cpuUsage READ cpuUsage NOTIFY cpuUsageChanged)
    Q_PROPERTY(double diskUsedGb READ diskUsedGb NOTIFY diskUsedGbChanged)
    Q_PROPERTY(double diskTotalGb READ diskTotalGb CONSTANT)
    Q_PROPERTY(QString uptime READ uptime NOTIFY uptimeChanged)
    Q_PROPERTY(int batteryLevel READ batteryLevel NOTIFY batteryLevelChanged)
    Q_PROPERTY(bool batteryCharging READ batteryCharging NOTIFY batteryChargingChanged)

public:
    explicit SystemInfo(QObject *parent = nullptr);

    QString hostname() const;
    QString kernelVersion() const;
    QString osVersion() const;
    QString cpuModel() const;
    QString gpuModel() const;
    int totalRam() const;
    int usedRam() const;
    double cpuUsage() const;
    double diskUsedGb() const;
    double diskTotalGb() const;
    QString uptime() const;
    int batteryLevel() const;
    bool batteryCharging() const;

signals:
    void hostnameChanged();
    void usedRamChanged();
    void cpuUsageChanged();
    void diskUsedGbChanged();
    void uptimeChanged();
    void batteryLevelChanged();
    void batteryChargingChanged();

private slots:
    void refresh();

private:
    QTimer m_timer;
    mutable QString m_cpuModel;
    mutable QString m_gpuModel;
    mutable int m_totalRam = 0;
    mutable double m_diskTotalGb = 0.0;

    double m_cpuUsage = 0.0;
    int m_usedRam = 0;
    double m_diskUsedGb = 0.0;
    int m_batteryLevel = 100;
    bool m_batteryCharging = false;

    // for CPU delta calculation
    long long m_prevIdle = 0, m_prevTotal = 0;

    void readCpuUsage();
    void readMemory();
    void readDisk();
    void readBattery();
    void initCpuModel();
    void initTotalRam();
    void initDiskTotal();
};
