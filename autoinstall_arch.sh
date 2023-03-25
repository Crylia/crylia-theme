#!/bin/bash

echo " "
echo "		___   __  ____________  ____________  ____    _______  "
echo "	   /   | / / / /_  __/ __ \/ ____/ __ \ \/ / /   /  _/   | "
echo "	  / /| |/ / / / / / / / / / /   / /_/ /\  / /    / // /| | "
echo "	 / ___ / /_/ / / / / /_/ / /___/ _, _/ / / /____/ // ___ | "
echo "	/_/  |_\____/ /_/  \____/\____/_/ |_| /_/_____/___/_/  |_| "
echo " "

yay -S awesome-git rofi-git picom-jonaburg-git ttf-meslo-nerd-font-powerlevel10k

sudo pacman -S papirus-icon-theme pulseaudio-alsa upower bluez bluez-utils xorg-setxkbmap xfce4-power-manager playerctl lightdm light-locker kitty thunar flameshot

cd
git clone --recurse-submodules https://github.com/Crylia/crylia-theme
cd crylia-theme
[ ! -d ~/.config/awesome ] && cp -r awesome ~/.config/. || cp -r ~/.config/awesome/ ~/.config/.awesome-backup && cp -r awesome ~/.config/.
[ ! -f ~/.config/picom.conf ] && cp picom.conf ~/.config/. || cp ~/.config/picom.conf ~/.config/.picom.conf.backup && cp picom.conf ~/.config/.
[ ! -d ~/.config/rofi ] && cp -r rofi ~/.config/. || cp -r ~/.config/rofi ~/.config/.rofi-backup && cp -r rofi ~/.config/.
[ ! -d ~/.config/kitty ] && cp -r kitty ~/.config/. || cp -r ~/.config/kitty ~/.config/.kitty-backup && cp -r kitty ~/.config/.


echo " ===== make sure to logout/reboot and select awesome desktop ====== "
