import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import ArchTitanSettings

ApplicationWindow {
    id: root
    width: 1180
    height: 760
    minimumWidth: 960
    minimumHeight: 620
    visible: true
    title: "ArchTitan Settings"
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint

    // ── Design tokens ─────────────────────────────────────────────
    readonly property color bgDeep:       "#07070F"
    readonly property color bgDark:       "#0B0B15"
    readonly property color bgPanel:      "#0F0F1A"
    readonly property color bgCard:       "#13131F"
    readonly property color bgHover:      "#1A1A2A"
    readonly property color borderAccent: "#7AA2F7"
    readonly property color borderSubtle: "#FFFFFF14"
    readonly property color borderGlow:   "#7AA2F730"
    readonly property color textPrimary:  "#E8E8F5"
    readonly property color textSecondary:"#8A94B8"
    readonly property color textAccent:   "#7AA2F7"
    readonly property color textDim:      "#555878"
    readonly property color accentBlue:   "#7AA2F7"
    readonly property color accentCyan:   "#00D4FF"
    readonly property color accentGreen:  "#9ECE6A"
    readonly property color accentRed:    "#F7768E"
    readonly property color accentOrange: "#FF9E64"
    readonly property color accentPurple: "#BB9AF7"

    readonly property int sidebarWidth: 230
    property int currentPage: 0

    readonly property var pages: [
        { name: "Appearance",  icon: "✦",  page: appearancePage  },
        { name: "Display",     icon: "⬡",  page: displayPage     },
        { name: "Network",     icon: "◈",  page: networkPage     },
        { name: "Audio",       icon: "◉",  page: audioPage       },
        { name: "Power",       icon: "⬟",  page: powerPage       },
        { name: "Security",    icon: "◆",  page: securityPage    },
        { name: "System",      icon: "⬢",  page: systemPage      },
        { name: "About",       icon: "◇",  page: aboutPage       }
    ]

    // ── Window drag ───────────────────────────────────────────────
    MouseArea {
        id: dragArea
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 60
        property point clickPos
        onPressed: (mouse) => { clickPos = Qt.point(mouse.x, mouse.y) }
        onPositionChanged: (mouse) => {
            var dx = mouse.x - clickPos.x
            var dy = mouse.y - clickPos.y
            root.x += dx; root.y += dy
        }
        z: -1
    }

    // ── Root background ───────────────────────────────────────────
    Rectangle {
        id: mainWindow
        anchors.fill: parent
        radius: 20
        color: root.bgDeep
        clip: true

        // ── Animated ambient orbs ─────────────────────────────────
        // Top-left blue orb
        Rectangle {
            id: orb1
            width: 500; height: 500
            x: -160; y: -200
            radius: 250
            color: "transparent"

            SequentialAnimation on opacity {
                running: true; loops: Animation.Infinite
                NumberAnimation { to: 0.07; duration: 4000; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0.12; duration: 4000; easing.type: Easing.InOutSine }
            }

            RadialGradient {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#7AA2F7" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }

        // Bottom-right purple orb
        Rectangle {
            id: orb2
            width: 420; height: 420
            x: root.width - 200; y: root.height - 180
            radius: 210
            color: "transparent"

            SequentialAnimation on opacity {
                running: true; loops: Animation.Infinite
                NumberAnimation { to: 0.05; duration: 5000; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0.09; duration: 5000; easing.type: Easing.InOutSine }
            }

            RadialGradient {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#BB9AF7" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }

        // Top-right cyan accent orb
        Rectangle {
            id: orb3
            width: 280; height: 280
            x: root.width - 60; y: -80
            radius: 140
            color: "transparent"
            opacity: 0.06

            RadialGradient {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#00D4FF" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }

        // ── Outer border glow ─────────────────────────────────────
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 1
            border.color: root.borderSubtle
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // ── Sidebar ───────────────────────────────────────────
            Rectangle {
                id: sidebar
                Layout.preferredWidth: root.sidebarWidth
                Layout.fillHeight: true
                color: "#09091480"
                radius: 20

                // Right-side square corners
                Rectangle {
                    anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
                    width: parent.radius
                    color: parent.color
                }

                // Right border with subtle glow
                Rectangle {
                    anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
                    width: 1
                    color: root.borderSubtle
                }

                ColumnLayout {
                    anchors { fill: parent; margins: 0 }
                    spacing: 0

                    // ── Logo area ─────────────────────────────────
                    Item {
                        Layout.fillWidth: true
                        height: 88

                        RowLayout {
                            anchors { left: parent.left; leftMargin: 24; verticalCenter: parent.verticalCenter }
                            spacing: 14

                            // Hexagon logo mark
                            Item {
                                width: 40; height: 40

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 40; height: 40; radius: 10
                                    color: Qt.rgba(root.accentBlue.r, root.accentBlue.g, root.accentBlue.b, 0.15)
                                    border.width: 1
                                    border.color: Qt.rgba(root.accentBlue.r, root.accentBlue.g, root.accentBlue.b, 0.35)

                                    SequentialAnimation on border.color {
                                        running: true; loops: Animation.Infinite
                                        ColorAnimation { to: Qt.rgba(root.accentBlue.r, root.accentBlue.g, root.accentBlue.b, 0.6); duration: 2000 }
                                        ColorAnimation { to: Qt.rgba(root.accentBlue.r, root.accentBlue.g, root.accentBlue.b, 0.25); duration: 2000 }
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "⬡"
                                    font.pixelSize: 20
                                    color: root.accentBlue
                                }
                            }

                            Column {
                                spacing: 3
                                Text {
                                    text: "ArchTitan"
                                    font { pixelSize: 15; weight: Font.Bold; family: "Inter"; letterSpacing: 0.5 }
                                }
                                Text {
                                    text: "Settings"
                                    font { pixelSize: 11; family: "Inter"; weight: Font.Light; letterSpacing: 1.5 }
                                }
                            }
                        }
                    }

                    // Divider
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16; Layout.rightMargin: 16
                        height: 1
                        color: root.borderSubtle
                    }

                    Item { height: 14 }

                    // ── Nav items ─────────────────────────────────
                    Repeater {
                        model: root.pages
                        delegate: SidebarItem {
                            Layout.fillWidth: true
                            icon: modelData.icon
                            label: modelData.name
                            active: root.currentPage === index
                            accentColor: root.accentBlue
                            bgHoverColor: root.bgHover
                            textPrimColor: root.textPrimary
                            textDimColor: root.textDim
                            onClicked: root.currentPage = index
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // ── Bottom status ─────────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16; Layout.rightMargin: 16
                        height: 1
                        color: root.borderSubtle
                    }

                    Item {
                        Layout.fillWidth: true
                        height: 64

                        Row {
                            anchors { left: parent.left; leftMargin: 22; verticalCenter: parent.verticalCenter }
                            spacing: 10

                            Rectangle {
                                width: 8; height: 8; radius: 4
                                color: root.accentGreen
                                anchors.verticalCenter: parent.verticalCenter
                                SequentialAnimation on opacity {
                                    running: true; loops: Animation.Infinite
                                    NumberAnimation { to: 0.4; duration: 1200 }
                                    NumberAnimation { to: 1.0; duration: 1200 }
                                }
                            }

                            Column {
                                spacing: 3
                                Text {
                                    text: "ArchTitan OS"
                                    font { pixelSize: 11; family: "Inter"; weight: Font.Medium }
                                    color: root.textSecondary
                                }
                                Text {
                                    text: "Settings v1.0"
                                    font { pixelSize: 10; family: "Inter" }
                                    color: root.textDim
                                    opacity: 0.7
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
                    height: 62
                    color: "transparent"

                    RowLayout {
                        anchors { fill: parent; leftMargin: 32; rightMargin: 20; topMargin: 2 }

                        Column {
                            spacing: 3
                            Text {
                                text: root.pages[root.currentPage].icon + "  " + root.pages[root.currentPage].name
                                font { pixelSize: 20; weight: Font.SemiBold; family: "Inter" }
                                color: root.textPrimary
                            }
                            Text {
                                text: "Configure your " + root.pages[root.currentPage].name.toLowerCase() + " preferences"
                                font { pixelSize: 11; family: "Inter" }
                                color: root.textDim
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // ── macOS-style window controls ────────────
                        RowLayout {
                            spacing: 10

                            Repeater {
                                model: [
                                    { color: "#FF5F57", hcolor: "#FF2D20", action: "close",    symbol: "×" },
                                    { color: "#FFBD2E", hcolor: "#FFB500", action: "minimize", symbol: "−" },
                                    { color: "#28CA41", hcolor: "#1DAF38", action: "maximize", symbol: "+" }
                                ]
                                delegate: Item {
                                    width: 14; height: 14

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 7
                                        color: wctrl.containsMouse ? modelData.hcolor : modelData.color
                                        Behavior on color { ColorAnimation { duration: 100 } }

                                        // Inner shine
                                        Rectangle {
                                            width: parent.width * 0.5; height: parent.height * 0.3
                                            x: parent.width * 0.2; y: parent.height * 0.12
                                            radius: height / 2
                                            color: "#FFFFFF"
                                            opacity: 0.3
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.symbol
                                        font { pixelSize: 10; weight: Font.Bold }
                                        color: "#00000080"
                                        visible: wctrl.containsMouse
                                    }

                                    MouseArea {
                                        id: wctrl
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (modelData.action === "close") root.close()
                                            else if (modelData.action === "minimize") root.showMinimized()
                                            else root.showMaximized()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Bottom border
                    Rectangle {
                        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                        height: 1
                        color: root.borderSubtle
                    }
                }

                // ── Page content ──────────────────────────────────
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
