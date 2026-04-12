#!/bin/bash

STATE="$HOME/.config/quickshell/state.json"
THEME=$(jq -r '.theme.name // "tokyonight"' "$STATE" 2>/dev/null)

if [ "$THEME" = "light" ]; then
    COLORS="$HOME/.config/rofi/colors-light.rasi"
else
    COLORS="$HOME/.config/rofi/colors-dark.rasi"
fi

rofi -show drun \
    -theme ~/.config/rofi/theme.rasi \
    -theme-str "@import \"$COLORS\""
