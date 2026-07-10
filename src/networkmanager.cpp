#include "networkmanager.h"
#include <QProcess>
#include <QRegularExpression>

NetworkManager::NetworkManager(QObject *parent) : QObject(parent) {
    refreshStatus();
}

void NetworkManager::refreshStatus() {
    // Active Wi-Fi connection name
    QProcess p;
    p.start("bash", {"-c", "nmcli -t -f NAME,TYPE,STATE con show --active 2>/dev/null | grep wifi"});
    p.waitForFinished(2000);
    QString out = p.readAllStandardOutput().trimmed();

    if (!out.isEmpty()) {
        m_connectedSsid = out.split(':').value(0);
        m_isConnected = true;
    } else {
        m_connectedSsid.clear();
        m_isConnected = false;
    }

    // IPv4
    QProcess ip4;
    ip4.start("bash", {"-c", "ip -4 addr show | grep 'inet ' | grep -v '127\\.' | awk '{print $2}' | cut -d/ -f1 | head -1"});
    ip4.waitForFinished(1000);
    m_ipAddress = ip4.readAllStandardOutput().trimmed();

    // IPv6 (global/link-local)
    QProcess ip6;
    ip6.start("bash", {"-c", "ip -6 addr show | grep 'inet6' | grep -v 'fe80' | grep -v 'host' | awk '{print $2}' | cut -d/ -f1 | head -1"});
    ip6.waitForFinished(1000);
    m_ipv6Address = ip6.readAllStandardOutput().trimmed();
    if (m_ipv6Address.isEmpty()) {
        // fall back to link-local
        QProcess ip6ll;
        ip6ll.start("bash", {"-c", "ip -6 addr show | grep 'inet6 fe80' | awk '{print $2}' | cut -d/ -f1 | head -1"});
        ip6ll.waitForFinished(800);
        m_ipv6Address = ip6ll.readAllStandardOutput().trimmed();
    }

    // MAC address of the active wireless interface
    QProcess mac;
    mac.start("bash", {"-c", "ip link show | grep -A1 'wl' | grep 'link/ether' | awk '{print $2}' | head -1"});
    mac.waitForFinished(800);
    m_macAddress = mac.readAllStandardOutput().trimmed().toUpper();

    // Link speed (via iw or ethtool)
    QProcess spd;
    spd.start("bash", {"-c", "iw dev 2>/dev/null | grep -A5 'Interface' | grep bitrate | awk '{print $3,$4}' | head -1"});
    spd.waitForFinished(800);
    QString rawSpeed = spd.readAllStandardOutput().trimmed();
    if (rawSpeed.isEmpty()) {
        // fallback: nmcli bitrate field
        QProcess spd2;
        spd2.start("bash", {"-c", "nmcli -t -f IN-USE,RATE dev wifi 2>/dev/null | grep '^\\*' | cut -d: -f2"});
        spd2.waitForFinished(800);
        rawSpeed = spd2.readAllStandardOutput().trimmed();
    }
    m_linkSpeed = rawSpeed.isEmpty() ? "—" : rawSpeed;

    // Signal strength
    QProcess sig;
    sig.start("bash", {"-c", "nmcli -t -f IN-USE,SIGNAL dev wifi 2>/dev/null | grep '^\\*' | cut -d: -f2"});
    sig.waitForFinished(1000);
    m_signalStrength = sig.readAllStandardOutput().trimmed().toInt();

    emit connectedSsidChanged();
    emit isConnectedChanged();
    emit ipAddressChanged();
    emit ipv6AddressChanged();
    emit macAddressChanged();
    emit linkSpeedChanged();
    emit signalStrengthChanged();
}

bool NetworkManager::wifiEnabled() const { return m_wifiEnabled; }
void NetworkManager::setWifiEnabled(bool v) {
    if (m_wifiEnabled == v) return;
    m_wifiEnabled = v;
    QProcess::startDetached("nmcli", {"radio", "wifi", v ? "on" : "off"});
    emit wifiEnabledChanged();
}

QString NetworkManager::connectedSsid() const { return m_connectedSsid; }
int NetworkManager::signalStrength() const { return m_signalStrength; }
QString NetworkManager::ipAddress() const { return m_ipAddress; }
QString NetworkManager::ipv6Address() const { return m_ipv6Address; }
QString NetworkManager::macAddress() const { return m_macAddress; }
QString NetworkManager::linkSpeed() const { return m_linkSpeed; }
bool NetworkManager::isConnected() const { return m_isConnected; }
QStringList NetworkManager::availableNetworks() const { return m_availableNetworks; }

void NetworkManager::scanNetworks() {
    QProcess *p = new QProcess(this);
    connect(p, &QProcess::finished, this, [this, p]() {
        QStringList nets;
        for (const QString &line : p->readAllStandardOutput().trimmed().split('\n')) {
            if (!line.isEmpty()) nets.append(line.trimmed());
        }
        m_availableNetworks = nets;
        emit availableNetworksChanged();
        p->deleteLater();
    });
    p->start("bash", {"-c", "nmcli -t -f SSID dev wifi list 2>/dev/null | sort -u | head -20"});
}

void NetworkManager::connectToNetwork(const QString &ssid, const QString &password) {
    QProcess *p = new QProcess(this);
    connect(p, &QProcess::finished, this, [this, p](int code) {
        if (code == 0) refreshStatus();
        else emit connectionError("Connection failed");
        p->deleteLater();
    });
    p->start("nmcli", {"dev", "wifi", "connect", ssid, "password", password});
}

void NetworkManager::disconnectNetwork() {
    QProcess::startDetached("nmcli", {"dev", "disconnect", "wifi"});
    m_connectedSsid.clear();
    m_isConnected = false;
    emit connectedSsidChanged();
    emit isConnectedChanged();
}
