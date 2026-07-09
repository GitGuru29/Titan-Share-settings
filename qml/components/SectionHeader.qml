import QtQuick
import QtQuick.Layouts
import ArchTitanSettings

Item {
    property string text: ""
    height: 36
    Layout.fillWidth: true

    Row {
        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
        spacing: 10

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: parent.parent.text.toUpperCase()
            font { pixelSize: 10; weight: Font.Bold; family: "Inter"; letterSpacing: 2.0 }
            color: "#3E4460"
        }

        // Gradient line
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: {
                var parentWidth = parent.parent.parent.width
                var textLen = parent.parent.text.length * 9 + 20
                return Math.max(0, parentWidth - textLen - 20)
            }
            height: 1
            visible: parent.parent.text !== ""

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#7AA2F720" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }
}
