#!/bin/bash
# ==========================================================
# Script d'installation et de configuration d'un environnement Hyprland sur Arch Linux
# ==========================================================
set -e  # Stoppe le script si une commande échoue

sudo rm /etc/resolv.conf
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# ----------------------------------------------------------
# 1️⃣  Dépendances de base et outils essentiels
# ----------------------------------------------------------
 sudo pacman -Syu --noconfirm

 sudo pacman -S --noconfirm --needed \
  base-devel \
  git \
  wget \
  curl \
  unzip \
  zip \
  ffmpeg \
  p7zip \
  jq \
  poppler \
  fd \
  ripgrep \
  fzf \
  zoxide \
  imagemagick \
  brightnessctl \
  power-profiles-daemon \
  nano
  
# ----------------------------------------------------------
# 2️⃣  Installation de yay (AUR helper)
# ----------------------------------------------------------
rm -rf yay
 sudo pacman -S --noconfirm --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay

yay -S   pciutils  usbutils

# ----------------------------------------------------------
# 3️⃣  Environnement Hyprland + outils Wayland
# ----------------------------------------------------------
 sudo pacman -S --noconfirm --needed \
  hyprland \
  uwsm \
  kitty \
  yazi \
  nautilus \
  slurp \
  grim \
  swappy \
  satty \
  hyprshot \
  hyprsunset \
  hyprpaper \
  mako \
  rofi \
  nwg-displays \
  bluetui \
  iwd \
  eza \
  bluez \
  bluez-utils \
  qt6-base \
  qt6-declarative \
  qt6-wayland \
  qt6-svg \
  qt6-5compat \
  qt6-imageformats

# QuickShell
yay -S --noconfirm --needed quickshell-git

# Polkit agent Hyprland
yay -S --noconfirm --needed hyprpolkitagent polkit
systemctl --user enable --now hyprpolkitagent.service

git clone https://github.com/Shanu-Kumawat/quickshell-overview ~/.config/quickshell/overview

# Bluetooth
 systemctl enable --now bluetooth.service

# (Facultatif) plugin pour Yazi
yay -S --noconfirm --needed yazi-rs-plugins-piper

# ----------------------------------------------------------
# 4️⃣  Composants complémentaires Hyprland
# ----------------------------------------------------------
yay -S --noconfirm --needed \
  waybar \
  hypridle \
  hyprlock \
  playerctl \
  xdg-desktop-portal-hyprland \
  wlogout

# ----------------------------------------------------------
# 5️⃣  Audio & affichage
# ----------------------------------------------------------
 sudo pacman -S --noconfirm --needed pipewire pipewire-pulse pavucontrol
systemctl --user enable --now pipewire.service pipewire-pulse.service

# ----------------------------------------------------------
# 6️⃣  Pilotes graphiques (à adapter)
# ----------------------------------------------------------
read -p "Installer les pilotes NVIDIA ? (o/N) : " install_nvidia
if [[ "$install_nvidia" =~ ^[oO]$ ]]; then
    sudo pacman -S --noconfirm --needed nvidia nvidia-utils
fi

read -p "Installer DisplayLink ? (o/N) : " install_displaylink
if [[ "$install_displaylink" =~ ^[oO]$ ]]; then
    yay -S --noconfirm --needed displaylink
fi

# ----------------------------------------------------------
# 7️⃣  Applications utilisateur
# ----------------------------------------------------------
yay -S --noconfirm --needed \
  zen-browser-bin \
  visual-studio-code-bin \
  nextcloud-client \
  spotify \
  onlyoffice-bin \
  tailscale \
  unp \
  btop \
  gazelle-tui \
  filezilla
# ----------------------------------------------------------
# 8️⃣  Polices & apparence
# ----------------------------------------------------------
 sudo pacman -S --noconfirm --needed \
  ttf-font-awesome \
  ttf-jetbrains-mono-nerd \
  qt5-declarative \
  qt5-quickcontrols2

# ----------------------------------------------------------
# 9️⃣  Gestionnaire d’affichage (SDDM)
# ----------------------------------------------------------
 sudo pacman -S --noconfirm --needed sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg
 systemctl enable --now sddm.service

# ----------------------------------------------------------
# 🔟  Shell Zsh
# ----------------------------------------------------------
yay -S --noconfirm --needed zsh
chsh -s "$(which zsh)"

# ----------------------------------------------------------
# 1️⃣1️⃣  Services réseau
# ----------------------------------------------------------
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
systemctl enable --now tailscaled.service


# hyprpm add
sudo pacman -S cmake meson cpio pkgconf git gc

# ----------------------------------------------------------
# ✅  Finalisation
# ----------------------------------------------------------
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP || true

echo
echo "✅ Installation terminée avec succès !"
echo
