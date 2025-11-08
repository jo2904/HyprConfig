#!/usr/bin/env bash

# Vérifie le mode actuel
current_mode=$(makoctl mode)

if [[ "$current_mode" == "do-not-disturb" ]]; then
    # Si on est en mode DND, repasser en normal
    makoctl mode normal
    notify-send "Notifications" "Mode Normal activé"
else
    # Sinon, passer en mode DND
    makoctl mode do-not-disturb
    notify-send "Notifications" "Mode Ne pas déranger activé"
fi
