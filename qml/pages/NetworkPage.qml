import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import ArchTitanSettings

Item {
    id: pageRoot
    anchors.fill: parent

    property color textHigh: globalTextHigh
    property color textMid:  globalTextMid
    property color textLow:  globalTextLow
    property color accent:   SettingsBackend.accentColor
    property color green:    "#4CAF82"
    property color red:      "#E05C6A"
    property color orange:   "#D4853A"

    // Toast state
    property string toastText: ""
    property bool toastIsError: false

    function showToast(msg, isErr) {
        toastText = msg
        toastIsError = !!isErr
        toastTimer.restart()
    }

    Timer {
        id: toastTimer
        interval: 3500
        onTriggered: toastText = ""
    }

    // Password modal state
    property string targetSsid: ""
    property bool targetIsSecured: true
    property bool showPasswordPrompt: false
    property string passwordInput: ""
    property bool hidePasswordChars: true

    function openConnectDialog(ssid, security) {
        targetSsid = ssid
        targetIsSecured = (security !== "--" && security !== "" && security.indexOf("Open") === -1)
        passwordInput = ""
        hidePasswordChars = true

        if (!targetIsSecured || NetworkManager.savedNetworks.indexOf(ssid) !== -1) {
            NetworkManager.connectToNetwork(ssid, "")
        } else {
            showPasswordPrompt = true
        }
    }

    Connections {
        target: NetworkManager
        function onConnectionSuccess(ssid) {
            showPasswordPrompt = false
            showToast("Connected to " + ssid, false)
        }
        function onConnectionError(msg) {
            showToast(msg, true)
        }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            width: parent.width
            spacing: 0

            Item { height: 20 }

            // ── Primary Network Status Banner ──────────────────────────────────
            SettingsCard {
                Layout.fillWidth: true
                Layout.leftMargin: 24; Layout.rightMargin: 24

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    // Modern Icon Container
                    Rectangle {
                        width: 52; height: 52; radius: 14
                        color: NetworkManager.ethernetConnected ? "#142A2A"
                             : NetworkManager.isConnected ? "#142D1F" : "#2D1418"
                        border.width: 1
                        border.color: NetworkManager.ethernetConnected ? "#1F4E4E"
                                    : NetworkManager.isConnected ? "#1E4D2B" : "#4D1E24"
                        Behavior on color { ColorAnimation { duration: 300 } }

                        // Animated Pulse Ring
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width + 4; height: parent.height + 4
                            radius: parent.radius + 2
                            color: "transparent"
                            border.width: 1
                            border.color: NetworkManager.ethernetConnected ? pageRoot.accent
                                        : NetworkManager.isConnected ? pageRoot.green : pageRoot.red
                            opacity: (NetworkManager.isConnected || NetworkManager.ethernetConnected) ? 0.3 : 0.15
                        }

                        // Pure Vector Icon
                        Item {
                            anchors.centerIn: parent
                            width: 26; height: 26

                            // Wifi Waves
                            Canvas {
                                anchors.fill: parent
                                visible: !NetworkManager.ethernetConnected
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.reset();
                                    ctx.lineWidth = 2.2;
                                    ctx.lineCap = "round";

                                    var cX = width / 2;
                                    var cY = height - 2;

                                    var col = NetworkManager.isConnected ? pageRoot.green : pageRoot.red;

                                    ctx.strokeStyle = col;
                                    ctx.beginPath(); ctx.arc(cX, cY, 18, -Math.PI * 0.75, -Math.PI * 0.25); ctx.stroke();
                                    ctx.beginPath(); ctx.arc(cX, cY, 12, -Math.PI * 0.75, -Math.PI * 0.25); ctx.stroke();
                                    ctx.beginPath(); ctx.arc(cX, cY, 6, -Math.PI * 0.75, -Math.PI * 0.25); ctx.stroke();

                                    ctx.fillStyle = col;
                                    ctx.beginPath(); ctx.arc(cX, cY, 2, 0, Math.PI * 2); ctx.fill();
                                }
                                Connections {
                                    target: NetworkManager
                                    function onIsConnectedChanged() { parent.requestPaint() }
                                }
                            }

                            // Ethernet Port Vector
                            Canvas {
                                anchors.fill: parent
                                visible: NetworkManager.ethernetConnected
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.reset();
                                    ctx.strokeStyle = pageRoot.accent;
                                    ctx.lineWidth = 2.0;
                                    ctx.lineJoin = "round";

                                    ctx.strokeRect(3, 4, 20, 14);
                                    ctx.strokeRect(8, 18, 10, 5);

                                    ctx.lineWidth = 1.5;
                                    ctx.beginPath();
                                    ctx.moveTo(7, 8); ctx.lineTo(7, 13);
                                    ctx.moveTo(11, 8); ctx.lineTo(11, 13);
                                    ctx.moveTo(15, 8); ctx.lineTo(15, 13);
                                    ctx.moveTo(19, 8); ctx.lineTo(19, 13);
                                    ctx.stroke();
                                }
                            }
                        }
                    }

                    Column {
                        spacing: 4
                        RowLayout {
                            spacing: 10
                            Text {
                                text: NetworkManager.ethernetConnected ? "Wired Ethernet" : "Wi-Fi Interface"
                                font { pixelSize: 16; family: "Inter" }
                                font.weight: Font.Bold
                                color: pageRoot.textHigh
                            }

                            // Pulsing Status Pill
                            Rectangle {
                                height: 22; radius: 11
                                width: statusText.implicitWidth + 24
                                color: (NetworkManager.ethernetConnected || NetworkManager.isConnected) ? "#143322" : "#331418"
                                border.width: 1
                                border.color: (NetworkManager.ethernetConnected || NetworkManager.isConnected) ? pageRoot.green + "60" : pageRoot.red + "60"

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 6

                                    Rectangle {
                                        width: 6; height: 6; radius: 3
                                        color: (NetworkManager.ethernetConnected || NetworkManager.isConnected) ? pageRoot.green : pageRoot.red
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        id: statusText
                                        text: NetworkManager.ethernetConnected ? "Ethernet Active"
                                            : NetworkManager.isConnected ? "Connected" : "Disconnected"
                                        font { pixelSize: 11; family: "Inter" }
                                        font.weight: Font.DemiBold
                                        color: (NetworkManager.ethernetConnected || NetworkManager.isConnected) ? pageRoot.green : pageRoot.red
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }

                        Text {
                            text: NetworkManager.ethernetConnected
                                  ? "Interface " + NetworkManager.ethernetInterface + "  •  " + (NetworkManager.ethernetIpAddress.length > 0 ? NetworkManager.ethernetIpAddress : NetworkManager.ipAddress)
                                  : NetworkManager.isConnected
                                  ? NetworkManager.connectedSsid + "  •  " + NetworkManager.ipAddress
                                  : "No active wireless or ethernet connection"
                            font { pixelSize: 12; family: "Inter" }
                            color: pageRoot.textMid
                        }
                    }

                    Item { Layout.fillWidth: true }

                    RowLayout {
                        spacing: 12

                        Text {
                            text: "Wi-Fi Switch"
                            font { pixelSize: 12; family: "Inter" }
                            color: pageRoot.textMid
                        }

                        TitanSwitch {
                            onColor: pageRoot.accent
                            checked: NetworkManager.wifiEnabled
                            onCheckedChanged: NetworkManager.wifiEnabled = checked
                        }
                    }
                }

                // Signal Meter Row
                Item {
                    Layout.fillWidth: true; height: 24
                    visible: NetworkManager.isConnected && !NetworkManager.ethernetConnected
                    Layout.topMargin: 10

                    Row {
                        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                        spacing: 12

                        Text {
                            text: "Signal Quality"
                            font { pixelSize: 11; family: "Inter" }
                            color: pageRoot.textLow
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            width: 200; height: 6; radius: 3; color: globalBg4
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width: (NetworkManager.signalStrength / 100) * parent.width
                                height: parent.height; radius: parent.radius
                                color: NetworkManager.signalStrength > 60 ? pageRoot.green
                                     : NetworkManager.signalStrength > 30 ? pageRoot.orange : pageRoot.red
                                Behavior on width { NumberAnimation { duration: 400 } }
                            }
                        }

                        Text {
                            text: NetworkManager.signalStrength + "%  (" + NetworkManager.linkSpeed + ")"
                            font { pixelSize: 11; family: "Inter" }
                            font.weight: Font.Medium
                            color: pageRoot.textMid
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            Item { height: 14 }

            // ── Ethernet (Wired Connection) Card ──────────────────────────────
            SettingsCard {
                Layout.fillWidth: true
                Layout.leftMargin: 24; Layout.rightMargin: 24
                title: "Ethernet Hardware"
                visible: NetworkManager.ethernetConnected || NetworkManager.ethernetInterface.length > 0

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14

                    Rectangle {
                        width: 40; height: 40; radius: 10
                        color: NetworkManager.ethernetConnected ? "#142A2A" : globalBg3
                        border.width: 1
                        border.color: NetworkManager.ethernetConnected ? "#1F4E4E" : globalBorder1

                        Canvas {
                            anchors.centerIn: parent
                            width: 20; height: 20
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                ctx.strokeStyle = NetworkManager.ethernetConnected ? pageRoot.green : pageRoot.textLow;
                                ctx.lineWidth = 1.6;
                                ctx.lineJoin = "round";

                                ctx.strokeRect(2, 3, 16, 11);
                                ctx.strokeRect(6, 14, 8, 4);
                            }
                        }
                    }

                    Column {
                        spacing: 2
                        Text {
                            text: "Wired Network Adapter (" + (NetworkManager.ethernetInterface.length > 0 ? NetworkManager.ethernetInterface : "eth0") + ")"
                            font { pixelSize: 13; family: "Inter" }
                            font.weight: Font.DemiBold
                            color: pageRoot.textHigh
                        }
                        Text {
                            text: NetworkManager.ethernetConnected
                                  ? "Cable Connected  •  " + NetworkManager.ethernetLinkSpeed
                                  : "Ethernet Cable Unplugged"
                            font { pixelSize: 11; family: "Inter" }
                            color: pageRoot.textMid
                        }
                    }

                    Item { Layout.fillWidth: true }

                    StatusBadge {
                        text: NetworkManager.ethernetConnected ? "Active Link" : "Disconnected"
                        statusColor: NetworkManager.ethernetConnected ? pageRoot.green : pageRoot.textLow
                    }
                }
            }

            Item { height: NetworkManager.ethernetInterface.length > 0 ? 14 : 0 }

            // ── Available Wi-Fi Networks Card ──────────────────────────────────
            SettingsCard {
                Layout.fillWidth: true
                Layout.leftMargin: 24; Layout.rightMargin: 24
                title: "Available Wi-Fi Networks"

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: NetworkManager.scannedNetworks.length + " networks detected"
                        font { pixelSize: 11; family: "Inter" }
                        color: pageRoot.textLow
                    }

                    Item { Layout.fillWidth: true }

                    TitanButton {
                        text: NetworkManager.isScanning ? "Scanning..." : "Scan Networks"
                        primary: false
                        width: 120
                        enabled: !NetworkManager.isScanning && NetworkManager.wifiEnabled
                        onClicked: NetworkManager.scanNetworks()
                    }
                }

                Item { height: 10 }

                // Network List
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: NetworkManager.wifiEnabled && NetworkManager.scannedNetworks.length > 0

                    Repeater {
                        model: NetworkManager.scannedNetworks
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: 52
                            radius: 9
                            color: netH.containsMouse ? globalBg4 : globalBg3
                            border.width: modelData.isConnected ? 1 : 1
                            border.color: modelData.isConnected ? pageRoot.green + "90"
                                        : netH.containsMouse ? globalBorder0 : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }
                            Behavior on border.color { ColorAnimation { duration: 120 } }

                            RowLayout {
                                anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
                                spacing: 14

                                // Signal Bars Vector
                                Row {
                                    spacing: 3
                                    anchors.verticalCenter: parent.verticalCenter
                                    Repeater {
                                        model: 4
                                        Rectangle {
                                            width: 3.5
                                            height: 6 + index * 3.5
                                            radius: 1.5
                                            color: (modelData.signal > (index * 25))
                                                   ? (modelData.signal > 60 ? pageRoot.green : pageRoot.accent)
                                                   : globalBorder0
                                            anchors.bottom: parent ? parent.bottom : undefined
                                        }
                                    }
                                }

                                Column {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    RowLayout {
                                        spacing: 8
                                        Text {
                                            text: modelData.ssid
                                            font { pixelSize: 13; family: "Inter" }
                                            font.weight: modelData.isConnected ? Font.Bold : Font.Medium
                                            color: pageRoot.textHigh
                                            elide: Text.ElideRight
                                        }

                                        // Security Pill Tag
                                        Rectangle {
                                            visible: modelData.security !== "--" && modelData.security !== "" && modelData.security.indexOf("Open") === -1
                                            height: 18; radius: 4
                                            width: secText.implicitWidth + 12
                                            color: globalBg4
                                            border.width: 1; border.color: globalBorder1

                                            Row {
                                                anchors.centerIn: parent
                                                spacing: 4
                                                Canvas {
                                                    width: 8; height: 9
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    onPaint: {
                                                        var ctx = getContext("2d");
                                                        ctx.reset();
                                                        ctx.strokeStyle = pageRoot.textLow;
                                                        ctx.lineWidth = 1.2;
                                                        ctx.beginPath(); ctx.arc(4, 3, 2, Math.PI, 0); ctx.stroke();
                                                        ctx.fillStyle = pageRoot.textLow;
                                                        ctx.fillRect(1.5, 4, 5, 4.5);
                                                    }
                                                }
                                                Text {
                                                    id: secText
                                                    text: modelData.security
                                                    font { pixelSize: 9; family: "Inter" }
                                                    color: pageRoot.textLow
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }
                                        }
                                    }

                                    Text {
                                        text: modelData.isConnected ? "Active Network Connection"
                                            : modelData.isSaved ? "Saved Network  •  Click to connect"
                                            : "Signal Strength " + modelData.signal + "%"
                                        font { pixelSize: 11; family: "Inter" }
                                        color: modelData.isConnected ? pageRoot.green : pageRoot.textMid
                                    }
                                }

                                // Actions
                                RowLayout {
                                    spacing: 8

                                    Text {
                                        visible: NetworkManager.isConnecting && NetworkManager.connectingSsid === modelData.ssid
                                        text: "Connecting..."
                                        font { pixelSize: 11; family: "Inter"; italic: true }
                                        color: pageRoot.orange
                                    }

                                    StatusBadge {
                                        visible: modelData.isConnected
                                        text: "Connected"
                                        statusColor: pageRoot.green
                                    }

                                    Rectangle {
                                        visible: modelData.isSaved && !modelData.isConnected
                                        width: 64; height: 28; radius: 6
                                        color: forgetH.containsMouse ? "#3D1A1A" : globalBg4
                                        border.width: 1
                                        border.color: forgetH.containsMouse ? pageRoot.red : globalBorder0

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Forget"
                                            font { pixelSize: 11; family: "Inter" }
                                            color: forgetH.containsMouse ? pageRoot.red : pageRoot.textMid
                                        }
                                        MouseArea {
                                            id: forgetH
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: NetworkManager.forgetNetwork(modelData.ssid)
                                        }
                                    }

                                    TitanButton {
                                        visible: !modelData.isConnected && !(NetworkManager.isConnecting && NetworkManager.connectingSsid === modelData.ssid)
                                        text: "Connect"
                                        primary: false
                                        width: 80
                                        onClicked: openConnectDialog(modelData.ssid, modelData.security)
                                    }
                                }
                            }

                            MouseArea {
                                id: netH
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                z: -1
                                onClicked: {
                                    if (!modelData.isConnected) {
                                        openConnectDialog(modelData.ssid, modelData.security)
                                    }
                                }
                            }
                        }
                    }
                }

                // Empty state card
                Rectangle {
                    Layout.fillWidth: true; height: 64; radius: 9; color: globalBg3
                    visible: !NetworkManager.wifiEnabled || NetworkManager.scannedNetworks.length === 0
                    border.width: 1; border.color: globalBorder1

                    Text {
                        anchors.centerIn: parent
                        text: !NetworkManager.wifiEnabled
                              ? "Wi-Fi radio disabled — enable Wi-Fi switch above to scan for networks"
                              : NetworkManager.isScanning
                              ? "Scanning for wireless networks..."
                              : "No wireless networks found — click Scan Networks to search"
                        font { pixelSize: 12; family: "Inter"; italic: true }
                        color: pageRoot.textLow
                    }
                }
            }

            Item { height: 14 }

            // ── Connection Details Card ───────────────────────────────────────
            SettingsCard {
                Layout.fillWidth: true
                Layout.leftMargin: 24; Layout.rightMargin: 24
                title: "Network Metrics & Details"
                visible: NetworkManager.isConnected || NetworkManager.ethernetConnected

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2; rowSpacing: 18; columnSpacing: 32

                    // Network Name
                    Column {
                        spacing: 4
                        Text {
                            text: "ACTIVE NETWORK"
                            font { pixelSize: 9; family: "Inter"; weight: Font.Bold; letterSpacing: 1.4 }
                            color: pageRoot.textLow
                        }
                        Text {
                            text: NetworkManager.ethernetConnected
                                  ? "Wired Ethernet (" + NetworkManager.ethernetInterface + ")"
                                  : NetworkManager.connectedSsid
                            font { pixelSize: 13; family: "Inter"; weight: Font.Medium }
                            color: pageRoot.textHigh
                            elide: Text.ElideRight; width: 230
                        }
                    }

                    // IPv4 Address + Vector Copy
                    Column {
                        spacing: 4
                        Text {
                            text: "IPV4 ADDRESS"
                            font { pixelSize: 9; family: "Inter"; weight: Font.Bold; letterSpacing: 1.4 }
                            color: pageRoot.textLow
                        }
                        RowLayout {
                            spacing: 8
                            Text {
                                text: NetworkManager.ethernetConnected
                                      ? (NetworkManager.ethernetIpAddress.length > 0 ? NetworkManager.ethernetIpAddress : "—")
                                      : (NetworkManager.ipAddress.length > 0 ? NetworkManager.ipAddress : "—")
                                font { pixelSize: 13; family: "Inter"; weight: Font.Medium }
                                color: pageRoot.textHigh
                            }

                            // Copy Vector Button
                            Rectangle {
                                width: 24; height: 24; radius: 5
                                color: copyIpH.containsMouse ? globalBg4 : "transparent"
                                border.width: 1; border.color: copyIpH.containsMouse ? globalBorder0 : "transparent"

                                Canvas {
                                    anchors.centerIn: parent
                                    width: 12; height: 12
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.reset();
                                        ctx.strokeStyle = pageRoot.accent;
                                        ctx.lineWidth = 1.3;
                                        ctx.strokeRect(1, 1, 7, 7);
                                        ctx.strokeRect(4, 4, 7, 7);
                                    }
                                }

                                MouseArea {
                                    id: copyIpH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        var ip = NetworkManager.ethernetConnected ? NetworkManager.ethernetIpAddress : NetworkManager.ipAddress
                                        NetworkManager.copyToClipboard(ip)
                                        showToast("IPv4 address copied to clipboard", false)
                                    }
                                }
                            }
                        }
                    }

                    // IPv6 Address
                    Column {
                        spacing: 4
                        Text {
                            text: "IPV6 ADDRESS"
                            font { pixelSize: 9; family: "Inter"; weight: Font.Bold; letterSpacing: 1.4 }
                            color: pageRoot.textLow
                        }
                        Text {
                            text: NetworkManager.ipv6Address.length > 0 ? NetworkManager.ipv6Address : "—"
                            font { pixelSize: 12; family: "Inter"; weight: Font.Medium }
                            color: pageRoot.textHigh
                            elide: Text.ElideRight; width: 240
                        }
                    }

                    // MAC Address + Vector Copy
                    Column {
                        spacing: 4
                        Text {
                            text: "MAC ADDRESS"
                            font { pixelSize: 9; family: "Inter"; weight: Font.Bold; letterSpacing: 1.4 }
                            color: pageRoot.textLow
                        }
                        RowLayout {
                            spacing: 8
                            Text {
                                text: NetworkManager.macAddress.length > 0 ? NetworkManager.macAddress : "—"
                                font { pixelSize: 13; family: "Inter"; weight: Font.Medium }
                                color: pageRoot.textHigh
                            }

                            // Copy Vector Button
                            Rectangle {
                                width: 24; height: 24; radius: 5
                                color: copyMacH.containsMouse ? globalBg4 : "transparent"
                                border.width: 1; border.color: copyMacH.containsMouse ? globalBorder0 : "transparent"

                                Canvas {
                                    anchors.centerIn: parent
                                    width: 12; height: 12
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.reset();
                                        ctx.strokeStyle = pageRoot.accent;
                                        ctx.lineWidth = 1.3;
                                        ctx.strokeRect(1, 1, 7, 7);
                                        ctx.strokeRect(4, 4, 7, 7);
                                    }
                                }

                                MouseArea {
                                    id: copyMacH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        NetworkManager.copyToClipboard(NetworkManager.macAddress)
                                        showToast("MAC address copied to clipboard", false)
                                    }
                                }
                            }
                        }
                    }

                    // Gateway
                    Column {
                        spacing: 4
                        Text {
                            text: "DEFAULT GATEWAY"
                            font { pixelSize: 9; family: "Inter"; weight: Font.Bold; letterSpacing: 1.4 }
                            color: pageRoot.textLow
                        }
                        Text {
                            text: NetworkManager.gatewayAddress.length > 0 ? NetworkManager.gatewayAddress : "—"
                            font { pixelSize: 13; family: "Inter"; weight: Font.Medium }
                            color: pageRoot.textHigh
                        }
                    }

                    // DNS Servers
                    Column {
                        spacing: 4
                        Text {
                            text: "DNS SERVERS"
                            font { pixelSize: 9; family: "Inter"; weight: Font.Bold; letterSpacing: 1.4 }
                            color: pageRoot.textLow
                        }
                        Text {
                            text: NetworkManager.dnsServers.length > 0 ? NetworkManager.dnsServers : "—"
                            font { pixelSize: 13; family: "Inter"; weight: Font.Medium }
                            color: pageRoot.textHigh
                            elide: Text.ElideRight; width: 240
                        }
                    }

                    // Link Speed
                    Column {
                        spacing: 4
                        Text {
                            text: "LINK SPEED"
                            font { pixelSize: 9; family: "Inter"; weight: Font.Bold; letterSpacing: 1.4 }
                            color: pageRoot.textLow
                        }
                        Text {
                            text: NetworkManager.ethernetConnected
                                  ? NetworkManager.ethernetLinkSpeed
                                  : (NetworkManager.linkSpeed.length > 0 ? NetworkManager.linkSpeed : "—")
                            font { pixelSize: 13; family: "Inter"; weight: Font.Medium }
                            color: pageRoot.textHigh
                        }
                    }

                    // Signal Quality
                    Column {
                        spacing: 4
                        Text {
                            text: "SIGNAL QUALITY"
                            font { pixelSize: 9; family: "Inter"; weight: Font.Bold; letterSpacing: 1.4 }
                            color: pageRoot.textLow
                        }
                        Text {
                            text: NetworkManager.ethernetConnected ? "100% (Wired Cable)" : NetworkManager.signalStrength + "%"
                            font { pixelSize: 13; family: "Inter"; weight: Font.Medium }
                            color: pageRoot.textHigh
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: globalBorder1; Layout.topMargin: 10; Layout.bottomMargin: 10 }

                RowLayout {
                    Layout.fillWidth: true

                    TitanButton {
                        visible: NetworkManager.isConnected
                        text: "Disconnect"
                        primary: false
                        width: 120
                        onClicked: NetworkManager.disconnectNetwork()
                    }

                    Item { Layout.fillWidth: true }
                }
            }

            Item { height: 28 }
        }
    }

    // ── Wi-Fi Password Prompt Modal Overlay ─────────────────────────
    Item {
        anchors.fill: parent
        visible: showPasswordPrompt
        z: 999

        Rectangle {
            anchors.fill: parent
            color: "#B0000000"
            MouseArea { anchors.fill: parent; onClicked: showPasswordPrompt = false }
        }

        Rectangle {
            anchors.centerIn: parent
            width: 380; height: 240
            radius: 16
            color: globalBg1
            border.width: 1
            border.color: pageRoot.accent

            // Glow Ring
            Rectangle {
                anchors.centerIn: parent
                width: parent.width + 6; height: parent.height + 6
                radius: parent.radius + 3
                color: "transparent"
                border.width: 2
                border.color: pageRoot.accent + "40"
                z: -1
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 22
                spacing: 12

                Text {
                    text: "Wi-Fi Authentication"
                    font { pixelSize: 16; family: "Inter"; weight: Font.Bold }
                    color: pageRoot.textHigh
                }

                Text {
                    text: "Enter password for network \"" + targetSsid + "\""
                    font { pixelSize: 12; family: "Inter" }
                    color: pageRoot.textMid
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Item { height: 2 }

                // Password input container
                Rectangle {
                    Layout.fillWidth: true; height: 44; radius: 9
                    color: globalBg3
                    border.width: 1
                    border.color: pwdInput.activeFocus ? pageRoot.accent : globalBorder0

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14; anchors.rightMargin: 12
                        spacing: 8

                        TextInput {
                            id: pwdInput
                            Layout.fillWidth: true
                            text: passwordInput
                            echoMode: hidePasswordChars ? TextInput.Password : TextInput.Normal
                            font { pixelSize: 13; family: "Inter" }
                            color: pageRoot.textHigh
                            focus: showPasswordPrompt
                            onTextChanged: passwordInput = text
                            onAccepted: {
                                showPasswordPrompt = false
                                NetworkManager.connectToNetwork(targetSsid, passwordInput)
                            }

                            Text {
                                visible: pwdInput.text.length === 0
                                text: "WPA / WPA2 / WPA3 Password"
                                font { pixelSize: 12; family: "Inter" }
                                color: pageRoot.textLow
                            }
                        }

                        // Vector Eye Toggle
                        Rectangle {
                            width: 28; height: 28; radius: 6
                            color: eyeH.containsMouse ? globalBg4 : "transparent"

                            Canvas {
                                anchors.centerIn: parent
                                width: 16; height: 16
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.reset();
                                    ctx.strokeStyle = pageRoot.textMid;
                                    ctx.lineWidth = 1.5;

                                    ctx.beginPath(); ctx.ellipse(1, 4, 14, 8); ctx.stroke();
                                    ctx.fillStyle = pageRoot.textMid;
                                    ctx.beginPath(); ctx.arc(8, 8, 2.5, 0, Math.PI * 2); ctx.fill();

                                    if (!hidePasswordChars) {
                                        ctx.beginPath(); ctx.moveTo(2, 14); ctx.lineTo(14, 2); ctx.stroke();
                                    }
                                }
                                Connections {
                                    target: pageRoot
                                    function onHidePasswordCharsChanged() { parent.requestPaint() }
                                }
                            }

                            MouseArea {
                                id: eyeH
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: hidePasswordChars = !hidePasswordChars
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    TitanButton {
                        text: "Cancel"
                        primary: false
                        Layout.fillWidth: true
                        onClicked: showPasswordPrompt = false
                    }

                    TitanButton {
                        text: NetworkManager.isConnecting ? "Connecting..." : "Connect"
                        primary: true
                        Layout.fillWidth: true
                        enabled: !NetworkManager.isConnecting
                        onClicked: {
                            showPasswordPrompt = false
                            NetworkManager.connectToNetwork(targetSsid, passwordInput)
                        }
                    }
                }
            }
        }
    }

    // ── Toast Banner ───────────────────────────────────────────────
    Rectangle {
        anchors { bottom: parent.bottom; bottomMargin: 24; horizontalCenter: parent.horizontalCenter }
        width: Math.min(pageRoot.width - 48, toastTextItem.implicitWidth + 40)
        height: 42; radius: 21
        color: toastIsError ? "#2A1418" : "#142A1E"
        border.width: 1
        border.color: toastIsError ? pageRoot.red : pageRoot.green
        visible: toastText.length > 0
        z: 1000

        RowLayout {
            anchors.centerIn: parent
            spacing: 10

            // Status Circle
            Rectangle {
                width: 8; height: 8; radius: 4
                color: toastIsError ? pageRoot.red : pageRoot.green
            }

            Text {
                id: toastTextItem
                text: toastText
                font { pixelSize: 12; family: "Inter"; weight: Font.Medium }
                color: toastIsError ? pageRoot.red : pageRoot.green
            }
        }
    }
}


