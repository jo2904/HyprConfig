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
    implicitHeight: 300

    ColumnLayout {
        id: main
        anchors.fill: parent
        spacing: 12

        // Header
        PageHeader {
            icon: NetworkService.ethernetIcon || "󰈂"
            title: "Ethernet"
            onBackClicked: root.backRequested()
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Config.surface1Color
        }

        // Ethernet Devices List
        ListView {
            id: ethernetList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 10
            clip: true
            spacing: 8

            model: NetworkService.ethernetDevices

            delegate: DeviceCard {
                required property var modelData
                required property int index

                title: modelData.device
                subtitle: modelData.connection || modelData.state
                icon: modelData.state === "connected" ? "󰈀" : "󰈂"

                active: modelData.state === "connected"
                connecting: false
                secured: false

                statusText: {
                    if (modelData.state === "connected")
                        return "Connected";
                    if (modelData.state === "connecting")
                        return "Connecting...";
                    if (modelData.state === "unavailable")
                        return "Cable unplugged";
                    if (modelData.state === "disconnected")
                        return "Disconnected";
                    return modelData.state;
                }

                showMenu: modelData.state === "connected" || modelData.state === "disconnected"

                menuModel: {
                    var list = [];
                    if (modelData.state === "connected") {
                        list.push({
                            text: "Disconnect",
                            action: "disconnect",
                            icon: "",
                            textColor: Config.warningColor,
                            iconColor: Config.warningColor
                        });
                    } else if (modelData.state === "disconnected") {
                        list.push({
                            text: "Connect",
                            action: "connect",
                            icon: "",
                            textColor: Config.successColor,
                            iconColor: Config.successColor
                        });
                    }
                    return list;
                }

                onMenuAction: actionId => {
                    if (actionId === "disconnect") {
                        NetworkService.disconnectEthernet(modelData.device);
                    } else if (actionId === "connect") {
                        NetworkService.connectEthernet(modelData.device);
                    }
                }

                onClicked: {
                    if (modelData.state === "connected") {
                        NetworkService.disconnectEthernet(modelData.device);
                    } else if (modelData.state === "disconnected") {
                        NetworkService.connectEthernet(modelData.device);
                    }
                }
            }

            // Empty state
            Column {
                anchors.centerIn: parent
                spacing: 12
                visible: ethernetList.count === 0

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 64
                    height: 64
                    radius: 32
                    color: Config.surface1Color

                    Text {
                        anchors.centerIn: parent
                        text: "󰈂"
                        font.family: Config.font
                        font.pixelSize: 28
                        color: Config.subtextColor
                        opacity: 0.5
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "No Ethernet devices"
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeNormal
                    color: Config.subtextColor
                    opacity: 0.7
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Connect a cable or USB adapter"
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeSmall
                    color: Config.subtextColor
                    opacity: 0.5
                }
            }
        }
    }
}
