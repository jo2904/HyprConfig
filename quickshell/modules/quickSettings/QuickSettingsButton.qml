pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import "../../components/"
import "../systemMonitor/"

BarButton {
    id: root

    active: quickSettingsWindow.visible
    contentItem: iconsLayout
    onClicked: quickSettingsWindow.visible = !quickSettingsWindow.visible

    RowLayout {
        id: iconsLayout
        anchors.centerIn: parent
        spacing: Config.spacing

        property color iconColor: root.active ? Config.accentColor : Config.textColor

        Behavior on iconColor {
            ColorAnimation {
                duration: Config.animDuration
            }
        }

        // SystemMonitor icon
        Text {
            text: "󰍛"
            font.family: Config.font
            font.pixelSize: Config.fontSizeLarge
            color: monitorWindow.visible ? Config.accentColor : iconsLayout.iconColor

            TapHandler {
                onTapped: monitorWindow.visible = !monitorWindow.visible
            }
        }

        // Audio icon
        Text {
            text: AudioService.systemIcon
            font.family: Config.font
            font.pixelSize: Config.fontSizeLarge
            color: AudioService.muted ? Config.subtextColor : iconsLayout.iconColor

            TapHandler {
                onTapped: AudioService.toggleMute()
            }

            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: event => {
                    if (event.angleDelta.y > 0)
                        AudioService.increaseVolume();
                    else if (event.angleDelta.y < 0)
                        AudioService.decreaseVolume();
                }
            }
        }

        WifiIcon {
            color: iconsLayout.iconColor
        }
        BluetoothIcon {
            color: iconsLayout.iconColor
        }
        BatteryIcon {
            color: iconsLayout.iconColor
        }
    }

    SystemMonitorWindow {
        id: monitorWindow
        visible: false
    }

    QuickSettingsWindow {
        id: quickSettingsWindow
        visible: false
    }
}
