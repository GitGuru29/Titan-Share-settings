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

    ColumnLayout {
        width: root.availableWidth
        spacing: 0

        Item { height: 28 }

        // ── Brightness ───────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Brightness"

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "○"
                    font { pixelSize: 14; family: "Inter" }
                    color: root.textLow
                }

                TitanSlider {
                    Layout.fillWidth: true
                    from: 0; to: 100; stepSize: 1
                    value: DisplayManager.brightness
                    onMoved: DisplayManager.brightness = value
                    fillColor: {
                        var t = DisplayManager.brightness / 100
                        return Qt.rgba(0.9, 0.7 * t + 0.3, 0.2, 1.0)
                    }
                }

                Text {
                    text: "◉"
                    font { pixelSize: 14; family: "Inter" }
                    color: root.textMid
                }

                Text {
                    text: DisplayManager.brightness + "%"
                    font { pixelSize: 12; family: "Inter" }
                    font.weight: Font.Medium
                    color: root.accent; Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        Item { height: 12 }

        // ── Night Light ──────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24

            RowLayout {
                Layout.fillWidth: true

                Column {
                    spacing: 4
                    Text {
                        text: "Night Light"
                        font { pixelSize: 13; family: "Inter" }
                        font.weight: Font.SemiBold
                        color: root.textHigh
                    }
                    Text {
                        text: "Reduces blue light via wlsunset"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textMid
                    }
                }
                Item { Layout.fillWidth: true }
                TitanSwitch {
                    onColor: "#D4853A"
                    checked: DisplayManager.nightLightEnabled
                    onCheckedChanged: DisplayManager.nightLightEnabled = checked
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#222222"; Layout.topMargin: 6; Layout.bottomMargin: 6 }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Column {
                    spacing: 4
                    Text {
                        text: "Color Temperature"
                        font { pixelSize: 13; family: "Inter" }
                        font.weight: Font.Medium
                        color: root.textHigh
                        opacity: DisplayManager.nightLightEnabled ? 1.0 : 0.35
                        Behavior on opacity { NumberAnimation { duration: 180 } }
                    }
                    Text {
                        text: DisplayManager.nightLightTemp + "K"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textMid
                        opacity: DisplayManager.nightLightEnabled ? 1.0 : 0.35
                        Behavior on opacity { NumberAnimation { duration: 180 } }
                    }
                }
                Item { Layout.fillWidth: true }

                TitanSlider {
                    width: 180
                    from: 1000; to: 6500; stepSize: 100
                    value: DisplayManager.nightLightTemp
                    onMoved: DisplayManager.nightLightTemp = value
                    enabled: DisplayManager.nightLightEnabled
                    opacity: DisplayManager.nightLightEnabled ? 1.0 : 0.35
                    Behavior on opacity { NumberAnimation { duration: 180 } }
                    fillColor: {
                        var t = DisplayManager.nightLightTemp / 6500
                        return Qt.rgba(1.0, 0.5 + t * 0.4, t * 0.7, 1.0)
                    }
                }
            }
        }

        Item { height: 12 }

        // ── Display info ─────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Display Info"

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Repeater {
                    model: [
                        { label: "Resolution",   value: DisplayManager.resolution                     },
                        { label: "Refresh Rate", value: DisplayManager.refreshRate.toFixed(1) + " Hz" }
                    ]
                    delegate: Rectangle {
                        Layout.fillWidth: true; height: 64; radius: 8
                        color: "#141414"; border.width: 1; border.color: "#222222"
                        Layout.rightMargin: index === 0 ? 6 : 0

                        Column {
                            anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                            spacing: 5
                            Text {
                                text: modelData.label.toUpperCase()
                                font { pixelSize: 9; family: "Inter" }
                                font.weight: Font.SemiBold
                                font.letterSpacing: 1.2
                                color: root.textLow
                            }
                            Text {
                                text: modelData.value
                                font { pixelSize: 20; family: "Inter" }
                                font.weight: Font.Bold
                                color: root.textHigh
                            }
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#222222"; Layout.topMargin: 10; Layout.bottomMargin: 10 }

            RowLayout {
                Layout.fillWidth: true
                Column {
                    spacing: 4
                    Text {
                        text: "Display Scale"
                        font { pixelSize: 13; family: "Inter" }
                        font.weight: Font.Medium
                        color: root.textHigh
                    }
                    Text {
                        text: "Hyprland monitor scale factor"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textMid
                    }
                }
                Item { Layout.fillWidth: true }
                TitanSlider {
                    width: 160; from: 0.5; to: 3.0; stepSize: 0.25
                    value: DisplayManager.scaleFactor
                    onMoved: DisplayManager.scaleFactor = value
                }
                Text {
                    text: DisplayManager.scaleFactor.toFixed(2) + "×"
                    font { pixelSize: 12; family: "Inter" }
                    font.weight: Font.Medium
                    color: root.accent; Layout.preferredWidth: 48
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        Item { height: 28 }
    }
}
