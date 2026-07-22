#!/bin/bash
# Lie chaque config/<app> du repo dans ~/.config/<app> par symlink.
# Idempotent : ne touche pas aux liens déjà corrects, sauvegarde tout
# fichier/dossier réel préexistant au lieu de l'écraser.
# Utilisé par install-env.sh (install complète) et update.sh (mise à jour).

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

link_app() {
    local name="$1"
    local src="$REPO_DIR/config/$name"
    local dest="$CONFIG_DIR/$name"

    if [ -L "$dest" ]; then
        if [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
            return
        fi
        echo "🔗 Remplacement du lien existant : $dest"
        rm "$dest"
    elif [ -e "$dest" ]; then
        local backup="$dest.bak-$(date +%Y%m%d%H%M%S)"
        echo "📦 $dest existe déjà, sauvegarde vers $backup"
        mv "$dest" "$backup"
    fi

    ln -s "$src" "$dest"
    echo "✅ $dest -> $src"
}

link_all_apps() {
    mkdir -p "$CONFIG_DIR"
    for app_dir in "$REPO_DIR"/config/*/; do
        link_app "$(basename "$app_dir")"
    done
}
