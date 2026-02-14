pragma ComponentBehavior: Bound
import QtQuick
import qs.config
import qs.services

BarButton {
    id: root

    contentItem: volumeIcon

    onClicked: AudioService.toggleMute()

    // Scroll to change volume
    WheelHandler {
        onWheel: event => {
            if (event.angleDelta.y > 0)
                AudioService.increaseVolume();
            else if (event.angleDelta.y < 0)
                AudioService.decreaseVolume();
        }
    }

    Text {
        id: volumeIcon
        anchors.centerIn: parent
        text: AudioService.systemIcon
        font.family: Config.font
        font.pixelSize: Config.fontSizeIcon
        color: AudioService.muted ? Config.subtextColor : Config.textColor

        Behavior on color {
            ColorAnimation { duration: Config.animDuration }
        }
    }
}
