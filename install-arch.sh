#!/usr/bin/env bash
# arch-auto-btrfs.sh — Arch install automatisée (LUKS + Btrfs + swapfile + systemd-boot + user jo)
set -euo pipefail

DISK="${1:-}"
HOSTNAME="archlinux"
USERNAME="jo"
TZONE="Europe/Paris"
LOCALE="fr_FR.UTF-8"
KEYMAP="fr"
SHELL_BIN="/bin/zsh"

# --- prérequis ---
if [[ ! -d /sys/firmware/efi/efivars ]]; then
  echo "❌ Ce script nécessite un boot UEFI (systemd-boot). Redémarre l'ISO en mode UEFI."
  exit 1
fi

if [[ -z "$DISK" || ! -b "$DISK" ]]; then
  echo "Usage: $0 /dev/sdX|/dev/nvme0n1"
  exit 1
fi

read -rp "⚠️ Le disque $DISK sera ENTIEREMENT effacé. Taper 'OUI' pour confirmer : " OK
[[ "$OK" == "OUI" ]] || exit 1

# --- nettoyage pour éviter 'unable to inform the kernel' ---
swapoff -a || true
umount -R /mnt 2>/dev/null || true
cryptsetup close cryptroot 2>/dev/null || true
vgchange -an 2>/dev/null || true

echo "[*] Partitionnement GPT (UEFI + LUKS + Btrfs)…"
wipefs -af "$DISK"
sgdisk -Zo "$DISK"
sleep 1
sgdisk -n1:0:+512MiB -t1:ef00 -c1:"EFI"
sgdisk -n2:0:0       -t2:8309 -c2:"cryptroot"
sync
partprobe "$DISK" || true
partx -u "$DISK" || true
sleep 2

if [[ "$DISK" == *"nvme"* ]]; then
  EFI="${DISK}p1"
  CRYPT="${DISK}p2"
else
  EFI="${DISK}1"
  CRYPT="${DISK}2"
fi

# --- chiffrement + FS ---
echo "[*] Chiffrement LUKS…"
cryptsetup luksFormat --type luks2 "$CRYPT"
cryptsetup open "$CRYPT" cryptroot

echo "[*] Formatage partitions…"
mkfs.fat -F32 "$EFI"
mkfs.btrfs -L archsys /dev/mapper/cryptroot

# --- subvolumes ---
mount /dev/mapper/cryptroot /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@swap
btrfs subvolume create /mnt/@snapshots
umount /mnt

# --- montage principal ---
mount -o noatime,ssd,compress=zstd,space_cache=v2,subvol=@ /dev/mapper/cryptroot /mnt
mkdir -p /mnt/{boot,home,.snapshots,swap}
mount -o noatime,ssd,compress=zstd,space_cache=v2,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o noatime,ssd,compress=zstd,space_cache=v2,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots
mount "$EFI" /mnt/boot

# --- base system ---
echo "[*] Installation du système de base…"
pacman -Sy --noconfirm reflector
reflector --country France,Germany --protocol https --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

pacstrap -K /mnt base base-devel linux linux-firmware \
  btrfs-progs zsh vim sudo git networkmanager

genfstab -U /mnt >> /mnt/etc/fstab

crypt_uuid=$(blkid -s UUID -o value "$CRYPT")

# --- config chroot ---
arch-chroot /mnt /bin/bash <<'CHROOT'
set -euo pipefail

# Variables passées via environnement parent non disponibles ici → redéfinir
HOSTNAME="archlinux"
USERNAME="jo"
TZONE="Europe/Paris"
LOCALE="fr_FR.UTF-8"
KEYMAP="fr"
SHELL_BIN="/bin/zsh"
# Récupérer l'UUID du device LUKS (injeté dans loader après chroot via env)
CRYPT_UUID_PLACEHOLDER="@@CRYPT_UUID@@"

ln -sf /usr/share/zoneinfo/$TZONE /etc/localtime
hwclock --systohc

sed -i "s/#$LOCALE/$LOCALE/" /etc/locale.gen
echo "LANG=$LOCALE" > /etc/locale.conf
locale-gen
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

echo "$HOSTNAME" > /etc/hostname
cat >/etc/hosts <<EOF
127.0.0.1 localhost
::1       localhost
127.0.1.1 $HOSTNAME.localdomain $HOSTNAME
EOF

# mkinitcpio (encrypt + resume)
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt filesystems resume fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P

# Utilisateur
useradd -m -G wheel -s $SHELL_BIN $USERNAME
echo "[*] Mot de passe root :";  passwd
echo "[*] Mot de passe $USERNAME :"; passwd $USERNAME
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
systemctl enable NetworkManager

# --- swapfile Btrfs = RAM + 2 GiB ---
mem_kb=\$(grep MemTotal /proc/meminfo | awk '{print \$2}')
mem_mib=\$(( (mem_kb + 1023) / 1024 ))
swap_mib=\$(( mem_mib + 2048 ))
SWAPFILE=/swap/swapfile
mkdir -p /swap
# crée un swapfile compatible Btrfs (no_cow, préalloué)
btrfs filesystem mkswapfile --size "\${swap_mib}M" "\$SWAPFILE"
chmod 600 "\$SWAPFILE"
mkswap "\$SWAPFILE"
swapon "\$SWAPFILE"
echo "\$SWAPFILE none swap defaults 0 0" >> /etc/fstab

# --- systemd-boot ---
bootctl --path=/boot install

# Microcode CPU
cpu_vendor=\$(LC_ALL=C lscpu | awk -F: '/Vendor ID/{gsub(/^[ \t]+/,"",\$2); print \$2}')
ucode_initrd=""
if [[ "\$cpu_vendor" == "GenuineIntel" ]]; then
  pacman -S --noconfirm --needed intel-ucode
  ucode_initrd="initrd  /intel-ucode.img"
elif [[ "\$cpu_vendor" == "AuthenticAMD" ]]; then
  pacman -S --noconfirm --needed amd-ucode
  ucode_initrd="initrd  /amd-ucode.img"
fi

# Calcul resume_offset pour hibernation sur fichier
# Nécessaire avec un swapfile (le noyau doit connaître l'offset physique)
offset=\$(filefrag -v "\$SWAPFILE" | awk '\$1==\"0:\" {gsub(/\\./,\"\"); print \$4}')
: "\${offset:=0}"  # fallback 0 si parsing diffère
resume_opts="resume=\$SWAPFILE resume_offset=\$offset"

# Entrées loader
cat >/boot/loader/loader.conf <<EOF
default arch.conf
timeout 3
editor no
EOF

# Entrée standard
cat >/boot/loader/entries/arch.conf <<EOF
title   Arch Linux (Btrfs)
linux   /vmlinuz-linux
\$ucode_initrd
initrd  /initramfs-linux.img
options cryptdevice=UUID=\$CRYPT_UUID_PLACEHOLDER:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ \$resume_opts rw
EOF

# Entrée fallback
cat >/boot/loader/entries/arch-fallback.conf <<EOF
title   Arch Linux (fallback)
linux   /vmlinuz-linux
\$ucode_initrd
initrd  /initramfs-linux-fallback.img
options cryptdevice=UUID=\$CRYPT_UUID_PLACEHOLDER:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ \$resume_opts rw
EOF

CHROOT

# injecter la vraie UUID LUKS dans les entrées systemd-boot créées en chroot
sed -i "s/@@CRYPT_UUID@@/${crypt_uuid}/g" /mnt/boot/loader/entries/arch.conf
sed -i "s/@@CRYPT_UUID@@/${crypt_uuid}/g" /mnt/boot/loader/entries/arch-fallback.conf

echo "✅ Installation terminée (LUKS + Btrfs + systemd-boot)"
echo "➡️  Tu peux maintenant copier/installer ta config : /mnt/home/${USERNAME}/"
echo "Ensuite : umount -R /mnt && swapoff -a && reboot"
