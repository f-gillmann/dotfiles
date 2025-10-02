#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

run_package_install() {
    printf "$PREFIX Proceeding to package installation...$NEWLINE"

    # Install base packages
    if ! install_base "$BASE_PACKAGES"; then
        printf "$PREFIX Failed to install base packages.$NEWLINE"
        return 1
    fi
    
    # Install AUR packages
    if ! install_aur "$AUR_PACKAGES"; then
        printf "$PREFIX Failed to install AUR packages.$NEWLINE"
        return 1
    fi

    # Install custom packages if the file exists
    if [[ -f "$CUSTOM_PACKAGES" ]]; then
        printf "$PREFIX Found custom packages file, installing...$NEWLINE"
        if ! install_base "$CUSTOM_PACKAGES"; then
            printf "$PREFIX Failed to install custom packages.$NEWLINE"
            return 1
        fi
    fi

    printf "$PREFIX Finished installing all packages.$NEWLINE"
    return 0
}
