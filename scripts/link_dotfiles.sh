#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

link_home_dir() {
    local rice_dir="$SCRIPT_DIR/rice"
    
    cd "$rice_dir"
    printf "$PREFIX Linking dotfiles to $HOME...$NEWLINE"
    
    stow --target="$HOME" hypr-catppuccin hyprland hyprlock hyprpaper kitty rofi waybar
    
    cd "$SCRIPT_DIR"
    printf "$PREFIX Finished linking home directory dotfiles.$NEWLINE"
}

link_root_dirs() {
    local rice_dir="$SCRIPT_DIR/rice"
    
    cd "$rice_dir"
    printf "$PREFIX Linking dotfiles to root directories...$NEWLINE"
    
    if is_pkg_installed grub && [ -f /boot/grub/grub.cfg ]; then
        printf "$PREFIX Linking grub-theme...$NEWLINE"
        sudo stow --target=/boot/grub/themes grub-theme
    fi
    
    cd "$SCRIPT_DIR"
    printf "$PREFIX Finished linking root directory dotfiles (if any were specified).$NEWLINE"
}
