import QtQuick
import QtQuick.Controls.Basic
import ArchTitanSettings

Switch {
    id: root

    property color onColor:   "#7AA2F7"
    property color offColor:  "#1A1A2C"
    property color knobColor: "#FFFFFF"

    implicitWidth: 50
    implicitHeight: 28

    indicator: Rectangle {
        width: root.implicitWidth
        height: root.implicitHeight
        radius: height / 2
        color: root.checked ? Qt.rgba(root.onColor.r, root.onColor.g, root.onColor.b, 0.25) : root.offColor
        border.width: 1
        border.color: root.checked
                      ? Qt.rgba(root.onColor.r, root.onColor.g, root.onColor.b, 0.6)
                      : "#FFFFFF14"

        Behavior on color { ColorAnimation { duration: 220 } }
        Behavior on border.color { ColorAnimation { duration: 220 } }

        // Track fill gradient
        Rectangle {
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
            width: root.checked ? parent.width : 0
            radius: parent.radius
            clip: true

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.rgba(root.onColor.r, root.onColor.g, root.onColor.b, 0.5) }
                GradientStop { position: 1.0; color: Qt.rgba(root.onColor.r, root.onColor.g, root.onColor.b, 0.15) }
            }
            Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
        }

        // Outer glow ring when on
        Rectangle {
            anchors { fill: parent; margins: -3 }
            radius: parent.radius + 3
            color: "transparent"
            border.width: root.checked ? 1 : 0
            border.color: Qt.rgba(root.onColor.r, root.onColor.g, root.onColor.b, 0.3)
            Behavior on border.width { NumberAnimation { duration: 200 } }
        }

        // Knob
        Rectangle {
            id: knob
            width: 22; height: 22
            radius: 11
            color: root.checked ? root.onColor : root.knobColor
            anchors.verticalCenter: parent.verticalCenter
            x: root.checked ? parent.width - width - 3 : 3
            Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 220 } }

            // Shine
            Rectangle {
                x: parent.width * 0.2; y: parent.height * 0.15
                width: parent.width * 0.35; height: parent.height * 0.28
                radius: height / 2
                color: "#FFFFFF"
                opacity: root.checked ? 0.35 : 0.6
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }
    }

    contentItem: Item {}
}
