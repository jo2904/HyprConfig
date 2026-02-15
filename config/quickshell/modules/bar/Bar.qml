pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import "../../components/"
import "../quickSettings/"
import "../notifications/"
import "../systemMonitor/"
import "../calendar/"

Scope {
    id: root

    readonly property int gapIn: 5
    readonly property int gapOut: 15

    // Écran cible pour la barre (vide = tous les écrans)
    property string targetScreen: StateService.get("bar.screen", "")

    // Mettre à jour quand le state change
    Connections {
        target: StateService
        function onStateLoaded() {
            root.targetScreen = StateService.get("bar.screen", "");
        }
    }

    // Filtrer les écrans : soit l'écran cible, soit tous
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
        // Si l'écran cible n'existe pas, utiliser le premier écran
        if (result.length === 0 && Quickshell.screens.length > 0) {
            result.push(Quickshell.screens[0]);
        }
        return result;
    }

    Variants {
        model: root.filteredScreens

        PanelWindow {
            required property var modelData

            property bool enableAutoHide: StateService.get("bar.autoHide", false)

            // NameSpace
            WlrLayershell.namespace: "qs_modules"

            // --- BAR CONFIGURATION ---
            implicitHeight: StateService.get("bar.height", 30)
            color: "transparent"
            screen: modelData

            // Overlay ensures it stays above games/fullscreen
            // WlrLayershell.layer: WlrLayer.Overlay

            // Set the exclusion mode
            exclusionMode: enableAutoHide ? ExclusionMode.Ignore : ExclusionMode.Normal

            // Ensure reserved area size when in Normal mode
            exclusiveZone: enableAutoHide ? 0 : height

            anchors {
                top: true
                left: true
                right: true
            }

            // --- AUTOHIDE LOGIC ---
            // If mouse is hovering, margin is 0 (show everything).
            // Otherwise, margin is -29 (hide, leaving 1px at the top to catch the mouse).
            margins.top: {
                if (WindowManagerService.anyModuleOpen || !enableAutoHide || mouseSensor.hovered)
                    return 0;

                return (-1 * (height - 1));
            }

            // Smooth window movement animation
            Behavior on margins.top {
                NumberAnimation {
                    duration: Config.animDuration
                    easing.type: Easing.OutExpo
                }
            }

            // --- MOUSE SENSOR ---
            // Covers the entire window. Since the window never "disappears" (only moves off-screen),
            // the remaining 1px still detects the mouse.
            HoverHandler {
                id: mouseSensor
            }

            Rectangle {
                id: barContent
                anchors.fill: parent
                color: Config.backgroundTransparentColor

                // --- LEFT ---
                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: root.gapOut
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: root.gapIn

                    Workspaces {}
                }

                // --- CENTER ---
                RowLayout {
                    anchors.centerIn: parent
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: root.gapIn

                    CalendarButton {}
                }

                // --- RIGHT ---
                RowLayout {
                    anchors.right: parent.right
                    anchors.rightMargin: root.gapOut
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: root.gapIn

                    TrayWidget {}
                    QuickSettingsButton {}
                    NotificationButton {}
                }
            }
        }
    }
}
