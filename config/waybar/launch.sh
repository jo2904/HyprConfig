#!/bin/bash

if hyprctl monitors | grep -q "DVI-I-1"; then
    waybar -c ~/.config/waybar/externe.json 
else
    waybar -c ~/.config/waybar/interne.json 
fi
