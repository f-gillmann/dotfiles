#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

RESET_COLOR="\e[0m"
COLOR="\e[36m"
LIGHT_COLOR="\e[96m"
UNDERLINE="\e[4m"
NEWLINE="\n"
PREFIX="${COLOR}\$${RESET_COLOR}/${LIGHT_COLOR}>${RESET_COLOR}"

# Check if dependencies are missing
DEPENDENCIES=("git")
MISSING_DEPENDENCIES=()
for dep in "${DEPENDENCIES[@]}"; do
    if ! pacman -Qq "$dep" &> /dev/null; then
        MISSING_DEPENDENCIES+=("$dep")
    fi
done

if [[ ${#MISSING_DEPENDENCIES} -gt 0 ]]; then
    printf "$PREFIX The following dependencies are missing:$NEWLINE"
    
    for dep in "${MISSING_DEPENDENCIES[@]}"; do
        echo "- $dep"
    done
    
    printf "$PREFIX Exiting...$NEWLINE"
    exit 1
fi

printf "$PREFIX Cloning files from ${LIGHT_COLOR}${UNDERLINE}https://github.com/f-gillmann/dotfiles${RESET_COLOR}.$NEWLINE"

# Define the target directory
DOTFILES_DIR="$HOME/.local/flg-dots"

# Create .local directory if it doesn't exist
mkdir -p "$HOME/.local"

# Check if the dotfiles directory exists
if [ -d "$DOTFILES_DIR" ]; then
    printf "$PREFIX"
    read -r -p " flg-dots already exists in ~/.local/. Do you want to overwrite it? [y/N]: " overwrite
    if [[ $overwrite =~ ^[Yy]$ ]]; then
        # Remove existing directory
        rm -rf "$DOTFILES_DIR"
    else
        printf "$PREFIX Exiting...$NEWLINE"
        exit 1
    fi
fi

git clone --recurse-submodules https://github.com/f-gillmann/dotfiles.git "$DOTFILES_DIR"

printf "$PREFIX Dotfiles have been cloned into ~/.local/flg-dots.$NEWLINE"

# Prompt if we wanna run the install script
printf "$PREFIX"
read -r -p " Do you want to run the install script now? [y/N]: " install
if [[ $install =~ ^[yY]$ ]]; then
    cd "$DOTFILES_DIR" &&
    chmod +x ./install.sh &&
    ./install.sh
else
    printf "$PREFIX Exiting...$NEWLINE"
    exit 1
fi
