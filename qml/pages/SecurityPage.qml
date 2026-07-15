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
        width: root.availableWidth; spacing: 0

        Item { height: 28 }

        SettingsCard {
            Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24

            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Rectangle {
                    width: 40; height: 40; radius: 9
                    color: SettingsBackend.autolockEnabled ? "#1A2030" : "#1A1A1A"
                    border.width: 1
                    border.color: SettingsBackend.autolockEnabled ? "#2A3A5A" : "#2A2A2A"
                    Behavior on color { ColorAnimation { duration: 180 } }
                    Text {
                        anchors.centerIn: parent
                        text: SettingsBackend.autolockEnabled ? "🔒" : "🔓"
                        font.pixelSize: 18
                    }
                }
                Column {
                    spacing: 4
                    Text {
                        text: "Screen Autolock"
                        font { pixelSize: 13; family: "Inter" }
                        font.weight: Font.DemiBold
                        color: root.textHigh
                    }
                    Text {
                        text: "Lock screen when idle using swaylock"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textMid
                    }
                }
                Item { Layout.fillWidth: true }
                TitanSwitch { checked: SettingsBackend.autolockEnabled; onCheckedChanged: SettingsBackend.autolockEnabled = checked }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: globalBorder1; Layout.topMargin: 6; Layout.bottomMargin: 6 }

            RowLayout {
                Layout.fillWidth: true
                Column {
                    spacing: 4
                    Text {
                        text: "Lock After"
                        font { pixelSize: 13; family: "Inter" }
                        font.weight: Font.Medium
                        color: root.textHigh
                        opacity: SettingsBackend.autolockEnabled ? 1.0 : 0.35
                    }
                    Text {
                        text: "Idle time before screen locks"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textMid
                        opacity: SettingsBackend.autolockEnabled ? 1.0 : 0.35
                    }
                }
                Item { Layout.fillWidth: true }
                TitanSlider {
                    width: 160; from: 60; to: 1800; stepSize: 60
                    value: SettingsBackend.autolockDelay; onValueChanged: SettingsBackend.autolockDelay = value
                    enabled: SettingsBackend.autolockEnabled
                    opacity: SettingsBackend.autolockEnabled ? 1.0 : 0.35
                }
                Text {
                    text: Math.floor(SettingsBackend.autolockDelay / 60) + " m"
                    font { pixelSize: 12; family: "Inter" }
                    font.weight: Font.Medium
                    color: root.accent; Layout.preferredWidth: 40; horizontalAlignment: Text.AlignRight
                    opacity: SettingsBackend.autolockEnabled ? 1.0 : 0.35
                }
            }
        }

        Item { height: 12 }

        SettingsCard {
            Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Security Features"

            Repeater {
                model: [
                    { label: "Titan Sandbox",      desc: "App isolation with nspawn containers", enabled: true  },
                    { label: "Secure Boot",         desc: "UEFI secure boot validation",          enabled: false },
                    { label: "Disk Encryption",     desc: "LUKS2 full disk encryption",           enabled: false },
                    { label: "Firewall (nftables)", desc: "Network packet filtering active",       enabled: true  }
                ]
                delegate: ColumnLayout {
                    Layout.fillWidth: true; spacing: 0
                    RowLayout {
                        Layout.fillWidth: true; height: 52; spacing: 12
                        Rectangle { width: 8; height: 8; radius: 4; color: modelData.enabled ? root.green : root.red; Layout.alignment: Qt.AlignVCenter }
                        Column {
                            spacing: 3
                            Text {
                                text: modelData.label
                                font { pixelSize: 13; family: "Inter" }
                                font.weight: Font.Medium
                                color: root.textHigh
                            }
                            Text {
                                text: modelData.desc
                                font { pixelSize: 11; family: "Inter" }
                                color: root.textMid
                            }
                        }
                        Item { Layout.fillWidth: true }
                        StatusBadge { text: modelData.enabled ? "Active" : "Inactive"; statusColor: modelData.enabled ? root.green : root.red }
                    }
                    Rectangle { Layout.fillWidth: true; height: 1; color: globalBorder1; visible: index < 3 }
                }
            }
        }

        Item { height: 12 }

        SettingsCard {
            Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Quick Actions"
            RowLayout {
                Layout.fillWidth: true; spacing: 10
                Repeater {
                    model: [{ text: "Lock Screen", icon: "🔒" }, { text: "Change Password", icon: "🔑" }]
                    delegate: Rectangle {
                        Layout.fillWidth: true; height: 48; radius: 8
                        color: actH.containsMouse ? globalBg4 : globalBg3
                        border.width: 1; border.color: globalBorder0
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Row {
                            anchors.centerIn: parent; spacing: 8
                            Text { text: modelData.icon; font.pixelSize: 16; anchors.verticalCenter: parent.verticalCenter }
                            Text {
                                text: modelData.text
                                font { pixelSize: 12; family: "Inter" }
                                font.weight: Font.Medium
                                color: root.textHigh
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        MouseArea { id: actH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                    }
                }
            }
        }

        Item { height: 12 }

        // ── Sandbox management ───────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Titan Sandbox Management"

            RowLayout {
                Layout.fillWidth: true
                Column {
                    spacing: 4
                    Text {
                        text: "Active Containers"
                        font { pixelSize: 13; family: "Inter" }
                        font.weight: Font.DemiBold
                        color: root.textHigh
                    }
                    Text {
                        text: "systemd-nspawn isolation via machinectl"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textMid
                    }
                }
                Item { Layout.fillWidth: true }
                StatusBadge {
                    text: sandboxList.count > 0 ? sandboxList.count + " Running" : "None Active"
                    statusColor: sandboxList.count > 0 ? root.green : root.textLow
                }
            }

            Item { height: 6 }

            // Container list (replace with real machinectl output in production)
            Repeater {
                id: sandboxList
                model: ["titan-browser", "titan-media"]
                delegate: ColumnLayout {
                    Layout.fillWidth: true; spacing: 0
                    RowLayout {
                        Layout.fillWidth: true; height: 42; spacing: 12
                        Rectangle { width: 7; height: 7; radius: 4; color: root.green; Layout.alignment: Qt.AlignVCenter }
                        Text {
                            text: modelData
                            font { pixelSize: 12; family: "Inter" }
                            font.weight: Font.Medium
                            color: root.textHigh; Layout.fillWidth: true
                        }
                        StatusBadge { text: "Running"; statusColor: root.green }
                    }
                    Rectangle { Layout.fillWidth: true; height: 1; color: globalBorder1; visible: index < sandboxList.count - 1 }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: globalBorder1; Layout.topMargin: 6; Layout.bottomMargin: 6 }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                TitanButton {
                    text: "Open Sandbox Shell"
                    primary: false; width: 160
                    onClicked: Qt.openUrlExternally("exec:kitty -e machinectl shell titan-browser")
                }
                TitanButton {
                    text: "List All"
                    primary: false; width: 100
                    onClicked: Qt.openUrlExternally("exec:kitty -e machinectl list")
                }
            }
        }

        Item { height: 24 }
        RowLayout {
            Layout.leftMargin: 24; Layout.rightMargin: 24
            Item { Layout.fillWidth: true }
            TitanButton { text: "Apply & Save"; primary: true; width: 130; onClicked: SettingsBackend.applyAndSave() }
        }
        Item { height: 28 }
    }
}
