#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

check_missing_dependencies() {
    declare -a MISSING=()
    local DEP
    
    for DEP in "${DEPENDENCIES[@]}"; do
        if ! pacman -Qq "$DEP" &> /dev/null; then
            MISSING+=("$DEP")
        fi
    done
    
    echo "${MISSING[@]}"
}

install_missing_depedencies() {
    local MISSING_DEPENDENCIES=("$@")
    local RESPONSE="${MISSING_DEPENDENCIES[-1]}"
    unset MISSING_DEPENDENCIES[-1]

    if [[ "$RESPONSE" =~ ^[yY]$ ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            printf "$PREFIX [DRY_RUN] Would run: sudo pacman -Sy$NEWLINE"
            printf "$PREFIX [DRY_RUN] Would run: sudo pacman -S --needed --noconfirm ${MISSING_DEPENDENCIES[*]}$NEWLINE"
            return 0
        else
            sudo pacman -Sy
            sudo pacman -S --needed --noconfirm "${MISSING_DEPENDENCIES[@]}"
            return 0
        fi
    else
        return 1
    fi
}
