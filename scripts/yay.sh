#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

install_yay() {
    PREVIOUS_DIR=$(pwd)
    TEMP_DIR=$(mktemp -d)

    git clone -c init.defaultBranch=master --quiet https://aur.archlinux.org/yay-bin.git $TEMP_DIR
    cd $TEMP_DIR &&
    makepkg -o &&
    makepkg -se &&
    makepkg -i --noconfirm

    cd $PREVIOUS_DIR
    rm -rf $TEMP_DIR
}
