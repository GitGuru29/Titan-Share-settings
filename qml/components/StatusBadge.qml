import QtQuick
import ArchTitanSettings

Rectangle {
    property string text: "Active"
    property color statusColor: "#9ECE6A"

    height: 22
    radius: 11
    width: label.implicitWidth + 26
    color: Qt.rgba(statusColor.r, statusColor.g, statusColor.b, 0.12)
    border.width: 1
    border.color: Qt.rgba(statusColor.r, statusColor.g, statusColor.b, 0.35)

    Row {
        anchors.centerIn: parent
        spacing: 7

        // Pulsing dot
        Rectangle {
            width: 6; height: 6; radius: 3
            color: parent.parent.statusColor
            anchors.verticalCenter: parent.verticalCenter

            SequentialAnimation on scale {
                running: true; loops: Animation.Infinite
                NumberAnimation { to: 1.3; duration: 900; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0; duration: 900; easing.type: Easing.InOutSine }
            }

            // Glow halo
            Rectangle {
                anchors.centerIn: parent
                width: 12; height: 12; radius: 6
                color: "transparent"
                border.width: 1
                border.color: Qt.rgba(parent.parent.parent.statusColor.r,
                                      parent.parent.parent.statusColor.g,
                                      parent.parent.parent.statusColor.b, 0.3)
                SequentialAnimation on opacity {
                    running: true; loops: Animation.Infinite
                    NumberAnimation { to: 0; duration: 900 }
                    NumberAnimation { to: 1; duration: 900 }
                }
            }
        }

        Text {
            id: label
            text: parent.parent.text
            font { pixelSize: 11; family: "Inter"; weight: Font.Medium; letterSpacing: 0.3 }
            color: parent.parent.statusColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
