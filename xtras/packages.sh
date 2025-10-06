#!/bin/bash

# Do whatever script1 needs to do...
echo "Running script 1..."

# Create a flag file to signal that this script ran
touch /tmp/script1.done
#
#################################################################
#FLAG_FILE="/tmp/script1.done"
#
# if [ ! -f "$FLAG_FILE" ]; then
#    echo "Error: script1 must be run before this script."
#    exit 1
#fi
#echo "Script1 was run before — continuing with script2."
##################################################################
#
#
sudo pacman -S git nano alacritty nautilus btop plocate fastfetch hyprland swaync waybar wofi pipewire networkmanager linux-headers dkms mesa otf-font-awesome nwg-look qt6ct --noconfirm

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

sudo updatedb

sudo chmod +x $(locate wallpick.sh)


