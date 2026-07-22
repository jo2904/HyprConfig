#!/usr/bin/env bash
# DND géré par quickshell (NotificationService), pas mako.

qs ipc call notifications toggleDnd

if [[ "$(qs ipc call notifications dndStatus 2>/dev/null)" == "on" ]]; then
    notify-send "Ne pas déranger" "Activé" -t 2000
else
    notify-send "Ne pas déranger" "Désactivé" -t 2000
fi
