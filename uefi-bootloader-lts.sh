#!/usr/bin/env bash
set -euo pipefail

# Arch Linux UEFI bootloader installer
# ESP must be mounted at /boot
# Usage:
#   sudo ./uefi-bootloader.sh                 # install systemd-boot (default)
#   sudo ./uefi-bootloader.sh --systemd-boot  # force systemd-boot
#   sudo ./uefi-bootloader.sh --grub          # force GRUB (UEFI)
#   sudo ./uefi-bootloader.sh --dry-run       # preview without executing

BOOTLOADER="systemd-boot"   # default
DRY_RUN="no"

bold() { printf "\033[1m%s\033[0m\n" "$*"; }
die()  { echo "ERROR: $*" >&2; exit 1; }
doit() { if [[ "$DRY_RUN" == "yes" ]]; then echo "[dry-run] $*"; else eval "$@"; fi; }

# Check root
[[ $EUID -eq 0 ]] || die "Run as root (use sudo)."

# Detect args
while (( "$#" )); do
  case "$1" in
    --systemd-boot) BOOTLOADER="systemd-boot"; shift ;;
    --grub)         BOOTLOADER="grub"; shift ;;
    --dry-run)      DRY_RUN="yes"; shift ;;
    -h|--help)
      cat <<EOF
Usage: $(basename "$0") [--systemd-boot | --grub] [--dry-run]

Bootloaders:
  --systemd-boot   Install systemd-boot (default, recommended)
  --grub           Install GRUB for UEFI

Other:
  --dry-run        Show what would be executed
  -h, --help       Show this help
EOF
      exit 0 ;;
    *) die "Unknown option: $1 (use --help)" ;;
  esac
done

# Confirm UEFI
[[ -d /sys/firmware/efi/efivars ]] || die "System is not UEFI."

ESP="/boot"
[[ -d "$ESP" ]] || die "ESP not mounted at /boot."

ROOT_UUID="$(blkid -s UUID -o value "$(findmnt -no SOURCE /)")"
[[ -n "$ROOT_UUID" ]] || die "Could not determine root UUID."

bold "==> System: UEFI"
bold "==> ESP: $ESP"
bold "==> Root UUID: $ROOT_UUID"
bold "==> Bootloader: $BOOTLOADER"

if [[ "$BOOTLOADER" == "systemd-boot" ]]; then
  doit "pacman -Sy --needed --noconfirm systemd efibootmgr"

  bold "==> Installing systemd-boot..."
  doit "bootctl --esp-path=\"$ESP\" install"

  LOADER_DIR="$ESP/loader"
  ENTRIES_DIR="$LOADER_DIR/entries"
  doit "mkdir -p \"$ENTRIES_DIR\""

  bold "==> Writing loader.conf..."
  doit "bash -c 'cat > \"$LOADER_DIR/loader.conf\" <<EOF
default arch
timeout 2
console-mode max
editor no
EOF'"

  bold "==> Creating Arch entry..."
  doit "bash -c 'cat > \"$ENTRIES_DIR/arch.conf\" <<EOF
title   Arch Linux
linux   /vmlinuz-linux-lts
initrd  /initramfs-linux-lts.img
options root=UUID=$ROOT_UUID rw systemd.unit=multi-user.target nomodeset noapic noacpi quiet loglevel=3 nowatchdog
EOF'"

  bold "==> Creating fallback entry..."
  doit "bash -c 'cat > \"$ENTRIES_DIR/arch-fallback.conf\" <<EOF
title   Arch Linux (fallback)
linux   /vmlinuz-linux-lts
initrd  /initramfs-linux-lts-fallback.img
options root=UUID=$ROOT_UUID rw systemd.unit=multi-user.target nomodeset noapic noacpi
EOF'"

  bold "==> Updating bootloader..."
  doit "bootctl --esp-path=\"$ESP\" update || true"
  doit "mkinitcpio -P"

  bold "==> Done! systemd-boot installed."

elif [[ "$BOOTLOADER" == "grub" ]]; then
  doit "pacman -Sy --needed --noconfirm grub efibootmgr"

  bold "==> Installing GRUB for UEFI..."
  doit "grub-install --target=x86_64-efi --efi-directory=\"$ESP\" --bootloader-id=Arch --recheck"

  bold "==> Generating grub.cfg..."
  doit "mkdir -p /boot/grub"
  if [[ ! -f /etc/default/grub ]]; then
    doit "bash -c 'cat > /etc/default/grub <<EOF
GRUB_DEFAULT=0
GRUB_TIMEOUT=2
GRUB_DISTRIBUTOR=Arch
GRUB_CMDLINE_LINUX=\"quiet loglevel=3 nowatchdog\"
EOF'"
  fi
  doit "grub-mkconfig -o /boot/grub/grub.cfg"

  bold "==> Done! GRUB installed."
fi

bold "==> Installation complete. You can reboot now."
