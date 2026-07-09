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
        width: root.width; spacing: 0

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
                    Text { text: "Screen Autolock"; font { pixelSize: 13; weight: Font.SemiBold; family: "Inter" }; color: root.textHigh }
                    Text { text: "Lock screen when idle using swaylock"; font { pixelSize: 12; family: "Inter" }; color: root.textMid }
                }
                Item { Layout.fillWidth: true }
                TitanSwitch { checked: SettingsBackend.autolockEnabled; onCheckedChanged: SettingsBackend.autolockEnabled = checked }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#222222"; Layout.topMargin: 6; Layout.bottomMargin: 6 }

            RowLayout {
                Layout.fillWidth: true
                Column {
                    spacing: 4
                    Text { text: "Lock After"; font { pixelSize: 13; weight: Font.Medium; family: "Inter" }; color: root.textHigh; opacity: SettingsBackend.autolockEnabled ? 1.0 : 0.35 }
                    Text { text: "Idle time before screen locks"; font { pixelSize: 12; family: "Inter" }; color: root.textMid; opacity: SettingsBackend.autolockEnabled ? 1.0 : 0.35 }
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
                    font { pixelSize: 12; family: "Inter"; weight: Font.Medium }
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
                        Rectangle { width: 8; height: 8; radius: 4; color: modelData.enabled ? root.green : root.red; anchors.verticalCenter: parent.verticalCenter }
                        Column {
                            spacing: 3
                            Text { text: modelData.label; font { pixelSize: 13; weight: Font.Medium; family: "Inter" }; color: root.textHigh }
                            Text { text: modelData.desc; font { pixelSize: 11; family: "Inter" }; color: root.textMid }
                        }
                        Item { Layout.fillWidth: true }
                        StatusBadge { text: modelData.enabled ? "Active" : "Inactive"; statusColor: modelData.enabled ? root.green : root.red }
                    }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#1F1F1F"; visible: index < 3 }
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
                        color: actH.containsMouse ? "#1E1E1E" : "#141414"
                        border.width: 1; border.color: "#2A2A2A"
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Row {
                            anchors.centerIn: parent; spacing: 8
                            Text { text: modelData.icon; font.pixelSize: 16; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: modelData.text; font { pixelSize: 12; family: "Inter"; weight: Font.Medium }; color: root.textHigh; anchors.verticalCenter: parent.verticalCenter }
                        }
                        MouseArea { id: actH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                    }
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
