alias hibernate='sudo systemctl hibernate'


# === Auto unpack aliases ===

# Extraction simple dans le dossier courant
alias unpack='unp'

# Extraction dans un dossier dédié au nom du fichier
alias unpack-dir='unp -u'

# === Bluetooth aliases and helper functions ===

# Activation / désactivation
alias bt-on='rfkill unblock bluetooth && bluetoothctl power on'
alias bt-off='bluetoothctl power off && rfkill block bluetooth'

# Scan
alias bt-scan='bluetoothctl scan on'
alias bt-scan-off='bluetoothctl scan off'
alias bt-devices='bluetoothctl devices'

# Connexion / déconnexion
bt-connect() {
  if [ -z "$1" ]; then
    echo "Usage: bt-connect <MAC_ADDRESS>"
    return 1
  fi
  bluetoothctl connect "$1"
}

bt-disconnect() {
  if [ -z "$1" ]; then
    echo "Usage: bt-disconnect <MAC_ADDRESS>"
    return 1
  fi
  bluetoothctl disconnect "$1"
}

# Appairage + confiance
bt-pair() {
  if [ -z "$1" ]; then
    echo "Usage: bt-pair <MAC_ADDRESS>"
    return 1
  fi
  bluetoothctl pair "$1"
  bluetoothctl trust "$1"
}

# Statut du contrôleur
alias bt-status='bluetoothctl show'

# Aide rapide
bt-help() {
  cat <<EOF
🔵 Bluetooth Commandes Rapides :

  bt-on               → Active le Bluetooth
  bt-off              → Désactive le Bluetooth
  bt-status           → État du contrôleur
  bt-scan             → Démarre le scan des appareils
  bt-scan-off         → Arrête le scan
  bt-devices          → Liste les appareils détectés
  bt-pair <MAC>       → Appaire et fait confiance à un appareil
  bt-connect <MAC>    → Connecte un appareil
  bt-disconnect <MAC> → Déconnecte un appareil

Exemple :
  bt-on
  bt-scan && sleep 5 && bt-scan-off
  bt-devices
  bt-pair AA:BB:CC:DD:EE:FF
  bt-connect AA:BB:CC:DD:EE:FF

EOF
}

# === WiFi aliases and helper functions ===
# Activation / désactivation
alias wifi-on='rfkill unblock wifi && nmcli radio wifi on'
alias wifi-off='nmcli radio wifi off && rfkill block wifi'

# Scan et liste des réseaux
alias wifi-scan='nmcli device wifi rescan'
alias wifi-list='nmcli device wifi list'
alias wifi-list-saved='nmcli connection show'

# Connexion / déconnexion
wifi-connect() {
    if [ -z "$1" ]; then
        echo "Usage: wifi-connect <SSID> [password]"
        echo "Si pas de mot de passe fourni, il sera demandé interactivement"
        return 1
    fi
    
    if [ -n "$2" ]; then
        nmcli device wifi connect "$1" password "$2"
    else
        nmcli device wifi connect "$1" --ask
    fi
}

wifi-disconnect() {
    if [ -z "$1" ]; then
        echo "Usage: wifi-disconnect <SSID>"
        return 1
    fi
    nmcli connection down "$1"
}

# Gestion des profils sauvegardés
wifi-forget() {
    if [ -z "$1" ]; then
        echo "Usage: wifi-forget <SSID>"
        return 1
    fi
    nmcli connection delete "$1"
}

wifi-reconnect() {
    if [ -z "$1" ]; then
        echo "Usage: wifi-reconnect <SSID>"
        return 1
    fi
    nmcli connection up "$1"
}

# Informations et statut
alias wifi-status='nmcli device status | grep wifi'
alias wifi-info='nmcli device show | grep -E "(DEVICE|TYPE|STATE|CONNECTION)"'
alias wifi-signal='nmcli device wifi list --rescan-ssid'

# Hotspot
wifi-hotspot() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: wifi-hotspot <SSID> <password>"
        return 1
    fi
    nmcli device wifi hotspot ssid "$1" password "$2"
}

alias wifi-hotspot-off='nmcli connection down Hotspot'

# Aide rapide
wifi-help() {
    cat <<EOF
📶 WiFi Commandes Rapides :
 wifi-on → Active le WiFi
 wifi-off → Désactive le WiFi
 wifi-status → État de l'interface WiFi
 wifi-info → Informations détaillées
 wifi-scan → Scan des réseaux disponibles
 wifi-list → Liste des réseaux détectés
 wifi-list-saved → Liste des profils sauvegardés
 wifi-connect <SSID> [password] → Connecte à un réseau
 wifi-disconnect <SSID> → Déconnecte d'un réseau
 wifi-reconnect <SSID> → Reconnecte à un profil sauvé
 wifi-forget <SSID> → Supprime un profil sauvé
 wifi-signal → Affiche la force des signaux
 wifi-hotspot <SSID> <password> → Crée un hotspot
 wifi-hotspot-off → Arrête le hotspot

Exemples :
 wifi-on
 wifi-scan && sleep 3 && wifi-list
 wifi-connect "MonWiFi" "motdepasse123"
 wifi-connect "WiFi_Public"  # Demande le mot de passe
 wifi-hotspot "MonHotspot" "password123"
EOF
}

yazi-help() {
  cat <<'EOF'
📁 YAZI - Raccourcis Clavier Principaux

🎯 Navigation :
  ↑ / ↓        → Se déplacer dans la liste
  z            → Aller au répertoire
  g / G        → Aller en haut / en bas
  ~            → Aller au répertoire personnel
  \`            → Aller au dernier répertoire

🗃️ Fichiers :
  o / Entrée   → Ouvrir un fichier
  y            → Copier
  x            → Couper
  X / Y        → Annuler l'action précédente
  p / P        → Coller (P force l'action)
  d            → Envoyer à la corbeille
  D            → Supprimer directement
  r            → Renommer
  a            → Créer un fichier ou dossier
  Tab          → Afficher les infos du fichier
  .            → Afficher/Masquer les fichiers cachés

🔍 Recherche & Filtres :
  /            → Rechercher un fichier
  n / N        → Résultat suivant / précédent
  f            → Appliquer un filtre
  s            → Recherche par nom
  S            → Recherche par contenu
  ,            → Ouvrir les options de tri

📋 Copier le chemin (c + touche) :
  c f          → Copier le nom du fichier
  c n          → Copier le nom sans extension
  c d          → Copier le chemin du dossier
  c c          → Copier le chemin complet du fichier

🧠 Marque-pages / Onglets :
  t            → Ajouter un onglet
  1...9        → Aller à l'onglet n
  Ctrl + c     → Fermer l'onglet actuel

⚙️ Divers :
  :            → Entrer une commande
  Espace       → Sélectionner/Désélectionner
  q            → Quitter Yazi


🔗 Docs officielles :
  https://yazi-rs.github.io/docs/quick-start/
EOF
}


# === Montage/démontage aliases et fonctions helper ===

# Listage des périphériques et points de montage
alias mnt-list='lsblk -f'
alias mnt-usb='lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT | grep -E "(sd[b-z]|nvme[1-9])"'
alias mnt-mounted='mount | grep -E "^/dev/" | column -t'
alias mnt-free='df -h'

# Montage automatique dans /mnt
mnt-mount() {
    if [ -z "$1" ]; then
        echo "Usage: mnt-mount <DEVICE> [MOUNT_POINT]"
        echo "Exemple: mnt-mount /dev/sdb1"
        echo "         mnt-mount /dev/sdb1 /mnt/usb"
        return 1
    fi
    
    local device="$1"
    local mount_point="${2:-/mnt/$(basename $device)}"
    
    # Créer le point de montage si nécessaire
    sudo mkdir -p "$mount_point"
    
    # Montage avec détection automatique du système de fichiers
    sudo mount "$device" "$mount_point" && \
    echo "✅ $device monté sur $mount_point"
}

# Démontage sécurisé
mnt-umount() {
    if [ -z "$1" ]; then
        echo "Usage: mnt-umount <DEVICE_OR_MOUNT_POINT>"
        echo "Exemple: mnt-umount /dev/sdb1"
        echo "         mnt-umount /mnt/usb"
        return 1
    fi
    
    sudo umount "$1" && \
    echo "✅ $1 démonté avec succès"
}

# Démontage forcé (en cas de périphérique occupé)
mnt-force-umount() {
    if [ -z "$1" ]; then
        echo "Usage: mnt-force-umount <DEVICE_OR_MOUNT_POINT>"
        return 1
    fi
    
    echo "⚠️  Démontage forcé de $1..."
    sudo umount -f "$1" 2>/dev/null || sudo umount -l "$1"
    echo "✅ $1 démonté (forcé)"
}

# Montage avec options spécifiques
mnt-mount-rw() {
    if [ -z "$1" ]; then
        echo "Usage: mnt-mount-rw <DEVICE> [MOUNT_POINT]"
        return 1
    fi
    
    local device="$1"
    local mount_point="${2:-/mnt/$(basename $device)}"
    
    sudo mkdir -p "$mount_point"
    sudo mount -o rw,user,exec "$device" "$mount_point" && \
    echo "✅ $device monté en lecture/écriture sur $mount_point"
}

# Montage en lecture seule
mnt-mount-ro() {
    if [ -z "$1" ]; then
        echo "Usage: mnt-mount-ro <DEVICE> [MOUNT_POINT]"
        return 1
    fi
    
    local device="$1"
    local mount_point="${2:-/mnt/$(basename $device)}"
    
    sudo mkdir -p "$mount_point"
    sudo mount -o ro "$device" "$mount_point" && \
    echo "✅ $device monté en lecture seule sur $mount_point"
}

# Éjection sécurisée (pour USB)
mnt-eject() {
    if [ -z "$1" ]; then
        echo "Usage: mnt-eject <DEVICE>"
        echo "Exemple: mnt-eject /dev/sdb"
        return 1
    fi
    
    local device="$1"
    
    # Démontage de toutes les partitions du périphérique
    for partition in ${device}*; do
        if mountpoint -q "$partition" 2>/dev/null || mount | grep -q "$partition"; then
            sudo umount "$partition" 2>/dev/null
        fi
    done
    
    # Éjection physique
    sudo eject "$device" 2>/dev/null && \
    echo "✅ $device éjecté en sécurité"
}

# Vérifier qui utilise un périphérique
mnt-who-uses() {
    if [ -z "$1" ]; then
        echo "Usage: mnt-who-uses <MOUNT_POINT>"
        return 1
    fi
    
    echo "🔍 Processus utilisant $1 :"
    sudo lsof +D "$1" 2>/dev/null || echo "Aucun processus trouvé"
}

# Synchronisation des données (flush)
alias mnt-sync='sync && echo "✅ Données synchronisées"'

# Informations détaillées sur un périphérique
mnt-info() {
    if [ -z "$1" ]; then
        echo "Usage: mnt-info <DEVICE>"
        return 1
    fi
    
    echo "📋 Informations sur $1 :"
    sudo fdisk -l "$1" 2>/dev/null
    echo ""
    sudo blkid "$1" 2>/dev/null
}

# Aide rapide
mnt-help() {
    cat <<EOF
💾 Commandes de Montage/Démontage :

📋 Listage :
 mnt-list → Affiche tous les périphériques (lsblk -f)
 mnt-usb → Affiche uniquement les périphériques USB/externes
 mnt-mounted → Liste les périphériques montés
 mnt-free → Espace disque disponible (df -h)

🔧 Montage :
 mnt-mount <device> [point] → Monte un périphérique
 mnt-mount-rw <device> [point] → Monte en lecture/écriture
 mnt-mount-ro <device> [point] → Monte en lecture seule

🔓 Démontage :
 mnt-umount <device|point> → Démonte proprement
 mnt-force-umount <device|point> → Démontage forcé
 mnt-eject <device> → Éjection sécurisée (USB)

🔍 Diagnostic :
 mnt-who-uses <point> → Qui utilise le périphérique ?
 mnt-info <device> → Infos détaillées sur le périphérique
 mnt-sync → Synchronise les données en attente

Exemples :
 mnt-list
 mnt-mount /dev/sdb1
 mnt-mount /dev/sdb1 /mnt/ma-cle-usb
 mnt-umount /mnt/ma-cle-usb
 mnt-eject /dev/sdb
EOF
}


# File system
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias cd="zd"
zd() {
  if [ $# -eq 0 ]; then
    builtin cd ~ && return
  elif [ -d "$1" ]; then
    builtin cd "$1"
  else
    z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
  fi
}
open() {
  xdg-open "$@" >/dev/null 2>&1 &
}

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alais ip='ip --color=auto'

# Compression
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress="tar -xzf"

# Write iso file to sd card
iso2sd() {
  if [ $# -ne 2 ]; then
    echo "Usage: iso2sd <input_file> <output_device>"
    echo "Example: iso2sd ~/Downloads/ubuntu-25.04-desktop-amd64.iso /dev/sda"
    echo -e "\nAvailable SD cards:"
    lsblk -d -o NAME | grep -E '^sd[a-z]' | awk '{print "/dev/"$1}'
  else
    sudo dd bs=4M status=progress oflag=sync if="$1" of="$2"
    sudo eject $2
  fi
}


alias usbformat='sudo bash -c "read -p \"Entrer le périphérique (ex: /dev/sdb) à formater : \" dev; read -p \"Entrez un label pour la clé : \" label; echo \"⚠️ Toutes les données sur \$dev seront effacées !\"; read -p \"Continuer ? (o/N) \" confirm; if [[ \$confirm == [oOyY] ]]; then umount \${dev}* 2>/dev/null; mkfs.vfat -F 32 -n \$label \$dev; echo \"✅ Clé \$dev formatée avec label \$label\"; else echo \"❌ Opération annulée\"; fi"'
