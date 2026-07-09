import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import ArchTitanSettings

ScrollView {
    id: root
    contentWidth: -1
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

    property color textHigh: "#EBEBEB"
    property color textMid:  "#8C8C8C"
    property color textLow:  "#4A4A4A"
    property color accent:   "#4C8BF5"
    property color green:    "#4CAF82"
    property color red:      "#E05C6A"

    ColumnLayout {
        width: root.width
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
                        font { pixelSize: 16; weight: Font.Bold; family: "Inter" }
                        color: NetworkManager.isConnected ? root.green : root.red
                    }
                }

                Column {
                    spacing: 6
                    RowLayout {
                        spacing: 10
                        Text {
                            text: "Wi-Fi"
                            font { pixelSize: 16; weight: Font.SemiBold; family: "Inter" }
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
                        width: 160; height: 4; radius: 2; color: "#2A2A2A"
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
                        font { pixelSize: 11; family: "Inter"; weight: Font.Medium }
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
                    color: netH.containsMouse ? "#1E1E1E" : "transparent"
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
                            font { pixelSize: 11; family: "Inter"; weight: Font.Medium }
                            color: root.green
                        }
                    }
                    MouseArea { id: netH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                }
            }

            Rectangle {
                Layout.fillWidth: true; height: 48; radius: 8; color: "#141414"
                visible: NetworkManager.availableNetworks.length === 0
                border.width: 1; border.color: "#1F1F1F"
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
                columns: 2; rowSpacing: 14; columnSpacing: 32
                Repeater {
                    model: [
                        { label: "Network",    value: NetworkManager.connectedSsid        },
                        { label: "IP Address", value: NetworkManager.ipAddress            },
                        { label: "Signal",     value: NetworkManager.signalStrength + "%" },
                        { label: "Status",     value: "Active"                            }
                    ]
                    delegate: Column {
                        spacing: 4
                        Text {
                            text: modelData.label.toUpperCase()
                            font { pixelSize: 9; weight: Font.SemiBold; family: "Inter"; letterSpacing: 1.2 }
                            color: root.textLow
                        }
                        Text {
                            text: modelData.value
                            font { pixelSize: 13; weight: Font.Medium; family: "Inter" }
                            color: root.textHigh
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#222222"; Layout.topMargin: 8; Layout.bottomMargin: 8 }

            TitanButton { text: "Disconnect"; primary: false; width: 120; onClicked: NetworkManager.disconnectNetwork() }
        }

        Item { height: 28 }
    }
}
