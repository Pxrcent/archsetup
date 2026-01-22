quick script to just install a fully functional bootloader on your arch linux UEFI x86-64 manual instalation,
just git clone this repo while chrooted and chmod the script to execute it.

by default it goes with the systemd-boot bootloader but you can choose grub by passing the flag --grub like this:

sudo ./uefi-bootloader.sh --grub

or force the systemd-boot by passing the --systemd-boot flag like this:

sudo ./uefi-bootloader.sh --systemd-boot

## This script was generated with the use with AI, to be more especific CHAT-GPT o5
