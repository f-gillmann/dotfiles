#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

run_dotfiles_install() {
    printf "$PREFIX Installing dotfiles...$NEWLINE"

    if ! install_home_dir; then
        printf "$PREFIX Failed to install home directory dotfiles.$NEWLINE"
        return 1
    fi

    printf "$PREFIX Finished installing dotfiles.$NEWLINE"
    return 0
}
