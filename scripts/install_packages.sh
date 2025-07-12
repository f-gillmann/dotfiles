#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

install_base() {
    if [[ -f "$1" ]]; then
        printf "$PREFIX Installing base packages from $1...$NEWLINE"
        if [[ "$DRY_RUN" == true ]]; then
            printf "$PREFIX [DRY_RUN] Would run: sudo pacman -Syq --needed --noconfirm - < \"$1\"$NEWLINE"
        else
            sudo pacman -Syq --needed --noconfirm - < "$1" 2>&1 | sed 's/warning:/ ->/g;' || {
                printf "$PREFIX Error: Failed to install base packages.$NEWLINE"
                exit 1
            }
            printf "$PREFIX Base packages installed successfully.$NEWLINE"
        fi
    else
        printf "$PREFIX Error: Base package list '$1' not found.$NEWLINE"
        exit 1
    fi
}

install_aur() {
    if [[ -f "$1" ]]; then
        printf "$PREFIX Installing AUR packages from $1...$NEWLINE"
        if [[ "$DRY_RUN" == true ]]; then
            printf "$PREFIX [DRY_RUN] Would run: yay -Syq --needed --noconfirm - < \"$1\"$NEWLINE"
        else
            yay -Syq --needed --noconfirm - < "$1" || {
                printf "$PREFIX Error: Failed to install AUR packages.$NEWLINE"
                exit 1
            }
            printf "$PREFIX AUR packages installed successfully.$NEWLINE"
        fi
    else
        printf "$PREFIX Error: AUR package list '$1' not found.$NEWLINE"
        exit 1
    fi
}