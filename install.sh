#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

#-----------#
# Variables #
#-----------#

SCRIPT_DIR="$HOME/.local/flg-dots"

# Get a random color for our highlights that is not black (30) or bigger than white (37)
HIGHLIGHT_COLOR=$((31 + $RANDOM % 6))

COLOR="\e[${HIGHLIGHT_COLOR}m"
LIGHT_COLOR="\e[$((${HIGHLIGHT_COLOR} + 60))m"
RESET_COLOR="\e[0m"
NEWLINE="\n"
PREFIX="${COLOR}\$${RESET_COLOR}/${LIGHT_COLOR}>${RESET_COLOR}"

BASE_PACKAGES="$SCRIPT_DIR/packages/base.pkgs"
AUR_PACKAGES="$SCRIPT_DIR/packages/aur.pkgs"
CUSTOM_PACKAGES="$SCRIPT_DIR/packages/custom.pkgs"

CURRENT_USER=$(whoami)
DATE_TIME=$(date +"%Y%m%d_%H%M%S")
UPDATE_MODE=false

#----------------#
# Source Scripts #
#----------------#

source "$SCRIPT_DIR/scripts/functions.sh"
source "$SCRIPT_DIR/scripts/install_dependencies.sh"
source "$SCRIPT_DIR/scripts/install_dotfiles.sh"
source "$SCRIPT_DIR/scripts/install_packages.sh"

# Source modular installation scripts
source "$SCRIPT_DIR/scripts/system_checks.sh"
source "$SCRIPT_DIR/scripts/check_dependencies.sh"
source "$SCRIPT_DIR/scripts/run_install_yay.sh"
source "$SCRIPT_DIR/scripts/run_package_install.sh"
source "$SCRIPT_DIR/scripts/install_omz.sh"
source "$SCRIPT_DIR/scripts/install_oh_my_posh.sh"
source "$SCRIPT_DIR/scripts/run_dotfiles_install.sh"
source "$SCRIPT_DIR/scripts/update_mode.sh"

#-----------------#
# Print Ascii Art #
#-----------------#

print_ascii_art $COLOR $LIGHT_COLOR

#-----------------------#
# Detect Install/Update #
#-----------------------#

if detect_update_mode; then
    UPDATE_MODE=true
    run_update_mode
    exit 0
fi

#-----------------------#
# Run Installation Flow #
#-----------------------#

printf "${NEWLINE}${PREFIX} ${LIGHT_COLOR}=== INSTALLING DOTFILES ===${RESET_COLOR}${NEWLINE}"

# 1. System checks
run_system_checks || exit 1

# 2. Check and install dependencies
run_dependency_check || exit 1

# 3. Install yay AUR helper
run_install_yay || exit 1

# 4. Install all packages
run_package_install || exit 1

# 5. Install Oh My Zsh
run_install_omz || exit 1

# 6. Install Oh My Posh
run_install_oh_my_posh || exit 1

# 7. Install dotfiles
run_dotfiles_install || exit 1

# 8. Mark installation complete
mark_installation_complete

printf "${NEWLINE}${PREFIX} ${LIGHT_COLOR}Installation completed successfully!${RESET_COLOR}${NEWLINE}"
printf "$PREFIX Please reboot your system to apply all changes.${NEWLINE}${NEWLINE}"
