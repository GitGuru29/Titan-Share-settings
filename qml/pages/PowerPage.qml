import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Effects
import ArchTitanSettings

ScrollView {
    id: root
    contentWidth: -1
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

    property color textHigh: globalTextHigh
    property color textMid:  globalTextMid
    property color textLow:  globalTextLow
    property color accent:   SettingsBackend.accentColor
    property color green:    "#4CAF82"
    property color orange:   "#D4853A"
    property color red:      "#E05C6A"

    readonly property var screenOffOptions: [
        { label: "1 m",  val: 60 },
        { label: "2 m",  val: 120 },
        { label: "5 m",  val: 300 },
        { label: "10 m", val: 600 },
        { label: "15 m", val: 900 },
        { label: "30 m", val: 1800 }
    ]

    readonly property var activeScreenOffModel: {
        var opts = screenOffOptions.slice();
        var current = SettingsBackend.screenTimeout;
        var found = false;
        for (var i = 0; i < opts.length; i++) {
            if (opts[i].val === current) {
                found = true;
                break;
            }
        }
        if (!found) {
            var lbl = current >= 60 ? Math.round(current / 60) + " m" : current + " s";
            opts.push({ label: lbl, val: current });
            // Sort by val
            opts.sort(function(a, b) { return a.val - b.val; });
        }
        return opts;
    }

    readonly property var suspendOptions: [
        { label: "Never", val: 99999 },
        { label: "5 m",  val: 300 },
        { label: "10 m", val: 600 },
        { label: "15 m", val: 900 },
        { label: "30 m", val: 1800 },
        { label: "1 h",  val: 3600 },
        { label: "2 h",  val: 7200 }
    ]

    readonly property var activeSuspendModel: {
        var opts = suspendOptions.slice();
        var current = SettingsBackend.suspendTimeout;
        var found = false;
        for (var i = 0; i < opts.length; i++) {
            if (opts[i].val === current) {
                found = true;
                break;
            }
        }
        if (!found) {
            var lbl = current >= 3600 ? Math.round(current / 3600) + " h" : Math.round(current / 60) + " m";
            opts.push({ label: lbl, val: current });
            // Sort by val, keeping Never (99999) at the end or start
            opts.sort(function(a, b) {
                if (a.val === 99999) return -1; // Never first
                if (b.val === 99999) return 1;
                return a.val - b.val;
            });
        }
        return opts;
    }

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

                    color: sel ? Qt.tint(globalBg3, Qt.rgba(Qt.color(modelData.accent).r, Qt.color(modelData.accent).g, Qt.color(modelData.accent).b, isDarkTheme ? 0.22 : 0.12)) : globalBg3
                    border.width: sel ? 2 : 1
                    border.color: sel ? modelData.accent : globalBorder0
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
                            color: sel ? root.textHigh : root.textLow
                            opacity: sel ? 0.8 : 1.0
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SettingsBackend.applyPowerProfileNow(modelData.name)
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

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12

                // Screen Off
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "Screen Off After"
                        font { pixelSize: 13; family: "Inter" }
                        font.weight: Font.Medium
                        color: root.textHigh
                    }
                    Text {
                        text: "Idle screen timeout"
                        font { pixelSize: 11; family: "Inter" }
                        color: root.textMid
                    }

                    Item { height: 2 }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 8

                        Repeater {
                            model: root.activeScreenOffModel
                            delegate: Rectangle {
                                height: 28
                                width: optLabel1.implicitWidth + 24
                                radius: 6
                                color: SettingsBackend.screenTimeout === modelData.val
                                       ? (isDarkTheme ? Qt.tint(globalBg3, Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.25))
                                                      : Qt.tint(globalBg3, Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.15)))
                                       : globalBg4
                                border.width: 1
                                border.color: SettingsBackend.screenTimeout === modelData.val ? root.accent : globalBorder0
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    id: optLabel1
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font { pixelSize: 12; family: "Inter" }
                                    font.weight: SettingsBackend.screenTimeout === modelData.val ? Font.DemiBold : Font.Normal
                                    color: SettingsBackend.screenTimeout === modelData.val ? root.textHigh : root.textMid
                                }

                                MouseArea {
                                    anchors.fill: parent; hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SettingsBackend.applyScreenTimeoutNow(modelData.val)
                                }
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: globalBorder1; Layout.topMargin: 4; Layout.bottomMargin: 4 }

                // Suspend
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "Suspend After"
                        font { pixelSize: 13; family: "Inter" }
                        font.weight: Font.Medium
                        color: root.textHigh
                    }
                    Text {
                        text: "System suspend timeout"
                        font { pixelSize: 11; family: "Inter" }
                        color: root.textMid
                    }

                    Item { height: 2 }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 8

                        Repeater {
                            model: root.activeSuspendModel
                            delegate: Rectangle {
                                height: 28
                                width: optLabel2.implicitWidth + 24
                                radius: 6
                                color: SettingsBackend.suspendTimeout === modelData.val
                                       ? (isDarkTheme ? Qt.tint(globalBg3, Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.25))
                                                      : Qt.tint(globalBg3, Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.15)))
                                       : globalBg4
                                border.width: 1
                                border.color: SettingsBackend.suspendTimeout === modelData.val ? root.accent : globalBorder0
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    id: optLabel2
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font { pixelSize: 12; family: "Inter" }
                                    font.weight: SettingsBackend.suspendTimeout === modelData.val ? Font.DemiBold : Font.Normal
                                    color: SettingsBackend.suspendTimeout === modelData.val ? root.textHigh : root.textMid
                                }

                                MouseArea {
                                    anchors.fill: parent; hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SettingsBackend.applySuspendTimeoutNow(modelData.val)
                                }
                            }
                        }
                    }
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
                        color: globalBg3; border.width: 1; border.color: globalBorder0

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
                        width: 5; height: 18; radius: 2; color: globalBorder0
                    }
                }
            }
        }

        Item { height: 28 }
    }
}
