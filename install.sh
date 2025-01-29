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

# Get a random color for our highlights that is not black (30) or bigger than white (37)
HIGHLIGHT_COLOR=$((31 + $RANDOM % 6))

COLOR="\e[${HIGHLIGHT_COLOR}m"
LIGHT_COLOR="\e[$((${HIGHLIGHT_COLOR} + 60))m"
RESET_COLOR="\e[0m"
NEWLINE="\n"
PREFIX="${COLOR}\$${RESET_COLOR}/${LIGHT_COLOR}>${RESET_COLOR}"

BASE_PACKAGES="packages/base.list"
AUR_PACKAGES="packages/aur.list"

#-----------------#
# Print Ascii Art #
#-----------------#

print_ascii_art $COLOR $LIGHT_COLOR

#--------------#
# System Check #
#--------------#

# Check if we're on an arch system
if ! grep -qE '(ID=arch|ID_LIKE=arch)' /etc/*-release; then
  printf "$PREFIX You are not running an Arch or Arch-based Linux distribution.$NEWLINE"
  exit 1
fi

# Check if we're on an arch-based system
if ! grep -qE '(ID_LIKE=arch)' /etc/*-release; then
  printf "$PREFIX Running on an Arch-based distribution is not officially supported${$NEWLINE}${PREFIX}"
  read -r -p " Do you wish to proceed with installation? [y/N] " response

  if [[ "$response" =~ ^[nN]$ ]]; then
    printf "$PREFIX Exiting...$NEWLINE"
    exit 1
  fi
fi

#--------------------#
# Check Dependencies #
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
  printf "$PREFIX The following dependencies are missing:$NEWLINE"

  for dep in "${MISSING_DEPENDENCIES[@]}"; do
    echo "- $dep"
  done

  printf "$PREFIX"
  read -r -p " Do you want to install them? [y/N] " response

  if [[ "$response" =~ ^[yY]$ ]]; then
    sudo pacman -Sy
    sudo pacman -S --needed --noconfirm "${MISSING_DEPENDENCIES[@]}"
  else
    printf "$PREFIX Exiting because required dependencies are not installed.$NEWLINE"
    exit 1
  fi
else
  printf "$PREFIX Dependencies are already installed.$NEWLINE"
fi

#-------------#
# Install yay #
#-------------#

if pacman -Qq "yay" &> /dev/null; then
  printf "$PREFIX yay is already installed.$NEWLINE"
else
  printf "$PREFIX Installing yay...$NEWLINE"
  install_yay &&
  printf "$PREFIX yay has been installed successfully.$NEWLINE"
fi

#------------------#
# Install Packages #
#------------------#

printf "$PREFIX Proceeding to package installation...$NEWLINE"

install_base "$BASE_PACKAGES" &&
install_aur "$AUR_PACKAGES" &&

printf "$PREFIX Finished installing all packages.$NEWLINE"
