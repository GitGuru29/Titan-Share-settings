import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import ArchTitanSettings

ScrollView {
    id: root
    contentWidth: -1
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

    property color textHigh: globalTextHigh
    property color textMid:  globalTextMid
    property color textLow:  globalTextLow
    property color accent:   SettingsBackend.accentColor
    property color red:      "#E05C6A"
    property color purple:   "#7C6FCD"

    ColumnLayout {
        width: root.availableWidth
        spacing: 0

        Item { height: 28 }

        // ── Master output ────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Output"

            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Rectangle {
                    width: 38; height: 38; radius: 9
                    color: AudioBackend.masterMuted ? "#2E1A1A" : "#1A1A1A"
                    border.width: 1
                    border.color: AudioBackend.masterMuted ? "#4A2A2A" : "#2A2A2A"
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: AudioBackend.masterMuted ? "✕" : (AudioBackend.masterVolume > 60 ? "▮▮▮" : "▮▮")
                        font { pixelSize: AudioBackend.masterMuted ? 14 : 10; family: "Inter" }
                        font.weight: Font.Bold
                        color: AudioBackend.masterMuted ? root.red : root.textMid
                    }

                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: AudioBackend.masterMuted = !AudioBackend.masterMuted
                    }
                }

                TitanSlider {
                    Layout.fillWidth: true
                    from: 0; to: 100; stepSize: 1
                    value: AudioBackend.masterVolume
                    onValueChanged: AudioBackend.masterVolume = value
                    enabled: !AudioBackend.masterMuted
                    opacity: AudioBackend.masterMuted ? 0.3 : 1.0
                    Behavior on opacity { NumberAnimation { duration: 180 } }
                    fillColor: {
                        if (AudioBackend.masterMuted) return "#3A3A3A"
                        var v = AudioBackend.masterVolume / 100
                        return v > 0.8 ? root.red : v > 0.5 ? "#D4853A" : root.accent
                    }
                }

                Text {
                    text: AudioBackend.masterMuted ? "Muted" : (AudioBackend.masterVolume + "%")
                    font { pixelSize: 12; family: "Inter" }
                    font.weight: Font.Medium
                    color: AudioBackend.masterMuted ? root.red : root.accent
                    Layout.preferredWidth: 48
                    horizontalAlignment: Text.AlignRight
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: globalBorder1; Layout.topMargin: 6; Layout.bottomMargin: 6 }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Output Device"
                    font { pixelSize: 12; family: "Inter" }
                    color: root.textLow
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: AudioBackend.activeOutput
                    font { pixelSize: 12; family: "Inter" }
                    font.weight: Font.Medium
                    color: root.textHigh; elide: Text.ElideRight
                    Layout.maximumWidth: 280
                }
            }
        }

        Item { height: 12 }

        // ── Microphone ───────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Microphone"

            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Rectangle {
                    width: 38; height: 38; radius: 9
                    color: AudioBackend.micMuted ? "#2E1A1A" : "#1A1A1A"
                    border.width: 1
                    border.color: AudioBackend.micMuted ? "#4A2A2A" : "#2A2A2A"
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: "MIC"
                        font { pixelSize: 9; family: "Inter" }
                        font.weight: Font.Bold
                        color: AudioBackend.micMuted ? root.red : root.textMid
                    }

                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: AudioBackend.micMuted = !AudioBackend.micMuted
                    }
                }

                TitanSlider {
                    Layout.fillWidth: true
                    from: 0; to: 100; stepSize: 1
                    value: AudioBackend.micVolume
                    onValueChanged: AudioBackend.micVolume = value
                    enabled: !AudioBackend.micMuted
                    opacity: AudioBackend.micMuted ? 0.3 : 1.0
                    Behavior on opacity { NumberAnimation { duration: 180 } }
                    fillColor: AudioBackend.micMuted ? "#3A3A3A" : root.purple
                }

                Text {
                    text: AudioBackend.micMuted ? "Muted" : (AudioBackend.micVolume + "%")
                    font { pixelSize: 12; family: "Inter" }
                    font.weight: Font.Medium
                    color: AudioBackend.micMuted ? root.red : root.purple
                    Layout.preferredWidth: 48
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        Item { height: 12 }

        // ── Equalizer Profiles ───────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            title: AudioBackend.spatialAudio ? "Equalizer Profiles (Paused)" : "Equalizer Profiles"
            enabled: !AudioBackend.spatialAudio
            opacity: AudioBackend.spatialAudio ? 0.4 : 1.0
            Behavior on opacity { NumberAnimation { duration: 150 } }

            Flow {
                Layout.fillWidth: true
                spacing: 12

                Repeater {
                    model: ["Flat", "Bass Boost", "Vocal", "Electronic", "Acoustic", "Custom"]
                    delegate: Rectangle {
                        height: 32
                        width: profileLabel.implicitWidth + 32
                        radius: 16
                        property bool sel: AudioBackend.activeEqProfile === modelData
                        color: sel
                               ? (isDarkTheme ? Qt.tint(globalBg3, Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.25))
                                              : Qt.tint(globalBg3, Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.15)))
                               : globalBg4
                        border.width: 1
                        border.color: sel ? root.accent : globalBorder0
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            id: profileLabel
                            anchors.centerIn: parent
                            text: modelData
                            font { pixelSize: 12; family: "Inter" }
                            font.weight: sel ? Font.DemiBold : Font.Normal
                            color: sel ? root.textHigh : root.textMid
                        }

                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: AudioBackend.activeEqProfile = modelData
                        }
                    }
                }
            }
        }

        Item { height: AudioBackend.activeEqProfile === "Custom" ? 12 : 0 }

        // ── Custom Equalizer Sliders ─────────────────────────────
        SettingsCard {
            id: customEqCard
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            title: AudioBackend.spatialAudio ? "Custom Equalizer Settings (Paused)" : "Custom Equalizer Settings"
            visible: AudioBackend.activeEqProfile === "Custom"
            enabled: !AudioBackend.spatialAudio
            opacity: AudioBackend.spatialAudio ? 0.4 : 1.0
            Behavior on opacity { NumberAnimation { duration: 150 } }


            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: 16
                
                Text {
                    text: "Fine-tune individual frequency bands manually. Changes are applied live."
                    font { pixelSize: 12; family: "Inter" }
                    color: root.textMid
                    Layout.fillWidth: true
                }
                
                TitanButton {
                    text: "Reset to Flat"
                    primary: false
                    Layout.preferredHeight: 28
                    onClicked: AudioBackend.resetCustomGains()
                }
            }

            RowLayout {
                id: slidersRow
                Layout.fillWidth: true
                spacing: 6
                
                Repeater {
                    model: [
                        { freq: "32Hz", index: 0 },
                        { freq: "64Hz", index: 1 },
                        { freq: "125Hz", index: 2 },
                        { freq: "250Hz", index: 3 },
                        { freq: "500Hz", index: 4 },
                        { freq: "1kHz", index: 5 },
                        { freq: "2kHz", index: 6 },
                        { freq: "4kHz", index: 7 },
                        { freq: "8kHz", index: 8 },
                        { freq: "16kHz", index: 9 }
                    ]
                    
                    delegate: ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 8
                        
                        Text {
                            text: modelData.freq
                            font { pixelSize: 10; family: "Inter" }
                            font.weight: Font.Medium
                            color: root.textLow
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        Slider {
                            id: eqSlider
                            orientation: Qt.Vertical
                            from: -12.0
                            to: 12.0
                            stepSize: 0.5
                            value: AudioBackend.customGains[modelData.index] || 0.0
                            onMoved: AudioBackend.setCustomBandGain(modelData.index, value)
                            Layout.preferredHeight: 140
                            Layout.alignment: Qt.AlignHCenter
                            
                            background: Rectangle {
                                implicitWidth: 4
                                implicitHeight: 140
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: globalBorder0
                                radius: 2
                                border.color: globalBorder1
                                border.width: 1

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 10; height: 1
                                    color: globalBorder1
                                }

                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    y: eqSlider.value >= 0 
                                       ? parent.height / 2 - (eqSlider.value / 12.0) * (parent.height / 2)
                                       : parent.height / 2
                                    width: 4
                                    height: Math.abs(eqSlider.value / 12.0) * (parent.height / 2)
                                    color: root.accent
                                    radius: 2
                                }
                            }

                            handle: Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: eqSlider.topPadding + (1 - eqSlider.visualPosition) * (eqSlider.availableHeight - height)
                                width: 14; height: 14; radius: 7
                                color: root.accent
                                border.width: 1.5
                                border.color: globalBg0
                                scale: eqSlider.pressed ? 0.85 : 1.0
                                Behavior on scale { NumberAnimation { duration: 80 } }
                            }
                        }
                        
                        Text {
                            text: (eqSlider.value > 0 ? "+" : "") + eqSlider.value.toFixed(1)
                            font { pixelSize: 9; family: "Inter" }
                            font.weight: Font.DemiBold
                            color: eqSlider.value === 0 ? root.textLow : root.accent
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }

        Item { height: 12 }

        // ── Spatial Audio ─────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Spatial Audio"

            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "Virtual Stereo Widening"
                        font { pixelSize: 14; family: "Inter" }
                        font.weight: Font.Medium
                        color: root.textHigh
                    }
                    Text {
                        text: "Expands stereo image using a Haas-effect delay. Best experienced with headphones."
                        font { pixelSize: 12; family: "Inter" }
                        color: root.textMid
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }

                TitanSwitch {
                    checked: AudioBackend.spatialAudio
                    onCheckedChanged: AudioBackend.spatialAudio = checked
                }
            }

            // Width control — only visible when spatial audio is on
            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 16
                spacing: 10
                visible: AudioBackend.spatialAudio
                opacity: AudioBackend.spatialAudio ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Width"
                        font { pixelSize: 12; family: "Inter" }
                        font.weight: Font.Medium
                        color: root.textMid
                    }

                    Item { Layout.fillWidth: true }

                    // Colourful width badge
                    Rectangle {
                        width: widthBadge.implicitWidth + 16
                        height: 22; radius: 11
                        color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.18)
                        border.width: 1
                        border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.4)

                        Text {
                            id: widthBadge
                            anchors.centerIn: parent
                            text: AudioBackend.spatialWidth + "%"
                            font { pixelSize: 11; family: "Inter" }
                            font.weight: Font.DemiBold
                            color: root.accent
                        }
                    }
                }

                TitanSlider {
                    Layout.fillWidth: true
                    from: 0; to: 100; stepSize: 1
                    value: AudioBackend.spatialWidth
                    onMoved: AudioBackend.spatialWidth = value
                }

                // Width presets
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: [
                            { label: "Subtle",  val: 30  },
                            { label: "Natural", val: 60  },
                            { label: "Wide",    val: 80  },
                            { label: "Maximum", val: 100 }
                        ]
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: 28; radius: 8
                            property bool sel: AudioBackend.spatialWidth === modelData.val
                            color: sel ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.2)
                                       : globalBg4
                            border.width: 1
                            border.color: sel ? root.accent : globalBorder0
                            Behavior on color { ColorAnimation { duration: 100 } }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                font { pixelSize: 11; family: "Inter" }
                                font.weight: sel ? Font.DemiBold : Font.Normal
                                color: sel ? root.accent : root.textMid
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: AudioBackend.spatialWidth = modelData.val
                            }
                        }
                    }
                }
            }
        }

        Item { height: 12 }

        // ── Audio Visualizer ─────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Audio Visualizer"

            Item {
                Layout.fillWidth: true
                height: 72

                Row {
                    anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                    spacing: 4

                    Repeater {
                        model: 24
                        Item {
                            width: 12; height: 72
                            anchors.bottom: parent ? parent.bottom : undefined

                            property real targetH: {
                                if (AudioBackend.masterMuted) return 3;
                                var levels = AudioBackend.eqLevels;
                                if (levels && levels.length > index) {
                                    var val = levels[index];
                                    return 6 + (val / 100.0) * 60; // scale 0-100 to 6-66px
                                }
                                return 6;
                            }
                            
                            Behavior on targetH { NumberAnimation { duration: 50; easing.type: Easing.OutQuad } }

                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: parent.targetH
                                radius: 3
                                color: root.accent
                                opacity: 0.5 + (index / 24) * 0.4
                            }
                        }
                    }
                }
            }
        }

        Item { height: 24 }

        RowLayout {
            Layout.leftMargin: 24; Layout.rightMargin: 24
            Item { Layout.fillWidth: true }
            TitanButton { text: "Open Mixer"; primary: false; width: 130; onClicked: AudioBackend.openMixer() }
        }

        Item { height: 28 }
    }
}
