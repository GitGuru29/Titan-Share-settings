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

            Rectangle { Layout.fillWidth: true; height: 1; color: "#222222"; Layout.topMargin: 6; Layout.bottomMargin: 6 }

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

        // ── EQ bars ──────────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 24; Layout.rightMargin: 24
            title: "Equalizer Preview"

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

                            property real barH: 10 + (index * 13 % 46)

                            SequentialAnimation on barH {
                                running: !AudioBackend.masterMuted
                                loops: Animation.Infinite
                                NumberAnimation { to: 6 + (index * 3 % 42); duration: 300 + (index * 37 % 240); easing.type: Easing.InOutSine }
                                NumberAnimation { to: 12 + (index * 7 % 44); duration: 260 + (index * 53 % 260); easing.type: Easing.InOutSine }
                            }

                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: AudioBackend.masterMuted ? 3 : parent.barH
                                radius: 3
                                color: root.accent
                                opacity: 0.5 + (index / 24) * 0.4
                                Behavior on height { NumberAnimation { duration: 100 } }
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
