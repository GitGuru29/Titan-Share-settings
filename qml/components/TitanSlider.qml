import QtQuick
import QtQuick.Controls.Basic
import ArchTitanSettings

Slider {
    id: root
    property color trackColor: "#1A1A2C"
    property color fillColor:  "#7AA2F7"
    property color knobColor:  "#FFFFFF"

    implicitHeight: 24

    background: Item {
        implicitHeight: 24

        // Track shadow/depth
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width; height: 6; radius: 3
            color: "#0A0A14"
        }

        // Track base
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width; height: 5; radius: 2.5
            color: root.trackColor
            border.width: 1
            border.color: "#FFFFFF08"
        }

        // Glowing fill
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: root.visualPosition * parent.width
            height: 5; radius: 2.5

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.rgba(root.fillColor.r, root.fillColor.g, root.fillColor.b, 0.7) }
                GradientStop { position: 1.0; color: root.fillColor }
            }

            Behavior on width { NumberAnimation { duration: 60 } }

            // Glow effect
            Rectangle {
                anchors { fill: parent; margins: -3 }
                radius: parent.radius + 3
                color: "transparent"
                border.width: root.pressed ? 3 : 2
                border.color: Qt.rgba(root.fillColor.r, root.fillColor.g, root.fillColor.b, root.pressed ? 0.25 : 0.12)
                Behavior on border.width { NumberAnimation { duration: 120 } }
            }
        }
    }

    handle: Item {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: 20; height: 20

        // Outer ring
        Rectangle {
            anchors.centerIn: parent
            width: root.pressed ? 24 : 20
            height: width; radius: width / 2
            color: "transparent"
            border.width: 2
            border.color: Qt.rgba(root.fillColor.r, root.fillColor.g, root.fillColor.b, root.pressed ? 0.6 : 0.35)
            Behavior on width { NumberAnimation { duration: 100 } }
            Behavior on border.color { ColorAnimation { duration: 100 } }
        }

        // Knob
        Rectangle {
            anchors.centerIn: parent
            width: root.pressed ? 10 : 14
            height: width; radius: width / 2
            color: root.knobColor
            Behavior on width { NumberAnimation { duration: 100 } }

            // Shine
            Rectangle {
                x: parent.width * 0.2; y: parent.height * 0.15
                width: parent.width * 0.4; height: parent.height * 0.3
                radius: height / 2
                color: "#FFFFFF"
                opacity: 0.5
            }
        }
    }
}
