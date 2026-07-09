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
    property color accentGreen:   "#9ECE6A"

    ColumnLayout {
        width: root.width
        spacing: 0

        Item { height: 32 }

        // ── Master volume ─────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            title: "OUTPUT"

            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                // Mute button
                Rectangle {
                    width: 42; height: 42; radius: 12
                    color: AudioBackend.masterMuted ? "#2A0E14" : "#141422"
                    border.width: 1
                    border.color: AudioBackend.masterMuted ? "#F7768E50" : "#FFFFFF10"
                    Behavior on color { ColorAnimation { duration: 200 } }

                    Text {
                        anchors.centerIn: parent
                        text: AudioBackend.masterMuted ? "🔇" : (AudioBackend.masterVolume > 60 ? "🔊" : "🔉")
                        font.pixelSize: 18
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: AudioBackend.masterMuted = !AudioBackend.masterMuted
                    }

                    scale: muteHov.containsMouse ? 1.05 : 1.0
                    Behavior on scale { NumberAnimation { duration: 120 } }

                    MouseArea {
                        id: muteHov
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
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
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    fillColor: {
                        var v = AudioBackend.masterVolume / 100
                        if (AudioBackend.masterMuted) return "#555878"
                        return v > 0.8 ? "#F7768E" : v > 0.5 ? "#E0AF68" : root.accentBlue
                    }
                }

                // Volume value pill
                Rectangle {
                    width: 60; height: 30; radius: 8
                    color: AudioBackend.masterMuted ? "#1A0810" : "#141422"
                    border.width: 1
                    border.color: AudioBackend.masterMuted ? "#F7768E30" : "#FFFFFF10"
                    Behavior on color { ColorAnimation { duration: 200 } }

                    Text {
                        anchors.centerIn: parent
                        text: AudioBackend.masterMuted ? "Muted" : (AudioBackend.masterVolume + "%")
                        font { pixelSize: 12; family: "Inter"; weight: Font.SemiBold }
                        color: AudioBackend.masterMuted ? "#F7768E" : root.accentBlue
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#FFFFFF08"; Layout.topMargin: 8; Layout.bottomMargin: 8 }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Output Device"
                    font { pixelSize: 12; family: "Inter" }
                    color: root.textDim
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: AudioBackend.activeOutput
                    font { pixelSize: 12; family: "Inter"; weight: Font.Medium }
                    color: root.textPrimary
                    elide: Text.ElideRight
                    Layout.maximumWidth: 300
                }
            }
        }

        Item { height: 14 }

        // ── Microphone ────────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            title: "MICROPHONE"

            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Rectangle {
                    width: 42; height: 42; radius: 12
                    color: AudioBackend.micMuted ? "#2A0E14" : "#141422"
                    border.width: 1
                    border.color: AudioBackend.micMuted ? "#F7768E50" : "#FFFFFF10"
                    Behavior on color { ColorAnimation { duration: 200 } }

                    Text { anchors.centerIn: parent; text: "🎙"; font.pixelSize: 18 }

                    Rectangle {
                        visible: AudioBackend.micMuted
                        anchors { right: parent.right; bottom: parent.bottom; margins: -2 }
                        width: 16; height: 16; radius: 8
                        color: "#F7768E"
                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            font { pixelSize: 9; weight: Font.Bold }
                            color: "#FFF"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
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
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    fillColor: AudioBackend.micMuted ? "#555878" : "#BB9AF7"
                }

                Rectangle {
                    width: 60; height: 30; radius: 8
                    color: AudioBackend.micMuted ? "#1A0810" : "#141422"
                    border.width: 1
                    border.color: AudioBackend.micMuted ? "#F7768E30" : "#FFFFFF10"
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Text {
                        anchors.centerIn: parent
                        text: AudioBackend.micMuted ? "Muted" : (AudioBackend.micVolume + "%")
                        font { pixelSize: 12; family: "Inter"; weight: Font.SemiBold }
                        color: AudioBackend.micMuted ? "#F7768E" : "#BB9AF7"
                    }
                }
            }
        }

        Item { height: 14 }

        // ── EQ visualizer ─────────────────────────────────────────
        SettingsCard {
            Layout.fillWidth: true
            Layout.leftMargin: 28; Layout.rightMargin: 28
            title: "EQUALIZER PREVIEW"

            Item {
                Layout.fillWidth: true
                height: 80

                // Background grid lines
                Column {
                    anchors.fill: parent
                    spacing: 0
                    Repeater {
                        model: 4
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#FFFFFF06"
                        }
                    }
                }

                Row {
                    anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                    spacing: 5

                    Repeater {
                        model: 22
                        Item {
                            width: 14
                            height: 80
                            anchors.bottom: parent ? parent.bottom : undefined

                            property real eqH: 14 + (index * 17 % 54)

                            SequentialAnimation on eqH {
                                running: !AudioBackend.masterMuted
                                loops: Animation.Infinite
                                NumberAnimation {
                                    to: 8 + (index * 3 % 50)
                                    duration: 280 + (index * 41 % 260)
                                    easing.type: Easing.InOutSine
                                }
                                NumberAnimation {
                                    to: 16 + (index * 7 % 48)
                                    duration: 240 + (index * 57 % 280)
                                    easing.type: Easing.InOutSine
                                }
                            }

                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: AudioBackend.masterMuted ? 4 : parent.eqH
                                radius: 4

                                Behavior on height { NumberAnimation { duration: 120 } }

                                gradient: Gradient {
                                    GradientStop {
                                        position: 0.0
                                        color: {
                                            var hue = index / 22
                                            return Qt.hsla(0.55 + hue * 0.15, 0.8, 0.65, 0.9)
                                        }
                                    }
                                    GradientStop { position: 1.0; color: Qt.rgba(0.48, 0.64, 0.97, 0.4) }
                                }
                            }
                        }
                    }
                }
            }
        }

        Item { height: 20 }

        RowLayout {
            Layout.leftMargin: 28; Layout.rightMargin: 28
            Item { Layout.fillWidth: true }
            TitanButton {
                text: "Open Mixer"
                primary: false; width: 160
                onClicked: AudioBackend.openMixer()
            }
        }

        Item { height: 32 }
    }
}
