#!/bin/bash

echo "
╭─────────────────────────────────────────────────────────────────╮
│    ______           ___          ________                       │
│   / ____/______  __/ (_)___ _   /_  __/ /_  ___  ____ ___  ___  │
│  / /   / ___/ / / / / / __ `/    / / / __ \/ _ \/ __ `__ \/ _ \ │
│ / /___/ /  / /_/ / / / /_/ /    / / / / / /  __/ / / / / /  __/ │
│ \____/_/   \__, /_/_/\__,_/    /_/ /_/ /_/\___/_/ /_/ /_/\___/  │
│           /____/                                                │
╰─────────────────────────────────────────────────────────────────╯
"

if (($EUID != 0)); then
  echo "ERROR: Please run as root!\n"
  exit
fi

# Try to install dependencies

if [whereis apt | awk '{print $2}' = "*apt"]; then
  apt update && apt install libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-dpms0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev libxext-dev meson ninja-build uthash-dev
else if [whereis pacman | awk '{print $2}' = "*apt"]; then
  pacman -Suy 
fi

CONFIG_PATH="$HOME/.config";

DESKTOP_FILE="awesome_crylia.desktop";
SESSION_PATH="/usr/share/xsessions";

# Copy the desktop file to the xsessions folder
cp $DESKTOP_FILE "$SESSION_PATH/$DESKTOP_FILE"

# Check if the file got copied
if ![ -f "$SESSION_PATH/$DESKTOP_FILE"]; then
  printf '%c' "ERROR: Couldn't copy .desktop file";
fi

function y_or_n {
  while true; do
    read -p "$* [Y/N]: " yn
    case $yn in
      [Yy]*) return 1;;
      [Nn]*) return 0;;
    esac
  done
}

# $1 the folder that should be backuped
# $2 the new backup folder name
# $3 the file to copy to $1
function backup_and_copy {
  if [-d "$1"]; then
    cp -r "$1" "$2"
    if [-d "$2"]; then
        rm -r "$1"
    else
        if (yes_or_no "WARNING: Couldn't create backup of $1, continue?" == 0); then
          echo "Aborted";
          exit -1;
        fi
    fi
  fi
  cp -r "$3 $1"
  if ![-d "$1"]; then
    echo "ERROR: Couldn't copy $3 to $1"
  fi
}

backup_and_copy "$CONFIG_PATH/crylia_theme" "$CONFIG_PATH/crylia_theme_backup" "awesome"

backup_and_copy "$CONFIG_PATH/kitty" "$CONFIG_PATH/kitty_backup" "kitty"

backup_and_copy "$CONFIG_PATH/starship.toml" "$CONFIG_PATH/starship.toml.backup" "starship.toml"

# Clone, build and install my awesome fork
git clone https://github.com/Crylia/awesome /tmp
cd /tmp/awesome
make
make install
rm -rf /tmp/awesome

while true; do
  read -p "Would you like to install my neofetch config? [Y/N]: " yn
  if (($yn == [Yy*])); then
    backup_and_copy "$CONFIG_PATH/neofetch" "$CONFIG_PATH/neofetch_backup" "neofetch"
  fi
done

# Clone, build and install picom
git clone https://github.com/yshui/picom.git /tmp
meson setup --buildtype=release build
ninja -C build
ninja -C build install
rm -rf /tmp/picom
