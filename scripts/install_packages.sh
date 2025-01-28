#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

install_base() {
  if [[ -f "$1" ]]; then
    printf "$PREFIX Installing base packages from $1...\n"
    sudo pacman -Sq --needed --noconfirm - < "$1" || {
      printf "$PREFIX Error: Failed to install base packages.\n"
      exit 1
    }
    printf "$PREFIX Base packages installed successfully.\n"
  else
    printf "$PREFIX Error: Base package list '$1' not found.\n"
    exit 1
  fi
}

install_aur() {
  if [[ -f "$1" ]]; then
    printf "$PREFIX Installing AUR packages from $1...\n"
    yay -Sq --needed --noconfirm - < "$1" || {
      printf "$PREFIX Error: Failed to install AUR packages.\n"
      exit 1
    }
    printf "$PREFIX AUR packages installed successfully.\n"
  else
    printf "$PREFIX Error: AUR package list '$1' not found.\n"
    exit 1
  fi
}
