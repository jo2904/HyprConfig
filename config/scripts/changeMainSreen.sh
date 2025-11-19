#!/bin/bash

WAYBAR_DIR="$HOME/.config/waybar"
TEMP="$WAYBAR_DIR/temp.json"
CONFIG="$HOME/.config/waybar/config.json"

# Liste des écrans Hyprland
monitors=($(hyprctl monitors -j | jq -r '.[].name'))

state="$HOME/.cache/waybar-screen"

# Écran actuel
if [[ -f "$state" ]]; then
    current=$(cat "$state")
else
    current=""
fi

# Trouver le suivant
next=""
for i in "${!monitors[@]}"; do
    if [[ "${monitors[$i]}" == "$current" ]]; then
        next_index=$(( (i + 1) % ${#monitors[@]} ))
        next="${monitors[$next_index]}"
    fi
done

# Si premier lancement → prendre le premier écran de la liste
[[ -z "$next" ]] && next="${monitors[0]}"

echo "$next" > "$state"

# Recréer temp.json minimal
cat > "$TEMP" <<EOF
{
  "output": "$next",
  "include": ["$CONFIG"]
}
EOF

# Relancer Waybar
pkill waybar
waybar -c "$TEMP"
