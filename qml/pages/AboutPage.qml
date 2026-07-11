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

    ColumnLayout {
        width: root.availableWidth; spacing: 0

        Item { height: 36 }

        // ── Hero ─────────────────────────────────────────────────
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true; height: 100

            Rectangle {
                anchors.centerIn: parent
                width: 80; height: 80; radius: 20
                color: "#1A2030"
                border.width: 1; border.color: "#2A3A5A"

                Image {
                    anchors.centerIn: parent
                    width: 48; height: 48
                    source: "qrc:/ArchTitanSettings/assets/icons/archtitan-logo.svg"
                    fillMode: Image.PreserveAspectFit; smooth: true
                }
            }
        }

        Item { height: 16 }

        Column {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8

            Text {
                text: "ArchTitan OS"
                anchors.horizontalCenter: parent.horizontalCenter
                font { pixelSize: 28; family: "Inter" }
                font.weight: Font.Bold
                color: root.textHigh
            }

            Text {
                text: "Precision · Performance · Privacy"
                anchors.horizontalCenter: parent.horizontalCenter
                font { pixelSize: 12; family: "Inter"; italic: true }
                color: root.textMid
            }
        }

        Item { height: 32 }

        // ── Version card ─────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Version Info"

            GridLayout {
                Layout.fillWidth: true
                columns: 2; rowSpacing: 14; columnSpacing: 32

                Repeater {
                    model: [
                        { label: "OS Version",   value: SystemInfo.osVersion                   },
                        { label: "Kernel",        value: SystemInfo.kernelVersion               },
                        { label: "Settings App",  value: "v" + SettingsBackend.version()        },
                        { label: "Qt Version",    value: "6.x (QML)"                           },
                        { label: "Desktop",       value: "Hyprland (Wayland)"                  },
                        { label: "Package Mgr",   value: "pacman + AUR"                        }
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
                        }
                    }
                }
            }
        }

        Item { height: 12 }

        // ── Built with ───────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Built With"

            Flow {
                Layout.fillWidth: true; spacing: 8

                Repeater {
                    model: ["Qt6 / QML", "Hyprland", "PipeWire", "NetworkManager",
                            "Wayland", "nspawn", "swww", "fish shell", "kitty", "rofi", "waybar", "Arch Linux"]
                    delegate: Rectangle {
                        height: 26; radius: 13
                        width: tagLbl.implicitWidth + 20
                        color: "#1A1A1A"
                        border.width: 1; border.color: "#2A2A2A"

                        Text {
                            id: tagLbl
                            anchors.centerIn: parent
                            text: modelData
                            font { pixelSize: 11; family: "Inter" }
                            color: root.textMid
                        }

                        MouseArea { anchors.fill: parent; hoverEnabled: true
                            onEntered: parent.border.color = "#3A3A3A"
                            onExited:  parent.border.color = "#2A2A2A"
                        }
                    }
                }
            }
        }

        Item { height: 20 }

        RowLayout {
            Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24
            spacing: 10
            Item { Layout.fillWidth: true }
            Repeater {
                model: [
                    { text: "GitHub",       url: "https://github.com/GitGuru29/archtitan-os"        },
                    { text: "Report Issue", url: "https://github.com/GitGuru29/archtitan-os/issues"  }
                ]
                delegate: TitanButton {
                    text: modelData.text; primary: false; Layout.preferredWidth: 140
                    onClicked: Qt.openUrlExternally(modelData.url)
                }
            }
        }

        Item { height: 16 }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "© 2026 ArchTitan Project  —  Final Year Project"
            font { pixelSize: 11; family: "Inter" }
            color: root.textLow; opacity: 0.6
        }

        Item { height: 32 }
    }
}
