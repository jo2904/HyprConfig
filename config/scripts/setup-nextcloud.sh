#!/bin/bash
# Seed ~/.config/Nextcloud/nextcloud.cfg avec les dossiers à synchroniser
# par défaut (Documents, divers, Images, Téléchargements), à partir du
# template versionné (config/nextcloud/nextcloud.cfg.template). Voir
# config/nextcloud/README.md pour le pourquoi (pas de symlink permanent :
# le client réécrit ce fichier en continu).
#
# Ne fait rien si nextcloud.cfg existe déjà — c'est un seed une-fois avant
# la première connexion, pas une config à garder synchronisée en continu.

REAL_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
CONFIG_DIR="$(cd "$(dirname "$REAL_SOURCE")/.." && pwd)"
TEMPLATE="$CONFIG_DIR/nextcloud/nextcloud.cfg.template"
DEST_DIR="$HOME/.config/Nextcloud"
DEST="$DEST_DIR/nextcloud.cfg"

AUTOSTART_SRC="$CONFIG_DIR/nextcloud/Nextcloud.desktop"
AUTOSTART_DEST_DIR="$HOME/.config/autostart"
AUTOSTART_DEST="$AUTOSTART_DEST_DIR/Nextcloud.desktop"

setup_nextcloud() {
    if [ -e "$DEST" ]; then
        echo "ℹ️  $DEST existe déjà — rien à faire."
        return 0
    fi

    mkdir -p "$DEST_DIR"
    cp "$TEMPLATE" "$DEST"
    mkdir -p ~/Documents ~/divers ~/Images ~/Téléchargements

    mkdir -p "$AUTOSTART_DEST_DIR"
    cp "$AUTOSTART_SRC" "$AUTOSTART_DEST"

    echo "✅ $DEST créé depuis le template (+ autostart au boot)."
    echo "   Lance Nextcloud et connecte-toi (webflow) : les 4 dossiers sont déjà déclarés."
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    setup_nextcloud
fi
