#!/bin/bash

TEMPDir="$HOME"

# Exit immediately if a command exits with a non-zero status
set -eE
find . -type f -name 'index.html*' -delete

bash ./packages.sh

cp -r config/ "$TEMPDir/.config/"
chmod +x "$TEMPDir/.config/scripts/"*.sh
chmod +x "$TEMPDir/.config/waybar/launch.sh"

mkdir -p "$TEMPDir/Images/screenshot"

source ./defaultApp.sh

mkdir -p ~/.cache/zsh
echo "source $TEMPDir/.config/zsh/zshrc.sh" >> ~/.zshrc

sudo ./theme-sddm.sh

mkdir -p "$TEMPDir/divers"

sudo mkdir -p /etc/systemd/logind.conf.d/
sudo tee /etc/systemd/logind.conf.d/power-key.conf <<'EOF'
[Login]
HandlePowerKey=ignore
EOF

ya pkg add yazi-rs/plugins:piper

sudo systemctl enable --now sddm.service

# Git config interactif
read -rp "Nom pour git (user.name) : " git_name
read -rp "Email pour git (user.email) : " git_email
git config --global user.name "$git_name"
git config --global user.email "$git_email"