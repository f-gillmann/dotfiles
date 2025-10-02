#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

run_install_omz() {
    printf "$PREFIX Checking for Oh My Zsh installation...$NEWLINE"
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        printf "$PREFIX Oh My Zsh is already installed.$NEWLINE"
        return 0
    fi
    
    if ! command -v zsh >/dev/null 2>&1; then
        printf "$PREFIX ERROR: zsh not found, cannot install Oh My Zsh or change default shell.$NEWLINE"
        return 1
    fi
    
    printf "$PREFIX Installing Oh My Zsh...$NEWLINE"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Remove default zshrc files that OMZ creates
    rm -f "$HOME/.zshrc"*
    
    # Change default shell to zsh
    printf "$PREFIX Changing default shell to zsh...$NEWLINE"
    chsh -s "$(command -v zsh)" "$CURRENT_USER"
    
    printf "$PREFIX Oh My Zsh installed successfully.$NEWLINE"
    return 0
}
