#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

#----------------#
# Source Scripts #
#----------------#

source ./functions.sh

#-----------------#
# Print ascii art #
#-----------------#

HIGHLIGHT_COLOR=$(get_highlight_color)
print_ascii_art $HIGHLIGHT_COLOR

#--------------------#
# Check dependencies #
#--------------------#

DEPENDENCIES=("git")
MISSING_DEPENDENCIES=$(check_dependencies "${DEPENDENCIES[@]}")

if [[ ${#MISSING_DEPENDENCIES} -gt 0 ]]; then
  echo "The following dependencies are missing:"
  for dep in "${MISSING_DEPENDENCIES[@]}"; do
    echo "- $dep"
  done

  read -r -p "Do you want to install them? [y/N] " response
  if [[ "$response" =~ ^[yY]$ ]]; then
    sudo pacman -S "${MISSING_DEPENDENCIES[@]}"
  else
    echo "Exiting because required dependencies are not installed."
    exit 1
  fi
fi

