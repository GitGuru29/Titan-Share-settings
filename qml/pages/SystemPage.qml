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
        width: root.availableWidth; spacing: 0

        Item { height: 28 }

        // ── Resource meters ──────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24
            spacing: 12

            Repeater {
                model: [
                    { label: "CPU",  suffix: "%",   colorFn: 1 },
                    { label: "RAM",  suffix: " MB", colorFn: 2 },
                    { label: "DISK", suffix: " GB", colorFn: 3 }
                ]
                delegate: Rectangle {
                    Layout.fillWidth: true; height: 120; radius: 10
                    color: "#141414"; border.width: 1; border.color: "#222222"

                    property real val: modelData.label === "CPU" ? SystemInfo.cpuUsage :
                                       modelData.label === "RAM" ? SystemInfo.usedRam :
                                       modelData.label === "DISK" ? SystemInfo.diskUsedGb : 0
                                       
                    property real maxVal: modelData.label === "CPU" ? 100 :
                                          modelData.label === "RAM" ? SystemInfo.totalRam :
                                          modelData.label === "DISK" ? SystemInfo.diskTotalGb : 1
                    property real pct: maxVal > 0 ? val / maxVal : 0
                    property color barColor: pct > 0.8 ? root.red : pct > 0.5 ? root.orange : root.accent

                    Column {
                        anchors { fill: parent; margins: 16 }
                        spacing: 8

                        Text {
                            text: modelData.label
                            font { pixelSize: 10; family: "Inter" }
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1.2
                            color: root.textLow
                        }

                        Text {
                            text: {
                                if (modelData.label === "CPU" || modelData.label === "DISK")
                                    return val.toFixed(1) + modelData.suffix
                                return val + modelData.suffix
                            }
                            font { pixelSize: 26; family: "Inter" }
                            font.weight: Font.Bold
                            color: barColor
                        }

                        Rectangle {
                            width: parent.width; height: 4; radius: 2; color: "#2A2A2A"
                            Rectangle {
                                width: parent.parent.parent.pct * parent.width
                                height: parent.height; radius: parent.radius
                                color: parent.parent.parent.barColor
                                Behavior on width { NumberAnimation { duration: 600 } }
                            }
                        }

                        Text {
                            text: "of " + (modelData.label === "DISK" ? maxVal.toFixed(1) : maxVal) + modelData.suffix
                            font { pixelSize: 10; family: "Inter" }
                            color: root.textLow
                            visible: maxVal > 0 && modelData.label !== "CPU"
                        }
                    }
                }
            }
        }

        Item { height: 16 }

        // ── System info ──────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "System Information"

            GridLayout {
                Layout.fillWidth: true
                columns: 2; rowSpacing: 14; columnSpacing: 32

                Repeater {
                    model: [
                        { label: "Hostname" },
                        { label: "Kernel"   },
                        { label: "CPU"      },
                        { label: "GPU"      },
                        { label: "Uptime"   },
                        { label: "OS"       }
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
                            text: {
                                if (modelData.label === "Hostname") return SystemInfo.hostname;
                                if (modelData.label === "Kernel") return SystemInfo.kernelVersion;
                                if (modelData.label === "CPU") return SystemInfo.cpuModel;
                                if (modelData.label === "GPU") return SystemInfo.gpuModel;
                                if (modelData.label === "Uptime") return SystemInfo.uptime;
                                if (modelData.label === "OS") return SystemInfo.osVersion;
                                return "";
                            }
                            font { pixelSize: 13; family: "Inter" }
                            font.weight: Font.Medium
                            color: root.textHigh; elide: Text.ElideRight
                            maximumLineCount: 1; width: 260
                        }
                    }
                }
            }
        }

        Item { height: 12 }

        // ── Titan services ───────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Titan Services"

            Repeater {
                model: [
                    "titan-hwm", "titan-sandboxd", "titanshare-daemon", "NetworkManager", "pipewire"
                ]
                delegate: ColumnLayout {
                    Layout.fillWidth: true; spacing: 0
                    RowLayout {
                        Layout.fillWidth: true; height: 46; spacing: 12
                        Rectangle { width: 7; height: 7; radius: 4; color: root.green; Layout.alignment: Qt.AlignVCenter }
                        Text {
                            text: modelData
                            font { pixelSize: 13; family: "Inter" }
                            font.weight: Font.Medium
                            color: root.textHigh; Layout.fillWidth: true
                        }
                        StatusBadge { text: "Running"; statusColor: root.green }
                    }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#1F1F1F"; visible: index < 4 }
                }
            }
        }

        Item { height: 28 }
    }
}
