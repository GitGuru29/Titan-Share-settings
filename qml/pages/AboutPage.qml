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
    property color accent:   SettingsBackend.accentColor
    property color bg1:      "#0D0D0F"
    property color bg2:      "#141417"
    property color bg3:      "#1C1C21"
    property color border0:  "#252528"

    ColumnLayout {
        width: root.availableWidth
        spacing: 0

        // ── Hero Section ──────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            height: 320

            // Background gradient glow
            Rectangle {
                anchors.centerIn: parent
                width: 480; height: 280
                radius: 240
                color: "transparent"
                layer.enabled: true
                layer.effect: null

                Rectangle {
                    anchors.centerIn: parent
                    width: 420; height: 220
                    radius: 210
                    color: root.accent
                    opacity: 0.06
                }
            }

            // Pulsing ring animation
            Rectangle {
                id: ring1
                anchors.centerIn: parent
                width: 200; height: 200
                radius: 100
                color: "transparent"
                border.width: 1
                border.color: root.accent
                opacity: 0

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.15; duration: 1600; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0;    duration: 1600; easing.type: Easing.InOutSine }
                }
                SequentialAnimation on width {
                    loops: Animation.Infinite
                    NumberAnimation { to: 240; duration: 3200; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 200; duration: 0 }
                }
                SequentialAnimation on height {
                    loops: Animation.Infinite
                    NumberAnimation { to: 240; duration: 3200; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 200; duration: 0 }
                }
            }

            Rectangle {
                id: ring2
                anchors.centerIn: parent
                width: 165; height: 165
                radius: 82.5
                color: "transparent"
                border.width: 1
                border.color: root.accent
                opacity: 0

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    PauseAnimation { duration: 500 }
                    NumberAnimation { to: 0.25; duration: 1400; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0;    duration: 1400; easing.type: Easing.InOutSine }
                }
            }

            // Logo circle
            Rectangle {
                anchors.centerIn: parent
                width: 136; height: 136
                radius: 68
                color: root.bg3
                border.width: 1.5
                border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.35)

                Image {
                    anchors.centerIn: parent
                    width: 90; height: 90
                    source: "qrc:/ArchTitanSettings/assets/icons/LOGO.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    opacity: 0.95
                }
            }

            // Title + subtitle below logo
            Column {
                anchors {
                    top: parent.verticalCenter
                    topMargin: 80
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: 6

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "ArchTitan Settings"
                    font { pixelSize: 26; family: "Inter" }
                    font.weight: Font.Bold
                    color: root.textHigh
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "System Control Center for ArchTitan OS"
                    font { pixelSize: 13; family: "Inter" }
                    color: root.textMid
                }
            }
        }

        // ── Quick Stats Row ───────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            spacing: 12

            Repeater {
                model: [
                    { label: "Version",  value: "v" + SettingsBackend.version() },
                    { label: "Platform", value: "Wayland"                        },
                    { label: "Runtime",  value: "Qt6 / QML"                      },
                    { label: "License",  value: "Open Source"                    }
                ]
                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 72
                    radius: 12
                    color: root.bg3
                    border.width: 1
                    border.color: root.border0

                    Column {
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.value
                            font { pixelSize: 15; family: "Inter" }
                            font.weight: Font.DemiBold
                            color: root.accent
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.label.toUpperCase()
                            font { pixelSize: 9; family: "Inter" }
                            font.weight: Font.Medium
                            font.letterSpacing: 1.5
                            color: root.textLow
                        }
                    }
                }
            }
        }

        Item { height: 16 }

        // ── System Info ───────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "System Information"

            GridLayout {
                Layout.fillWidth: true
                columns: 2; rowSpacing: 18; columnSpacing: 40

                Repeater {
                    model: [
                        { label: "OS",          value: SystemInfo.osVersion        },
                        { label: "Kernel",      value: SystemInfo.kernelVersion    },
                        { label: "Desktop",     value: "Hyprland (Wayland)"        },
                        { label: "Package Mgr", value: "pacman + AUR"              },
                        { label: "Shell",       value: "fish"                      },
                        { label: "Audio",       value: "PipeWire / WirePlumber"    }
                    ]
                    delegate: RowLayout {
                        spacing: 12

                        // Accent dot
                        Rectangle {
                            width: 6; height: 6; radius: 3
                            color: root.accent
                            opacity: 0.8
                        }

                        Column {
                            spacing: 2
                            Text {
                                text: modelData.label.toUpperCase()
                                font { pixelSize: 9; family: "Inter" }
                                font.weight: Font.Medium
                                font.letterSpacing: 1.2
                                color: root.textLow
                            }
                            Text {
                                text: modelData.value
                                font { pixelSize: 13; family: "Inter" }
                                font.weight: Font.Medium
                                color: root.textHigh
                            }
                        }
                    }
                }
            }
        }

        Item { height: 12 }

        // ── Tech Stack ────────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Tech Stack"

            Flow {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: [
                        "Qt6 / QML", "C++17", "PipeWire", "WirePlumber",
                        "Hyprland", "Wayland", "NetworkManager", "systemd",
                        "swww", "fish shell", "waybar", "rofi",
                        "kitty", "Arch Linux", "pacman", "AUR"
                    ]
                    delegate: Rectangle {
                        height: 28; radius: 14
                        width: chipLabel.implicitWidth + 24
                        color: "transparent"
                        border.width: 1
                        border.color: chipArea.containsMouse
                                      ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.5)
                                      : root.border0
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: root.accent
                            opacity: chipArea.containsMouse ? 0.08 : 0
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }

                        Text {
                            id: chipLabel
                            anchors.centerIn: parent
                            text: modelData
                            font { pixelSize: 11; family: "Inter" }
                            color: chipArea.containsMouse ? root.textHigh : root.textMid
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        MouseArea { id: chipArea; anchors.fill: parent; hoverEnabled: true }
                    }
                }
            }
        }

        Item { height: 12 }

        // ── Project Links ─────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Project"

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Repeater {
                    model: [
                        { icon: "⭐", label: "GitHub",       url: "https://github.com/GitGuru29/archtitan-os"       },
                        { icon: "🐛", label: "Report Issue", url: "https://github.com/GitGuru29/archtitan-os/issues" },
                        { icon: "📖", label: "Wiki",         url: "https://github.com/GitGuru29/archtitan-os/wiki"   }
                    ]
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 56; radius: 10
                        color: linkArea.containsMouse ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.08) : root.bg3
                        border.width: 1
                        border.color: linkArea.containsMouse
                                      ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.4)
                                      : root.border0
                        Behavior on color       { ColorAnimation { duration: 150 } }
                        Behavior on border.color{ ColorAnimation { duration: 150 } }

                        Row {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: modelData.icon
                                font.pixelSize: 16
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: modelData.label
                                font { pixelSize: 13; family: "Inter" }
                                font.weight: Font.Medium
                                color: linkArea.containsMouse ? root.accent : root.textMid
                                Behavior on color { ColorAnimation { duration: 150 } }
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: linkArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Qt.openUrlExternally(modelData.url)
                        }
                    }
                }
            }
        }

        Item { height: 24 }

        // ── Footer ────────────────────────────────────────────────
        Column {
            Layout.alignment: Qt.AlignHCenter
            spacing: 6

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "© 2026 ArchTitan Project"
                font { pixelSize: 12; family: "Inter" }
                font.weight: Font.Medium
                color: root.textLow
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Built with passion for ArchTitan OS  •  Final Year Project"
                font { pixelSize: 11; family: "Inter" }
                color: root.textLow
                opacity: 0.5
            }
        }

        Item { height: 36 }
    }
}
