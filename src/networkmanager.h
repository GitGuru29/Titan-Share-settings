#pragma once
#include <QObject>
#include <QString>
#include <QStringList>

class NetworkManager : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool wifiEnabled READ wifiEnabled WRITE setWifiEnabled NOTIFY wifiEnabledChanged)
    Q_PROPERTY(QString connectedSsid READ connectedSsid NOTIFY connectedSsidChanged)
    Q_PROPERTY(int signalStrength READ signalStrength NOTIFY signalStrengthChanged)
    Q_PROPERTY(QString ipAddress READ ipAddress NOTIFY ipAddressChanged)
    Q_PROPERTY(QString ipv6Address READ ipv6Address NOTIFY ipv6AddressChanged)
    Q_PROPERTY(QString macAddress READ macAddress NOTIFY macAddressChanged)
    Q_PROPERTY(QString linkSpeed READ linkSpeed NOTIFY linkSpeedChanged)
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY isConnectedChanged)
    Q_PROPERTY(QStringList availableNetworks READ availableNetworks NOTIFY availableNetworksChanged)

public:
    explicit NetworkManager(QObject *parent = nullptr);

    bool wifiEnabled() const;
    void setWifiEnabled(bool v);
    QString connectedSsid() const;
    int signalStrength() const;
    QString ipAddress() const;
    QString ipv6Address() const;
    QString macAddress() const;
    QString linkSpeed() const;
    bool isConnected() const;
    QStringList availableNetworks() const;

    Q_INVOKABLE void scanNetworks();
    Q_INVOKABLE void connectToNetwork(const QString &ssid, const QString &password);
    Q_INVOKABLE void disconnectNetwork();

signals:
    void wifiEnabledChanged();
    void connectedSsidChanged();
    void signalStrengthChanged();
    void ipAddressChanged();
    void ipv6AddressChanged();
    void macAddressChanged();
    void linkSpeedChanged();
    void isConnectedChanged();
    void availableNetworksChanged();
    void connectionError(const QString &message);

private:
    bool m_wifiEnabled = true;
    QString m_connectedSsid;
    int m_signalStrength = 0;
    QString m_ipAddress;
    QString m_ipv6Address;
    QString m_macAddress;
    QString m_linkSpeed;
    bool m_isConnected = false;
    QStringList m_availableNetworks;

    void refreshStatus();
};
