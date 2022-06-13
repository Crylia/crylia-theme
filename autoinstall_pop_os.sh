#!/bin/bash

echo " "
echo "		___   __  ____________  ____________  ____    _______  "
echo "	   /   | / / / /_  __/ __ \/ ____/ __ \ \/ / /   /  _/   | "
echo "	  / /| |/ / / / / / / / / / /   / /_/ /\  / /    / // /| | "
echo "	 / ___ / /_/ / / / / /_/ / /___/ _, _/ / / /____/ // ___ | "
echo "	/_/  |_\____/ /_/  \____/\____/_/ |_| /_/_____/___/_/  |_| "
echo " "                                                          


# dependencies for meson, ninja, rofi, awesome and all extra optional packages
sudo apt -y install meson ninja-build cmake cmake-data pkg-config papirus-icon-theme xorg build-essential git make autoconf automake flex bison check go-md2man doxygen cppcheck ohcount pulseaudio-utils upower bluez xorg xfce4-power-manager playerctl lightdm light-locker libxcb-ewmh-dev libxcb-xfixes0-dev libev-dev libxcb-damage0-dev libxcb-sync-dev libxcb-composite0-dev libxcb-present-dev uthash-dev libconfig-dev libgl-dev alacritty bison flex check

# fonts
cd
mkdir .fonts
cd .fonts
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf 
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf

# awesome-git (awesome from apt does NOT work)
cd
sudo apt  build-dep -y awesome
git clone https://github.com/awesomewm/awesome
cd awesome
make package
cd build/
sudo dpkg -i awesome*.deb

# rofi (rofi  from apt does NOT work)
cd
git clone https://github.com/davatorium/rofi/
cd rofi
meson setup build
ninja -C build
ninja -C build install

# picom  (picom from apt does NOT work)
cd
git clone https://github.com/jonaburg/picom
cd picom
meson --buildtype=release . build
sudo ninja -C build
sudo ninja -C build install

cd
git clone --recurse-submodules https://github.com/Crylia/crylia-theme
cd crylia-theme
cp -r awesome ~/.config/.
cp -r picom.conf ~/.config/.
cp -r rofi ~/.config/.
cp -r alacritty ~/.config/.


echo " ===== make sure to reboot and select awesome desktop ====== "
