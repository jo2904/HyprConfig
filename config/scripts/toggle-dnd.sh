#!/usr/bin/env bash

# Vérifie le mode actuel
current_mode=$(makoctl mode)

if [[ "$current_mode" == "do-not-disturb" ]]; then
    makoctl mode normal
    notify-send "Ne pas déranger" "Désactivé" -t 2000
else
    makoctl mode do-not-disturb
    notify-send "Ne pas déranger" "Activé" -t 2000
fi
