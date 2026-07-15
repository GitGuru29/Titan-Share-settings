import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import ArchTitanSettings


ApplicationWindow {
    id: root
    width: 1160
    height: 740
    minimumWidth: 920
    minimumHeight: 580
    visible: true
    title: "ArchTitan Settings"
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint

    // ── Design tokens ──────────────────────────────────────────────
    readonly property bool isDarkTheme: WallpaperManager.isDark

    readonly property color globalBg0:          isDarkTheme ? "#0D0D0D" : "#F5F5F5"
    readonly property color globalBg1:          isDarkTheme ? "#B3111111" : "#B3FFFFFF"
    readonly property color globalBg2:          isDarkTheme ? "#99171717" : "#99E5E5E5"
    readonly property color globalBg3:          isDarkTheme ? "#161616" : "#EAEAEA"
    readonly property color globalBg4:          isDarkTheme ? "#242424" : "#DDDDDD"
    readonly property color globalBorder0:      isDarkTheme ? "#2A2A2A" : "#CCCCCC"
    readonly property color globalBorder1:      isDarkTheme ? "#1F1F1F" : "#E0E0E0"
    readonly property color globalTextHigh:     isDarkTheme ? "#EBEBEB" : "#111111"
    readonly property color globalTextMid:      isDarkTheme ? "#8C8C8C" : "#444444"
    readonly property color globalTextLow:      isDarkTheme ? "#4A4A4A" : "#777777"

    readonly property color bg0:          globalBg0
    readonly property color bg1:          globalBg1
    readonly property color bg2:          globalBg2
    readonly property color bg3:          isDarkTheme ? "#1C1C1C" : "#E5E5E5"
    readonly property color bg4:          globalBg4
    readonly property color border0:      globalBorder0
    readonly property color border1:      globalBorder1
    property color accent:       SettingsBackend.accentColor
    property color accentDim:    Qt.alpha(SettingsBackend.accentColor, 0.25)
    readonly property color textHigh:     globalTextHigh
    readonly property color textMid:      globalTextMid
    readonly property color textLow:      globalTextLow
    readonly property color green:        "#4CAF82"
    readonly property color red:          "#E05C6A"
    readonly property color orange:       "#D4853A"
    readonly property color purple:       "#7C6FCD"

    readonly property int sidebarW: 220
    property int currentPage: 0

    readonly property var pages: [
        { name: "Appearance",  icon: "appearance", label: "Appearance"  },
        { name: "Display",     icon: "display",    label: "Display"      },
        { name: "Network",     icon: "network",    label: "Network"      },
        { name: "Audio",       icon: "audio",      label: "Audio"        },
        { name: "Power",       icon: "power",      label: "Power"        },
        { name: "Security",    icon: "security",   label: "Security"     },
        { name: "System",      icon: "system",     label: "System"       },
        { name: "About",       icon: "about",      label: "About"        }
    ]

    // ── Window drag ────────────────────────────────────────────────
    MouseArea {
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 52
        property point clickPos
        onPressed:  (mouse) => { clickPos = Qt.point(mouse.x, mouse.y) }
        onPositionChanged: (mouse) => {
            root.x += mouse.x - clickPos.x
            root.y += mouse.y - clickPos.y
        }
        z: -1
    }

    // ── Window shell ───────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: 12
        color: root.bg1
        clip: true

        // Outer border
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 1
            border.color: root.border0
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // ── Sidebar ───────────────────────────────────────────
            Rectangle {
                Layout.preferredWidth: root.sidebarW
                Layout.fillHeight: true
                color: root.bg2
                radius: 12

                // Square off right corners
                Rectangle {
                    anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
                    width: 12
                    color: parent.color
                }

                // Right border
                Rectangle {
                    anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
                    width: 1
                    color: root.border1
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // ── Logo ──────────────────────────────────────
                    Item {
                        Layout.fillWidth: true
                        height: 90

                        Image {
                            anchors {
                                left: parent.left; leftMargin: 10
                                right: parent.right; rightMargin: 10
                                verticalCenter: parent.verticalCenter
                            }
                            height: 70
                            source: "qrc:/ArchTitanSettings/assets/icons/LOGO.png"
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }
                    }

                    // Divider
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: root.border1
                    }

                    Item { height: 8 }

                    // ── Nav items ─────────────────────────────────
                    Repeater {
                        model: root.pages
                        delegate: SidebarItem {
                            Layout.fillWidth: true
                            iconSource: "qrc:/ArchTitanSettings/assets/icons/" + modelData.icon + ".svg"
                            label: modelData.label
                            active: root.currentPage === index
                            accent:   root.accent
                            bgActive:  root.bg3
                            bgHover:   root.bg4
                            textActive: root.textHigh
                            textNormal: root.textMid
                            onClicked: root.currentPage = index
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // ── Bottom status ─────────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: root.border1
                    }

                    Item {
                        Layout.fillWidth: true
                        height: 56

                        Row {
                            anchors {
                                left: parent.left; leftMargin: 18
                                verticalCenter: parent.verticalCenter
                            }
                            spacing: 8

                            Rectangle {
                                width: 7; height: 7; radius: 4
                                color: root.green
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                spacing: 2
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: "ArchTitan OS"
                                    font { pixelSize: 11; family: "Inter" }
                                    font.weight: Font.Medium
                                    color: root.textMid
                                }
                                Text {
                                    text: "Settings v1.0"
                                    font { pixelSize: 10; family: "Inter" }
                                    color: root.textLow
                                }
                            }
                        }
                    }
                }
            }

            // ── Content area ──────────────────────────────────────
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // ── Title bar ─────────────────────────────────────
                Rectangle {
                    id: titleBar
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    height: 52
                    color: "transparent"

                    RowLayout {
                        anchors { fill: parent; leftMargin: 28; rightMargin: 18 }

                        Column {
                            spacing: 2
                            Text {
                                text: root.pages[root.currentPage].label
                                font { pixelSize: 17; family: "Inter" }
                                font.weight: Font.DemiBold
                                color: root.textHigh
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Window controls
                        RowLayout {
                            spacing: 8

                            Repeater {
                                model: [
                                    { col: "#ED6A5E", hov: "#C9504A", act: "close",    sym: "×" },
                                    { col: "#F5BF4F", hov: "#D4A030", act: "minimize", sym: "−" },
                                    { col: "#61C554", hov: "#48A83D", act: "maximize", sym: "+" }
                                ]
                                delegate: Item {
                                    width: 13; height: 13
                                    Rectangle {
                                        anchors.fill: parent; radius: 7
                                        color: wc.containsMouse ? modelData.hov : modelData.col
                                        Behavior on color { ColorAnimation { duration: 80 } }
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.sym
                                        font.pixelSize: 9
                                        font.weight: Font.Bold
                                        color: "#00000070"
                                        visible: wc.containsMouse
                                    }
                                    MouseArea {
                                        id: wc; anchors.fill: parent; hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (modelData.act === "close")    root.close()
                                            else if (modelData.act === "minimize") root.showMinimized()
                                            else root.showMaximized()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                        height: 1
                        color: root.border1
                    }
                }

                // ── Page stack ────────────────────────────────────
                Item {
                    anchors { top: titleBar.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
                    clip: true

                    StackLayout {
                        anchors.fill: parent
                        currentIndex: root.currentPage

                        AppearancePage { id: appearancePage }
                        DisplayPage    { id: displayPage    }
                        NetworkPage    { id: networkPage    }
                        AudioPage      { id: audioPage      }
                        PowerPage      { id: powerPage      }
                        SecurityPage   { id: securityPage   }
                        SystemPage     { id: systemPage     }
                        AboutPage      { id: aboutPage      }
                    }
                }
            }
        }
    }
}
