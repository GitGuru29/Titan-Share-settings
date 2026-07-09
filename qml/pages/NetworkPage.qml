import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import ArchTitanSettings

ScrollView {
    id: root
    contentWidth: -1
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

    property color textPrimary:   "#E8E8F5"
    property color textSecondary: "#8A94B8"
    property color textDim:       "#555878"
    property color accentBlue:    "#7AA2F7"
    property color accentGreen:   "#9ECE6A"
    property color accentRed:     "#F7768E"

    ColumnLayout {
        width: root.width
        spacing: 0

        Item { height: 32 }

        // ── Wi-Fi status hero card ────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28

            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                // Wi-Fi icon ring
                Item {
                    width: 56; height: 56

                    Rectangle {
                        anchors.centerIn: parent
                        width: 56; height: 56; radius: 28
                        color: NetworkManager.isConnected
                               ? Qt.rgba(root.accentGreen.r, root.accentGreen.g, root.accentGreen.b, 0.12)
                               : Qt.rgba(root.accentRed.r,   root.accentRed.g,   root.accentRed.b,   0.10)
                        border.width: 1
                        border.color: NetworkManager.isConnected
                                      ? Qt.rgba(root.accentGreen.r, root.accentGreen.g, root.accentGreen.b, 0.4)
                                      : Qt.rgba(root.accentRed.r,   root.accentRed.g,   root.accentRed.b,   0.35)
                        Behavior on color { ColorAnimation { duration: 400 } }
                        Behavior on border.color { ColorAnimation { duration: 400 } }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "◈"
                        font.pixelSize: 26
                        color: NetworkManager.isConnected ? root.accentGreen : root.accentRed
                        Behavior on color { ColorAnimation { duration: 400 } }
                    }
                }

                Column {
                    spacing: 8
                    RowLayout {
                        spacing: 12
                        Text {
                            text: "Wi-Fi"
                            font { pixelSize: 18; weight: Font.SemiBold; family: "Inter" }
                            color: root.textPrimary
                        }
                        StatusBadge {
                            text: NetworkManager.isConnected ? "Connected" : "Disconnected"
                            statusColor: NetworkManager.isConnected ? root.accentGreen : root.accentRed
                        }
                    }
                    Text {
                        text: NetworkManager.isConnected
                              ? NetworkManager.connectedSsid + "   ·   " + NetworkManager.ipAddress
                              : "No network connected"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textDim
                    }
                }

                Item { Layout.fillWidth: true }

                TitanSwitch {
                    onColor: root.accentGreen
                    checked: NetworkManager.wifiEnabled
                    onCheckedChanged: NetworkManager.wifiEnabled = checked
                }
            }

            // Signal strength bar
            Item {
                Layout.fillWidth: true
                height: 28
                visible: NetworkManager.isConnected
                Layout.topMargin: 8

                Row {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    spacing: 8
                    Text {
                        text: "Signal"
                        font { pixelSize: 11; family: "Inter" }
                        color: root.textDim
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        width: 200; height: 6; radius: 3
                        color: "#1A1A2C"
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            width: (NetworkManager.signalStrength / 100) * parent.width
                            height: parent.height; radius: parent.radius
                            color: NetworkManager.signalStrength > 60 ? root.accentGreen
                                 : NetworkManager.signalStrength > 30 ? "#E0AF68"
                                 : root.accentRed
                            Behavior on width { NumberAnimation { duration: 600 } }
                            Behavior on color { ColorAnimation { duration: 300 } }
                        }
                    }
                    Text {
                        text: NetworkManager.signalStrength + "%"
                        font { pixelSize: 12; family: "Inter"; weight: Font.Medium }
                        color: root.accentBlue
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        Item { height: 14 }

        // ── Available networks ────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            title: "AVAILABLE NETWORKS"

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                TitanButton {
                    text: "Scan Networks"
                    primary: false; width: 140
                    onClicked: NetworkManager.scanNetworks()
                }
            }

            Item { height: 4 }

            Repeater {
                model: NetworkManager.availableNetworks
                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 48; radius: 10
                    color: netHov.containsMouse ? "#17172A" : "transparent"
                    border.width: NetworkManager.connectedSsid === modelData ? 1 : 0
                    border.color: Qt.rgba(root.accentGreen.r, root.accentGreen.g, root.accentGreen.b, 0.3)
                    Behavior on color { ColorAnimation { duration: 120 } }

                    RowLayout {
                        anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                        spacing: 12

                        // Signal dots
                        Row {
                            spacing: 2
                            anchors.verticalCenter: parent.verticalCenter
                            Repeater {
                                model: 4
                                Rectangle {
                                    width: 4
                                    height: 4 + index * 4
                                    radius: 2
                                    color: root.accentBlue
                                    opacity: index < 3 ? 0.9 : 0.35
                                    anchors.bottom: parent ? parent.bottom : undefined
                                }
                            }
                        }

                        Text {
                            text: modelData
                            font { pixelSize: 13; family: "Inter" }
                            color: root.textPrimary
                            Layout.fillWidth: true
                        }

                        Text {
                            text: NetworkManager.connectedSsid === modelData ? "✓  Connected" : ""
                            font { pixelSize: 12; family: "Inter"; weight: Font.Medium }
                            color: root.accentGreen
                        }
                    }

                    MouseArea {
                        id: netHov
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            // Empty state
            Rectangle {
                Layout.fillWidth: true
                height: 52; radius: 10
                color: "#0C0C18"
                visible: NetworkManager.availableNetworks.length === 0
                border.width: 1; border.color: "#FFFFFF08"

                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "◈"
                        font.pixelSize: 18
                        color: root.textDim
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "No networks found — click Scan to search"
                        font { pixelSize: 12; family: "Inter"; italic: true }
                        color: root.textDim
                    }
                }
            }
        }

        Item { height: 14 }

        // ── Connection details ────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            title: "CONNECTION DETAILS"
            visible: NetworkManager.isConnected

            GridLayout {
                Layout.fillWidth: true
                columns: 2; rowSpacing: 16; columnSpacing: 32

                Repeater {
                    model: [
                        { label: "SSID",       value: NetworkManager.connectedSsid,       color: "#7AA2F7" },
                        { label: "IP Address", value: NetworkManager.ipAddress,            color: "#9ECE6A" },
                        { label: "Signal",     value: NetworkManager.signalStrength + "%", color: "#E0AF68" },
                        { label: "Status",     value: "Active",                            color: "#9ECE6A" }
                    ]
                    delegate: Column {
                        spacing: 5
                        Text {
                            text: modelData.label
                            font { pixelSize: 9; weight: Font.Bold; family: "Inter"; letterSpacing: 1.5 }
                            color: root.textDim
                        }
                        Text {
                            text: modelData.value
                            font { pixelSize: 14; weight: Font.SemiBold; family: "Inter" }
                            color: modelData.color
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#FFFFFF08"; Layout.topMargin: 8; Layout.bottomMargin: 8 }

            TitanButton {
                text: "Disconnect"
                primary: false; width: 130
                onClicked: NetworkManager.disconnectNetwork()
            }
        }

        Item { height: 32 }
    }
}
