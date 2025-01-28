#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

#----------------#
# Source Scripts #
#----------------#

source ./scripts/functions.sh
source ./scripts/install_packages.sh

#-----------#
# Variables #
#-----------#

HIGHLIGHT_COLOR=$((31 + $RANDOM % 6))
COLOR="\e[${HIGHLIGHT_COLOR}m"
LIGHT_COLOR="\e[$((${HIGHLIGHT_COLOR} + 60))m"
RESET_COLOR="\e[0m"
PREFIX="${COLOR}\$${RESET_COLOR}/${LIGHT_COLOR}>${RESET_COLOR}"

BASE_PACKAGES="packages/base.list"
AUR_PACKAGES="packages/aur.list"

#-----------------#
# Print ascii art #
#-----------------#

print_ascii_art $COLOR $LIGHT_COLOR

#--------------#
# System check #
#--------------#

if ! grep -qE '(ID=arch|ID_LIKE=arch)' /etc/*-release; then
  printf "$PREFIX You are not running an Arch or Arch-based Linux distribution.\n"
  exit 1
fi

if ! grep -qE '(ID_LIKE=arch)' /etc/*-release; then
  printf "$PREFIX Running on an Arch-based distribution is not officially supported\n$PREFIX"
  read -r -p " Do you wish to proceed with installation? [y/N] " response

  if [[ "$response" =~ ^[nN]$ ]]; then
    printf "$PREFIX Exiting...\n"
    exit 1
  fi
fi

#--------------------#
# Check dependencies #
#--------------------#

DEPENDENCIES=("git" "base-devel")
MISSING_DEPENDENCIES=()

# Check if dependencies are missing
for dep in "${DEPENDENCIES[@]}"; do
  if ! pacman -Qq "$dep" &> /dev/null; then
    MISSING_DEPENDENCIES+=("$dep")
  fi
done

# Install missing dependencies
if [[ ${#MISSING_DEPENDENCIES} -gt 0 ]]; then
  printf "$PREFIX The following dependencies are missing:\n"

  for dep in "${MISSING_DEPENDENCIES[@]}"; do
    echo "- $dep"
  done

  printf "$PREFIX"
  read -r -p " Do you want to install them? [y/N] " response

  if [[ "$response" =~ ^[yY]$ ]]; then
    sudo pacman -Sy
    sudo pacman -S --needed --noconfirm "${MISSING_DEPENDENCIES[@]}"
  else
    printf "$PREFIX Exiting because required dependencies are not installed.\n"
    exit 1
  fi
else
  printf "$PREFIX Dependencies are already installed.\n"
fi

#-------------#
# Install yay #
#-------------#

if pacman -Qq "yay" &> /dev/null; then
  printf "$PREFIX yay is already installed.\n"
else
  printf "$PREFIX Installing yay...\n"
  install_yay &&
  printf "$PREFIX yay has been installed successfully.\n"
fi

#------------------#
# Install packages #
#------------------#

printf "$PREFIX Proceeding to package installation...\n"

install_base "$BASE_PACKAGES" &&
install_aur "$AUR_PACKAGES" &&

printf "$PREFIX Finished installing all packages.\n"
