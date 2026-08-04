#!/bin/bash
# ==========================================================
# Script d'installation et de configuration d'un environnement Hyprland sur Arch Linux
# ==========================================================
set -e  # Stoppe le script si une commande échoue

sudo systemctl enable --now systemd-timesyncd.service
# --now : resolved doit tourner et avoir reçu ses serveurs DNS (via NetworkManager,
# voir install-arch.sh) avant qu'on pointe resolv.conf vers son stub, sinon la
# résolution casse juste avant le pacman -Syu qui suit.
sudo systemctl enable --now systemd-resolved.service

sudo rm -f /etc/resolv.conf
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
makepkg -s --noconfirm
sudo pacman -U --noconfirm *.pkg.tar.zst
cd ..
rm -rf yay

yay -S --noconfirm --needed pciutils usbutils

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

# quickshell-overview est versionné dans config/quickshell/overview et livré par le symlink

# Bluetooth
 systemctl enable --now bluetooth.service

# Le plugin piper pour Yazi est versionné dans config/yazi/plugins/piper.yazi et livré par le symlink

# ----------------------------------------------------------
# 4️⃣  Composants complémentaires Hyprland
# ----------------------------------------------------------
yay -S --noconfirm --needed \
  waybar \
  hypridle \
  hyprlock \
  playerctl \
  xdg-desktop-portal-hyprland

# ----------------------------------------------------------
# 5️⃣  Audio & affichage
# ----------------------------------------------------------
 sudo pacman -S --noconfirm --needed pipewire pipewire-pulse pavucontrol
systemctl --user enable --now pipewire.service pipewire-pulse.service

# ----------------------------------------------------------
# 6️⃣  Pilotes graphiques (à adapter)
# ----------------------------------------------------------
# install_nvidia / install_displaylink peuvent déjà être fournies (exportées
# par install-env.sh, qui pose toutes les questions d'un coup au tout début) —
# on ne redemande que si packages.sh est lancé seul.
if [[ -z "${install_nvidia+x}" ]]; then
    read -t 15 -rp "Installer les pilotes NVIDIA ? (o/N, 15s) : " install_nvidia || true
fi
if [[ "$install_nvidia" =~ ^[oO]$ ]]; then
    sudo pacman -S --noconfirm --needed nvidia nvidia-utils
fi

if [[ -z "${install_displaylink+x}" ]]; then
    read -t 15 -rp "Installer DisplayLink ? (o/N, 15s) : " install_displaylink || true
fi
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
  kdbusaddons \
  spotify \
  onlyoffice-bin \
  tailscale \
  unp \
  btop \
  gazelle-tui \
  filezilla \
  openlogi-bin
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

# ----------------------------------------------------------
# 🔟  Shell Zsh
# ----------------------------------------------------------
yay -S --noconfirm --needed zsh
# sudo : sans ça, chsh redemande interactivement le mot de passe de
# l'utilisateur courant via PAM — un prompt de plus sans timeout, en plein
# milieu du script.
sudo chsh -s "$(which zsh)" "$USER"

# ----------------------------------------------------------
# 1️⃣1️⃣  Services réseau
# ----------------------------------------------------------
systemctl enable --now tailscaled.service


# hyprpm add
sudo pacman -S --noconfirm --needed cmake meson cpio pkgconf git gc

# ----------------------------------------------------------
# 🔥  Firewall (ufw)
# ----------------------------------------------------------
sudo pacman -S --noconfirm --needed ufw
sudo systemctl enable --now ufw.service
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
sudo ufw allow in on tailscale0

# ----------------------------------------------------------
# ✅  Finalisation
# ----------------------------------------------------------
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP || true

echo
echo "✅ Installation terminée avec succès !"
echo
