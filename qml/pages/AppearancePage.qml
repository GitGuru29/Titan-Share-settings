import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import ArchTitanSettings

ScrollView {
    id: root
    contentWidth: -1
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

    property color textHigh:  "#EBEBEB"
    property color textMid:   "#8C8C8C"
    property color textLow:   "#4A4A4A"
    property color accent:    "#4C8BF5"
    property color green:     "#4CAF82"
    property color orange:    "#D4853A"

    readonly property var accentColors: [
        "#4C8BF5", "#00BCD4", "#9575CD", "#66BB6A",
        "#FFA726", "#EF5350", "#26A69A", "#FDD835"
    ]

    ColumnLayout {
        width: root.width
        spacing: 0

        Item { height: 28 }

        // ── Theme picker ─────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            spacing: 12

            Repeater {
                model: [
                    { name: "Dark",     bg: "#111111", bg2: "#0D0D0D" },
                    { name: "Darker",   bg: "#0A0A0A", bg2: "#070707" },
                    { name: "Midnight", bg: "#08080D", bg2: "#050508" },
                    { name: "Dim",      bg: "#181818", bg2: "#131313" }
                ]
                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 104; radius: 10
                    color: "#161616"
                    border.width: SettingsBackend.colorTheme === modelData.name ? 2 : 1
                    border.color: SettingsBackend.colorTheme === modelData.name
                                  ? root.accent : "#2A2A2A"
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    // Preview window
                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        Rectangle {
                            width: 60; height: 38; radius: 7
                            color: modelData.bg
                            anchors.horizontalCenter: parent.horizontalCenter
                            border.width: 1; border.color: "#2A2A2A"

                            // Titlebar
                            Rectangle {
                                width: parent.width; height: 9
                                color: Qt.lighter(modelData.bg, 1.6)
                                topLeftRadius: 7; topRightRadius: 7
                                Row {
                                    anchors { left: parent.left; leftMargin: 5; verticalCenter: parent.verticalCenter }
                                    spacing: 3
                                    Repeater {
                                        model: ["#ED6A5E", "#F5BF4F", "#61C554"]
                                        Rectangle { width: 4; height: 4; radius: 2; color: modelData }
                                    }
                                }
                            }
                            // Lines
                            Column {
                                anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: 13; margins: 6 }
                                spacing: 3
                                Repeater {
                                    model: 3
                                    Rectangle {
                                        width: (3 - index) * 10 + 16; height: 2; radius: 1
                                        color: root.accent; opacity: 0.3 + index * 0.15
                                    }
                                }
                            }
                        }

                        Text {
                            text: modelData.name
                            anchors.horizontalCenter: parent.horizontalCenter
                            font { pixelSize: 11; family: "Inter"; weight: SettingsBackend.colorTheme === modelData.name ? Font.Medium : Font.Normal }
                            color: SettingsBackend.colorTheme === modelData.name ? root.textHigh : root.textMid
                        }
                    }

                    MouseArea {
                        anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SettingsBackend.colorTheme = modelData.name
                    }
                }
            }
        }

        Item { height: 16 }

        // ── Accent color ─────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Accent Color"

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Repeater {
                    model: root.accentColors
                    delegate: Item {
                        width: 30; height: 30
                        Rectangle {
                            anchors.centerIn: parent
                            width: SettingsBackend.accentColor === modelData ? 30 : 24
                            height: width; radius: width / 2
                            color: modelData
                            border.width: SettingsBackend.accentColor === modelData ? 2 : 0
                            border.color: "#FFFFFF"
                            Behavior on width { NumberAnimation { duration: 120 } }
                            MouseArea {
                                anchors.fill: parent; hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: SettingsBackend.accentColor = modelData
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 64; height: 26; radius: 6
                    color: SettingsBackend.accentColor
                    Behavior on color { ColorAnimation { duration: 180 } }
                    Text {
                        anchors.centerIn: parent
                        text: SettingsBackend.accentColor
                        font { pixelSize: 10; family: "Inter"; weight: Font.Medium }
                        color: "#FFFFFF"
                    }
                }
            }
        }

        Item { height: 12 }

        // ── Visual effects ────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Visual Effects"

            RowLayout {
                Layout.fillWidth: true
                Column {
                    spacing: 4
                    Text {
                        text: "Blur / Transparency"
                        font { pixelSize: 13; family: "Inter"; weight: Font.Medium }
                        color: root.textHigh
                    }
                    Text {
                        text: "Frosted glass effect on panels"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textMid
                    }
                }
                Item { Layout.fillWidth: true }
                TitanSwitch {
                    checked: SettingsBackend.glassmorphism
                    onCheckedChanged: SettingsBackend.glassmorphism = checked
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#222222"; Layout.topMargin: 6; Layout.bottomMargin: 6 }

            RowLayout {
                Layout.fillWidth: true
                Column {
                    spacing: 4
                    Text {
                        text: "Panel Opacity"
                        font { pixelSize: 13; family: "Inter"; weight: Font.Medium }
                        color: root.textHigh
                    }
                    Text {
                        text: "Transparency level for sidebars"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textMid
                    }
                }
                Item { Layout.fillWidth: true }
                TitanSlider {
                    width: 160; from: 0.4; to: 1.0; stepSize: 0.01
                    value: SettingsBackend.panelOpacity
                    onValueChanged: SettingsBackend.panelOpacity = value
                }
                Text {
                    text: Math.round(SettingsBackend.panelOpacity * 100) + "%"
                    font { pixelSize: 12; family: "Inter"; weight: Font.Medium }
                    color: root.accent
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        Item { height: 12 }

        // ── Icon theme ────────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Icon Theme"

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Repeater {
                    model: ["Papirus-Dark", "Papirus", "Adwaita", "Breeze-Dark"]
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 46; radius: 8
                        color: SettingsBackend.iconTheme === modelData ? "#1E2A3A" : "#1A1A1A"
                        border.width: 1
                        border.color: SettingsBackend.iconTheme === modelData ? root.accent : "#2A2A2A"
                        Behavior on color       { ColorAnimation { duration: 150 } }
                        Behavior on border.color{ ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font { pixelSize: 12; family: "Inter"; weight: SettingsBackend.iconTheme === modelData ? Font.Medium : Font.Normal }
                            color: SettingsBackend.iconTheme === modelData ? root.textHigh : root.textMid
                        }

                        MouseArea {
                            anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: SettingsBackend.iconTheme = modelData
                        }
                    }
                }
            }
        }

        Item { height: 12 }

        // ── Typography ────────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Typography"

            RowLayout {
                Layout.fillWidth: true
                Column {
                    spacing: 4
                    Text {
                        text: "Font Size"
                        font { pixelSize: 13; family: "Inter"; weight: Font.Medium }
                        color: root.textHigh
                    }
                    Text {
                        text: "System-wide interface font size"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textMid
                    }
                }
                Item { Layout.fillWidth: true }
                TitanSlider {
                    width: 160; from: 9; to: 18; stepSize: 1
                    value: SettingsBackend.fontSize
                    onValueChanged: SettingsBackend.fontSize = value
                }
                Text {
                    text: SettingsBackend.fontSize + " pt"
                    font { pixelSize: 12; family: "Inter"; weight: Font.Medium }
                    color: root.accent
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        Item { height: 24 }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            Item { Layout.fillWidth: true }
            TitanButton { text: "Reset Defaults"; primary: false; width: 140; onClicked: SettingsBackend.resetToDefaults() }
            Item { width: 10 }
            TitanButton { text: "Apply & Save"; primary: true; width: 130; onClicked: SettingsBackend.applyAndSave() }
        }

        Item { height: 28 }
    }
}
