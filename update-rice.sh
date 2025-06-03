#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

#------------#
# Update Dir #
#------------#

PREVIOUS_DIR=$(pwd)
DOTS_DIR="$HOME/dotfiles"

cd $DOTS_DIR

#----------------#
# Source Scripts #
#----------------#

source ./scripts/functions.sh
source ./scripts/install_dotfiles.sh

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

BASE_PACKAGES="packages/base.pkgs"
AUR_PACKAGES="packages/aur.pkgs"
CUSTOM_PACKAGES="packages/custom.pkgs"

SCRIPT_DIR="$DOTS_DIR"

#-----------------#
# Print Ascii Art #
#-----------------#

print_ascii_art $COLOR $LIGHT_COLOR

#--------------#
# System Check #
#--------------#

# Check if we're running with root
if [ "$EUID" -eq 0 ]; then
    printf "$PREFIX You are running this script with sudo or as root, please stop, exiting...$NEWLINE"
    exit 1
fi

# Check if we're on an arch system
if ! grep -qsE '(ID=arch|ID_LIKE=arch)' /etc/*-release; then
    printf "$PREFIX You are not running an Arch or Arch-based Linux distribution.$NEWLINE"
    exit 1
fi

# Check if we're on an arch-based system
if grep -qsE '(ID_LIKE=arch)' /etc/*-release; then
    printf "$PREFIX Running on an Arch-based distribution is not officially supported${NEWLINE}${PREFIX}"
    read -r -p " Do you wish to proceed with installation? [y/N] " response
    
    if [[ "$response" =~ ^[nN]$ ]]; then
        printf "$PREFIX Exiting...$NEWLINE"
        exit 1
    fi
fi

#------------------#
# Install dotfiles #
#------------------#

printf "$PREFIX Installing dotfiles...$NEWLINE"

install_home_dir
install_root_dirs

printf "$PREFIX Finished installing dotfiles...$NEWLINE"

cd $PREVIOUS_DIR