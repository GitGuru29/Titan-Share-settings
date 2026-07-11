import QtQuick
import QtQuick.Layouts
import ArchTitanSettings

Rectangle {
    id: root
    color: "#161616"
    radius: 10
    border.width: 1
    border.color: hover.containsMouse ? "#2F2F2F" : "#1F1F1F"
    implicitHeight: col.implicitHeight + 36
    clip: true

    Behavior on border.color { ColorAnimation { duration: 150 } }

    default property alias content: col.children
    property string title: ""
    property string headerIcon: ""

    ColumnLayout {
        id: col
        anchors { fill: parent; margins: 20 }
        spacing: 0

        // Optional title
        Item {
            visible: root.title !== ""
            Layout.fillWidth: true
            height: 28

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.title.toUpperCase()
                font { pixelSize: 10; family: "Inter" }
                font.weight: Font.SemiBold
                font.letterSpacing: 1.2
                color: "#4A4A4A"
            }
        }

        // Subtle divider under title
        Rectangle {
            visible: root.title !== ""
            Layout.fillWidth: true
            height: 1
            color: "#1F1F1F"
            Layout.bottomMargin: 12
        }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}
