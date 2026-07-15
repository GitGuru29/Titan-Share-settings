import QtQuick
import QtQuick.Layouts
import ArchTitanSettings

Item {
    id: root
    height: 44
    implicitHeight: 44

    property string iconSource: ""
    property string label: ""
    property bool   active: false
    property color  accent:     "#4C8BF5"
    property color  bgActive:   globalBg3
    property color  bgHover:    globalBg4
    property color  textActive: globalTextHigh
    property color  textNormal: globalTextMid

    signal clicked()

    // Background
    Rectangle {
        anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
        radius: 7
        color: root.active ? root.bgActive : (hover.containsMouse ? root.bgHover : "transparent")
        Behavior on color { ColorAnimation { duration: 120 } }

        // Left active indicator
        Rectangle {
            anchors {
                left: parent.left; leftMargin: -8
                top: parent.top; topMargin: 10
                bottom: parent.bottom; bottomMargin: 10
            }
            width: 3; radius: 2
            color: root.accent
            opacity: root.active ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }
    }

    RowLayout {
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left; leftMargin: 16
            right: parent.right; rightMargin: 12
        }
        spacing: 11

        // Icon — shown directly, opacity indicates active/hover state
        Image {
            width: 16; height: 16
            source: root.iconSource
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: root.active ? 1.0 : (hover.containsMouse ? 0.65 : 0.35)
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }

        Text {
            text: root.label
            font { pixelSize: 13
                weight: root.active ? Font.Medium : Font.Normal
                family: "Inter" }
            color: root.active ? root.textActive : root.textNormal
            Behavior on color { ColorAnimation { duration: 120 } }
            Layout.fillWidth: true
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
