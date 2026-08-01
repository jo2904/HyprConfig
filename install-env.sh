#!/bin/bash

TEMPDir="$HOME"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Exit immediately if a command exits with a non-zero status
set -eE
find "$REPO_DIR" -type f -name 'index.html*' -delete

# --- Toutes les questions d'un coup, avant de lancer quoi que ce soit de
# long : après ça le script tourne sans interaction, on peut le lancer et
# revenir quand c'est fini. Timeout sur chaque question pour ne jamais
# rester bloqué (ex: lancé via une session SSH qui coupe).
if ! git config --global user.name >/dev/null 2>&1; then
    read -t 20 -rp "Nom pour git (user.name, 20s) : " GIT_NAME || true
    read -t 20 -rp "Email pour git (user.email, 20s) : " GIT_EMAIL || true
fi
read -t 15 -rp "Installer les pilotes NVIDIA ? (o/N, 15s) : " install_nvidia || true
read -t 15 -rp "Installer DisplayLink ? (o/N, 15s) : " install_displaylink || true
export install_nvidia install_displaylink

if [[ -n "${GIT_NAME:-}" && -n "${GIT_EMAIL:-}" ]]; then
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
elif ! git config --global user.name >/dev/null 2>&1; then
    echo "⏭️  git user.name/email non configurés — à faire à la main plus tard :"
    echo "    git config --global user.name \"...\" && git config --global user.email \"...\""
fi

# Cache les identifiants sudo pour toute la durée du script : packages.sh
# installe beaucoup de paquets AUR (souvent plus long que le cache sudo par
# défaut ~15min) — sans ça, sudo redemande le mot de passe en plein milieu
# d'un build et le script reste planté sans qu'on le voie.
sudo -v
( while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done ) &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT

bash "$REPO_DIR/packages.sh"

source "$REPO_DIR/link-config.sh"
link_all_apps

source "$REPO_DIR/config/scripts/link-zen-config.sh"
link_zen_config

source "$REPO_DIR/config/scripts/setup-nextcloud.sh"
setup_nextcloud

chmod +x "$TEMPDir/.config/scripts/"*.sh
chmod +x "$TEMPDir/.config/waybar/launch.sh"

mkdir -p "$TEMPDir/Images/screenshot"

source "$REPO_DIR/defaultApp.sh"

mkdir -p ~/.cache/zsh
ZSHRC_LINE="source $TEMPDir/.config/zsh/zshrc.sh"
grep -qxF "$ZSHRC_LINE" ~/.zshrc 2>/dev/null || echo "$ZSHRC_LINE" >> ~/.zshrc

sudo "$REPO_DIR/theme-sddm.sh"
sudo "$REPO_DIR/harden-pam.sh"

mkdir -p "$TEMPDir/divers"

sudo mkdir -p /etc/systemd/logind.conf.d/
sudo tee /etc/systemd/logind.conf.d/power-key.conf <<'EOF'
[Login]
HandlePowerKey=ignore
EOF

sudo systemctl enable --now sddm.service
