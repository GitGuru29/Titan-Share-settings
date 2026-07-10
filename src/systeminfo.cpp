#include "systeminfo.h"
#include <QFile>
#include <QTextStream>
#include <QProcess>
#include <QDir>
#include <QDateTime>
#include <QRegularExpression>
#include <sys/statvfs.h>
#include <unistd.h>

SystemInfo::SystemInfo(QObject *parent) : QObject(parent) {
    // Eager init of CONSTANT properties before QML first reads them
    initCpuModel();
    initTotalRam();
    initDiskTotal();

    m_timer.setInterval(2000);
    connect(&m_timer, &QTimer::timeout, this, &SystemInfo::refresh);
    m_timer.start();
    refresh();
}

void SystemInfo::refresh() {
    readCpuUsage();
    readMemory();
    readDisk();
    readBattery();
}

QString SystemInfo::hostname() const {
    char buf[256];
    if (gethostname(buf, sizeof(buf)) == 0)
        return QString::fromLocal8Bit(buf);
    return "archtitan";
}

QString SystemInfo::kernelVersion() const {
    QFile f("/proc/version");
    if (f.open(QIODevice::ReadOnly)) {
        QString line = QTextStream(&f).readLine();
        // "Linux version X.Y.Z ..."
        QStringList parts = line.split(' ');
        if (parts.size() >= 3) return parts[2];
    }
    return "unknown";
}

QString SystemInfo::osVersion() const {
    QFile f("/etc/os-release");
    if (f.open(QIODevice::ReadOnly)) {
        QTextStream ts(&f);
        while (!ts.atEnd()) {
            QString line = ts.readLine();
            if (line.startsWith("PRETTY_NAME="))
                return line.mid(13).remove('"');
        }
    }
    return "ArchTitan OS";
}

void SystemInfo::initCpuModel() {
    QFile f("/proc/cpuinfo");
    if (f.open(QIODevice::ReadOnly)) {
        QTextStream ts(&f);
        while (!ts.atEnd()) {
            QString line = ts.readLine();
            if (line.startsWith("model name")) {
                m_cpuModel = line.section(':', 1).trimmed();
                // Shorten verbose Intel/AMD strings
                m_cpuModel.replace(QRegularExpression("\\s{2,}"), " ");
                return;
            }
        }
    }
    // Fallback: try /proc/cpuinfo Hardware field (ARM)
    QFile f2("/proc/cpuinfo");
    if (f2.open(QIODevice::ReadOnly)) {
        QTextStream ts(&f2);
        while (!ts.atEnd()) {
            QString line = ts.readLine();
            if (line.startsWith("Hardware")) {
                m_cpuModel = line.section(':', 1).trimmed();
                return;
            }
        }
    }
    m_cpuModel = "Unknown CPU";
}

void SystemInfo::initTotalRam() {
    QFile f("/proc/meminfo");
    if (f.open(QIODevice::ReadOnly)) {
        QTextStream ts(&f);
        while (!ts.atEnd()) {
            QString line = ts.readLine();
            if (line.startsWith("MemTotal:")) {
                m_totalRam = line.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts).value(1).toLongLong() / 1024;
                return;
            }
        }
    }
}

void SystemInfo::initDiskTotal() {
    struct statvfs st;
    if (statvfs("/", &st) == 0)
        m_diskTotalGb = (double)(st.f_blocks * st.f_frsize) / (1024.0*1024.0*1024.0);
}

QString SystemInfo::cpuModel() const {
    return m_cpuModel.isEmpty() ? QStringLiteral("Unknown CPU") : m_cpuModel;
}

QString SystemInfo::gpuModel() const {
    if (!m_gpuModel.isEmpty()) return m_gpuModel;
    QProcess p;
    p.start("bash", {"-c", "lspci 2>/dev/null | grep -iE 'VGA|3D|Display' | head -1 | sed 's/.*: //'"});
    p.waitForFinished(1000);
    m_gpuModel = p.readAllStandardOutput().trimmed();
    if (m_gpuModel.isEmpty()) m_gpuModel = "Unknown GPU";
    return m_gpuModel;
}

int SystemInfo::totalRam() const { return m_totalRam; }

double SystemInfo::diskTotalGb() const { return m_diskTotalGb; }

int SystemInfo::usedRam() const { return m_usedRam; }
double SystemInfo::cpuUsage() const { return m_cpuUsage; }
double SystemInfo::diskUsedGb() const { return m_diskUsedGb; }
int SystemInfo::batteryLevel() const { return m_batteryLevel; }
bool SystemInfo::batteryCharging() const { return m_batteryCharging; }


QString SystemInfo::uptime() const {
    QFile f("/proc/uptime");
    if (f.open(QIODevice::ReadOnly)) {
        double secs = QTextStream(&f).readLine().split(' ')[0].toDouble();
        int h = (int)secs / 3600;
        int m = ((int)secs % 3600) / 60;
        return QString("%1h %2m").arg(h).arg(m);
    }
    return "N/A";
}

void SystemInfo::readCpuUsage() {
    QFile f("/proc/stat");
    if (!f.open(QIODevice::ReadOnly)) return;
    QString line = QTextStream(&f).readLine();
    QStringList parts = line.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts);
    if (parts.size() < 8) return;

    long long user    = parts[1].toLongLong();
    long long nice    = parts[2].toLongLong();
    long long system  = parts[3].toLongLong();
    long long idle    = parts[4].toLongLong();
    long long iowait  = parts[5].toLongLong();
    long long irq     = parts[6].toLongLong();
    long long softirq = parts[7].toLongLong();

    long long total = user + nice + system + idle + iowait + irq + softirq;
    long long dTotal = total - m_prevTotal;
    long long dIdle  = idle - m_prevIdle;

    if (dTotal > 0) {
        double usage = 100.0 * (1.0 - (double)dIdle / dTotal);
        if (!qFuzzyCompare(m_cpuUsage, usage)) {
            m_cpuUsage = usage;
            emit cpuUsageChanged();
        }
    }
    m_prevTotal = total;
    m_prevIdle  = idle;
}

void SystemInfo::readMemory() {
    QFile f("/proc/meminfo");
    if (!f.open(QIODevice::ReadOnly)) return;
    QTextStream ts(&f);
    long long total = 0, avail = 0;
    while (!ts.atEnd()) {
        QString line = ts.readLine();
        if (line.startsWith("MemTotal:"))
            total = line.split(QRegularExpression("\\s+"))[1].toLongLong();
        else if (line.startsWith("MemAvailable:"))
            avail = line.split(QRegularExpression("\\s+"))[1].toLongLong();
    }
    int used = (int)((total - avail) / 1024);
    if (m_usedRam != used) {
        m_usedRam = used;
        emit usedRamChanged();
    }
}

void SystemInfo::readDisk() {
    struct statvfs st;
    if (statvfs("/", &st) == 0) {
        double used = (double)((st.f_blocks - st.f_bfree) * st.f_frsize) / (1024*1024*1024);
        if (!qFuzzyCompare(m_diskUsedGb, used)) {
            m_diskUsedGb = used;
            emit diskUsedGbChanged();
        }
    }
}

void SystemInfo::readBattery() {
    QString batPath;
    QDir bat("/sys/class/power_supply");
    for (const QString &e : bat.entryList({"BAT*"}, QDir::Dirs)) {
        batPath = "/sys/class/power_supply/" + e;
        break;
    }
    if (batPath.isEmpty()) return;

    auto readSysFile = [](const QString &path) -> QString {
        QFile f(path);
        if (f.open(QIODevice::ReadOnly))
            return QTextStream(&f).readLine().trimmed();
        return {};
    };

    int lvl = readSysFile(batPath + "/capacity").toInt();
    QString status = readSysFile(batPath + "/status");
    bool charging = (status == "Charging" || status == "Full");

    if (m_batteryLevel != lvl) { m_batteryLevel = lvl; emit batteryLevelChanged(); }
    if (m_batteryCharging != charging) { m_batteryCharging = charging; emit batteryChargingChanged(); }
}
