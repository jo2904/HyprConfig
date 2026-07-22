#!/bin/bash
screenDir="$HOME/Images/screenshot"

# hyprshot (-s) et satty (--disable-notifications) ont chacun leur propre
# notification par défaut : on les coupe toutes les deux et on envoie la
# nôtre à la fin, pour n'avoir qu'une seule notif par capture.
pkill slurp || {
  hyprshot -m "${1:-region}" --raw -s |
    satty --filename - \
      --output-filename "$screenDir/screenshot-$(date +'%d_%m_%H_%M').png" \
      --early-exit \
      --actions-on-enter save-to-clipboard \
      --save-after-copy \
      --copy-command 'wl-copy' \
      --disable-notifications \
    && notify-send -i image-x-generic "Capture d'écran" "Copiée dans le presse-papiers" -t 2000
}