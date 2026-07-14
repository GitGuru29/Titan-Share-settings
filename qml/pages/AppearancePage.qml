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
    property color accent:    SettingsBackend.accentColor
    property color green:     "#4CAF82"
    property color orange:    "#D4853A"

    readonly property var accentColors: [
        "#4C8BF5", "#00BCD4", "#9575CD", "#66BB6A",
        "#FFA726", "#EF5350", "#26A69A", "#FDD835"
    ]

    ColumnLayout {
        width: root.availableWidth
        spacing: 0

        Item { height: 28 }

        // ── Theme picker ─────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            spacing: 12

            Repeater {
                model: [
                    { name: "Dark",     bg: "#1C1C1C", bg2: "#111111" },
                    { name: "Darker",   bg: "#0A0A0A", bg2: "#050505" },
                    { name: "Midnight", bg: "#0F111A", bg2: "#090A0F" },
                    { name: "Dim",      bg: "#2D2D2D", bg2: "#222222" }
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
                            font { pixelSize: 11; family: "Inter" }
                            font.weight: SettingsBackend.colorTheme === modelData.name ? Font.Medium : Font.Normal
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
                        font { pixelSize: 10; family: "Inter" }
                        font.weight: Font.Medium
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
                        font { pixelSize: 13; family: "Inter" }
                        font.weight: Font.Medium
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
                    onColor: root.accent
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
                        font { pixelSize: 13; family: "Inter" }
                        font.weight: Font.Medium
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
                    fillColor: root.accent
                    value: SettingsBackend.panelOpacity
                    onValueChanged: SettingsBackend.panelOpacity = value
                }
                Text {
                    text: Math.round(SettingsBackend.panelOpacity * 100) + "%"
                    font { pixelSize: 12; family: "Inter" }
                    font.weight: Font.Medium
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
                        height: 70; radius: 8
                        color: SettingsBackend.iconTheme === modelData ? "#1E2A3A" : "#1A1A1A"
                        border.width: 1
                        border.color: SettingsBackend.iconTheme === modelData ? root.accent : "#2A2A2A"
                        Behavior on color       { ColorAnimation { duration: 150 } }
                        Behavior on border.color{ ColorAnimation { duration: 150 } }

                        Column {
                            anchors.centerIn: parent
                            spacing: 6
                            
                            // Mock folder icon preview
                            Item {
                                width: 28; height: 22
                                anchors.horizontalCenter: parent.horizontalCenter
                                Rectangle {
                                    y: 6; width: 28; height: 16; radius: 3
                                    color: modelData.includes("Adwaita") ? "#E3C293" : (modelData.includes("Breeze") ? "#3DAEE9" : (modelData.includes("Dark") ? "#3D82AE" : "#4FC3F7"))
                                }
                                Rectangle {
                                    x: 2; y: 2; width: 12; height: 6; radius: 2
                                    color: Qt.lighter(modelData.includes("Adwaita") ? "#E3C293" : (modelData.includes("Breeze") ? "#3DAEE9" : (modelData.includes("Dark") ? "#3D82AE" : "#4FC3F7")), 1.15)
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData
                                font { pixelSize: 11; family: "Inter" }
                                font.weight: SettingsBackend.iconTheme === modelData ? Font.Medium : Font.Normal
                                color: SettingsBackend.iconTheme === modelData ? root.textHigh : root.textMid
                            }
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

            // Font Family row
            Column {
                Layout.fillWidth: true
                spacing: 10

                Row {
                    spacing: 0
                    Text {
                        text: "Font Family"
                        font { pixelSize: 13; family: "Inter" }
                        font.weight: Font.Medium
                        color: root.textHigh
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Flow {
                    width: parent.width
                    spacing: 8

                    Repeater {
                        model: ["Inter", "JetBrains Mono", "Fira Code", "Roboto", "Noto Sans", "Ubuntu", "Cascadia Code"]
                        delegate: Rectangle {
                            height: 30
                            width: ffLabel.implicitWidth + 24
                            radius: 6
                            color: SettingsBackend.fontFamily === modelData ? "#1E2A3A" : "#1A1A1A"
                            border.width: 1
                            border.color: SettingsBackend.fontFamily === modelData ? root.accent : "#2A2A2A"
                            Behavior on color       { ColorAnimation { duration: 120 } }
                            Behavior on border.color{ ColorAnimation { duration: 120 } }

                            Text {
                                id: ffLabel
                                anchors.centerIn: parent
                                text: modelData
                                font { pixelSize: 12; family: modelData }
                                color: SettingsBackend.fontFamily === modelData ? root.textHigh : root.textMid
                            }

                            MouseArea {
                                anchors.fill: parent; hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: SettingsBackend.fontFamily = modelData
                            }
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#222222"; Layout.topMargin: 4; Layout.bottomMargin: 4 }

            // Font Size row
            RowLayout {
                Layout.fillWidth: true
                Column {
                    spacing: 4
                    Text {
                        text: "Font Size"
                        font { pixelSize: 13; family: "Inter" }
                        font.weight: Font.Medium
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
                    width: 160; from: 10; to: 24; stepSize: 1
                    fillColor: root.accent
                    value: SettingsBackend.fontSize
                    onValueChanged: SettingsBackend.fontSize = value
                }
                Text {
                    text: SettingsBackend.fontSize + " pt"
                    font { pixelSize: 12; family: "Inter" }
                    font.weight: Font.Medium
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
