pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.services

Singleton {
    id: root

    // ========================================================================
    // SCHEDULE
    // 07:30 → light theme
    // 22:00 → tokyonight theme
    // hyprsunset temperatures are handled by hyprsunset.conf automatically
    // ========================================================================

    readonly property int lightHour: 7
    readonly property int lightMinute: 30
    readonly property int darkHour: 22
    readonly property int darkMinute: 0

    // Apply the right theme on startup based on current time
    Component.onCompleted: {
        applyScheduledTheme();
    }

    // Re-check every time minutes change
    Connections {
        target: TimeService

        function onMinutesChanged() {
            const h = TimeService.hours;
            const m = TimeService.minutes;

            if (h === root.darkHour && m === root.darkMinute) {
                if (ThemeService.currentThemeName !== "tokyonight")
                    ThemeService.applyTheme("tokyonight");
            } else if (h === root.lightHour && m === root.lightMinute) {
                if (ThemeService.currentThemeName !== "light")
                    ThemeService.applyTheme("light");
            }
        }
    }

    function applyScheduledTheme() {
        const h = TimeService.hours;
        const m = TimeService.minutes;
        const totalMins = h * 60 + m;
        const darkStart = root.darkHour * 60 + root.darkMinute;
        const lightStart = root.lightHour * 60 + root.lightMinute;

        // Dark: 22:00 → 07:30 (wraps midnight)
        const isDark = totalMins >= darkStart || totalMins < lightStart;
        const expected = isDark ? "tokyonight" : "light";

        if (ThemeService.currentThemeName !== expected)
            ThemeService.applyTheme(expected);
    }
}
