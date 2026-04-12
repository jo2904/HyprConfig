#!/bin/bash
screenDir="$HOME/Images/screenshot"

pkill slurp || hyprshot -m ${1:-region} --raw --no-border |
  satty --filename - \
    --output-filename "$screenDir/screenshot-$(date +'%d_%m_%H_%M').png" \
    --early-exit \
    --actions-on-enter save-to-clipboard \
    --save-after-copy \
    --copy-command 'wl-copy'