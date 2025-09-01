#!/bin/bash

sudo pacman -S kitty nautilus btop fastfetch wayland xorg-xwayland wayland-utils xorg xorg-server xorg-xinit xf86-video-intel hyprland swaync waybar rofi pipewire linux-headers dkms intel-ucode alsa-utils mesa --noconfirm

git clone https://aur.archlinux.org/yay.git

cd yay

makepkg -si
