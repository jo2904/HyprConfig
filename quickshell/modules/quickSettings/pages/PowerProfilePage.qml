pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import "../../../components/"

Item {
    id: root

    signal backRequested

    Layout.fillWidth: true
    implicitHeight: main.implicitHeight

    ColumnLayout {
        id: main
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 12

        // Header
        PageHeader {
            icon: PowerProfileService.icon
            iconColor: PowerProfileService.profileColor
            title: "Power Profile"
            onBackClicked: root.backRequested()
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Config.surface1Color
        }

        // Content
        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: 10
            spacing: 16

            // Large icon
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                radius: 32
                color: Qt.alpha(PowerProfileService.profileColor, 0.2)

                Behavior on color {
                    ColorAnimation {
                        duration: Config.animDuration
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: PowerProfileService.icon
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeIconLarge
                    color: PowerProfileService.profileColor
                }
            }

            // Status
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: PowerProfileService.label
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeLarge
                    font.bold: true
                    color: Config.textColor
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Select a power profile"
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeSmall
                    color: Config.subtextColor
                }
            }

            // Profile cards
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                Repeater {
                    model: [
                        {
                            id: "performance",
                            label: "Performance",
                            description: "Maximum performance, higher power usage",
                            icon: "󰓅",
                            color: "#f7768e"
                        },
                        {
                            id: "balanced",
                            label: "Balanced",
                            description: "Balance between performance and battery",
                            icon: "󰾅",
                            color: "#e0af68"
                        },
                        {
                            id: "power-saver",
                            label: "Power Saver",
                            description: "Reduced performance, longer battery life",
                            icon: "󰾆",
                            color: "#9ece6a"
                        }
                    ]

                    delegate: Rectangle {
                        id: profileCard

                        required property var modelData
                        required property int index

                        readonly property bool isCurrent: PowerProfileService.currentProfile === modelData.id

                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        radius: Config.radius
                        color: {
                            if (cardMouse.pressed)
                                return Qt.darker(Config.surface1Color, 1.1);
                            if (cardMouse.containsMouse)
                                return Config.surface2Color;
                            return Config.surface1Color;
                        }
                        border.width: isCurrent ? 2 : 0
                        border.color: modelData.color

                        Behavior on color {
                            ColorAnimation {
                                duration: Config.animDurationShort
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 15
                            anchors.rightMargin: 15
                            spacing: 12

                            // Profile icon
                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
                                radius: Config.radius
                                color: profileCard.isCurrent ? Qt.alpha(profileCard.modelData.color, 0.2) : Config.surface2Color

                                Text {
                                    anchors.centerIn: parent
                                    text: profileCard.modelData.icon
                                    font.family: Config.font
                                    font.pixelSize: Config.fontSizeIcon
                                    color: profileCard.isCurrent ? profileCard.modelData.color : Config.subtextColor
                                }
                            }

                            // Text
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: profileCard.modelData.label
                                    font.family: Config.font
                                    font.pixelSize: Config.fontSizeNormal
                                    font.bold: true
                                    color: Config.textColor
                                }

                                Text {
                                    text: profileCard.modelData.description
                                    font.family: Config.font
                                    font.pixelSize: Config.fontSizeSmall
                                    color: Config.subtextColor
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            // Check mark
                            Text {
                                visible: profileCard.isCurrent
                                text: "󰄬"
                                font.family: Config.font
                                font.pixelSize: Config.fontSizeIcon
                                color: profileCard.modelData.color
                            }
                        }

                        MouseArea {
                            id: cardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PowerProfileService.setProfile(profileCard.modelData.id)
                        }
                    }
                }
            }
        }
    }
}
