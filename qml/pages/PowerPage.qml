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
                        icon: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'><path fill='%234CAF82' d='M17,8C8,10 5.9,16.17 3.82,21.34L5.71,22L6.66,19.7C7.14,19.87 7.64,20 8,20C19,20 22,3 22,3C21,5 14,5.25 9,6.25C4,7.25 7,11.5 7,11.5C7,11.5 9,8 17,8Z'/></svg>"
                    },
                    { 
                        name: "Balanced",
                        desc: "Smart performance",
                        accent: "#4C8BF5",
                        icon: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'><path fill='%234C8BF5' d='M3,17V19H9V17H3M3,5V7H13V5H3M13,21V19H21V17H13V15H11V21H13M7,9V11H3V13H7V15H9V9H7M21,13V11H11V13H21M15,9H17V7H21V5H17V3H15V9Z'/></svg>"
                    },
                    { 
                        name: "Performance",
                        desc: "Max CPU performance",
                        accent: "#D4853A",
                        icon: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'><path fill='%23D4853A' d='M7,2V13H10V22L17,10H13L17,2H7Z'/></svg>"
                    }
                ]
                delegate: Rectangle {
                    Layout.fillWidth: true; height: 110; radius: 10
                    property bool sel: SettingsBackend.powerProfile === modelData.name

                    color: sel ? Qt.rgba(Qt.color(modelData.accent).r, Qt.color(modelData.accent).g, Qt.color(modelData.accent).b, 0.08) : "#161616"
                    border.width: sel ? 2 : 1
                    border.color: sel ? modelData.accent : "#2A2A2A"
                    Behavior on color       { ColorAnimation { duration: 180 } }
                    Behavior on border.color{ ColorAnimation { duration: 180 } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        Rectangle {
                            width: 40; height: 40; radius: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Qt.rgba(Qt.color(modelData.accent).r, Qt.color(modelData.accent).g, Qt.color(modelData.accent).b, sel ? 0.18 : 0.08)
                            border.width: 1
                            border.color: Qt.rgba(Qt.color(modelData.accent).r, Qt.color(modelData.accent).g, Qt.color(modelData.accent).b, sel ? 0.5 : 0.2)

                            Image {
                                anchors.centerIn: parent
                                width: 22; height: 22
                                source: modelData.icon
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                mipmap: true
                            }
                        }

                        Text {
                            text: modelData.name
                            font { pixelSize: 12; family: "Inter" }
                            font.weight: Font.Medium
                            color: sel ? root.textHigh : root.textMid
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: modelData.desc
                            font { pixelSize: 10; family: "Inter" }
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
