#!/bin/bash

# Fichiers de configuration
WAYBAR_DIR="$HOME/.config/waybar"
WAYBAR_TEMP="$WAYBAR_DIR/temp.json"
WAYBAR_CONFIG="$HOME/.config/waybar/config.json"
QUICKSHELL_STATE="$HOME/.config/quickshell/state.json"

# État partagé pour le suivi de l'écran actuel
STATE_FILE="$HOME/.cache/bar-screen"

# Liste des écrans Hyprland
monitors=($(hyprctl monitors -j | jq -r '.[].name'))

# Écran actuel
if [[ -f "$STATE_FILE" ]]; then
    current=$(cat "$STATE_FILE")
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

echo "$next" > "$STATE_FILE"

# Détecter quelle barre est en cours d'exécution
if pgrep -x "waybar" > /dev/null; then
    # === WAYBAR ===
    cat > "$WAYBAR_TEMP" <<EOF
{
  "output": "$next",
  "include": ["$WAYBAR_CONFIG"]
}
EOF
    pkill waybar
    waybar -c "$WAYBAR_TEMP" &

elif pgrep -x "quickshell" > /dev/null; then
    # === QUICKSHELL ===
    # Mettre à jour state.json avec jq (FileView dans StateService détectera le changement)
    if [[ -f "$QUICKSHELL_STATE" ]]; then
        tmp=$(mktemp)
        jq --arg screen "$next" '.bar.screen = $screen' "$QUICKSHELL_STATE" > "$tmp" && mv "$tmp" "$QUICKSHELL_STATE"
    else
        mkdir -p "$(dirname "$QUICKSHELL_STATE")"
        echo "{\"bar\":{\"screen\":\"$next\"}}" > "$QUICKSHELL_STATE"
    fi

else
    echo "Aucune barre détectée (waybar ou quickshell)"
    exit 1
fi

echo "Barre déplacée vers: $next"
