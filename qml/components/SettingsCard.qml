import QtQuick
import QtQuick.Layouts
import ArchTitanSettings

Rectangle {
    id: root
    color: "#0F0F1B"
    radius: 14
    border.width: 1
    border.color: hover.containsMouse ? "#FFFFFF1E" : "#FFFFFF0C"
    implicitHeight: column.implicitHeight + 40
    clip: true

    Behavior on border.color { ColorAnimation { duration: 200 } }

    default property alias content: column.children
    property string title: ""
    property string headerIcon: ""

    // ── Lift on hover ─────────────────────────────────────────────
    property real hoverScale: 1.0
    scale: hoverScale
    Behavior on hoverScale { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }

    // ── Glass gradient overlay ────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#FFFFFF07" }
            GradientStop { position: 0.4; color: "#FFFFFF03" }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    // ── Top shimmer line ──────────────────────────────────────────
    Rectangle {
        anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: 1; leftMargin: 1; rightMargin: 1 }
        height: 1
        radius: parent.parent.radius
        color: "#FFFFFF12"
    }

    ColumnLayout {
        id: column
        anchors { fill: parent; margins: 22 }
        spacing: 0

        // ── Optional title row ────────────────────────────────────
        RowLayout {
            visible: root.title !== ""
            Layout.fillWidth: true
            Layout.bottomMargin: 16
            spacing: 8

            Text {
                text: root.headerIcon
                font.pixelSize: 11
                visible: root.headerIcon !== ""
                color: "#7AA2F7"
            }

            Text {
                text: root.title
                font {
                    pixelSize: 10
                    weight: Font.Bold
                    family: "Inter"
                    letterSpacing: 1.8
                }
                color: "#4A5070"
            }

            Item { Layout.fillWidth: true }

            // Title accent dot
            Rectangle {
                width: 4; height: 4; radius: 2
                color: "#7AA2F740"
                visible: root.title !== ""
            }
        }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hoverScale = 1.005
        onExited:  root.hoverScale = 1.0
    }
}
