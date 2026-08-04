#!/bin/bash

WAYBAR_DIR="$HOME/.config/waybar"
TEMP="$WAYBAR_DIR/temp.json"

# Récupérer les moniteurs Hyprland
monitors=$(hyprctl monitors -j)

# Choisir le meilleur écran :
# 1. Trier par surface (desc)
# 2. Si égalité → eDP-1 est mis en dernier
best=$(echo "$monitors" | jq -r '
    map({
        name: .name,
        area: (.width * .height),
        is_edp: (.name == "eDP-1")
    })
    | sort_by(-.area, .is_edp)
    | .[0].name
')

# Générer un fichier minimal temp.json
cat > "$TEMP" <<EOF
{
  "output": "AUTO",
  "include": ["$HOME/.config/waybar/config.json"]
}
EOF

# Modifier output = best
tmp=$(mktemp)
jq --arg out "$best" '.output = $out' "$TEMP" > "$tmp"
mv "$tmp" "$TEMP"

# Relancer waybar
pkill waybar
waybar -c "$TEMP"
