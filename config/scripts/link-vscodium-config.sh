#!/bin/bash
# Lie la config VSCodium versionnée (config/vscodium/) dans le vrai profil
# VSCodium de la machine (~/.config/VSCodium/User), par symlink — même
# logique que link-zen-config.sh, ciblée sur les fichiers stables du
# profil (voir config/vscodium/README.md pour le détail de ce qui est lié
# et pourquoi).
#
# Installe aussi les extensions listées dans config/vscodium/extensions.txt.
#
# Idempotent, comme link-zen-config.sh : ne touche pas aux liens déjà
# corrects, sauvegarde tout fichier/dossier réel préexistant. Au tout
# premier lancement (sur la machine "source"), si le repo n'a pas encore
# le fichier, il est importé (déplacé) depuis le profil vers le repo puis
# relié.

# readlink -f d'abord : ce script est aussi accédé via le symlink
# ~/.config/scripts -> repo/config/scripts posé par link-config.sh, et
# `dirname` seul ne suivrait pas ce lien jusqu'au vrai chemin du repo.
REAL_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
CONFIG_DIR="$(cd "$(dirname "$REAL_SOURCE")/.." && pwd)"
VSCODIUM_SRC_DIR="$CONFIG_DIR/vscodium"
VSCODIUM_USER_DIR="$HOME/.config/VSCodium/User"

# name:type — type = file ou dir (une entrée par item à synchroniser)
VSCODIUM_ITEMS=(
    "settings.json:file"
    "keybindings.json:file"
    "snippets:dir"
)

link_vscodium_item() {
    local rel="$1" type="$2"
    local src="$VSCODIUM_SRC_DIR/User/$rel"
    local dest="$VSCODIUM_USER_DIR/$rel"

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

    # Garantit que la cible existe (dossier réel pour "dir", parent pour
    # "file") afin qu'un symlink pendant ne bloque pas VSCodium à la
    # création du fichier (ex: keybindings.json avant tout raccourci custom).
    if [ "$type" = "dir" ]; then
        mkdir -p "$src"
    else
        mkdir -p "$(dirname "$src")"
    fi

    ln -s "$src" "$dest"
    echo "✅ $dest -> $src"
}

link_vscodium_config() {
    if ! command -v codium >/dev/null 2>&1; then
        echo "ℹ️  VSCodium non installé — rien à lier."
        return
    fi
    mkdir -p "$VSCODIUM_USER_DIR"
    mkdir -p "$VSCODIUM_SRC_DIR/User"
    for item in "${VSCODIUM_ITEMS[@]}"; do
        link_vscodium_item "${item%%:*}" "${item##*:}"
    done
}

# Installe les extensions listées dans extensions.txt (une par ligne, id
# "editeur.nom") qui manquent encore sur cette machine. N'enlève jamais une
# extension installée en plus — liste additive uniquement.
install_vscodium_extensions() {
    command -v codium >/dev/null 2>&1 || return
    local list="$VSCODIUM_SRC_DIR/extensions.txt"
    [ -f "$list" ] || return

    local installed
    installed="$(codium --list-extensions 2>/dev/null)"

    local ext
    while IFS= read -r ext; do
        [ -z "$ext" ] && continue
        [[ "$ext" == \#* ]] && continue
        grep -qix "$ext" <<< "$installed" && continue
        echo "📦 Installation extension VSCodium : $ext"
        codium --install-extension "$ext" >/dev/null
    done < "$list"
}

# Permet à la fois le "source" (réutilisé par install-env.sh / update.sh)
# et l'exécution directe (./link-vscodium-config.sh)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    link_vscodium_config
    install_vscodium_extensions
fi
