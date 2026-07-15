import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import ArchTitanSettings

ScrollView {
    id: root
    contentWidth: -1
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

    property color textHigh: globalTextHigh
    property color textMid:  globalTextMid
    property color textLow:  globalTextLow
    property color accent:   SettingsBackend.accentColor
    property color green:    "#4CAF82"
    property color red:      "#E05C6A"

    ColumnLayout {
        width: root.availableWidth
        spacing: 0

        Item { height: 28 }

        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Rectangle {
                    width: 44; height: 44; radius: 10
                    color: NetworkManager.isConnected ? "#1A2E1A" : "#2E1A1A"
                    border.width: 1
                    border.color: NetworkManager.isConnected ? "#2A4A2A" : "#4A2A2A"
                    Behavior on color { ColorAnimation { duration: 300 } }
                    Text {
                        anchors.centerIn: parent
                        text: NetworkManager.isConnected ? "↑↓" : "✗"
                        font { pixelSize: 16; family: "Inter" }
                        font.weight: Font.Bold
                        color: NetworkManager.isConnected ? root.green : root.red
                    }
                }

                Column {
                    spacing: 6
                    RowLayout {
                        spacing: 10
                        Text {
                            text: "Wi-Fi"
                            font { pixelSize: 16; family: "Inter" }
                            font.weight: Font.DemiBold
                            color: root.textHigh
                        }
                        StatusBadge {
                            text: NetworkManager.isConnected ? "Connected" : "Disconnected"
                            statusColor: NetworkManager.isConnected ? root.green : root.red
                        }
                    }
                    Text {
                        text: NetworkManager.isConnected
                              ? NetworkManager.connectedSsid + "  ·  " + NetworkManager.ipAddress
                              : "No network connected"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textMid
                    }
                }

                Item { Layout.fillWidth: true }

                TitanSwitch {
                    onColor: root.accent
                    checked: NetworkManager.wifiEnabled
                    onCheckedChanged: NetworkManager.wifiEnabled = checked
                }
            }

            Item {
                Layout.fillWidth: true; height: 24
                visible: NetworkManager.isConnected
                Layout.topMargin: 6

                Row {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    spacing: 8
                    Text {
                        text: "Signal"
                        font { pixelSize: 11; family: "Inter" }
                        color: root.textLow
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        width: 160; height: 4; radius: 2; color: globalBorder0
                        anchors.verticalCenter: parent.verticalCenter
                        Rectangle {
                            width: (NetworkManager.signalStrength / 100) * parent.width
                            height: parent.height; radius: parent.radius
                            color: NetworkManager.signalStrength > 60 ? root.green
                                 : NetworkManager.signalStrength > 30 ? "#D4853A" : root.red
                            Behavior on width { NumberAnimation { duration: 500 } }
                        }
                    }
                    Text {
                        text: NetworkManager.signalStrength + "%"
                        font { pixelSize: 11; family: "Inter" }
                        font.weight: Font.Medium
                        color: root.textMid
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        Item { height: 12 }

        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Available Networks"

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                TitanButton { text: "Scan"; primary: false; width: 90; onClicked: NetworkManager.scanNetworks() }
            }

            Item { height: 6 }

            Repeater {
                model: NetworkManager.availableNetworks
                delegate: Rectangle {
                    Layout.fillWidth: true; height: 44; radius: 7
                    color: netH.containsMouse ? globalBg4 : "transparent"
                    border.width: NetworkManager.connectedSsid === modelData ? 1 : 0
                    border.color: root.green + "50"
                    Behavior on color { ColorAnimation { duration: 100 } }
                    RowLayout {
                        anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                        spacing: 10
                        Row {
                            spacing: 2; anchors.verticalCenter: parent.verticalCenter
                            Repeater {
                                model: 4
                                Rectangle {
                                    width: 3; height: 4 + index * 3; radius: 1
                                    color: root.textMid; opacity: index < 3 ? 0.8 : 0.3
                                    anchors.bottom: parent ? parent.bottom : undefined
                                }
                            }
                        }
                        Text {
                            text: modelData
                            font { pixelSize: 13; family: "Inter" }
                            color: root.textHigh; Layout.fillWidth: true
                        }
                        Text {
                            visible: NetworkManager.connectedSsid === modelData
                            text: "Connected"
                            font { pixelSize: 11; family: "Inter" }
                            font.weight: Font.Medium
                            color: root.green
                        }
                    }
                    MouseArea { id: netH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                }
            }

            Rectangle {
                Layout.fillWidth: true; height: 48; radius: 8; color: globalBg3
                visible: NetworkManager.availableNetworks.length === 0
                border.width: 1; border.color: globalBorder1
                Text {
                    anchors.centerIn: parent
                    text: "No networks found — click Scan"
                    font { pixelSize: 12; family: "Inter"; italic: true }
                    color: root.textLow
                }
            }
        }

        Item { height: 12 }

        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Connection Details"
            visible: NetworkManager.isConnected

            GridLayout {
                Layout.fillWidth: true
                columns: 2; rowSpacing: 16; columnSpacing: 32

                Repeater {
                    model: [
                        { label: "Network",     value: NetworkManager.connectedSsid                  },
                        { label: "IPv4 Address",value: NetworkManager.ipAddress.length > 0 ? NetworkManager.ipAddress : "—" },
                        { label: "IPv6 Address",value: NetworkManager.ipv6Address.length > 0 ? NetworkManager.ipv6Address : "—" },
                        { label: "MAC Address", value: NetworkManager.macAddress.length > 0 ? NetworkManager.macAddress : "—" },
                        { label: "Link Speed",  value: NetworkManager.linkSpeed.length > 0  ? NetworkManager.linkSpeed  : "—" },
                        { label: "Signal",      value: NetworkManager.signalStrength + "%"           }
                    ]
                    delegate: Column {
                        spacing: 4
                        Text {
                            text: modelData.label.toUpperCase()
                            font { pixelSize: 9; family: "Inter" }
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1.2
                            color: root.textLow
                        }
                        Text {
                            text: modelData.value
                            font { pixelSize: 13; family: "Inter" }
                            font.weight: Font.Medium
                            color: root.textHigh
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            width: 220
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: globalBorder1; Layout.topMargin: 8; Layout.bottomMargin: 8 }

            TitanButton { text: "Disconnect"; primary: false; width: 120; onClicked: NetworkManager.disconnectNetwork() }
        }

        Item { height: 28 }
    }
}
