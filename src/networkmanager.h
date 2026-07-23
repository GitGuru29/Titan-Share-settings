#pragma once
#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>
#include <QTimer>

class NetworkManager : public QObject {
    Q_OBJECT

    // Wi-Fi Properties
    Q_PROPERTY(bool wifiEnabled READ wifiEnabled WRITE setWifiEnabled NOTIFY wifiEnabledChanged)
    Q_PROPERTY(QString connectedSsid READ connectedSsid NOTIFY connectedSsidChanged)
    Q_PROPERTY(int signalStrength READ signalStrength NOTIFY signalStrengthChanged)
    Q_PROPERTY(QString ipAddress READ ipAddress NOTIFY ipAddressChanged)
    Q_PROPERTY(QString ipv6Address READ ipv6Address NOTIFY ipv6AddressChanged)
    Q_PROPERTY(QString macAddress READ macAddress NOTIFY macAddressChanged)
    Q_PROPERTY(QString linkSpeed READ linkSpeed NOTIFY linkSpeedChanged)
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY isConnectedChanged)
    Q_PROPERTY(QStringList availableNetworks READ availableNetworks NOTIFY availableNetworksChanged)
    Q_PROPERTY(QVariantList scannedNetworks READ scannedNetworks NOTIFY scannedNetworksChanged)
    Q_PROPERTY(QStringList savedNetworks READ savedNetworks NOTIFY savedNetworksChanged)

    // Ethernet Properties
    Q_PROPERTY(bool ethernetConnected READ ethernetConnected NOTIFY ethernetConnectedChanged)
    Q_PROPERTY(QString ethernetInterface READ ethernetInterface NOTIFY ethernetInterfaceChanged)
    Q_PROPERTY(QString ethernetIpAddress READ ethernetIpAddress NOTIFY ethernetIpAddressChanged)
    Q_PROPERTY(QString ethernetLinkSpeed READ ethernetLinkSpeed NOTIFY ethernetLinkSpeedChanged)
    Q_PROPERTY(QString primaryConnectionType READ primaryConnectionType NOTIFY primaryConnectionTypeChanged)

    // Network Details Properties
    Q_PROPERTY(QString gatewayAddress READ gatewayAddress NOTIFY gatewayAddressChanged)
    Q_PROPERTY(QString dnsServers READ dnsServers NOTIFY dnsServersChanged)

    // State & Async Properties
    Q_PROPERTY(bool isScanning READ isScanning NOTIFY isScanningChanged)
    Q_PROPERTY(bool isConnecting READ isConnecting NOTIFY isConnectingChanged)
    Q_PROPERTY(QString connectingSsid READ connectingSsid NOTIFY connectingSsidChanged)

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
    QVariantList scannedNetworks() const;
    QStringList savedNetworks() const;

    bool ethernetConnected() const;
    QString ethernetInterface() const;
    QString ethernetIpAddress() const;
    QString ethernetLinkSpeed() const;
    QString primaryConnectionType() const;

    QString gatewayAddress() const;
    QString dnsServers() const;

    bool isScanning() const;
    bool isConnecting() const;
    QString connectingSsid() const;

    Q_INVOKABLE void refreshStatus();
    Q_INVOKABLE void scanNetworks();
    Q_INVOKABLE void connectToNetwork(const QString &ssid, const QString &password = QString());
    Q_INVOKABLE void disconnectNetwork();
    Q_INVOKABLE void forgetNetwork(const QString &ssid);
    Q_INVOKABLE void copyToClipboard(const QString &text);

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
    void scannedNetworksChanged();
    void savedNetworksChanged();

    void ethernetConnectedChanged();
    void ethernetInterfaceChanged();
    void ethernetIpAddressChanged();
    void ethernetLinkSpeedChanged();
    void primaryConnectionTypeChanged();

    void gatewayAddressChanged();
    void dnsServersChanged();

    void isScanningChanged();
    void isConnectingChanged();
    void connectingSsidChanged();

    void connectionSuccess(const QString &ssid);
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
    QVariantList m_scannedNetworks;
    QStringList m_savedNetworks;

    bool m_ethernetConnected = false;
    QString m_ethernetInterface;
    QString m_ethernetIpAddress;
    QString m_ethernetLinkSpeed;
    QString m_primaryConnectionType = "none";

    QString m_gatewayAddress;
    QString m_dnsServers;

    bool m_isScanning = false;
    bool m_isConnecting = false;
    QString m_connectingSsid;

    QTimer *m_pollTimer = nullptr;
};

