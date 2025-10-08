#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

run_install_omz() {
    printf "$PREFIX Checking for Oh My Zsh installation...$NEWLINE"
    
    if ! command -v zsh >/dev/null 2>&1; then
        printf "$PREFIX ERROR: zsh not found, cannot install Oh My Zsh or change default shell.$NEWLINE"
        return 1
    fi
    
    # Install Oh My Zsh if not present
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        printf "$PREFIX Installing Oh My Zsh...$NEWLINE"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
        
        # Change default shell to zsh
        printf "$PREFIX Changing default shell to zsh...$NEWLINE"
        chsh -s "$(command -v zsh)" "$CURRENT_USER"
        
        printf "$PREFIX Oh My Zsh installed successfully.$NEWLINE"
    else
        printf "$PREFIX Oh My Zsh is already installed.$NEWLINE"
    fi
    
    # Check and install fast-syntax-highlighting plugin
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting" ]; then
        printf "$PREFIX Installing fast-syntax-highlighting plugin...$NEWLINE"
        git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
    else
        printf "$PREFIX fast-syntax-highlighting plugin is already installed.$NEWLINE"
    fi
    
    # Check and install zsh-syntax-highlighting plugin
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
        printf "$PREFIX Installing zsh-syntax-highlighting plugin...$NEWLINE"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    else
        printf "$PREFIX zsh-syntax-highlighting plugin is already installed.$NEWLINE"
    fi
    
    return 0
}
