#!/bin/bash

TEMPDir='/home/jo/'

# Exit immediately if a command exits with a non-zero status
set -eE
find . -type f -name 'index.html*' -delete

#sudo ./packages.sh

cp -r config/. $TEMPDir/.config/
chmod +x $TEMPDir/.config/scripts/*.sh
chmod +x $TEMPDir/.config/waybar/launch.sh

mkdir -p $TEMPDir/Images/screenshot

source ./defaultApp.sh

echo "source $TEMPDir/.config/zsh/zshrc.sh" >> ~/.zshrc

sudo ./theme-sddm.sh

mkdir -p $TEMPDir/divers

# ----------------------------------------------------------
# 🔟  Hyprland plugins (via hyprpm)
# ----------------------------------------------------------
sudo pacman -S cmake meson cpio pkgconf git gcc
hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm enable hyprexpo

hyprpm add https://github.com/yz778/hyprview
hyprpm enable hyprview


ya pkg add yazi-rs/plugins:piper

sudo systemctl enable --now sddm.service
