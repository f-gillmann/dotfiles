#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

print_ascii_art() {
    # ██████╗  ██████╗ ████████╗███████╗
    # ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝
    # ██║  ██║██║   ██║   ██║   ███████╗
    # ██║  ██║██║   ██║   ██║   ╚════██║
    # ██████╔╝╚██████╔╝   ██║   ███████║
    # ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝
    #
    # █████████████████████████████████╗
    # ╚════════════════════════════════╝

    RESET="\e[0m"
    NEWLINE="\n"

    # Print the ascii art from the comment above with a specified color and light color
    printf "${NEWLINE}"
    printf "    ${RESET}██████${1}╗${RESET}  ██████${1}╗${RESET} ████████${1}╗${RESET}███████${1}╗${RESET}${NEWLINE}"
    printf "    ${RESET}██${1}╔══${RESET}██${1}╗${RESET}██${1}╔═══${RESET}██${1}╗╚══${RESET}██${1}╔══╝${RESET}██${1}╔════╝${RESET}${NEWLINE}"
    printf "    ${RESET}██${1}║${RESET}  ██${1}║${RESET}██${1}║${RESET}   ██${1}║${RESET}   ██${1}║${RESET}   ███████${1}╗${RESET}${NEWLINE}"
    printf "    ${RESET}██${1}║${RESET}  ██${1}║${RESET}██${1}║${RESET}   ██${1}║${RESET}   ██${1}║${RESET}   ${1}╚════${RESET}██${1}║${RESET}${NEWLINE}"
    printf "    ${RESET}██████${1}╔╝╚${RESET}██████${1}╔╝${RESET}   ██${1}║${RESET}   ███████${1}║${RESET}${NEWLINE}"
    printf "    ${1}╚═════╝${RESET}  ${1}╚═════╝${RESET}    ${1}╚═╝${RESET}   ${1}╚══════╝${RESET}${NEWLINE}"
    printf "    █████████████████████████████████${2}╗${RESET}${NEWLINE}"
    printf "    ${2}╚════════════════════════════════╝${NEWLINE}"
    printf "        ${RESET}made by${RESET} ${2}Florian Gillmann${RESET}${NEWLINE}${NEWLINE}"
}

install_yay() {
    PREVIOUS_DIR=$(pwd)
    TEMP_DIR=$(mktemp -d)
    if [[ "$DRY_RUN" == true ]]; then
        printf "$PREFIX [DRY_RUN] Would run: git clone https://aur.archlinux.org/yay-bin.git $TEMP_DIR$NEWLINE"
        printf "$PREFIX [DRY_RUN] Would run: cd $TEMP_DIR && makepkg -o && makepkg -se && makepkg -i --noconfirm$NEWLINE"
        printf "$PREFIX [DRY_RUN] Would run: rm -rf $TEMP_DIR$NEWLINE"
    else
        git clone -c init.defaultBranch=master --quiet https://aur.archlinux.org/yay-bin.git $TEMP_DIR
        cd $TEMP_DIR &&
        makepkg -o &&
        makepkg -se &&
        makepkg -i --noconfirm
        cd $PREVIOUS_DIR
        rm -rf $TEMP_DIR
    fi
}

is_pkg_installed() {
    local PKG=$1

    if pacman -Qi "${PKG}" &>/dev/null; then
      return 0
    else
      return 1
    fi
}

# Thanks to
# https://github.com/HyDE-Project/HyDE/blob/a1ed62411cd86426002bb3b0b968ebc0cac9da18/Scripts/global_fn.sh#L69-L88
detect_nvidia() {
    readarray -t GPU < <(lspci -k | grep -E "VGA|3D" | awk -F ': ' '{print $NF}')

    if grep -iq nvidia <<<"${GPU[@]}"; then
      return 0
    else
      return 1
    fi
}
