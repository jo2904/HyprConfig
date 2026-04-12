#!/bin/bash

STATE="$HOME/.config/quickshell/state.json"
ROFI_DIR="$HOME/.config/rofi"

CURRENT=$(jq -r '.theme.name // "tokyonight"' "$STATE")

if [[ "$CURRENT" == "light" ]]; then
    NEW_THEME="tokyonight"
    cp "$ROFI_DIR/colors-dark.rasi" "$ROFI_DIR/colors.rasi"
    notify-send "Theme" "Mode nuit activé" -t 2000
else
    NEW_THEME="light"
    cp "$ROFI_DIR/colors-light.rasi" "$ROFI_DIR/colors.rasi"
    notify-send "Theme" "Mode jour activé" -t 2000
fi

jq --arg t "$NEW_THEME" '.theme.name = $t' "$STATE" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"
