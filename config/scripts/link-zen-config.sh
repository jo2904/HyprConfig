#!/bin/bash
# Lie la config Zen Browser versionnée (config/zen-browser/) dans le profil
# Zen réel de la machine, par symlink — même logique que link-config.sh mais
# ciblée sur quelques fichiers précis du profil (voir config/zen-browser/README.md
# pour le détail de ce qui est lié et pourquoi).
#
# Le nom du dossier de profil (ex: "8ritxzwy.Default (release)") est un hash
# aléatoire propre à chaque installation : il est résolu dynamiquement via
# installs.ini, jamais codé en dur.
#
# Idempotent, comme link-config.sh : ne touche pas aux liens déjà corrects,
# sauvegarde tout fichier réel préexistant. Au tout premier lancement (sur la
# machine "source"), si le repo n'a pas encore le fichier, il est importé
# (déplacé) depuis le profil vers le repo puis relié.

# readlink -f d'abord : ce script est aussi accédé via le symlink
# ~/.config/scripts -> repo/config/scripts posé par link-config.sh, et
# `dirname` seul ne suivrait pas ce lien jusqu'au vrai chemin du repo.
REAL_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
CONFIG_DIR="$(cd "$(dirname "$REAL_SOURCE")/.." && pwd)"
ZEN_SRC_DIR="$CONFIG_DIR/zen-browser"
ZEN_CONFIG_ROOT="$HOME/.config/zen"

# name:type — type = file ou dir (une entrée par item à synchroniser)
ZEN_ITEMS=(
    "chrome:dir"
    "zen-themes.json:file"
    "zen-keyboard-shortcuts.json:file"
)

find_zen_profile_dir() {
    local installs_ini="$ZEN_CONFIG_ROOT/installs.ini"
    [ -f "$installs_ini" ] || return 1

    local rel
    rel="$(grep -m1 '^Default=' "$installs_ini" | cut -d= -f2-)"
    [ -n "$rel" ] || return 1

    local dir="$ZEN_CONFIG_ROOT/$rel"
    [ -d "$dir" ] || return 1

    printf '%s\n' "$dir"
}

link_zen_item() {
    local rel="$1" type="$2"
    local src="$ZEN_SRC_DIR/$rel"
    local dest="$PROFILE_DIR/$rel"

    if [ -L "$dest" ]; then
        if [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
            return
        fi
        echo "🔗 Remplacement du lien existant : $dest"
        rm "$dest"
    elif [ -e "$dest" ]; then
        if [ ! -e "$src" ]; then
            echo "📥 Import initial de $rel dans le repo"
            mkdir -p "$(dirname "$src")"
            mv "$dest" "$src"
        else
            local backup="$dest.bak-$(date +%Y%m%d%H%M%S)"
            echo "📦 $dest existe déjà, sauvegarde vers $backup"
            mv "$dest" "$backup"
        fi
    fi

    # Garantit que la cible existe (dossier réel pour "dir", parent pour "file")
    # afin qu'un symlink pendant ne bloque pas Zen à la création du fichier.
    if [ "$type" = "dir" ]; then
        mkdir -p "$src"
    else
        mkdir -p "$(dirname "$src")"
    fi

    ln -s "$src" "$dest"
    echo "✅ $dest -> $src"
}

link_zen_config() {
    if PROFILE_DIR="$(find_zen_profile_dir)"; then
        mkdir -p "$ZEN_SRC_DIR"
        for item in "${ZEN_ITEMS[@]}"; do
            link_zen_item "${item%%:*}" "${item##*:}"
        done
    else
        echo "ℹ️  Profil Zen Browser introuvable (jamais lancé sur cette machine ?) — rien à lier."
    fi
}

# Permet à la fois le "source" (réutilisé par install-env.sh / update.sh)
# et l'exécution directe (./link-zen-config.sh)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    link_zen_config
fi
