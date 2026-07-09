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

    readonly property var accentColors: [
        "#7AA2F7", "#00D4FF", "#BB9AF7", "#9ECE6A",
        "#FF9E64", "#F7768E", "#73DACA", "#E0AF68"
    ]

    ColumnLayout {
        width: root.width
        spacing: 0

        Item { height: 32 }

        // ── Theme picker ──────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 28
            Layout.rightMargin: 28
            spacing: 14

            Repeater {
                model: [
                    { name: "Dark",     bg: "#12121C", bg2: "#0E0E18" },
                    { name: "Darker",   bg: "#0A0A14", bg2: "#07070F" },
                    { name: "Midnight", bg: "#08080F", bg2: "#050508" },
                    { name: "Dim",      bg: "#16161F", bg2: "#111118" }
                ]
                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 110; radius: 14
                    border.width: SettingsBackend.colorTheme === modelData.name ? 2 : 1
                    border.color: SettingsBackend.colorTheme === modelData.name
                                  ? root.accentBlue + "CC" : "#FFFFFF12"

                    color: SettingsBackend.colorTheme === modelData.name
                           ? Qt.rgba(root.accentBlue.r, root.accentBlue.g, root.accentBlue.b, 0.08)
                           : "transparent"

                    Behavior on border.color { ColorAnimation { duration: 200 } }
                    Behavior on color        { ColorAnimation { duration: 200 } }

                    // Inner gradient bg
                    Rectangle {
                        anchors { fill: parent; margins: 1 }
                        radius: parent.radius - 1
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: modelData.bg  }
                            GradientStop { position: 1.0; color: modelData.bg2 }
                        }
                    }

                    // Mini mock window preview
                    Column {
                        anchors.centerIn: parent
                        spacing: 10

                        // Window mock
                        Rectangle {
                            width: 64; height: 42; radius: 8
                            color: Qt.lighter(modelData.bg, 1.5)
                            anchors.horizontalCenter: parent.horizontalCenter
                            border.width: 1
                            border.color: "#FFFFFF10"

                            // Title bar
                            Rectangle {
                                width: parent.width; height: 10; radius: 4
                                color: Qt.lighter(modelData.bg, 1.8)
                                anchors.top: parent.top

                                Row {
                                    anchors { left: parent.left; leftMargin: 5; verticalCenter: parent.verticalCenter }
                                    spacing: 3
                                    Repeater {
                                        model: ["#FF5F57", "#FFBD2E", "#28CA41"]
                                        Rectangle { width: 4; height: 4; radius: 2; color: modelData }
                                    }
                                }
                            }

                            // Content lines
                            Column {
                                anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: 14; margins: 7 }
                                spacing: 4
                                Repeater {
                                    model: 3
                                    Rectangle {
                                        width: (3 - index) * 12 + 18; height: 3; radius: 1.5
                                        color: root.accentBlue
                                        opacity: 0.25 + index * 0.15
                                    }
                                }
                            }
                        }

                        Text {
                            text: modelData.name
                            anchors.horizontalCenter: parent.horizontalCenter
                            font { pixelSize: 12; family: "Inter"; weight: SettingsBackend.colorTheme === modelData.name ? Font.SemiBold : Font.Normal }
                            color: SettingsBackend.colorTheme === modelData.name ? root.textPrimary : root.textDim
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }

                    // Selected checkmark
                    Rectangle {
                        anchors { top: parent.top; right: parent.right; topMargin: 8; rightMargin: 8 }
                        width: 18; height: 18; radius: 9
                        color: root.accentBlue
                        visible: SettingsBackend.colorTheme === modelData.name
                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            font { pixelSize: 10; weight: Font.Bold }
                            color: "#FFFFFF"
                        }
                    }

                    scale: themeHov.containsMouse ? 1.02 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150 } }

                    MouseArea {
                        id: themeHov
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SettingsBackend.colorTheme = modelData.name
                    }
                }
            }
        }

        Item { height: 20 }

        // ── Accent color ─────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            title: "ACCENT COLOR"

            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Repeater {
                    model: root.accentColors
                    delegate: Item {
                        width: 34; height: 34

                        Rectangle {
                            anchors.centerIn: parent
                            width: SettingsBackend.accentColor === modelData ? 34 : 28
                            height: width; radius: width / 2
                            color: modelData
                            border.width: SettingsBackend.accentColor === modelData ? 2 : 0
                            border.color: "#FFFFFFCC"
                            Behavior on width { NumberAnimation { duration: 150 } }

                            // Inner shine
                            Rectangle {
                                x: parent.width * 0.25; y: parent.height * 0.15
                                width: parent.width * 0.35; height: parent.height * 0.28
                                radius: height / 2
                                color: "#FFFFFF"
                                opacity: 0.4
                            }

                            MouseArea {
                                id: accentHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: SettingsBackend.accentColor = modelData
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Current color swatch
                Rectangle {
                    width: 70; height: 28; radius: 8
                    color: SettingsBackend.accentColor
                    Behavior on color { ColorAnimation { duration: 200 } }

                    Text {
                        anchors.centerIn: parent
                        text: SettingsBackend.accentColor
                        font { pixelSize: 10; family: "Inter"; weight: Font.Medium }
                        color: "#FFFFFF"
                        opacity: 0.9
                    }
                }
            }
        }

        Item { height: 14 }

        // ── Visual effects ───────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            title: "VISUAL EFFECTS"

            RowLayout {
                Layout.fillWidth: true

                Column {
                    spacing: 5
                    Text {
                        text: "Glassmorphism"
                        font { pixelSize: 14; family: "Inter"; weight: Font.Medium }
                        color: root.textPrimary
                    }
                    Text {
                        text: "Frosted glass blur on panels and overlays"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textDim
                    }
                }
                Item { Layout.fillWidth: true }
                TitanSwitch {
                    checked: SettingsBackend.glassmorphism
                    onCheckedChanged: SettingsBackend.glassmorphism = checked
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#FFFFFF08"; Layout.topMargin: 6; Layout.bottomMargin: 6 }

            RowLayout {
                Layout.fillWidth: true
                Column {
                    spacing: 5
                    Text {
                        text: "Panel Opacity"
                        font { pixelSize: 14; family: "Inter"; weight: Font.Medium }
                        color: root.textPrimary
                    }
                    Text {
                        text: "Transparency level for sidebars and panels"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textDim
                    }
                }
                Item { Layout.fillWidth: true }
                TitanSlider {
                    width: 180
                    from: 0.4; to: 1.0; stepSize: 0.01
                    value: SettingsBackend.panelOpacity
                    onValueChanged: SettingsBackend.panelOpacity = value
                }
                Text {
                    text: Math.round(SettingsBackend.panelOpacity * 100) + "%"
                    font { pixelSize: 13; family: "Inter"; weight: Font.Medium }
                    color: root.accentBlue
                    Layout.preferredWidth: 44
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        Item { height: 14 }

        // ── Icon theme ───────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            title: "ICON THEME"

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Repeater {
                    model: ["Papirus-Dark", "Papirus", "Adwaita", "Breeze-Dark"]
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 54; radius: 10
                        color: SettingsBackend.iconTheme === modelData
                               ? Qt.rgba(root.accentBlue.r, root.accentBlue.g, root.accentBlue.b, 0.12)
                               : "#0F0F1A"
                        border.width: 1
                        border.color: SettingsBackend.iconTheme === modelData
                                      ? Qt.rgba(root.accentBlue.r, root.accentBlue.g, root.accentBlue.b, 0.5)
                                      : "#FFFFFF0C"

                        Behavior on color       { ColorAnimation { duration: 180 } }
                        Behavior on border.color{ ColorAnimation { duration: 180 } }

                        Column {
                            anchors.centerIn: parent
                            spacing: 5
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: ["◈", "◉", "◆", "◇"][index]
                                font.pixelSize: 16
                                color: SettingsBackend.iconTheme === modelData ? root.accentBlue : "#404060"
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData
                                font { pixelSize: 11; family: "Inter" }
                                color: SettingsBackend.iconTheme === modelData ? root.textPrimary : root.textDim
                            }
                        }

                        scale: iconHov.containsMouse ? 1.02 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150 } }

                        MouseArea {
                            id: iconHov
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: SettingsBackend.iconTheme = modelData
                        }
                    }
                }
            }
        }

        Item { height: 14 }

        // ── Typography ───────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            title: "TYPOGRAPHY"

            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                Column {
                    spacing: 5
                    Text {
                        text: "Font Size"
                        font { pixelSize: 14; family: "Inter"; weight: Font.Medium }
                        color: root.textPrimary
                    }
                    Text {
                        text: "System-wide interface font size"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textDim
                    }
                }
                Item { Layout.fillWidth: true }
                TitanSlider {
                    width: 200
                    from: 9; to: 18; stepSize: 1
                    value: SettingsBackend.fontSize
                    onValueChanged: SettingsBackend.fontSize = value
                }
                Text {
                    text: SettingsBackend.fontSize + " pt"
                    font { pixelSize: 13; family: "Inter"; weight: Font.SemiBold }
                    color: root.accentBlue
                    Layout.preferredWidth: 46
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        Item { height: 28 }

        // ── Action bar ───────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            Item { Layout.fillWidth: true }
            TitanButton { text: "Reset Defaults"; primary: false; width: 150; onClicked: SettingsBackend.resetToDefaults() }
            Item { width: 12 }
            TitanButton { text: "Apply & Save"; primary: true; width: 150; onClicked: SettingsBackend.applyAndSave() }
        }

        Item { height: 32 }
    }
}
