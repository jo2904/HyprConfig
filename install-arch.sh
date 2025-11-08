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

if [[ -z "$DISK" || ! -b "$DISK" ]]; then
  echo "Usage: $0 /dev/sdX|/dev/nvme0n1"
  exit 1
fi

read -rp "⚠️ Le disque $DISK sera ENTIEREMENT effacé. Taper 'OUI' pour confirmer : " OK
[[ "$OK" == "OUI" ]] || exit 1

echo "[*] Partitionnement GPT (UEFI + LUKS + Btrfs)…"
wipefs -af "$DISK"
sgdisk -Zo "$DISK"
sgdisk -n1:0:+512MiB -t1:ef00 -c1:"EFI"
sgdisk -n2:0:0       -t2:8309 -c2:"cryptroot"
partprobe "$DISK"
sleep 2

if [[ "$DISK" == *"nvme"* ]]; then
  EFI="${DISK}p1"
  CRYPT="${DISK}p2"
else
  EFI="${DISK}1"
  CRYPT="${DISK}2"
fi

cryptsetup luksFormat --type luks2 "$CRYPT"
cryptsetup open "$CRYPT" cryptroot

mkfs.fat -F32 "$EFI"
mkfs.btrfs -L archsys /dev/mapper/cryptroot

# Subvolumes
mount /dev/mapper/cryptroot /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@swap
btrfs subvolume create /mnt/@snapshots
umount /mnt

# Montage principal
mount -o noatime,ssd,compress=zstd,space_cache=v2,subvol=@ /dev/mapper/cryptroot /mnt
mkdir -p /mnt/{boot,home,.snapshots}
mount -o noatime,ssd,compress=zstd,space_cache=v2,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o noatime,ssd,compress=zstd,space_cache=v2,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots
mount "$EFI" /mnt/boot

# Base install
pacman -Sy --noconfirm reflector
reflector --country France,Germany --protocol https --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
pacstrap -K /mnt base base-devel linux linux-firmware \
  btrfs-progs zsh vim sudo git networkmanager

genfstab -U /mnt >> /mnt/etc/fstab

crypt_uuid=$(blkid -s UUID -o value "$CRYPT")

arch-chroot /mnt /bin/bash <<CHROOT
set -euo pipefail

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

# mkinitcpio
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt filesystems resume fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P

# User
useradd -m -G wheel -s $SHELL_BIN $USERNAME
echo "[*] Mot de passe root :"
passwd
echo "[*] Mot de passe $USERNAME :"
passwd $USERNAME
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
systemctl enable NetworkManager

# Swapfile sur Btrfs
SWAPFILE=/swap/swapfile
mkdir -p /swap
btrfs filesystem mkswapfile --size 0 --size-min "$((($(grep MemTotal /proc/meminfo | awk '{print $2}') / 1024) + 2048))M" /swap/swapfile
chmod 600 /swap/swapfile
mkswap /swap/swapfile
swapon /swap/swapfile
echo "/swap/swapfile none swap defaults 0 0" >> /etc/fstab

# systemd-boot
bootctl --path=/boot install

cat >/boot/loader/loader.conf <<EOF
default arch.conf
timeout 3
editor no
EOF

cat >/boot/loader/entries/arch.conf <<EOF
title   Arch Linux (Btrfs)
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options cryptdevice=UUID=$crypt_uuid:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ resume=/swap/swapfile rw
EOF

CHROOT

echo "✅ Installation terminée (LUKS + Btrfs + systemd-boot)"
echo "➡️  Copie ton script Hyprland dans /mnt/home/$USERNAME/"
echo "Ensuite : umount -R /mnt && swapoff -a && reboot"
