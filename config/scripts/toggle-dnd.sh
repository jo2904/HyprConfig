#!/usr/bin/env bash

if makoctl mode | grep -q "do-not-disturb"; then
    makoctl mode -r do-not-disturb
    notify-send "Ne pas déranger" "Désactivé" -t 2000
else
    makoctl mode -a do-not-disturb
    notify-send "Ne pas déranger" "Activé" -t 2000
fi
