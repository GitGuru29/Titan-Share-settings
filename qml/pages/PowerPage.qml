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
            opts.sort(function(a, b) {
                if (a.val === 99999) return -1;
                if (b.val === 99999) return 1;
                return a.val - b.val;
            });
        }
        return opts;
    }

    ColumnLayout {
        width: root.availableWidth
        spacing: 0

        Item { height: 20 }

        // ── Page Header ──────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            spacing: 4

            Text {
                text: "Power"
                font { pixelSize: 22; family: "Inter" }
                font.weight: Font.Bold
                color: root.textHigh
            }
        }

        Item { height: 20 }

        // ── Power Profile Selector ───────────────────────────────
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
                        icon: "qrc:/ArchTitanSettings/assets/icons/powersaving.png"
                    },
                    { 
                        name: "Balanced",
                        desc: "Smart performance",
                        accent: "#4C8BF5",
                        icon: "qrc:/ArchTitanSettings/assets/icons/balanced.png"
                    },
                    { 
                        name: "Performance",
                        desc: "Max CPU performance",
                        accent: "#D4853A",
                        icon: "qrc:/ArchTitanSettings/assets/icons/performance_nobg.png"
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
                                anchors.centerIn: parent
                                width: 52; height: 52
                                source: modelData.icon
                                fillMode: Image.PreserveAspectFit
                                smooth: true
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

        // ── Timeouts Card ────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "TIMEOUTS"

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 14

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
                        color: root.textLow
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
                                property bool sel: SettingsBackend.screenTimeout === modelData.val
                                color: sel ? root.accent : globalBg4
                                border.width: 1
                                border.color: sel ? root.accent : globalBorder0
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    id: optLabel1
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font { pixelSize: 12; family: "Inter" }
                                    font.weight: sel ? Font.Medium : Font.Normal
                                    color: sel ? "#FFFFFF" : root.textMid
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

                Rectangle { Layout.fillWidth: true; height: 1; color: globalBorder1 }

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
                        color: root.textLow
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
                                property bool sel: SettingsBackend.suspendTimeout === modelData.val
                                color: sel ? root.accent : globalBg4
                                border.width: 1
                                border.color: sel ? root.accent : globalBorder0
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    id: optLabel2
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font { pixelSize: 12; family: "Inter" }
                                    font.weight: sel ? Font.Medium : Font.Normal
                                    color: sel ? "#FFFFFF" : root.textMid
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

        Item { height: 16 }

        // ── Battery Card ─────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "BATTERY"

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                // Battery level header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    ColumnLayout {
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
                            text: SystemInfo.batteryCharging ? "⚡ Charging" : (SystemInfo.acConnected ? "🔌 Plugged In" : "🔋 On Battery")
                            font { pixelSize: 12; family: "Inter" }
                            color: root.textLow
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Horizontal battery bar graphics
                    Item {
                        width: 120; height: 48
                        Layout.alignment: Qt.AlignVCenter

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

                // Grid Row 1 (Health, Cycles, Condition)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // Battery Health tile
                    Rectangle {
                        Layout.fillWidth: true; height: 72; radius: 10
                        color: globalBg4; border.width: 1; border.color: globalBorder1

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: SystemInfo.batteryHealth >= 0 ? SystemInfo.batteryHealth + "%" : "N/A"
                                font { pixelSize: 22; family: "Inter" }
                                font.weight: Font.Bold
                                color: SystemInfo.batteryHealth >= 80 ? root.green : root.orange
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: "Battery Health"
                                font { pixelSize: 11; family: "Inter" }
                                color: root.textLow
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    // Cycle Count tile
                    Rectangle {
                        Layout.fillWidth: true; height: 72; radius: 10
                        color: globalBg4; border.width: 1; border.color: globalBorder1

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: SystemInfo.batteryCycles >= 0 ? SystemInfo.batteryCycles : "N/A"
                                font { pixelSize: 22; family: "Inter" }
                                font.weight: Font.Bold
                                color: root.orange
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: "Charge Cycles"
                                font { pixelSize: 11; family: "Inter" }
                                color: root.textLow
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    // Condition tile
                    Rectangle {
                        Layout.fillWidth: true; height: 72; radius: 10
                        color: globalBg4; border.width: 1; border.color: globalBorder1

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: {
                                    var h = SystemInfo.batteryHealth
                                    if (h < 0) return "Unknown"
                                    if (h >= 90) return "Excellent"
                                    if (h >= 80) return "Good"
                                    if (h >= 60) return "Fair"
                                    return "Poor"
                                }
                                font { pixelSize: 18; family: "Inter" }
                                font.weight: Font.Bold
                                color: root.green
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: "Condition"
                                font { pixelSize: 11; family: "Inter" }
                                color: root.textLow
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }

                // Grid Row 2 (Est. Runtime / Status, Live Draw)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // Charging / Runtime tile
                    Rectangle {
                        Layout.fillWidth: true; height: 72; radius: 10
                        color: globalBg4; border.width: 1; border.color: globalBorder1

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: SystemInfo.batteryCharging ? "⚡" : (SystemInfo.estimatedRuntime > 0 ? Math.floor(SystemInfo.estimatedRuntime) + "h " + Math.round((SystemInfo.estimatedRuntime % 1) * 60) + "m" : "—")
                                font { pixelSize: 20; family: "Inter" }
                                font.weight: Font.Bold
                                color: root.orange
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: SystemInfo.batteryCharging ? "Charging" : "Est. Runtime"
                                font { pixelSize: 11; family: "Inter" }
                                color: root.textLow
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    // Live Draw tile
                    Rectangle {
                        Layout.fillWidth: true; height: 72; radius: 10
                        color: globalBg4; border.width: 1; border.color: globalBorder1

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: {
                                    var w = SystemInfo.powerNow / 1000000
                                    return w > 0 ? w.toFixed(1) + " W" : "—"
                                }
                                font { pixelSize: 20; family: "Inter" }
                                font.weight: Font.Bold
                                color: root.textMid
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: "Live Draw"
                                font { pixelSize: 11; family: "Inter" }
                                color: root.textLow
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: globalBorder1 }

                // Toggles Row (Battery Protection & Rapid Charge)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 14

                    // Battery Protection
                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            spacing: 3
                            Text {
                                text: "Battery Protection"
                                font { pixelSize: 13; family: "Inter" }
                                font.weight: Font.Medium
                                color: root.textHigh
                            }
                            Text {
                                text: "Charges to 100% — turn on when plugged in all day"
                                font { pixelSize: 12; family: "Inter" }
                                color: root.textLow
                            }
                        }
                        Item { Layout.fillWidth: true }
                        TitanSwitch {
                            onColor: root.accent
                            checked: SystemInfo.chargeProtectionEnabled
                            onCheckedChanged: SystemInfo.setChargeProtection(checked)
                        }
                    }

                    // Rapid Charge
                    RowLayout {
                        visible: SystemInfo.rapidChargeSupported
                        Layout.fillWidth: true
                        ColumnLayout {
                            spacing: 3
                            Text {
                                text: "Rapid Charge"
                                font { pixelSize: 13; family: "Inter" }
                                font.weight: Font.Medium
                                color: root.textHigh
                            }
                            Text {
                                text: "Charge faster than normal — generates more heat"
                                font { pixelSize: 12; family: "Inter" }
                                color: root.textLow
                            }
                        }
                        Item { Layout.fillWidth: true }
                        TitanSwitch {
                            onColor: root.accent
                            checked: SystemInfo.rapidChargeEnabled
                            onCheckedChanged: SystemInfo.setRapidCharge(checked)
                        }
                    }
                }
            }
        }

        Item { height: 28 }
    }
}
