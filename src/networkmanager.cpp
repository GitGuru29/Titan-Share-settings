#include "networkmanager.h"
#include <QProcess>
#include <QRegularExpression>

NetworkManager::NetworkManager(QObject *parent) : QObject(parent) {
    refreshStatus();
}

void NetworkManager::refreshStatus() {
    // Check connected SSID via nmcli
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

    // IP address
    QProcess ip;
    ip.start("bash", {"-c", "ip -4 addr show | grep 'inet ' | grep -v '127\\.' | awk '{print $2}' | cut -d/ -f1 | head -1"});
    ip.waitForFinished(1000);
    m_ipAddress = ip.readAllStandardOutput().trimmed();

    // Signal strength
    QProcess sig;
    sig.start("bash", {"-c", "nmcli -t -f IN-USE,SIGNAL dev wifi 2>/dev/null | grep '^\\*' | cut -d: -f2"});
    sig.waitForFinished(1000);
    m_signalStrength = sig.readAllStandardOutput().trimmed().toInt();

    emit connectedSsidChanged();
    emit isConnectedChanged();
    emit ipAddressChanged();
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
