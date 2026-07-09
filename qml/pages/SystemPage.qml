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

        // ── Resource meters ───────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            spacing: 14

            Repeater {
                model: [
                    {
                        label: "CPU",
                        value: SystemInfo.cpuUsage,
                        max: 100,
                        suffix: "%",
                        color: SystemInfo.cpuUsage > 80 ? "#F7768E" : SystemInfo.cpuUsage > 50 ? "#E0AF68" : "#7AA2F7",
                        icon: "⬢",
                        sub: ""
                    },
                    {
                        label: "RAM",
                        value: SystemInfo.usedRam,
                        max: SystemInfo.totalRam,
                        suffix: " MB",
                        color: (SystemInfo.totalRam > 0 && (SystemInfo.usedRam / SystemInfo.totalRam) > 0.8) ? "#F7768E" : "#BB9AF7",
                        icon: "◉",
                        sub: SystemInfo.totalRam + " MB"
                    },
                    {
                        label: "DISK",
                        value: SystemInfo.diskUsedGb,
                        max: SystemInfo.diskTotalGb,
                        suffix: " GB",
                        color: (SystemInfo.diskTotalGb > 0 && (SystemInfo.diskUsedGb / SystemInfo.diskTotalGb) > 0.85) ? "#F7768E" : "#9ECE6A",
                        icon: "◈",
                        sub: SystemInfo.diskTotalGb.toFixed(1) + " GB"
                    }
                ]
                delegate: Rectangle {
                    Layout.fillWidth: true; height: 140; radius: 14
                    color: "#0C0C18"
                    border.width: 1; border.color: "#FFFFFF0A"
                    clip: true

                    // Background fill based on usage level
                    Rectangle {
                        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                        height: (modelData.max > 0 ? (modelData.value / modelData.max) : 0) * parent.height
                        radius: parent.radius
                        opacity: 0.08
                        color: modelData.color
                        Behavior on height { NumberAnimation { duration: 700; easing.type: Easing.OutCubic } }
                    }

                    // Top shimmer
                    Rectangle {
                        anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: 1; leftMargin: 1; rightMargin: 1 }
                        height: 1; radius: parent.parent.radius
                        color: "#FFFFFF0C"
                    }

                    Column {
                        anchors { fill: parent; margins: 18 }
                        spacing: 10

                        // Label + icon row
                        Row {
                            spacing: 8
                            Rectangle {
                                width: 26; height: 26; radius: 7
                                color: Qt.rgba(Qt.color(modelData.color).r, Qt.color(modelData.color).g, Qt.color(modelData.color).b, 0.15)
                                border.width: 1
                                border.color: Qt.rgba(Qt.color(modelData.color).r, Qt.color(modelData.color).g, Qt.color(modelData.color).b, 0.3)
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    anchors.centerIn: parent; text: modelData.icon
                                    font.pixelSize: 12; color: modelData.color
                                }
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.label
                                font { pixelSize: 10; weight: Font.Bold; family: "Inter"; letterSpacing: 1.5 }
                                color: root.textDim
                            }
                        }

                        // Value
                        Text {
                            text: {
                                if (modelData.label === "DISK") return modelData.value.toFixed(1) + modelData.suffix
                                if (modelData.label === "CPU") return modelData.value.toFixed(1) + modelData.suffix
                                return modelData.value + modelData.suffix
                            }
                            font { pixelSize: 28; weight: Font.Bold; family: "Inter" }
                            color: modelData.color
                        }

                        // Progress track
                        Rectangle {
                            width: parent.width; height: 5; radius: 2.5
                            color: "#1A1A2C"

                            Rectangle {
                                width: modelData.max > 0 ? (modelData.value / modelData.max) * parent.width : 0
                                height: parent.height; radius: parent.radius
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: Qt.rgba(Qt.color(modelData.color).r, Qt.color(modelData.color).g, Qt.color(modelData.color).b, 0.7) }
                                    GradientStop { position: 1.0; color: modelData.color }
                                }
                                Behavior on width { NumberAnimation { duration: 700 } }
                            }
                        }

                        Text {
                            text: modelData.sub !== "" ? "of " + modelData.sub : ""
                            font { pixelSize: 10; family: "Inter" }
                            color: root.textDim
                            visible: modelData.sub !== ""
                        }
                    }
                }
            }
        }

        Item { height: 20 }

        // ── System info ───────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            title: "SYSTEM INFORMATION"

            GridLayout {
                Layout.fillWidth: true
                columns: 2; rowSpacing: 18; columnSpacing: 32

                Repeater {
                    model: [
                        { label: "HOSTNAME", value: SystemInfo.hostname,      color: "#7AA2F7" },
                        { label: "KERNEL",   value: SystemInfo.kernelVersion,  color: "#9ECE6A" },
                        { label: "CPU",      value: SystemInfo.cpuModel,       color: "#BB9AF7" },
                        { label: "GPU",      value: SystemInfo.gpuModel,       color: "#73DACA" },
                        { label: "UPTIME",   value: SystemInfo.uptime,         color: "#E0AF68" },
                        { label: "OS",       value: SystemInfo.osVersion,      color: "#7AA2F7" }
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
                            font { pixelSize: 13; weight: Font.Medium; family: "Inter" }
                            color: modelData.color
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            width: 280
                        }
                    }
                }
            }
        }

        Item { height: 14 }

        // ── Titan services ────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            title: "TITAN SERVICES"

            Repeater {
                model: [
                    { name: "titan-hwm",          icon: "⬢", clr: "#7AA2F7" },
                    { name: "titan-sandboxd",      icon: "◈", clr: "#BB9AF7" },
                    { name: "titanshare-daemon",   icon: "◉", clr: "#9ECE6A" },
                    { name: "NetworkManager",      icon: "◈", clr: "#73DACA" },
                    { name: "pipewire",            icon: "◉", clr: "#E0AF68" }
                ]
                delegate: ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        height: 46
                        spacing: 12

                        Rectangle {
                            width: 30; height: 30; radius: 8
                            color: Qt.rgba(Qt.color(modelData.clr).r, Qt.color(modelData.clr).g, Qt.color(modelData.clr).b, 0.10)
                            border.width: 1
                            border.color: Qt.rgba(Qt.color(modelData.clr).r, Qt.color(modelData.clr).g, Qt.color(modelData.clr).b, 0.25)
                            Text { anchors.centerIn: parent; text: modelData.icon; font.pixelSize: 13; color: modelData.clr }
                        }

                        Text {
                            text: modelData.name
                            font { pixelSize: 13; family: "Inter"; weight: Font.Medium }
                            color: root.textPrimary
                            Layout.fillWidth: true
                        }

                        StatusBadge { text: "Running"; statusColor: "#9ECE6A" }
                    }

                    Rectangle {
                        Layout.fillWidth: true; height: 1
                        color: "#FFFFFF06"
                        visible: index < 4
                    }
                }
            }
        }

        Item { height: 32 }
    }
}
