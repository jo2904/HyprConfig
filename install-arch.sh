#!/usr/bin/env bash
# arch-auto-btrfs.sh — Installation Arch automatisée (LUKS2 + Btrfs + Swapfile + systemd-boot + user jo)
set -euo pipefail

DISK="${1:-}"
HOSTNAME="archlinux"
USERNAME="jo"
TZONE="Europe/Paris"
LOCALE="fr_FR.UTF-8"
KEYMAP="fr"
SHELL_BIN="/bin/zsh"

# --- Vérifications ---
if [[ ! -d /sys/firmware/efi/efivars ]]; then
  echo "❌ Ce script requiert un boot UEFI (systemd-boot ne marche pas en BIOS)."
  exit 1
fi

if [[ -z "$DISK" || ! -b "$DISK" ]]; then
  echo "Usage: $0 /dev/sdX  |  /dev/nvme0n1"
  exit 1
fi

read -t 30 -rp "⚠️ Le disque $DISK sera ENTIEREMENT effacé. Taper 'OUI' pour confirmer (30s, sinon annulé) : " OK || true
[[ "$OK" == "OUI" ]] || { echo "❌ Annulé (pas de confirmation 'OUI')."; exit 1; }

# --- Nettoyage ---
echo "[*] Préparation du disque..."
swapoff -a || true
umount -R /mnt 2>/dev/null || true
cryptsetup close cryptroot 2>/dev/null || true
vgchange -an 2>/dev/null || true

# --- Partitionnement ---
echo "[*] Partitionnement GPT (EFI + LUKS)..."
# Résoudre /dev/disk/by-id/... vers /dev/sdX|/dev/nvme0n1
KDISK="$(readlink -f -- "$DISK")"
BASE="$(basename "$KDISK")"

wipefs -af "$KDISK"
sgdisk -Zo "$KDISK"
sleep 1
sgdisk -n1:0:+512MiB -t1:ef00 -c1:"EFI"        "$KDISK"
sgdisk -n2:0:0       -t2:8309 -c2:"cryptroot"  "$KDISK"
sync

# Définir proprement les chemins attendus
SEP=""
[[ "$BASE" =~ ^nvme ]] && SEP="p"
# Par nom noyau
EFI_DEV="/dev/${BASE}${SEP}1"
CRYPT_DEV="/dev/${BASE}${SEP}2"
# Par étiquette GPT (plus fiable, udev crée ces liens)
EFI="/dev/disk/by-partlabel/EFI"
CRYPT="/dev/disk/by-partlabel/cryptroot"

# 🔧 Forçage du rescannage du disque
echo "[*] Forçage du rescannage du disque..."
udevadm settle
partprobe "$KDISK" || true
sleep 1
if [[ -e "/sys/class/block/$BASE/device/rescan" ]]; then
  echo 1 > "/sys/class/block/$BASE/device/rescan" 2>/dev/null || true
fi
sleep 1
partx -u "$KDISK" || true
blockdev --rereadpt "$KDISK" 2>/dev/null || true
udevadm settle

# ⏳ Attendre que les partitions existent (par nom ou par partlabel)
ok=false
for i in {1..10}; do
  if [[ -b "$EFI_DEV" && -b "$CRYPT_DEV" ]]; then
    ok=true; break
  fi
  if [[ -e "$EFI" && -e "$CRYPT" ]]; then
    ok=true; break
  fi
  echo "[!] Partitions non visibles, tentative ($i/10)..."
  sleep 1
  udevadm settle
  partprobe "$KDISK" || true
done

if ! $ok; then
  echo "❌ Impossible de détecter les partitions après création."
  echo "--- sgdisk -p ---"
  sgdisk -p "$KDISK" || true
  echo "-----------------"
  exit 1
fi

# Affichage clair (déjà vérifié automatiquement ci-dessus, ceci est juste
# pour le log — pas de pause : la confirmation 'OUI' du tout début est le
# seul point d'arrêt de ce script, pour pouvoir le lancer et revenir plus
# tard sans qu'il reste bloqué en plein milieu).
lsblk -o NAME,PATH,SIZE,TYPE,FSTYPE "$KDISK"

# --- Chiffrement ---
echo "[*] Chiffrement LUKS2..."
cryptsetup luksFormat --type luks2 "$CRYPT"
cryptsetup open "$CRYPT" cryptroot

# --- Systèmes de fichiers ---
# -f sur mkfs.btrfs : sans ça, un re-run après un échec partiel sur le même
# disque (signature déjà présente) peut refuser ou demander une confirmation
# interactive — exactement le genre de prompt caché qu'on veut éviter.
mkfs.fat -F32 "$EFI"
mkfs.btrfs -f -L archsys /dev/mapper/cryptroot

# --- Subvolumes ---
mount /dev/mapper/cryptroot /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@swap
btrfs subvolume create /mnt/@snapshots
umount /mnt

# --- Montage principal ---
mount -o noatime,ssd,compress=zstd,space_cache=v2,subvol=@ /dev/mapper/cryptroot /mnt
mkdir -p /mnt/{boot,home,.snapshots,swap}
mount -o noatime,ssd,compress=zstd,space_cache=v2,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o noatime,ssd,compress=zstd,space_cache=v2,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots
# Pas de compress= ici : c'est le subvolume qui accueille le swapfile, il
# doit rester en dehors de @ pour ne pas finir dans les snapshots (et donc
# potentiellement déplacé par un rollback, ce qui casserait le resume_offset
# calculé plus bas).
mount -o noatime,ssd,space_cache=v2,subvol=@swap /dev/mapper/cryptroot /mnt/swap
mount "$EFI" /mnt/boot

# --- Installation du système de base ---
echo "[*] Installation des paquets de base..."
pacman -Sy --noconfirm reflector
reflector --country France,Germany --protocol https --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

pacstrap -K /mnt base base-devel linux linux-firmware \
  btrfs-progs zsh vim sudo git networkmanager

# reflector n'a amélioré que le mirrorlist de l'ISO live (utilisé par
# pacstrap ci-dessus) — pacstrap ne le propage pas dans /mnt, qui hérite
# sinon du template quasi vide du paquet pacman-mirrorlist. Sans cette
# copie, le premier `pacman -Syu` de packages.sh après reboot serait très
# lent, voire échouerait faute de miroir actif.
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

genfstab -U /mnt >> /mnt/etc/fstab

crypt_uuid=$(blkid -s UUID -o value "$CRYPT")

# --- Configuration dans le chroot ---
arch-chroot /mnt /bin/bash <<'CHROOT'
set -euo pipefail

# Variables internes
HOSTNAME="archlinux"
USERNAME="jo"
TZONE="Europe/Paris"
LOCALE="fr_FR.UTF-8"
KEYMAP="fr"
SHELL_BIN="/bin/zsh"
CRYPT_UUID_PLACEHOLDER="@@CRYPT_UUID@@"

# --- Localisation ---
ln -sf /usr/share/zoneinfo/$TZONE /etc/localtime
hwclock --systohc

sed -i "s/#$LOCALE/$LOCALE/" /etc/locale.gen
echo "LANG=$LOCALE" > /etc/locale.conf
locale-gen
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

mkdir -p /etc/X11/xorg.conf.d
cat > /etc/X11/xorg.conf.d/00-keyboard.conf <<EOF
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "$KEYMAP"
        Option "XkbModel" "pc105"
EndSection
EOF

echo "$HOSTNAME" > /etc/hostname
cat >/etc/hosts <<EOF
127.0.0.1 localhost
::1       localhost
127.0.1.1 $HOSTNAME.localdomain $HOSTNAME
EOF

# --- mkinitcpio ---
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt filesystems resume fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P

# --- Utilisateur ---
useradd -m -G wheel -s $SHELL_BIN $USERNAME
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
# Pas de mot de passe root : le compte reste verrouillé (pas de connexion
# possible), tout passe par le sudo de $USERNAME via %wheel ci-dessus.
passwd -l root
systemctl enable NetworkManager

# --- DNS : systemd-resolved géré par NetworkManager ---
# Sans ça, packages.sh bascule /etc/resolv.conf vers le stub de resolved
# (/run/systemd/resolve/stub-resolv.conf) alors que resolved n'a jamais
# tourné ni reçu de serveurs DNS — la résolution casse juste avant le
# premier pacman -Syu du script.
systemctl enable systemd-resolved.service
mkdir -p /etc/NetworkManager/conf.d
cat >/etc/NetworkManager/conf.d/dns.conf <<'EOF'
[main]
dns=systemd-resolved
EOF

# --- Swapfile Btrfs (RAM + 2 GiB) --- /swap est déjà le subvolume @swap,
# monté avant pacstrap/genfstab (voir plus haut).
mem_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
mem_mib=$(( (mem_kb + 1023) / 1024 ))
swap_mib=$(( mem_mib + 2048 ))
SWAPFILE=/swap/swapfile
btrfs filesystem mkswapfile --size "${swap_mib}M" "$SWAPFILE"
chmod 600 "$SWAPFILE"
mkswap "$SWAPFILE"
swapon "$SWAPFILE"
echo "$SWAPFILE none swap defaults 0 0" >> /etc/fstab

# --- systemd-boot ---
bootctl --path=/boot install

# --- Microcode CPU ---
cpu_vendor=$(LC_ALL=C lscpu | awk -F: '/Vendor ID/{gsub(/^[ \t]+/,"",$2); print $2}')
ucode_initrd=""
if [[ "$cpu_vendor" == "GenuineIntel" ]]; then
  pacman -S --noconfirm --needed intel-ucode
  ucode_initrd="initrd  /intel-ucode.img"
elif [[ "$cpu_vendor" == "AuthenticAMD" ]]; then
  pacman -S --noconfirm --needed amd-ucode
  ucode_initrd="initrd  /amd-ucode.img"
fi

# --- Resume offset pour hibernation ---
offset=$(btrfs inspect-internal map-swapfile -r "$SWAPFILE")
: "${offset:=0}"
resume_opts="resume=$SWAPFILE resume_offset=$offset"

# --- Config bootloader ---
cat >/boot/loader/loader.conf <<EOF
default arch.conf
timeout 3
editor no
EOF

cat >/boot/loader/entries/arch.conf <<EOF
title   Arch Linux (Btrfs)
linux   /vmlinuz-linux
$ucode_initrd
initrd  /initramfs-linux.img
options cryptdevice=UUID=$CRYPT_UUID_PLACEHOLDER:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ $resume_opts rw
EOF

cat >/boot/loader/entries/arch-fallback.conf <<EOF
title   Arch Linux (fallback)
linux   /vmlinuz-linux
$ucode_initrd
initrd  /initramfs-linux-fallback.img
options cryptdevice=UUID=$CRYPT_UUID_PLACEHOLDER:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ $resume_opts rw
EOF

CHROOT

# Sortie du heredoc => ici tu as repris la main
# Pas de mot de passe root (compte verrouillé plus haut) — seul $USERNAME
# en a besoin d'un, pour se connecter et utiliser sudo.
echo "[*] Définis un mot de passe pour $USERNAME :"
arch-chroot /mnt passwd "$USERNAME"

# Injection de la vraie UUID
sed -i "s/@@CRYPT_UUID@@/${crypt_uuid}/g" /mnt/boot/loader/entries/arch.conf
sed -i "s/@@CRYPT_UUID@@/${crypt_uuid}/g" /mnt/boot/loader/entries/arch-fallback.conf

echo "✅ Installation terminée (LUKS + Btrfs + systemd-boot)"
echo "[*] Nettoyage..."
arch-chroot /mnt swapoff -a || true
umount -R /mnt
cryptsetup close cryptroot
echo "✅ Prêt à redémarrer !"
