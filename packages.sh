#!/bin/bash

sudo pacman -S git nano alacritty nautilus btop fastfetch hyprland swaync waybar wofi pipewire linux-headers dkms mesa otf-font-awesome --noconfirm

git clone https://aur.archlinux.org/yay.git

cd yay

makepkg -si
