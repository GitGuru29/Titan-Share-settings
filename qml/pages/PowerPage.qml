import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Effects
import ArchTitanSettings

ScrollView {
    id: root
    contentWidth: -1
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

    property color textHigh: "#EBEBEB"
    property color textMid:  "#8C8C8C"
    property color textLow:  "#4A4A4A"
    property color accent:   SettingsBackend.accentColor
    property color green:    "#4CAF82"
    property color orange:   "#D4853A"
    property color red:      "#E05C6A"

    ColumnLayout {
        width: root.availableWidth
        spacing: 0

        Item { height: 28 }

        // ── Power profile selector ───────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            spacing: 12

            Repeater {
                model: [
                    { 
                        name: "Power Saver",
                        desc: "Maximize battery life",
                        accent: "#4CAF82",
                        icon: "qrc:/ArchTitanSettings/assets/icons/powersaving.png",
                        colorize: false
                    },
                    { 
                        name: "Balanced",
                        desc: "Smart performance",
                        accent: "#4C8BF5",
                        icon: "qrc:/ArchTitanSettings/assets/icons/balanced.png",
                        colorize: false
                    },
                    { 
                        name: "Performance",
                        desc: "Max CPU performance",
                        accent: "#D4853A",
                        icon: "qrc:/ArchTitanSettings/assets/icons/performance_nobg.png",
                        colorize: false
                    }
                ]
                delegate: Rectangle {
                    Layout.fillWidth: true; height: 145; radius: 12
                    property bool sel: SettingsBackend.powerProfile === modelData.name

                    color: sel ? Qt.rgba(Qt.color(modelData.accent).r, Qt.color(modelData.accent).g, Qt.color(modelData.accent).b, 0.08) : "#161616"
                    border.width: sel ? 2 : 1
                    border.color: sel ? modelData.accent : "#2A2A2A"
                    Behavior on color       { ColorAnimation { duration: 180 } }
                    Behavior on border.color{ ColorAnimation { duration: 180 } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 10

                        Rectangle {
                            width: 64; height: 64; radius: 14
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Qt.rgba(Qt.color(modelData.accent).r, Qt.color(modelData.accent).g, Qt.color(modelData.accent).b, sel ? 0.18 : 0.08)
                            border.width: 1
                            border.color: Qt.rgba(Qt.color(modelData.accent).r, Qt.color(modelData.accent).g, Qt.color(modelData.accent).b, sel ? 0.5 : 0.2)

                            Image {
                                id: profileIcon
                                anchors.centerIn: parent
                                width: modelData.colorize ? 24 : 52
                                height: modelData.colorize ? 24 : 52
                                sourceSize: modelData.colorize ? Qt.size(24, 24) : undefined
                                source: modelData.icon
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                mipmap: !modelData.colorize
                                visible: !modelData.colorize
                            }
                            MultiEffect {
                                anchors.fill: profileIcon
                                source: profileIcon
                                colorization: 1.0
                                colorizationColor: modelData.accent
                                visible: modelData.colorize
                            }
                        }

                        Text {
                            text: modelData.name
                            font { pixelSize: 13; family: "Inter" }
                            font.weight: Font.Medium
                            color: sel ? root.textHigh : root.textMid
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: modelData.desc
                            font { pixelSize: 11; family: "Inter" }
                            color: root.textLow
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SettingsBackend.powerProfile = modelData.name
                    }
                }
            }
        }

        Item { height: 16 }

        // ── Timeouts ─────────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Timeouts"

            RowLayout {
                Layout.fillWidth: true
                Column {
                    spacing: 4
                    Text {
                        text: "Screen Off After"
                        font { pixelSize: 13; family: "Inter" }
                        font.weight: Font.Medium
                        color: root.textHigh
                    }
                    Text {
                        text: "Idle screen timeout"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textMid
                    }
                }
                Item { Layout.fillWidth: true }
                TitanSlider {
                    width: 160; from: 30; to: 1800; stepSize: 30
                    value: SettingsBackend.screenTimeout
                    onValueChanged: SettingsBackend.screenTimeout = value
                }
                Text {
                    text: SettingsBackend.screenTimeout >= 60
                          ? Math.floor(SettingsBackend.screenTimeout / 60) + " m"
                          : SettingsBackend.screenTimeout + " s"
                    font { pixelSize: 12; family: "Inter" }
                    font.weight: Font.Medium
                    color: root.accent; Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#222222"; Layout.topMargin: 6; Layout.bottomMargin: 6 }

            RowLayout {
                Layout.fillWidth: true
                Column {
                    spacing: 4
                    Text {
                        text: "Suspend After"
                        font { pixelSize: 13; family: "Inter" }
                        font.weight: Font.Medium
                        color: root.textHigh
                    }
                    Text {
                        text: "System suspend timeout"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textMid
                    }
                }
                Item { Layout.fillWidth: true }
                TitanSlider {
                    width: 160; from: 60; to: 3600; stepSize: 60
                    value: SettingsBackend.suspendTimeout
                    onValueChanged: SettingsBackend.suspendTimeout = value
                }
                Text {
                    text: Math.floor(SettingsBackend.suspendTimeout / 60) + " m"
                    font { pixelSize: 12; family: "Inter" }
                    font.weight: Font.Medium
                    color: root.accent; Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        Item { height: 12 }

        // ── Battery ──────────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Battery"

            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                // Battery level text
                Column {
                    spacing: 4
                    Text {
                        text: SystemInfo.batteryLevel + "%"
                        font { pixelSize: 32; family: "Inter" }
                        font.weight: Font.Bold
                        color: SystemInfo.batteryLevel > 40 ? root.green
                             : SystemInfo.batteryLevel > 20 ? root.orange : root.red
                        Behavior on color { ColorAnimation { duration: 500 } }
                    }
                    Text {
                        text: SystemInfo.batteryCharging ? "Charging" : "On Battery"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textMid
                    }
                }

                Item { Layout.fillWidth: true }

                // Battery bar
                Item {
                    width: 120; height: 48; Layout.alignment: Qt.AlignVCenter

                    Rectangle {
                        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                        width: parent.width - 6; radius: 6
                        color: "#1A1A1A"; border.width: 1; border.color: "#2A2A2A"

                        Rectangle {
                            anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: 3 }
                            width: Math.max(0, (SystemInfo.batteryLevel / 100) * (parent.width - 6))
                            radius: 4
                            color: SystemInfo.batteryLevel > 40 ? root.green
                                 : SystemInfo.batteryLevel > 20 ? root.orange : root.red
                            Behavior on width { NumberAnimation { duration: 800; easing.type: Easing.OutCubic } }
                            Behavior on color { ColorAnimation { duration: 500 } }
                        }
                    }
                    Rectangle {
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        width: 5; height: 18; radius: 2; color: "#2A2A2A"
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
