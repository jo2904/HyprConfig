pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string currentProfile: "balanced"

    readonly property string icon: {
        switch (currentProfile) {
        case "performance":
            return "󰓅";
        case "power-saver":
            return "󰾆";
        default:
            return "󰾅";
        }
    }

    readonly property string label: {
        switch (currentProfile) {
        case "performance":
            return "Performance";
        case "power-saver":
            return "Power Saver";
        default:
            return "Balanced";
        }
    }

    readonly property color profileColor: {
        switch (currentProfile) {
        case "performance":
            return "#f7768e";
        case "power-saver":
            return "#9ece6a";
        default:
            return "#e0af68";
        }
    }

    Component.onCompleted: {
        getProfile.running = true;
    }

    function cycleProfile() {
        switch (currentProfile) {
        case "balanced":
            setProfile("performance");
            break;
        case "performance":
            setProfile("power-saver");
            break;
        case "power-saver":
            setProfile("balanced");
            break;
        }
    }

    function setProfile(name) {
        setProfileProc.command = ["powerprofilesctl", "set", name];
        setProfileProc.running = true;
    }

    // Get current profile
    Process {
        id: getProfile
        command: ["powerprofilesctl", "get"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                const profile = data.trim();
                if (profile)
                    root.currentProfile = profile;
            }
        }
    }

    // Set profile
    Process {
        id: setProfileProc
        running: false

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                getProfile.running = true;
            }
        }
    }

    // Poll for external changes
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: getProfile.running = true
    }
}
