pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
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

            readonly property HyprlandMonitor hyprMonitor: Hyprland.monitorFor(modelData)
            property bool hasFullscreenWindow: false

            function updateFullscreenState() {
                if (!hyprMonitor || !Hyprland.windows) {
                    hasFullscreenWindow = false;
                    return;
                }
                let found = false;
                for (const win of Hyprland.windows.values) {
                    if (win.fullscreen && win.monitor?.id === hyprMonitor.id) {
                        found = true;
                        break;
                    }
                }
                hasFullscreenWindow = found;
            }

            Component.onCompleted: updateFullscreenState()

            Connections {
                target: Hyprland
                function onRawEvent(event) {
                    if (!event) return;
                    if (["fullscreen", "activewindow", "workspace", "movewindow", "openwindow", "closewindow"].includes(event.name))
                        updateFullscreenState();
                }
            }

            // NameSpace
            WlrLayershell.namespace: "qs_modules"

            // --- BAR CONFIGURATION ---
            implicitHeight: StateService.get("bar.height", 30)
            color: "transparent"
            screen: modelData

            // Overlay ensures it stays above games/fullscreen
            // WlrLayershell.layer: WlrLayer.Overlay

            // Set the exclusion mode
            exclusionMode: (enableAutoHide || hasFullscreenWindow) ? ExclusionMode.Ignore : ExclusionMode.Normal

            // Ensure reserved area size when in Normal mode
            exclusiveZone: (enableAutoHide || hasFullscreenWindow) ? 0 : height

            anchors {
                top: true
                left: true
                right: true
            }

            // --- AUTOHIDE / FULLSCREEN LOGIC ---
            // Fullscreen: hide bar completely (no sentinel pixel).
            // AutoHide: leave 1px at top to catch mouse, unless a module is open.
            margins.top: {
                if (hasFullscreenWindow)
                    return -height;

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
