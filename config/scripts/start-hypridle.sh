#!/bin/bash
# Génère hypridle-lock-timeout.conf (source par hypridle.conf) puis lance hypridle.
# PC fixe (pas de batterie) -> verrouillage après 30min. PC portable -> 3min.

CONF="$HOME/.config/hypr/hypridle-lock-timeout.conf"

if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
  LOCK_TIMEOUT=180
else
  LOCK_TIMEOUT=1800
fi

echo "\$lock_timeout = $LOCK_TIMEOUT" > "$CONF"

exec hypridle
