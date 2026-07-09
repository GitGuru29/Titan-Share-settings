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

        // ── Screen lock ───────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Rectangle {
                    width: 42; height: 42; radius: 12
                    color: SettingsBackend.autolockEnabled ? "#0A0E1A" : "#14141E"
                    border.width: 1
                    border.color: SettingsBackend.autolockEnabled ? "#7AA2F740" : "#FFFFFF10"
                    Behavior on color       { ColorAnimation { duration: 200 } }
                    Behavior on border.color{ ColorAnimation { duration: 200 } }

                    Text { anchors.centerIn: parent; text: "◆"; font.pixelSize: 20; color: root.accentBlue; opacity: SettingsBackend.autolockEnabled ? 1.0 : 0.4 }
                }

                Column {
                    spacing: 5
                    Text {
                        text: "Screen Autolock"
                        font { pixelSize: 14; weight: Font.SemiBold; family: "Inter" }
                        color: root.textPrimary
                    }
                    Text {
                        text: "Lock screen when idle using swaylock"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textDim
                    }
                }
                Item { Layout.fillWidth: true }
                TitanSwitch {
                    checked: SettingsBackend.autolockEnabled
                    onCheckedChanged: SettingsBackend.autolockEnabled = checked
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#FFFFFF08"; Layout.topMargin: 8; Layout.bottomMargin: 8 }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                Column {
                    spacing: 5
                    Text {
                        text: "Lock After"
                        font { pixelSize: 13; weight: Font.Medium; family: "Inter" }
                        color: root.textPrimary
                        opacity: SettingsBackend.autolockEnabled ? 1.0 : 0.4
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }
                    Text {
                        text: "Idle time before screen locks"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textDim
                        opacity: SettingsBackend.autolockEnabled ? 1.0 : 0.4
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }
                }
                Item { Layout.fillWidth: true }
                TitanSlider {
                    width: 200; from: 60; to: 1800; stepSize: 60
                    value: SettingsBackend.autolockDelay
                    onValueChanged: SettingsBackend.autolockDelay = value
                    enabled: SettingsBackend.autolockEnabled
                    opacity: SettingsBackend.autolockEnabled ? 1.0 : 0.3
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }
                Rectangle {
                    width: 52; height: 28; radius: 8; color: "#1A1A2C"
                    border.width: 1; border.color: "#FFFFFF10"
                    opacity: SettingsBackend.autolockEnabled ? 1.0 : 0.4
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    Text {
                        anchors.centerIn: parent
                        text: Math.floor(SettingsBackend.autolockDelay / 60) + " m"
                        font { pixelSize: 12; family: "Inter"; weight: Font.SemiBold }
                        color: root.accentBlue
                    }
                }
            }
        }

        Item { height: 14 }

        // ── Security features ─────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            title: "SECURITY FEATURES"

            Repeater {
                model: [
                    { label: "Titan Sandbox",      desc: "App isolation with nspawn containers",  enabled: true,  icon: "◈", clr: "#9ECE6A" },
                    { label: "Secure Boot",         desc: "UEFI secure boot validation",           enabled: false, icon: "◆", clr: "#F7768E" },
                    { label: "Disk Encryption",     desc: "LUKS2 full disk encryption",            enabled: false, icon: "⬟", clr: "#F7768E" },
                    { label: "Firewall (nftables)", desc: "Network packet filtering active",        enabled: true,  icon: "⬡", clr: "#9ECE6A" }
                ]
                delegate: ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        height: 56
                        spacing: 14

                        Rectangle {
                            width: 34; height: 34; radius: 9
                            color: modelData.enabled
                                   ? Qt.rgba(Qt.color(modelData.clr).r, Qt.color(modelData.clr).g, Qt.color(modelData.clr).b, 0.12)
                                   : "#141420"
                            border.width: 1
                            border.color: modelData.enabled
                                          ? Qt.rgba(Qt.color(modelData.clr).r, Qt.color(modelData.clr).g, Qt.color(modelData.clr).b, 0.35)
                                          : "#FFFFFF0C"

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon; font.pixelSize: 14
                                color: modelData.enabled ? modelData.clr : root.textDim
                            }
                        }

                        Column {
                            spacing: 4
                            Text {
                                text: modelData.label
                                font { pixelSize: 13; weight: Font.Medium; family: "Inter" }
                                color: root.textPrimary
                            }
                            Text {
                                text: modelData.desc
                                font { pixelSize: 11; family: "Inter" }
                                color: root.textDim
                            }
                        }

                        Item { Layout.fillWidth: true }

                        StatusBadge {
                            text: modelData.enabled ? "Active" : "Inactive"
                            statusColor: modelData.enabled ? root.accentGreen : root.accentRed
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true; height: 1
                        color: "#FFFFFF07"
                        visible: index < 3
                    }
                }
            }
        }

        Item { height: 14 }

        // ── Quick actions ─────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            title: "QUICK ACTIONS"

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Repeater {
                    model: [
                        { text: "Lock Screen",     icon: "◆" },
                        { text: "Change Password", icon: "⬟" }
                    ]
                    delegate: Rectangle {
                        Layout.fillWidth: true; height: 54; radius: 12
                        color: actHov.containsMouse ? "#1A1A2C" : "#0F0F1A"
                        border.width: 1
                        border.color: actHov.containsMouse ? "#FFFFFF1E" : "#FFFFFF0C"
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Row {
                            anchors.centerIn: parent
                            spacing: 10
                            Text { anchors.verticalCenter: parent.verticalCenter; text: modelData.icon; font.pixelSize: 16; color: root.accentBlue }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.text
                                font { pixelSize: 13; family: "Inter"; weight: Font.Medium }
                                color: root.textPrimary
                            }
                        }

                        scale: actHov.pressed ? 0.97 : 1.0
                        Behavior on scale { NumberAnimation { duration: 90 } }

                        MouseArea {
                            id: actHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (index === 0) Qt.openUrlExternally("exec:swaylock")
                                else Qt.openUrlExternally("exec:kitty -e passwd")
                            }
                        }
                    }
                }
            }
        }

        Item { height: 24 }

        RowLayout {
            Layout.leftMargin: 28; Layout.rightMargin: 28
            Item { Layout.fillWidth: true }
            TitanButton { text: "Apply & Save"; primary: true; width: 150; onClicked: SettingsBackend.applyAndSave() }
        }

        Item { height: 32 }
    }
}
