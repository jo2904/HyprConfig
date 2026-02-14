#!/bin/bash

STATE_FILE="$HOME/.cache/hypr-powersave"

if [[ -f "$STATE_FILE" ]]; then
    # Désactiver le mode économie → restaurer les effets
    rm "$STATE_FILE"

    hyprctl keyword decoration:blur:enabled true
    hyprctl keyword decoration:blur:passes 3
    hyprctl keyword decoration:blur:size 14
    hyprctl keyword decoration:shadow:enabled true
    hyprctl keyword animations:enabled true

    notify-send "Mode Performance" "Effets visuels activés" -t 2000
else
    # Activer le mode économie → couper les effets coûteux
    touch "$STATE_FILE"

    hyprctl keyword decoration:blur:enabled false
    hyprctl keyword decoration:shadow:enabled false
    hyprctl keyword animations:enabled false

    notify-send "Mode Économie" "Effets visuels désactivés" -t 2000
fi
