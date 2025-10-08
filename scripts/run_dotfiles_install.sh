#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

install_dotfiles() {
    local rice_dir="$SCRIPT_DIR/rice"
    cd "$rice_dir"
    printf "$PREFIX Installing dotfiles to $HOME...$NEWLINE"
    
    local stow_pkgs="hyprcursor hyprland kitty quickshell wallpapers zsh"
    
    # Create some dirs in case they don't exist to make sure
    # that we don't have an ugly linking problem with stow
    mkdir -p "$HOME/.config/hypr"
    mkdir -p "$HOME/.local/share/icons"
    
    stow --adopt --target="$HOME" $stow_pkgs
    
    # Git reset in case we adopted unwanted changes
    cd "$SCRIPT_DIR"
    git reset --hard HEAD
    cd "$rice_dir"
    
    xdg-user-dirs-update
    
    cd "$SCRIPT_DIR"
    printf "$PREFIX Finished installing home directory dotfiles.$NEWLINE"
}

run_dotfiles_install() {
    printf "$PREFIX Installing dotfiles...$NEWLINE"

    if ! install_dotfiles; then
        printf "$PREFIX Failed to install home directory dotfiles.$NEWLINE"
        return 1
    fi

    printf "$PREFIX Finished installing dotfiles.$NEWLINE"
    return 0
}
