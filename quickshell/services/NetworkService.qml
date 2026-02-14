pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // --- WIFI PROPERTIES ---
    property var accessPoints: []
    property var savedSsids: []
    property bool wifiEnabled: true
    property string wifiInterface: ""
    property string connectingSsid: ""
    readonly property bool scanning: rescanProc.running
    readonly property string wifiIcon: {
        if (!wifiEnabled)
            return "󰤮";
        const active = getActiveNetwork();
        if (active)
            return getWifiIcon(active.signal);
        return "󰤫";
    }

    // --- ETHERNET PROPERTIES ---
    property var ethernetDevices: []  // [{device, state, connection}]
    readonly property bool ethernetConnected: {
        for (var i = 0; i < ethernetDevices.length; i++) {
            if (ethernetDevices[i].state === "connected")
                return true;
        }
        return false;
    }
    readonly property string ethernetIcon: {
        if (ethernetConnected)
            return "󰈀";  // Connected ethernet icon
        if (ethernetDevices.length > 0)
            return "󰈂";  // Disconnected ethernet icon
        return "";  // No ethernet device
    }

    // --- COMBINED SYSTEM ICON ---
    readonly property string systemIcon: {
        // Prioritize ethernet if connected
        if (ethernetConnected)
            return "󰈀";
        // Otherwise show wifi status
        return wifiIcon;
    }

    // --- FUNCTIONS ---

    function getActiveNetwork() {
        for (var i = 0; i < accessPoints.length; i++) {
            if (accessPoints[i].active === true)
                return accessPoints[i];
        }
        return null;
    }

    function getWifiIcon(signal) {
        if (signal > 80)
            return "󰤨";
        if (signal > 60)
            return "󰤥";
        if (signal > 40)
            return "󰤢";
        if (signal > 20)
            return "󰤟";
        return "󰤫";
    }

    // Status text (WiFi)
    readonly property string statusText: {
        if (!wifiEnabled)
            return "Off";

        const active = getActiveNetwork();

        // If there is an active network, return the SSID
        if (active)
            return active.ssid || "Hidden Network";

        // If enabled but not connected
        return "On";
    }

    // Status text (Ethernet)
    readonly property string ethernetStatusText: {
        for (var i = 0; i < ethernetDevices.length; i++) {
            if (ethernetDevices[i].state === "connected")
                return ethernetDevices[i].connection || ethernetDevices[i].device;
        }
        if (ethernetDevices.length > 0)
            return "Disconnected";
        return "No device";
    }

    // --- ETHERNET FUNCTIONS ---

    function connectEthernet(device) {
        console.log("Connecting ethernet:", device);
        connectEthernetProc.command = ["nmcli", "dev", "connect", device];
        connectEthernetProc.running = true;
    }

    function disconnectEthernet(device) {
        console.log("Disconnecting ethernet:", device);
        disconnectEthernetProc.command = ["nmcli", "dev", "disconnect", device];
        disconnectEthernetProc.running = true;
    }

    // --- WIFI FUNCTIONS ---

    function toggleWifi() {
        const cmd = wifiEnabled ? "off" : "on";
        toggleWifiProc.command = ["nmcli", "radio", "wifi", cmd];
        toggleWifiProc.running = true;
    }

    function scan() {
        if (!scanning)
            rescanProc.running = true;
    }

    function disconnect() {
        if (wifiInterface !== "") {
            console.log("Disconnecting interface: " + wifiInterface);
            disconnectProc.command = ["nmcli", "dev", "disconnect", wifiInterface];
            disconnectProc.running = true;
        }
    }

    function connect(ssid, password) {
        console.log("Attempting to connect to:", ssid);
        root.connectingSsid = ssid; // Mark which one we are trying

        if (password && password.length > 0) {
            connectProc.command = ["nmcli", "dev", "wifi", "connect", ssid, "password", password];
        } else {
            // Try connecting using saved profile
            connectProc.command = ["nmcli", "dev", "wifi", "connect", ssid];
        }
        connectProc.running = true;
    }

    function forget(ssid) {
        console.log("Forgetting network: " + ssid);
        forgetProc.command = ["nmcli", "connection", "delete", "id", ssid];
        forgetProc.running = true;
    }

    // Internal function to clean up failed connections
    function cleanUpBadConnection(ssid) {
        console.warn("Connection failed. Removing invalid profile for: " + ssid);
        // Uses forgetProc to delete, since it is the same logic
        forget(ssid);
    }

    // --- PROCESSES ---

    // Connection Process
    Process {
        id: connectProc

        stdout: SplitParser {
            onRead: data => console.log("[Wifi] " + data)
        }
        stderr: SplitParser {
            onRead: data => console.error("[Wifi Error] " + data)
        }

        onExited: code => {
            // If exit code is 0, success. Otherwise, there was an error (wrong password, timeout, etc).
            if (code !== 0) {
                console.error("Failed to connect. Exit code: " + code);

                // IF FAILED: Delete the created profile so it doesn't remain incorrectly marked as "Saved"
                if (root.connectingSsid !== "") {
                    root.cleanUpBadConnection(root.connectingSsid);
                }
            } else {
                console.log("Connected successfully!");
            }

            // Reset state and update lists
            root.connectingSsid = "";
            getSavedProc.running = true;
            getNetworksProc.running = true;
        }
    }

    // Detect Wifi Interface
    Process {
        id: findInterfaceProc
        command: ["nmcli", "-g", "DEVICE,TYPE", "device"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const lines = data.trim().split("\n");
                lines.forEach(line => {
                    const parts = line.split(":");
                    if (parts.length >= 2 && parts[1] === "wifi") {
                        root.wifiInterface = parts[0];
                    }
                });
            }
        }
    }

    // Status Monitor (Enabled/Disabled)
    Process {
        id: statusProc
        command: ["nmcli", "radio", "wifi"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                root.wifiEnabled = (data.trim() === "enabled");
                if (root.wifiEnabled)
                    getSavedProc.running = true;
                getNetworksProc.running = true;
            }
        }
    }

    // Toggle On/Off
    Process {
        id: toggleWifiProc
        onExited: statusProc.running = true
    }

    // Rescan (Refresh)
    Process {
        id: rescanProc
        command: ["nmcli", "dev", "wifi", "list", "--rescan", "yes"]
        onExited: getNetworksProc.running = true
    }

    // Disconnect
    Process {
        id: disconnectProc
        onExited: getNetworksProc.running = true
    }

    // Forget Network
    Process {
        id: forgetProc
        // The command is defined dynamically before running
        onExited: {
            getSavedProc.running = true;
            getNetworksProc.running = true;
        }
    }

    // Automatic Update Timer
    Timer {
        interval: 10000
        running: root.wifiEnabled
        repeat: true
        onTriggered: {
            getSavedProc.running = true;
            getNetworksProc.running = true;
        }
    }

    // List Saved Networks
    Process {
        id: getSavedProc
        command: ["nmcli", "-g", "NAME,TYPE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                var savedList = [];
                lines.forEach(line => {
                    const parts = line.split(":");
                    if (parts.length >= 2 && parts[1] === "802-11-wireless") {
                        savedList.push(parts[0]);
                    }
                });
                root.savedSsids = savedList;
            }
        }
    }

    // List Available Networks (Scan)
    Process {
        id: getNetworksProc
        command: ["nmcli", "-g", "IN-USE,SIGNAL,SSID,SECURITY,BSSID,CHAN,RATE", "dev", "wifi", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                var tempParams = [];
                const seen = new Set();

                lines.forEach(line => {
                    if (line.length < 5)
                        return;
                    // Handle escaped colons in BSSID (e.g., 20\:66\:CF\:...)
                    // Replace escaped colons with placeholder, split, then restore
                    const placeholder = "\x00";
                    const sanitized = line.replace(/\\:/g, placeholder);
                    const parts = sanitized.split(":");
                    if (parts.length < 7)
                        return;

                    const inUse = parts[0].trim() === "*";
                    const signal = parseInt(parts[1]) || 0;
                    const ssid = parts[2].replace(new RegExp(placeholder, "g"), ":");
                    const security = parts[3].replace(new RegExp(placeholder, "g"), ":");
                    // Restore colons in BSSID
                    const bssid = parts[4].replace(new RegExp(placeholder, "g"), ":");
                    const channel = parts[5];
                    const rate = parts[6];

                    if (!ssid)
                        return;

                    const isSaved = root.savedSsids.includes(ssid);

                    // If this SSID already exists, update it only if this one is active
                    if (seen.has(ssid)) {
                        if (inUse) {
                            // Replace the existing entry with the active one
                            const idx = tempParams.findIndex(ap => ap.ssid === ssid);
                            if (idx !== -1) {
                                tempParams[idx] = {
                                    ssid: ssid,
                                    signal: signal,
                                    active: true,
                                    secure: security.length > 0,
                                    securityType: security || "Open",
                                    saved: isSaved,
                                    bssid: bssid,
                                    channel: channel,
                                    rate: rate
                                };
                            }
                        }
                        return;
                    }
                    seen.add(ssid);

                    tempParams.push({
                        ssid: ssid,
                        signal: signal,
                        active: inUse,
                        secure: security.length > 0,
                        securityType: security || "Open",
                        saved: isSaved,
                        bssid: bssid,
                        channel: channel,
                        rate: rate
                    });
                });

                // Sort: Connected > Saved > Signal
                tempParams.sort((a, b) => {
                    if (a.active)
                        return -1;
                    if (b.active)
                        return 1;
                    if (a.saved && !b.saved)
                        return -1;
                    if (!a.saved && b.saved)
                        return 1;
                    return b.signal - a.signal;
                });

                root.accessPoints = tempParams;
            }
        }
    }

    // ========================================================================
    // ETHERNET PROCESSES
    // ========================================================================

    // Detect Ethernet devices and their status
    Process {
        id: getEthernetProc
        command: ["nmcli", "-g", "DEVICE,TYPE,STATE,CONNECTION", "device", "status"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                var devices = [];
                lines.forEach(line => {
                    const parts = line.split(":");
                    if (parts.length >= 3 && parts[1] === "ethernet") {
                        devices.push({
                            device: parts[0],
                            state: parts[2],
                            connection: parts[3] || ""
                        });
                    }
                });
                root.ethernetDevices = devices;
            }
        }
    }

    // Ethernet status update timer
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: getEthernetProc.running = true
    }

    // Connect Ethernet
    Process {
        id: connectEthernetProc
        onExited: getEthernetProc.running = true
    }

    // Disconnect Ethernet
    Process {
        id: disconnectEthernetProc
        onExited: getEthernetProc.running = true
    }
}
