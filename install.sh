#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

#----------------#
# Source Scripts #
#----------------#

source ./scripts/functions.sh
source ./scripts/yay.sh

#-----------#
# Variables #
#-----------#

HIGHLIGHT_COLOR=$(get_highlight_color)
COLOR="\e[${HIGHLIGHT_COLOR}m"
LIGHT_COLOR="\e[$((${HIGHLIGHT_COLOR} + 60))m"
RESET_COLOR="\e[0m"

PREFIX="${COLOR}\$${RESET_COLOR}/${LIGHT_COLOR}>${RESET_COLOR}"

#-----------------#
# Print ascii art #
#-----------------#

print_ascii_art $COLOR $LIGHT_COLOR

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
