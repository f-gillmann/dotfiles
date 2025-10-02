#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

run_system_checks() {
    printf "$PREFIX Running system checks...$NEWLINE"
    
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
    
    printf "$PREFIX System checks passed.$NEWLINE"
}
