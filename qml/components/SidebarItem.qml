import QtQuick
import QtQuick.Layouts
import ArchTitanSettings

Item {
    id: root
    height: 40
    implicitHeight: 40

    property string iconSource: ""
    property string label: ""
    property bool   active: false
    property color  accent:     SettingsBackend.accentColor
    property color  textActive: isDarkTheme ? "#FFFFFF" : "#111111"
    property color  textNormal: isDarkTheme ? "#888890" : "#666666"

    signal clicked()

    // Background pill
    Rectangle {
        anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
        radius: 8
        color: root.active 
               ? (isDarkTheme ? "#202026" : "#E2E2EA") 
               : (hover.containsMouse ? (isDarkTheme ? "#16161A" : "#ECECEF") : "transparent")
        border.width: root.active ? 1 : 0
        border.color: isDarkTheme ? "#2C2C34" : "#D0D0DA"
        Behavior on color { ColorAnimation { duration: 150 } }

        // Left active indicator
        Rectangle {
            anchors {
                left: parent.left; leftMargin: 4
                verticalCenter: parent.verticalCenter
            }
            width: 3; height: 16; radius: 1.5
            color: root.accent
            opacity: root.active ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 26
            rightMargin: 20
        }
        spacing: 12

        Image {
            id: iconImg
            width: 16; height: 16
            source: root.iconSource
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: root.active ? 1.0 : (hover.containsMouse ? 0.75 : 0.45)
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }

        Text {
            text: root.label
            font { pixelSize: 13
                weight: root.active ? Font.Medium : Font.Normal
                family: "Inter" }
            color: root.active ? root.textActive : (hover.containsMouse ? (isDarkTheme ? "#D0D0D8" : "#333333") : root.textNormal)
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
