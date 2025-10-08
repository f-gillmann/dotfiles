#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

run_yay_install() {
    if pacman -Qq "yay" &> /dev/null; then
        printf "$PREFIX yay is already installed.$NEWLINE"
        return 0
    fi
    
    printf "$PREFIX Installing yay...$NEWLINE"
    
    # Clone yay repository
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    
    # Build and install yay
    makepkg -si --noconfirm
    
    cd "$SCRIPT_DIR"
    rm -rf /tmp/yay
    
    if [[ $? -eq 0 ]]; then
        printf "$PREFIX yay has been installed successfully.$NEWLINE"
        return 0
    else
        printf "$PREFIX Failed to install yay.$NEWLINE"
        return 1
    fi
}
