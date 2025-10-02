#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

install_home_dir() {
    local rice_dir="$SCRIPT_DIR/rice"
    cd "$rice_dir"
    printf "$PREFIX Installing dotfiles to $HOME...$NEWLINE"
    
    local stow_pkgs="hyprcursor hyprland quickshell kitty rofi wallpapers wallust waypaper zsh"
    
    # Create some dirs in case they don't exist to make sure
    # that we don't have an ugly linking problem with stow
    mkdir -p "$HOME/.config/hypr"
    mkdir -p "$HOME/.local/share/icons"
    
    stow --adopt --target="$HOME" $stow_pkgs
    
    # Git reset in case we adopted unwanted changes
    cd "$SCRIPT_DIR"
    git reset --hard HEAD
    cd "$rice_dir"
    
    # Enable Nvidia-specific configuration if Nvidia GPU is detected
    if detect_nvidia; then
        printf "$PREFIX Nvidia GPU detected, enabling Nvidia-specific configuration...$NEWLINE"
        local hyprland_conf="$HOME/.config/hypr/hyprland.conf"
        
        if [ -f "$hyprland_conf" ]; then
            # Uncomment the nvidia.conf source line
            sed -i 's/^#source = ~\/.config\/hypr\/hyprland\/nvidia\.conf/source = ~\/.config\/hypr\/hyprland\/nvidia.conf/' "$hyprland_conf"
            printf "$PREFIX Nvidia configuration enabled in hyprland.conf.$NEWLINE"
        else
            printf "$PREFIX Warning: hyprland.conf not found at $hyprland_conf.$NEWLINE"
        fi
    else
        printf "$PREFIX No Nvidia GPU detected, using default configuration.$NEWLINE"
    fi
    
    xdg-user-dirs-update
    
    cd "$SCRIPT_DIR"
    printf "$PREFIX Finished installing home directory dotfiles.$NEWLINE"
}
