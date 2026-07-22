pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services

Scope {
    id: rootScope

    // Écran cible (le même que la barre) : les notifs ne s'affichent que là,
    // pas sur tous les écrans branchés.
    property string targetScreen: StateService.get("bar.screen", "")

    Connections {
        target: StateService
        function onStateLoaded() {
            rootScope.targetScreen = StateService.get("bar.screen", "");
        }
    }

    readonly property var filteredScreens: {
        if (targetScreen === "") {
            return Quickshell.screens;
        }
        let result = [];
        for (let i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === targetScreen) {
                result.push(Quickshell.screens[i]);
                break;
            }
        }
        if (result.length === 0 && Quickshell.screens.length > 0) {
            result.push(Quickshell.screens[0]);
        }
        return result;
    }

    Variants {
        model: rootScope.filteredScreens

        delegate: PanelWindow {
            id: window

            required property var modelData
            screen: modelData

            // Only shows if there are active popups
            visible: NotificationService.activePopupCount > 0

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: -1
            WlrLayershell.namespace: "qs_modules"

            anchors {
                top: true
                right: true
            }

            margins {
                top: Config.barHeight + 10
                right: 10
            }

            implicitWidth: Config.notifWidth
            implicitHeight: notifListView.contentHeight

            color: "transparent"

            // Empty mask for when there are no notifications
            Region {
                id: emptyRegion
            }

            mask: (NotificationService.activePopupCount > 0 && implicitHeight > 0) ? null : emptyRegion

            ListView {
                id: notifListView
                anchors.fill: parent

                // Uses the list of active popups
                model: NotificationService.popups

                spacing: 0
                interactive: false

                // Repositioning animation
                displaced: Transition {
                    NumberAnimation {
                        properties: "y"
                        duration: Config.animDuration
                        easing.type: Easing.OutQuad
                    }
                }

                delegate: NotificationCard {
                    required property var modelData

                    wrapper: modelData
                    popupMode: true
                }
            }
        }
    }
}
