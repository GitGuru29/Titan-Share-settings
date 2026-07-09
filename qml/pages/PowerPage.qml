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

        // ── Power profile selector ────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            spacing: 14

            Repeater {
                model: [
                    { name: "Power Saver",  desc: "Maximize battery life",  icon: "🌿", clr: "#9ECE6A", bg: "#0A160A" },
                    { name: "Balanced",     desc: "Smart performance",       icon: "⚖",  clr: "#7AA2F7", bg: "#0A0E1A" },
                    { name: "Performance",  desc: "Max CPU performance",     icon: "⚡",  clr: "#FF9E64", bg: "#1A0F06" }
                ]
                delegate: Rectangle {
                    Layout.fillWidth: true; height: 136; radius: 14
                    property bool sel: SettingsBackend.powerProfile === modelData.name

                    color: sel
                           ? Qt.rgba(Qt.color(modelData.clr).r, Qt.color(modelData.clr).g, Qt.color(modelData.clr).b, 0.10)
                           : modelData.bg
                    border.width: sel ? 2 : 1
                    border.color: sel ? modelData.clr : "#FFFFFF10"

                    Behavior on color       { ColorAnimation { duration: 220 } }
                    Behavior on border.color{ ColorAnimation { duration: 220 } }

                    // Top shimmer
                    Rectangle {
                        anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: 1; leftMargin: 1; rightMargin: 1 }
                        height: 1; radius: parent.parent.radius
                        color: sel ? Qt.rgba(Qt.color(modelData.clr).r, Qt.color(modelData.clr).g, Qt.color(modelData.clr).b, 0.4) : "#FFFFFF0A"
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 10

                        // Icon ring
                        Item {
                            width: 52; height: 52
                            anchors.horizontalCenter: parent.horizontalCenter

                            Rectangle {
                                anchors.centerIn: parent
                                width: 52; height: 52; radius: 26
                                color: Qt.rgba(Qt.color(modelData.clr).r, Qt.color(modelData.clr).g, Qt.color(modelData.clr).b, sel ? 0.20 : 0.08)
                                border.width: 1
                                border.color: Qt.rgba(Qt.color(modelData.clr).r, Qt.color(modelData.clr).g, Qt.color(modelData.clr).b, sel ? 0.6 : 0.2)
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                font.pixelSize: 24
                            }
                        }

                        Text {
                            text: modelData.name
                            font { pixelSize: 13; weight: Font.SemiBold; family: "Inter" }
                            color: sel ? Qt.color(modelData.clr) : root.textPrimary
                            anchors.horizontalCenter: parent.horizontalCenter
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        Text {
                            text: modelData.desc
                            font { pixelSize: 11; family: "Inter" }
                            color: sel ? Qt.rgba(Qt.color(modelData.clr).r, Qt.color(modelData.clr).g, Qt.color(modelData.clr).b, 0.7) : root.textDim
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    // Selected check
                    Rectangle {
                        anchors { top: parent.top; right: parent.right; topMargin: 10; rightMargin: 10 }
                        width: 20; height: 20; radius: 10
                        color: modelData.clr
                        visible: sel
                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            font { pixelSize: 11; weight: Font.Bold }
                            color: "#000000CC"
                        }
                    }

                    scale: pfHov.containsMouse ? 1.02 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150 } }

                    MouseArea {
                        id: pfHov
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SettingsBackend.powerProfile = modelData.name
                    }
                }
            }
        }

        Item { height: 20 }

        // ── Timeouts ──────────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            title: "TIMEOUTS"

            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                Column {
                    spacing: 5
                    Text {
                        text: "Screen Off After"
                        font { pixelSize: 14; weight: Font.Medium; family: "Inter" }
                        color: root.textPrimary
                    }
                    Text {
                        text: "Idle screen timeout"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textDim
                    }
                }
                Item { Layout.fillWidth: true }
                TitanSlider {
                    width: 200; from: 30; to: 1800; stepSize: 30
                    value: SettingsBackend.screenTimeout
                    onValueChanged: SettingsBackend.screenTimeout = value
                }
                Rectangle {
                    width: 52; height: 28; radius: 8; color: "#1A1A2C"
                    border.width: 1; border.color: "#FFFFFF10"
                    Text {
                        anchors.centerIn: parent
                        text: SettingsBackend.screenTimeout >= 60
                              ? Math.floor(SettingsBackend.screenTimeout / 60) + " m"
                              : SettingsBackend.screenTimeout + " s"
                        font { pixelSize: 12; family: "Inter"; weight: Font.SemiBold }
                        color: root.accentBlue
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#FFFFFF08"; Layout.topMargin: 8; Layout.bottomMargin: 8 }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                Column {
                    spacing: 5
                    Text {
                        text: "Suspend After"
                        font { pixelSize: 14; weight: Font.Medium; family: "Inter" }
                        color: root.textPrimary
                    }
                    Text {
                        text: "System suspend timeout"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textDim
                    }
                }
                Item { Layout.fillWidth: true }
                TitanSlider {
                    width: 200; from: 60; to: 3600; stepSize: 60
                    value: SettingsBackend.suspendTimeout
                    onValueChanged: SettingsBackend.suspendTimeout = value
                }
                Rectangle {
                    width: 52; height: 28; radius: 8; color: "#1A1A2C"
                    border.width: 1; border.color: "#FFFFFF10"
                    Text {
                        anchors.centerIn: parent
                        text: Math.floor(SettingsBackend.suspendTimeout / 60) + " m"
                        font { pixelSize: 12; family: "Inter"; weight: Font.SemiBold }
                        color: root.accentBlue
                    }
                }
            }
        }

        Item { height: 14 }

        // ── Battery ───────────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            title: "BATTERY"

            RowLayout {
                Layout.fillWidth: true
                spacing: 24

                // Battery icon
                Rectangle {
                    width: 56; height: 56; radius: 14
                    color: {
                        if (SystemInfo.batteryLevel > 40) return "#0A160A"
                        if (SystemInfo.batteryLevel > 20) return "#160E04"
                        return "#1A0808"
                    }
                    border.width: 1
                    border.color: {
                        if (SystemInfo.batteryLevel > 40) return "#9ECE6A40"
                        if (SystemInfo.batteryLevel > 20) return "#E0AF6840"
                        return "#F7768E40"
                    }
                    Behavior on color { ColorAnimation { duration: 500 } }

                    Text {
                        anchors.centerIn: parent
                        text: SystemInfo.batteryCharging ? "🔌" : "🔋"
                        font.pixelSize: 26
                    }
                }

                Column {
                    spacing: 8
                    Text {
                        text: SystemInfo.batteryLevel + "%"
                        font { pixelSize: 36; weight: Font.Bold; family: "Inter" }
                        color: {
                            if (SystemInfo.batteryLevel > 40) return "#9ECE6A"
                            if (SystemInfo.batteryLevel > 20) return "#E0AF68"
                            return "#F7768E"
                        }
                        Behavior on color { ColorAnimation { duration: 500 } }
                    }
                    Text {
                        text: SystemInfo.batteryCharging ? "⚡  Charging" : "On Battery"
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textDim
                    }
                }

                Item { Layout.fillWidth: true }

                // Battery body visual
                Item {
                    width: 130; height: 52
                    anchors.verticalCenter: parent.verticalCenter

                    // Battery body
                    Rectangle {
                        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                        width: parent.width - 8
                        radius: 6
                        color: "#0C0C18"
                        border.width: 1; border.color: "#FFFFFF18"

                        // Fill
                        Rectangle {
                            anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: 3 }
                            width: Math.max(0, ((SystemInfo.batteryLevel / 100) * (parent.width - 6)))
                            radius: 4
                            color: {
                                if (SystemInfo.batteryLevel > 40) return "#9ECE6A"
                                if (SystemInfo.batteryLevel > 20) return "#E0AF68"
                                return "#F7768E"
                            }
                            Behavior on width { NumberAnimation { duration: 800; easing.type: Easing.OutCubic } }
                            Behavior on color { ColorAnimation { duration: 500 } }

                            // Shine
                            Rectangle {
                                anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: 2; margins: 4 }
                                height: 4; radius: 2
                                color: "#FFFFFF"
                                opacity: 0.25
                            }
                        }
                    }

                    // Nub
                    Rectangle {
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        width: 6; height: 22; radius: 3
                        color: "#FFFFFF18"
                    }
                }
            }
        }

        Item { height: 24 }

        RowLayout {
            Layout.leftMargin: 28; Layout.rightMargin: 28
            Item { Layout.fillWidth: true }
            TitanButton { text: "Apply & Save"; primary: true; width: 150; onClicked: SettingsBackend.applyAndSave() }
        }

        Item { height: 32 }
    }
}
