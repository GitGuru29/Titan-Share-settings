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

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                // ── Level row ────────────────────────────────────
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
                            text: SystemInfo.batteryCharging ? "⚡  Charging" : (SystemInfo.acConnected ? "🔌  Plugged In" : "🔋  On Battery")
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

                // ── Divider ──────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true; height: 1
                    color: globalBorder1
                    Layout.topMargin: 16; Layout.bottomMargin: 16
                }

                // ── Health & Cycles row ──────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // Battery Health tile
                    Rectangle {
                        Layout.fillWidth: true; height: 72; radius: 10
                        color: globalBg4
                        border.width: 1
                        border.color: {
                            var h = SystemInfo.batteryHealth
                            if (h < 0) return globalBorder1
                            return h >= 80 ? Qt.rgba(0.30, 0.69, 0.51, 0.45)
                                 : h >= 50 ? Qt.rgba(0.83, 0.52, 0.23, 0.45)
                                           : Qt.rgba(0.88, 0.36, 0.42, 0.45)
                        }
                        Behavior on border.color { ColorAnimation { duration: 400 } }

                        Column {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: SystemInfo.batteryHealth >= 0 ? SystemInfo.batteryHealth + "%" : "N/A"
                                font { pixelSize: 22; family: "Inter" }
                                font.weight: Font.Bold
                                color: {
                                    var h = SystemInfo.batteryHealth
                                    if (h < 0) return root.textLow
                                    return h >= 80 ? root.green : h >= 50 ? root.orange : root.red
                                }
                                Behavior on color { ColorAnimation { duration: 400 } }
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Battery Health"
                                font { pixelSize: 11; family: "Inter" }
                                color: root.textLow
                            }
                        }
                    }

                    // Cycle Count tile
                    Rectangle {
                        Layout.fillWidth: true; height: 72; radius: 10
                        color: globalBg4
                        border.width: 1
                        border.color: {
                            var c = SystemInfo.batteryCycles
                            if (c < 0) return globalBorder1
                            return c < 300  ? Qt.rgba(0.30, 0.69, 0.51, 0.45)
                                 : c < 700  ? Qt.rgba(0.83, 0.52, 0.23, 0.45)
                                            : Qt.rgba(0.88, 0.36, 0.42, 0.45)
                        }
                        Behavior on border.color { ColorAnimation { duration: 400 } }

                        Column {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: SystemInfo.batteryCycles >= 0 ? SystemInfo.batteryCycles : "N/A"
                                font { pixelSize: 22; family: "Inter" }
                                font.weight: Font.Bold
                                color: {
                                    var c = SystemInfo.batteryCycles
                                    if (c < 0) return root.textLow
                                    return c < 300 ? root.green : c < 700 ? root.orange : root.red
                                }
                                Behavior on color { ColorAnimation { duration: 400 } }
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Charge Cycles"
                                font { pixelSize: 11; family: "Inter" }
                                color: root.textLow
                            }
                        }
                    }

                    // Health description tile
                    Rectangle {
                        Layout.fillWidth: true; height: 72; radius: 10
                        color: globalBg4
                        border.width: 1; border.color: globalBorder1

                        Column {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: {
                                    var h = SystemInfo.batteryHealth
                                    if (h < 0) return "Unknown"
                                    if (h >= 90) return "Excellent"
                                    if (h >= 80) return "Good"
                                    if (h >= 60) return "Fair"
                                    if (h >= 40) return "Poor"
                                    return "Replace"
                                }
                                font { pixelSize: 18; family: "Inter" }
                                font.weight: Font.SemiBold
                                color: {
                                    var h = SystemInfo.batteryHealth
                                    if (h < 0) return root.textLow
                                    return h >= 80 ? root.green : h >= 50 ? root.orange : root.red
                                }
                                Behavior on color { ColorAnimation { duration: 400 } }
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Condition"
                                font { pixelSize: 11; family: "Inter" }
                                color: root.textLow
                            }
                        }
                    }
                }

                // ── Est. Runtime + Live Wattage row ──────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Layout.topMargin: 12

                    // Estimated Runtime tile
                    Rectangle {
                        Layout.fillWidth: true; height: 72; radius: 10
                        color: globalBg4
                        border.width: 1
                        border.color: {
                            var r = SystemInfo.estimatedRuntime
                            if (r < 0) return globalBorder1        // charging
                            return r >= 2.0 ? Qt.rgba(0.30, 0.69, 0.51, 0.45)
                                 : r >= 1.0 ? Qt.rgba(0.83, 0.52, 0.23, 0.45)
                                            : Qt.rgba(0.88, 0.36, 0.42, 0.45)
                        }
                        Behavior on border.color { ColorAnimation { duration: 400 } }

                        Column {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: {
                                    var r = SystemInfo.estimatedRuntime
                                    if (r < 0) return "⚡"
                                    var h = Math.floor(r)
                                    var m = Math.round((r - h) * 60)
                                    return h + "h " + m + "m"
                                }
                                font { pixelSize: 20; family: "Inter" }
                                font.weight: Font.Bold
                                color: {
                                    var r = SystemInfo.estimatedRuntime
                                    if (r < 0) return root.accent
                                    return r >= 2.0 ? root.green : r >= 1.0 ? root.orange : root.red
                                }
                                Behavior on color { ColorAnimation { duration: 400 } }
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: SystemInfo.estimatedRuntime < 0 ? "Charging" : "Est. Runtime"
                                font { pixelSize: 11; family: "Inter" }
                                color: root.textLow
                            }
                        }
                    }

                    // Live Power Draw tile
                    Rectangle {
                        Layout.fillWidth: true; height: 72; radius: 10
                        color: globalBg4
                        border.width: 1
                        border.color: {
                            var w = SystemInfo.powerNow / 1000000
                            if (w <= 0) return globalBorder1
                            return w < 10 ? Qt.rgba(0.30, 0.69, 0.51, 0.45)
                                 : w < 20 ? Qt.rgba(0.83, 0.52, 0.23, 0.45)
                                          : Qt.rgba(0.88, 0.36, 0.42, 0.45)
                        }
                        Behavior on border.color { ColorAnimation { duration: 400 } }

                        Column {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: {
                                    var w = SystemInfo.powerNow / 1000000
                                    return w > 0 ? w.toFixed(1) + " W" : "—"
                                }
                                font { pixelSize: 20; family: "Inter" }
                                font.weight: Font.Bold
                                color: {
                                    var w = SystemInfo.powerNow / 1000000
                                    if (w <= 0) return root.textLow
                                    return w < 10 ? root.green : w < 20 ? root.orange : root.red
                                }
                                Behavior on color { ColorAnimation { duration: 400 } }
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Live Draw"
                                font { pixelSize: 11; family: "Inter" }
                                color: root.textLow
                            }
                        }
                    }
                }


                // ── Battery Protection (universal — adapts to hardware) ──
                Loader {
                    id: batteryProtectLoader
                    Layout.fillWidth: true

                    sourceComponent: Component {
                        ColumnLayout {
                            spacing: 0

                            Rectangle {
                                Layout.fillWidth: true; height: 1
                                color: globalBorder1
                                Layout.topMargin: 16; Layout.bottomMargin: 16
                            }

                            // Content for SUPPORTED hardware
                            ColumnLayout {
                                visible: SystemInfo.chargeProtectionSupported
                                Layout.fillWidth: true
                                spacing: 0

                                // Header row
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 12

                                    Column {
                                        spacing: 4
                                        Layout.fillWidth: true

                                    Text {
                                        text: "Battery Protection"
                                        font { pixelSize: 13; family: "Inter" }
                                        font.weight: Font.Medium
                                        color: root.textHigh
                                    }
                                    Text {
                                        text: {
                                            var m = SystemInfo.chargeProtectionMode
                                            if (m === "threshold")
                                                return "Stop charging at a set % to extend long-term battery life"
                                            if (m === "conservation")
                                                return SystemInfo.chargeProtectionEnabled
                                                    ? "Charging capped at ~60% — battery lifespan protected"
                                                    : "Charges to 100% — turn on when plugged in all day"
                                            if (m === "asus_mode")
                                                return "ASUS ROG charge mode — Balanced protects long-term capacity"
                                            return ""
                                        }
                                        font { pixelSize: 11; family: "Inter" }
                                        color: SystemInfo.chargeProtectionEnabled ? root.green : root.textMid
                                        Behavior on color { ColorAnimation { duration: 300 } }
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }
                                }

                                // Toggle pill — only for binary (conservation) mode
                                Rectangle {
                                    visible: SystemInfo.chargeProtectionMode === "conservation"
                                    width: 44; height: 24; radius: 12
                                    color: SystemInfo.chargeProtectionEnabled
                                           ? Qt.rgba(0.30, 0.69, 0.51, 0.85)
                                           : globalBg4
                                    border.width: 1
                                    border.color: SystemInfo.chargeProtectionEnabled ? "#4CAF82" : globalBorder0
                                    Behavior on color      { ColorAnimation { duration: 220 } }
                                    Behavior on border.color { ColorAnimation { duration: 220 } }

                                    Rectangle {
                                        width: 18; height: 18; radius: 9
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: SystemInfo.chargeProtectionEnabled ? parent.width - width - 3 : 3
                                        color: "white"
                                        Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: SystemInfo.setChargeProtection(!SystemInfo.chargeProtectionEnabled)
                                    }
                                }
                            }

                            // ── Threshold mode: % chips (ThinkPad, ASUS, Samsung, Framework…) ──
                            Flow {
                                visible: SystemInfo.chargeProtectionMode === "threshold"
                                Layout.fillWidth: true
                                spacing: 8
                                Layout.topMargin: 10

                                Repeater {
                                    model: [60, 70, 80, 85, 90, 95, 100]
                                    delegate: Rectangle {
                                        height: 28
                                        width: chipLabel.implicitWidth + 24
                                        radius: 6
                                        property bool sel: SystemInfo.chargeLimit === modelData
                                        color: sel
                                               ? (isDarkTheme
                                                   ? Qt.tint(globalBg3, Qt.rgba(root.green.r, root.green.g, root.green.b, 0.25))
                                                   : Qt.tint(globalBg3, Qt.rgba(root.green.r, root.green.g, root.green.b, 0.15)))
                                               : globalBg4
                                        border.width: 1
                                        border.color: sel ? "#4CAF82" : globalBorder0
                                        Behavior on color { ColorAnimation { duration: 120 } }

                                        Text {
                                            id: chipLabel
                                            anchors.centerIn: parent
                                            text: modelData === 100 ? "100%  (Off)" : modelData + "%"
                                            font { pixelSize: 12; family: "Inter" }
                                            font.weight: sel ? Font.DemiBold : Font.Normal
                                            color: sel ? root.green : root.textMid
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SystemInfo.setChargeLimit(modelData)
                                        }
                                    }
                                }
                            }

                            // ── ASUS ROG mode: 3-way chips ──────────────────
                            Flow {
                                visible: SystemInfo.chargeProtectionMode === "asus_mode"
                                Layout.fillWidth: true
                                spacing: 8
                                Layout.topMargin: 10

                                Repeater {
                                    model: [
                                        { label: "🍃  Balanced (~80%)",   mode: 0 },
                                        { label: "🔋  Full Charge",       mode: 1 },
                                        { label: "⚡  Gaming (Always on)", mode: 2 }
                                    ]
                                    delegate: Rectangle {
                                        height: 28
                                        width: asusLabel.implicitWidth + 24
                                        radius: 6
                                        property bool sel: SystemInfo.asusChargeMode === modelData.mode
                                        color: sel
                                               ? Qt.tint(globalBg3, Qt.rgba(root.accent.r, root.accent.g, root.accent.b, isDarkTheme ? 0.25 : 0.15))
                                               : globalBg4
                                        border.width: 1
                                        border.color: sel ? root.accent : globalBorder0
                                        Behavior on color { ColorAnimation { duration: 120 } }

                                        Text {
                                            id: asusLabel
                                            anchors.centerIn: parent
                                            text: modelData.label
                                            font { pixelSize: 12; family: "Inter" }
                                            font.weight: sel ? Font.DemiBold : Font.Normal
                                            color: sel ? root.textHigh : root.textMid
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SystemInfo.setAsusChargeMode(modelData.mode)
                                        }
                                    }
                                }
                            }

                            // Active hint card
                            Rectangle {
                                visible: SystemInfo.chargeProtectionEnabled
                                Layout.fillWidth: true
                                height: protHintCol.implicitHeight + 16
                                radius: 8
                                color: Qt.rgba(0.30, 0.69, 0.51, isDarkTheme ? 0.10 : 0.07)
                                border.width: 1
                                border.color: Qt.rgba(0.30, 0.69, 0.51, 0.30)
                                Layout.topMargin: 10

                                Column {
                                    id: protHintCol
                                    anchors { left: parent.left; right: parent.right; margins: 12; verticalCenter: parent.verticalCenter }
                                    spacing: 2

                                    Text {
                                        text: {
                                            var m = SystemInfo.chargeProtectionMode
                                            if (m === "threshold")  return "🍃  Charging stops at " + SystemInfo.chargeLimit + "%"
                                            if (m === "conservation") return "🍃  Conservation mode is ON"
                                            if (m === "asus_mode" && SystemInfo.asusChargeMode === 0) return "🍃  ASUS Balanced mode — capped at ~80%"
                                            return "🍃  Battery protection is active"
                                        }
                                        font { pixelSize: 12; family: "Inter" }
                                        font.weight: Font.Medium
                                        color: root.green
                                    }
                                    Text {
                                        text: "Battery is being protected. Ideal when plugged in for long periods."
                                        font { pixelSize: 11; family: "Inter" }
                                        color: root.textMid
                                        wrapMode: Text.WordWrap
                                        width: parent.width
                                    }
                                }
                                }
                            }
                            
                            // Content for UNSUPPORTED hardware
                            ColumnLayout {
                                visible: !SystemInfo.chargeProtectionSupported
                                Layout.fillWidth: true
                                spacing: 12

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 12

                                    Column {
                                        spacing: 4
                                        Layout.fillWidth: true

                                        Text {
                                            text: "Battery Protection"
                                            font { pixelSize: 13; family: "Inter" }
                                            font.weight: Font.Medium
                                            color: root.textMid
                                        }
                                        Text {
                                            text: "Hardware not supported"
                                            font { pixelSize: 11; family: "Inter" }
                                            color: root.textLow
                                        }
                                    }
                                }
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: unsuppHintCol.implicitHeight + 20
                                    radius: 8
                                    color: Qt.rgba(root.textLow.r, root.textLow.g, root.textLow.b, isDarkTheme ? 0.05 : 0.03)
                                    border.width: 1
                                    border.color: Qt.rgba(root.textLow.r, root.textLow.g, root.textLow.b, 0.15)
                                    
                                    RowLayout {
                                        id: unsuppHintCol
                                        anchors { left: parent.left; right: parent.right; margins: 12; verticalCenter: parent.verticalCenter }
                                        spacing: 12
                                        
                                        Text {
                                            text: "⚠"
                                            font.pixelSize: 16
                                            color: root.textMid
                                            Layout.alignment: Qt.AlignTop
                                        }
                                        
                                        Column {
                                            Layout.fillWidth: true
                                            spacing: 4
                                            
                                            Text {
                                                text: "Feature Unavailable"
                                                font { pixelSize: 12; family: "Inter" }
                                                font.weight: Font.Medium
                                                color: root.textMid
                                            }
                                            Text {
                                                text: "Your device does not meet the minimum hardware requirements or lacks the necessary ACPI/sysfs interfaces for advanced battery protection."
                                                font { pixelSize: 11; family: "Inter" }
                                                color: root.textLow
                                                wrapMode: Text.WordWrap
                                                width: parent.width
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Rapid Charge toggle (Lenovo IdeaPad only for now) ───
                Loader {
                    id: rapidChargeLoader
                    Layout.fillWidth: true
                    active: SystemInfo.rapidChargeSupported

                    sourceComponent: Component {
                        ColumnLayout {
                            spacing: 0

                            Rectangle {
                                Layout.fillWidth: true; height: 1
                                color: globalBorder1
                                Layout.topMargin: 16; Layout.bottomMargin: 16
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                Column {
                                    spacing: 4
                                    Layout.fillWidth: true
                                    Text {
                                        text: "Rapid Charge"
                                        font { pixelSize: 13; family: "Inter" }
                                        font.weight: Font.Medium
                                        color: root.textHigh
                                    }
                                    Text {
                                        text: "Charge faster than normal — generates more heat"
                                        font { pixelSize: 11; family: "Inter" }
                                        color: root.textMid
                                    }
                                }

                                Rectangle {
                                    width: 44; height: 24; radius: 12
                                    color: SystemInfo.rapidChargeEnabled
                                           ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.85)
                                           : globalBg4
                                    border.width: 1
                                    border.color: SystemInfo.rapidChargeEnabled ? root.accent : globalBorder0
                                    Behavior on color       { ColorAnimation { duration: 220 } }
                                    Behavior on border.color { ColorAnimation { duration: 220 } }

                                    Rectangle {
                                        width: 18; height: 18; radius: 9
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: SystemInfo.rapidChargeEnabled ? parent.width - width - 3 : 3
                                        color: "white"
                                        Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: SystemInfo.setRapidCharge(!SystemInfo.rapidChargeEnabled)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Item { height: 28 }
    }
}
