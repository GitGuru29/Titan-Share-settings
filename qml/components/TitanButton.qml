import QtQuick
import QtQuick.Controls.Basic
import ArchTitanSettings

Rectangle {
    id: root
    height: 38
    radius: 10
    implicitWidth: label.implicitWidth + 40

    property string text: "Button"
    property bool primary: true
    property color accentColor: "#7AA2F7"

    // ── Dynamic color ─────────────────────────────────────────────
    color: "transparent"
    Behavior on opacity { NumberAnimation { duration: 150 } }

    // ── Primary gradient fill ─────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        visible: root.primary
        opacity: root.enabled ? (hover.pressed ? 0.85 : (hover.containsMouse ? 1.0 : 0.9)) : 0.3
        Behavior on opacity { NumberAnimation { duration: 120 } }

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.lighter(root.accentColor, hover.containsMouse ? 1.15 : 1.0) }
            GradientStop { position: 1.0; color: Qt.rgba(root.accentColor.r * 0.7, root.accentColor.g * 0.7, root.accentColor.b, 1.0) }
        }
    }

    // ── Secondary outline fill ────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        visible: !root.primary
        color: hover.containsMouse ? "#1E1E30" : "#14141E"
        border.width: 1
        border.color: hover.containsMouse ? "#FFFFFF22" : "#FFFFFF12"
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    // ── Top shimmer ───────────────────────────────────────────────
    Rectangle {
        anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: 1; leftMargin: 1; rightMargin: 1 }
        height: 1; radius: 10
        color: root.primary ? "#FFFFFF30" : "#FFFFFF0A"
        visible: root.enabled
    }

    // ── Glow shadow for primary ───────────────────────────────────
    Rectangle {
        anchors { fill: parent; margins: -4 }
        radius: parent.radius + 4
        color: "transparent"
        border.width: hover.containsMouse && root.primary ? 2 : 0
        border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.3)
        visible: root.primary && root.enabled
        Behavior on border.width { NumberAnimation { duration: 200 } }
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        font { pixelSize: 13; weight: Font.SemiBold; family: "Inter"; letterSpacing: 0.3 }
        color: root.primary ? "#FFFFFF" : "#C0C8E0"
        opacity: root.enabled ? 1.0 : 0.35
    }

    scale: hover.pressed ? 0.96 : 1.0
    Behavior on scale { NumberAnimation { duration: 90 } }

    signal clicked()

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
        enabled: root.enabled
    }
}
