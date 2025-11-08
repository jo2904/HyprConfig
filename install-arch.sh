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
  echo "Usage: $0 /dev/sdX | /dev/nvme0n1"
  exit 1
fi

read -rp "⚠️ Le disque $DISK sera ENTIEREMENT effacé. Taper 'OUI' pour confirmer : " OK
[[ "$OK" == "OUI" ]] || exit 1

# --- Nettoyage ---
echo "[*] Préparation du disque..."
swapoff -a || true
umount -R /mnt 2>/dev/null || true
cryptsetup close cryptroot 2>/dev/null || true
vgchange -an 2>/dev/null || true

# --- Partitionnement ---
echo "[*] Partitionnement GPT (EFI + LUKS)..."
wipefs -af "$DISK"
sgdisk -Zo "$DISK"
sleep 1
sgdisk -n1:0:+512MiB -t1:ef00 -c1:"EFI"
sgdisk -n2:0:0       -t2:8309 -c2:"cryptroot"
sync
# 🔧 Force kernel rescan
for i in {1..5}; do
  partprobe "$DISK" || true
  partx -u "$DISK" || true
  sleep 2
  if lsblk "$DISK" | grep -q "${DISK}1"; then
    break
  fi
  echo "[!] Partition table not visible yet, retrying ($i/5)..."
done

lsblk "$DISK"

read -rp "Vérifie ci-dessus que ${EFI} et ${CRYPT} existent, puis ENTER pour continuer"

# --- Chiffrement ---
echo "[*] Chiffrement LUKS2..."
cryptsetup luksFormat --type luks2 "$CRYPT"
cryptsetup open "$CRYPT" cryptroot

# --- Systèmes de fichiers ---
mkfs.fat -F32 "$EFI"
mkfs.btrfs -L archsys /dev/mapper/cryptroot

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
mount "$EFI" /mnt/boot

# --- Installation du système de base ---
echo "[*] Installation des paquets de base..."
pacman -Sy --noconfirm reflector
reflector --country France,Germany --protocol https --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

pacstrap -K /mnt base base-devel linux linux-firmware \
  btrfs-progs zsh vim sudo git networkmanager

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
echo "[*] Définis un mot de passe root :"
passwd
echo "[*] Définis un mot de passe pour $USERNAME :"
passwd $USERNAME
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
systemctl enable NetworkManager

# --- Swapfile Btrfs (RAM + 2 GiB) ---
mem_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
mem_mib=$(( (mem_kb + 1023) / 1024 ))
swap_mib=$(( mem_mib + 2048 ))
SWAPFILE=/swap/swapfile
mkdir -p /swap
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
offset=$(filefrag -v "$SWAPFILE" | awk '$1=="0:" {gsub(/\./,""); print $4}')
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

# Injection de la vraie UUID
sed -i "s/@@CRYPT_UUID@@/${crypt_uuid}/g" /mnt/boot/loader/entries/arch.conf
sed -i "s/@@CRYPT_UUID@@/${crypt_uuid}/g" /mnt/boot/loader/entries/arch-fallback.conf

echo "✅ Installation terminée (LUKS + Btrfs + systemd-boot)"
echo "➡️  Tu peux maintenant copier ton dossier 'config' ou faire un git clone dans /mnt/home/${USERNAME}/"
echo "Ensuite : umount -R /mnt && swapoff -a && reboot"
