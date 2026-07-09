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

        Item { height: 48 }

        // ── Hero logo ─────────────────────────────────────────────
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            height: 130

            // Outer glow ring
            Rectangle {
                anchors.centerIn: parent
                width: 120; height: 120; radius: 60
                color: "transparent"
                border.width: 1
                border.color: Qt.rgba(root.accentBlue.r, root.accentBlue.g, root.accentBlue.b, 0.15)

                SequentialAnimation on border.color {
                    running: true; loops: Animation.Infinite
                    ColorAnimation { to: Qt.rgba(root.accentBlue.r, root.accentBlue.g, root.accentBlue.b, 0.4); duration: 2500 }
                    ColorAnimation { to: Qt.rgba(root.accentBlue.r, root.accentBlue.g, root.accentBlue.b, 0.10); duration: 2500 }
                }
            }

            // Mid ring
            Rectangle {
                anchors.centerIn: parent
                width: 96; height: 96; radius: 48
                color: Qt.rgba(root.accentBlue.r, root.accentBlue.g, root.accentBlue.b, 0.07)
                border.width: 1
                border.color: Qt.rgba(root.accentBlue.r, root.accentBlue.g, root.accentBlue.b, 0.25)

                SequentialAnimation on scale {
                    running: true; loops: Animation.Infinite
                    NumberAnimation { to: 1.04; duration: 2200; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.00; duration: 2200; easing.type: Easing.InOutSine }
                }
            }

            // Core
            Rectangle {
                anchors.centerIn: parent
                width: 72; height: 72; radius: 36
                color: Qt.rgba(root.accentBlue.r, root.accentBlue.g, root.accentBlue.b, 0.12)
                border.width: 1
                border.color: Qt.rgba(root.accentBlue.r, root.accentBlue.g, root.accentBlue.b, 0.5)
            }

            Text {
                anchors.centerIn: parent
                text: "⬡"
                font.pixelSize: 42
                color: root.accentBlue

                SequentialAnimation on opacity {
                    running: true; loops: Animation.Infinite
                    NumberAnimation { to: 0.7; duration: 2000 }
                    NumberAnimation { to: 1.0; duration: 2000 }
                }
            }
        }

        Item { height: 20 }

        Column {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            Text {
                text: "ArchTitan OS"
                anchors.horizontalCenter: parent.horizontalCenter
                font { pixelSize: 32; weight: Font.Bold; family: "Inter"; letterSpacing: -0.5 }
            }

            // Tagline with gradient accent words
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                Repeater {
                    model: ["Precision", "·", "Performance", "·", "Privacy"]
                    delegate: Text {
                        text: modelData
                        font { pixelSize: 13; family: "Inter"; italic: modelData === "·" ? false : true }
                        color: modelData === "·" ? root.textDim : root.accentBlue
                        opacity: modelData === "·" ? 0.4 : 0.85
                    }
                }
            }
        }

        Item { height: 40 }

        // ── Version card ──────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            title: "VERSION INFO"

            GridLayout {
                Layout.fillWidth: true
                columns: 2; rowSpacing: 18; columnSpacing: 32

                Repeater {
                    model: [
                        { label: "OS VERSION",   value: SystemInfo.osVersion,             color: "#7AA2F7" },
                        { label: "KERNEL",       value: SystemInfo.kernelVersion,          color: "#9ECE6A" },
                        { label: "SETTINGS APP", value: "v" + SettingsBackend.version(),   color: "#BB9AF7" },
                        { label: "QT VERSION",   value: "6.x (QML)",                      color: "#73DACA" },
                        { label: "DESKTOP",      value: "Hyprland (Wayland)",              color: "#E0AF68" },
                        { label: "PACKAGE MGR",  value: "pacman + AUR",                   color: "#7AA2F7" }
                    ]
                    delegate: Column {
                        spacing: 5
                        Text {
                            text: modelData.label
                            font { pixelSize: 9; weight: Font.Bold; family: "Inter"; letterSpacing: 1.6 }
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
        }

        Item { height: 14 }

        // ── Built with ────────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            title: "BUILT WITH"

            Flow {
                Layout.fillWidth: true
                spacing: 10

                Repeater {
                    model: [
                        { text: "Qt6 / QML",    clr: "#7AA2F7" },
                        { text: "Hyprland",     clr: "#BB9AF7" },
                        { text: "PipeWire",     clr: "#E0AF68" },
                        { text: "NetworkManager",clr:"#9ECE6A" },
                        { text: "Wayland",      clr: "#73DACA" },
                        { text: "nspawn",       clr: "#F7768E" },
                        { text: "swww",         clr: "#7AA2F7" },
                        { text: "fish shell",   clr: "#9ECE6A" },
                        { text: "kitty",        clr: "#BB9AF7" },
                        { text: "rofi",         clr: "#E0AF68" },
                        { text: "waybar",       clr: "#73DACA" },
                        { text: "Arch Linux",   clr: "#7AA2F7" }
                    ]
                    delegate: Rectangle {
                        height: 28; radius: 14
                        width: tagLabel.implicitWidth + 24
                        color: Qt.rgba(Qt.color(modelData.clr).r, Qt.color(modelData.clr).g, Qt.color(modelData.clr).b, 0.10)
                        border.width: 1
                        border.color: Qt.rgba(Qt.color(modelData.clr).r, Qt.color(modelData.clr).g, Qt.color(modelData.clr).b, 0.28)

                        scale: tagHov.containsMouse ? 1.05 : 1.0
                        Behavior on scale { NumberAnimation { duration: 120 } }

                        Text {
                            id: tagLabel
                            anchors.centerIn: parent
                            text: modelData.text
                            font { pixelSize: 11; family: "Inter"; weight: Font.Medium }
                            color: modelData.clr
                        }

                        MouseArea {
                            id: tagHov
                            anchors.fill: parent
                            hoverEnabled: true
                        }
                    }
                }
            }
        }

        Item { height: 20 }

        // ── Links ─────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            spacing: 12
            Item { Layout.fillWidth: true }

            Repeater {
                model: [
                    { text: "GitHub",       url: "https://github.com/GitGuru29/archtitan-os" },
                    { text: "Report Issue", url: "https://github.com/GitGuru29/archtitan-os/issues" }
                ]
                delegate: TitanButton {
                    text: modelData.text; primary: false; width: 150
                    onClicked: Qt.openUrlExternally(modelData.url)
                }
            }
        }

        Item { height: 36 }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "© 2026 ArchTitan Project  —  Final Year Project"
            font { pixelSize: 11; family: "Inter"; letterSpacing: 0.5 }
        }

        Item { height: 36 }
    }
}
