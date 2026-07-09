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

    ColumnLayout {
        width: root.width
        spacing: 0

        Item { height: 32 }

        // ── Brightness ────────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            title: "BRIGHTNESS"

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                // Moon icon
                Rectangle {
                    width: 32; height: 32; radius: 16
                    color: "#1A1A2C"
                    border.width: 1; border.color: "#FFFFFF10"
                    Text {
                        anchors.centerIn: parent
                        text: "🌙"; font.pixelSize: 14
                    }
                }

                TitanSlider {
                    Layout.fillWidth: true
                    from: 0; to: 100; stepSize: 1
                    value: DisplayManager.brightness
                    onValueChanged: DisplayManager.brightness = value
                    fillColor: {
                        var t = DisplayManager.brightness / 100
                        return Qt.rgba(0.9, 0.85 * t + 0.3, 0.3 * t, 1.0)
                    }
                }

                // Sun icon
                Rectangle {
                    width: 32; height: 32; radius: 16
                    color: "#1A1A2C"
                    border.width: 1; border.color: "#FFFFFF10"
                    Text {
                        anchors.centerIn: parent
                        text: "☀"; font.pixelSize: 14
                    }
                }

                // Value pill
                Rectangle {
                    width: 56; height: 28; radius: 8
                    color: "#1A1A2C"
                    border.width: 1; border.color: "#FFFFFF10"
                    Text {
                        anchors.centerIn: parent
                        text: DisplayManager.brightness + "%"
                        font { pixelSize: 13; family: "Inter"; weight: Font.SemiBold }
                        color: root.accentBlue
                    }
                }
            }
        }

        Item { height: 14 }

        // ── Night Light ───────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28

            RowLayout {
                Layout.fillWidth: true

                // Icon
                Rectangle {
                    width: 42; height: 42; radius: 12
                    color: "#1A0D2A"
                    border.width: 1
                    border.color: DisplayManager.nightLightEnabled ? "#BB9AF750" : "#FFFFFF10"
                    Text { anchors.centerIn: parent; text: "🌙"; font.pixelSize: 20 }
                }

                Column {
                    spacing: 5
                    Layout.leftMargin: 4
                    Text {
                        text: "Night Light"
                        font { pixelSize: 14; weight: Font.SemiBold; family: "Inter" }
                        color: root.textPrimary
                    }
                    Text {
                        text: "Reduces blue light at night via wlsunset"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textDim
                    }
                }
                Item { Layout.fillWidth: true }
                TitanSwitch {
                    onColor: "#BB9AF7"
                    checked: DisplayManager.nightLightEnabled
                    onCheckedChanged: DisplayManager.nightLightEnabled = checked
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#FFFFFF08"; Layout.topMargin: 8; Layout.bottomMargin: 8 }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Column {
                    spacing: 5
                    Text {
                        text: "Color Temperature"
                        font { pixelSize: 13; weight: Font.Medium; family: "Inter" }
                        color: root.textPrimary
                        opacity: DisplayManager.nightLightEnabled ? 1.0 : 0.4
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }
                    Text {
                        text: "Warm  ←  " + DisplayManager.nightLightTemp + "K  →  Cool"
                        font { pixelSize: 11; family: "Inter" }
                        color: root.textDim
                        opacity: DisplayManager.nightLightEnabled ? 1.0 : 0.4
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }
                }
                Item { Layout.fillWidth: true }

                TitanSlider {
                    width: 220
                    from: 1000; to: 6500; stepSize: 100
                    value: DisplayManager.nightLightTemp
                    onValueChanged: DisplayManager.nightLightTemp = value
                    enabled: DisplayManager.nightLightEnabled
                    opacity: DisplayManager.nightLightEnabled ? 1.0 : 0.35
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    fillColor: {
                        var t = DisplayManager.nightLightTemp / 6500
                        return Qt.rgba(1.0, 0.5 + t * 0.4, t * 0.8, 1.0)
                    }
                }
            }
        }

        Item { height: 14 }

        // ── Display info + Scale ──────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            title: "DISPLAY INFO"

            // Metrics row
            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                Repeater {
                    model: [
                        { label: "RESOLUTION",    value: DisplayManager.resolution,                      color: "#7AA2F7" },
                        { label: "REFRESH RATE",  value: DisplayManager.refreshRate.toFixed(1) + " Hz",  color: "#9ECE6A" }
                    ]
                    delegate: Rectangle {
                        Layout.fillWidth: true; height: 74; radius: 10
                        color: "#0C0C18"
                        border.width: 1; border.color: "#FFFFFF08"
                        Layout.rightMargin: index === 0 ? 8 : 0

                        Column {
                            anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                            spacing: 6
                            Text {
                                text: modelData.label
                                font { pixelSize: 9; weight: Font.Bold; family: "Inter"; letterSpacing: 1.5 }
                                color: "#3E4460"
                            }
                            Text {
                                text: modelData.value
                                font { pixelSize: 22; weight: Font.Bold; family: "Inter" }
                                color: modelData.color
                            }
                        }

                        // Accent line
                        Rectangle {
                            anchors { left: parent.left; top: parent.top; bottom: parent.bottom; topMargin: 12; bottomMargin: 12 }
                            width: 3; radius: 2
                            color: modelData.color
                            opacity: 0.6
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#FFFFFF08"; Layout.topMargin: 12; Layout.bottomMargin: 12 }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                Column {
                    spacing: 5
                    Text {
                        text: "Display Scale"
                        font { pixelSize: 14; weight: Font.Medium; family: "Inter" }
                        color: root.textPrimary
                    }
                    Text {
                        text: "Hyprland monitor scale factor"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textDim
                    }
                }
                Item { Layout.fillWidth: true }
                TitanSlider {
                    width: 200
                    from: 0.5; to: 3.0; stepSize: 0.25
                    value: DisplayManager.scaleFactor
                    onValueChanged: DisplayManager.scaleFactor = value
                }
                Rectangle {
                    width: 52; height: 28; radius: 8
                    color: "#1A1A2C"; border.width: 1; border.color: "#FFFFFF10"
                    Text {
                        anchors.centerIn: parent
                        text: DisplayManager.scaleFactor.toFixed(2) + "×"
                        font { pixelSize: 12; family: "Inter"; weight: Font.SemiBold }
                        color: root.accentBlue
                    }
                }
            }
        }

        Item { height: 32 }
    }
}
