import QtQuick
import QtQuick.Layouts
import ArchTitanSettings

Item {
    id: root
    height: 48
    implicitHeight: 48

    property string icon: ""
    property string label: ""
    property bool active: false
    property color accentColor: "#7AA2F7"
    property color bgHoverColor: "#1A1A2A"
    property color textPrimColor: "#E8E8F5"
    property color textDimColor: "#555878"

    signal clicked()

    // ── Pill-shaped active background ─────────────────────────────
    Rectangle {
        id: activeBg
        anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
        radius: 10
        opacity: root.active ? 1 : (hover.containsMouse ? 0.6 : 0)
        Behavior on opacity { NumberAnimation { duration: 180 } }

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.18) }
            GradientStop { position: 1.0; color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.04) }
        }

        // Left accent stripe
        Rectangle {
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom; topMargin: 8; bottomMargin: 8 }
            width: 3; radius: 2
            color: root.accentColor
            opacity: root.active ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        // Glow border
        border.width: root.active ? 1 : 0
        border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.25)
        Behavior on border.width { NumberAnimation { duration: 150 } }
    }

    // ── Content row ───────────────────────────────────────────────
    RowLayout {
        anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 24; right: parent.right; rightMargin: 14 }
        spacing: 13

        // Icon container
        Item {
            width: 26; height: 26

            Rectangle {
                anchors.centerIn: parent
                width: 26; height: 26; radius: 7
                color: root.active
                       ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.2)
                       : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Text {
                anchors.centerIn: parent
                text: root.icon
                font.pixelSize: 14
                color: root.active ? root.accentColor : root.textDimColor
                Behavior on color { ColorAnimation { duration: 150 } }
                opacity: root.active ? 1.0 : (hover.containsMouse ? 0.8 : 0.55)
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }
        }

        Text {
            text: root.label
            font {
                pixelSize: 13
                weight: root.active ? Font.SemiBold : Font.Normal
                family: "Inter"
            }
            color: root.active ? root.textPrimColor : root.textDimColor
            Behavior on color { ColorAnimation { duration: 150 } }
            Layout.fillWidth: true
        }

        // Active dot indicator
        Rectangle {
            width: 6; height: 6; radius: 3
            color: root.accentColor
            opacity: root.active ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
