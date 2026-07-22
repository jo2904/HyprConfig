#!/bin/bash
# Met à jour la config sans repasser par une installation complète :
# récupère les derniers changements du repo et s'assure que les liens
# symboliques + permissions sont à jour. Ne touche ni aux paquets, ni à
# SDDM, ni à systemd (voir install-env.sh pour une machine neuve).

set -eE
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

git pull

source "$REPO_DIR/link-config.sh"
link_all_apps

chmod +x "$HOME/.config/scripts/"*.sh
chmod +x "$HOME/.config/waybar/launch.sh"

echo "✅ Config à jour."
