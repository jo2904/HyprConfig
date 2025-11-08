#!/bin/bash
# ==========================================================
# Script d'installation et de configuration d'un environnement Hyprland sur Arch Linux
# ==========================================================
set -e  # Stoppe le script si une commande échoue

# ----------------------------------------------------------
# 1️⃣  Dépendances de base et outils essentiels
# ----------------------------------------------------------
sudo pacman -Syu --noconfirm

# Outils système et utilitaires de base
sudo pacman -S --noconfirm --needed \
  base-devel \
  git \
  wget curl \
  unzip zip \
  ffmpeg \
  7zip jq poppler fd ripgrep fzf \
  zoxide imagemagick \
  brightnessctl power-profiles-daemon

# ----------------------------------------------------------
# 2️⃣  Installation de yay (AUR helper)
# ----------------------------------------------------------
rm -rf yay
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

# ----------------------------------------------------------
# 3️⃣  Environnement Hyprland + outils Wayland
# ----------------------------------------------------------
sudo pacman -S --noconfirm --needed \
  hyprland \
  uwsm \
  kitty \
  yazi \
  nautilus \
  slurp grim swappy satty \
  hyprshot hyprsunset \
  hyprpaper \
  mako rofi \
  nwg-displays \
  bluetui \
  iwd \
  eza \
  doxx \
  bluez \
  bluez-utils \
  wiremix \
  wlogout

yay -S hyprpolkitagent polkit
systemctl --user enable --now hyprpolkitagent.service

sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

# (facultatif) plugin pour yazi
yay -S --noconfirm yazi-rs-plugins-piper

# ----------------------------------------------------------
# 4️⃣  Composants complémentaires Hyprland
# ----------------------------------------------------------
yay -S --noconfirm \
  waybar \
  hypridle hyprlock \
  playerctl \
  xdg-desktop-portal-hyprland

# ----------------------------------------------------------
# 5️⃣  Audio & affichage
# ----------------------------------------------------------
yay -S --noconfirm pipewire pipewire-pulse pavucontrol
systemctl --user enable --now pipewire.service pipewire-pulse.service

# ----------------------------------------------------------
# 6️⃣  Pilotes graphiques
# ⚠️  Adapter selon ta carte : nvidia / amd / intel
# ----------------------------------------------------------
# Exemple NVIDIA :
# sudo pacman -S --noconfirm nvidia nvidia-utils
# yay -S --noconfirm displaylink

# ----------------------------------------------------------
# 7️⃣  Applications utilisateur
# ----------------------------------------------------------
yay -S --noconfirm \
  zen-browser-bin \
  visual-studio-code-bin \
  nextcloud-client \
  spotify \
  onlyoffice-bin \
  tailscale \
  unp btop \
  gazelle-tui

# ----------------------------------------------------------
# 8️⃣  Polices & apparence
# ----------------------------------------------------------
sudo pacman -S --noconfirm ttf-font-awesome
sudo pacman -S ttf-jetbrains-mono-nerd


# ----------------------------------------------------------
# 9️⃣  Gestionnaire d’affichage (SDDM)
# ----------------------------------------------------------
sudo pacman -S --noconfirm sddm

# ----------------------------------------------------------
# 1️⃣1️⃣  Shell Zsh
# ----------------------------------------------------------
yay -S --noconfirm zsh
chsh -s "$(which zsh)"

# ----------------------------------------------------------
# 1️⃣2️⃣  Services réseau
# ----------------------------------------------------------
sudo systemctl enable --now tailscaled.service

# ----------------------------------------------------------
# ✅  Finalisation
# ----------------------------------------------------------
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

echo
echo "✅ Installation terminée avec succès !"
echo "💡 Redémarre ton système et connecte-toi sur Hyprland via SDDM."
echo
