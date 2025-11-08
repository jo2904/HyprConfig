#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -eE
find . -type f -name 'index.html*' -delete

# source ./packages.sh


cp -r config/. ~/.config/
chmod +x ~/.config/scripts/*.sh
chmod +x ~/.config/waybar/launch.sh

mkdir -p $HOME/Images/screenshot

source ./defaultApp.sh

echo "source $HOME/.config/zsh/zshrc.sh" >> ~/.zshrc

source ./theme-sddm.sh

mkdir -p $HOME/divers

cp config/nextcloud/nextcloud.cfg $HOME/.config/Nextcloud/nextcloud.cfg

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
