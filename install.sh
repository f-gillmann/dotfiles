#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

#----------------#
# Source Scripts #
#----------------#

source ./scripts/backups.sh
source ./scripts/functions.sh
source ./scripts/install_dependencies.sh
source ./scripts/install_dotfiles.sh
source ./scripts/install_packages.sh

#-----------#
# Variables #
#-----------#

# Get a random color for our highlights that is not black (30) or bigger than white (37)
HIGHLIGHT_COLOR=$((31 + $RANDOM % 6))

COLOR="\e[${HIGHLIGHT_COLOR}m"
LIGHT_COLOR="\e[$((${HIGHLIGHT_COLOR} + 60))m"
RESET_COLOR="\e[0m"
NEWLINE="\n"
PREFIX="${COLOR}\$${RESET_COLOR}/${LIGHT_COLOR}>${RESET_COLOR}"

BASE_PACKAGES="packages/base.pkgs"
AUR_PACKAGES="packages/aur.pkgs"
CUSTOM_PACKAGES="packages/custom.pkgs"

CURRENT_USER=$(whoami)
DATE_TIME=$(date +"%Y%m%d_%H%M%S")
SCRIPT_DIR=$(dirname "$0")
BACKUP_NAME="backup_${CURRENT_USER}_${DATE_TIME}"
BACKUP_DIR="./$BACKUP_NAME"
BACKUPS=true
DRY_RUN=false

#-------------#
# CLI options #
#-------------#

usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -n    Disable backups"
    echo "  -d    (Dry run) Show what changes would be made without applying them"
    echo "  -h    Show this help message"
    echo ""
}

while getopts ":ndh" option; do
    case $option in
        n) BACKUPS=false;;
        d) DRY_RUN=true;;
        h) usage; exit 0;;
        \?) 
            echo "Invalid option: -$OPTARG"
            usage
            exit 1;;
    esac
done

#-----------------#
# Print Ascii Art #
#-----------------#

print_ascii_art $COLOR $LIGHT_COLOR

#---------------------#
# Print Configuration #
#---------------------#

printf "$PREFIX --- Configuration ---$NEWLINE"
printf "$PREFIX Dry run:        %s$NEWLINE" "$( [ "$DRY_RUN" = true ] && echo "Enabled" || echo "Disabled" )"
printf "$PREFIX Backups:        %s$NEWLINE" "$( [ "$BACKUPS" = false ] && echo "Disabled" || echo "Enabled" )"
printf "$PREFIX User:           %s$NEWLINE" "$CURRENT_USER"
if [ "$BACKUPS" = true ]; then
    printf "$PREFIX Backup folder:  %s$NEWLINE" "$BACKUP_DIR"
fi
printf "$PREFIX --- Configuration ---$NEWLINE"
printf "$PREFIX Note: If you wanna change these, run '$0 -h' to see all options $NEWLINE"

if [ "$DRY_RUN" = false ]; then
    printf "$PREFIX Dry run is disabled. Do you want to proceed with running the script? [y/N] "
    read -r response
    if [[ ! "$response" =~ ^[yY]$ ]]; then
        printf "$PREFIX Exiting...$NEWLINE"
        exit 0
    fi
fi

#--------------#
# System Check #
#--------------#

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

if [ "$DRY_RUN" = false ]; then
    # Prompt for sudo password and keep the session alive
    sudo -v
    while true; do sleep 60; sudo -n true; kill -0 "$$" || exit; done 2>/dev/null &
    SUDO_KEEPALIVE_PID=$!
    # Ensures that we kill the sudo keep-alive process on script exit
    trap 'kill $SUDO_KEEPALIVE_PID' EXIT
fi

# TODO: move this into seperate scripts
# TODO: god and clean this up too - wtf

# Check if we're running grub and configure it if so
if is_pkg_installed grub && [ -f /boot/grub/grub.cfg ]; then
    # Backup grub files
    mkdir -p $BACKUP_DIR/grub
    sudo cp /etc/default/grub $BACKUP_DIR/grub
    sudo cp /boot/grub/grub.cfg $BACKUP_DIR/grub.cfg
    
    if detect_nvidia; then
        printf "$PREFIX Detected Nvidia GPU, configuring...$NEWLINE"
        
        sudo mkdir -p /etc/modprobe.d
        echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf > /dev/null
        
        # Nvidia modules
        if [ -f /etc/mkinitcpio.conf ] && command -v mkinitcpio >/dev/null; then
            current_modules_line=$(sudo grep -E "^MODULES=\s*\([^#]*\)$" /etc/mkinitcpio.conf)
            
            if [ -n "$current_modules_line" ]; then
                current_modules_content=$(echo "$current_modules_line" | sed -E 's/^MODULES=\s*\((.*)\)\s*$/\1/')
                normalized_current_modules=" $(echo "$current_modules_content" | tr -s ' ') "
                
                required_nvidia_modules=("nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm")
                modules_to_actually_append=()
                
                for module_name in "${required_nvidia_modules[@]}"; do
                    if ! echo "$normalized_current_modules" | grep -q " $module_name "; then
                        modules_to_actually_append+=("$module_name")
                    fi
                done
                
                if [ ${#modules_to_actually_append[@]} -gt 0 ]; then
                    string_of_modules_to_append=""
                    for new_module in "${modules_to_actually_append[@]}"; do
                        string_of_modules_to_append="$string_of_modules_to_append $new_module"
                    done
                    
                    if [[ -n "$current_modules_content" && ! "$current_modules_content" =~ ^[[:space:]]*$ ]]; then
                        updated_modules_content="$current_modules_content$string_of_modules_to_append"
                    else
                        updated_modules_content="${string_of_modules_to_append# }"
                    fi
                    
                    cleaned_updated_modules_content=$(echo "$updated_modules_content" | xargs)
                    new_mkinitcpio_modules_line="MODULES=($cleaned_updated_modules_content)"
                    
                    if sudo sed -i.mkinitcpio_nvidia.bak -E "s|^MODULES=\s*\([^#]*\)$|$new_mkinitcpio_modules_line|" /etc/mkinitcpio.conf; then
                        printf "$PREFIX NVIDIA modules updated in /etc/mkinitcpio.conf.$NEWLINE"
                    else
                        printf "$PREFIX ERROR: Failed to update /etc/mkinitcpio.conf.$NEWLINE"
                    fi
                fi
            fi
        fi
    fi
    
    sudo sed -i -e '
    s|^GRUB_DEFAULT=.*|GRUB_DEFAULT=saved|

    s|^GRUB_GFXMODE=.*|GRUB_GFXMODE=3840x2160,2560x1440,1920x1080,1280x720,auto|

    s|^#GRUB_GFXPAYLOAD_LINUX=.*|GRUB_GFXPAYLOAD_LINUX=keep|
    s|^GRUB_GFXPAYLOAD_LINUX=.*|GRUB_GFXPAYLOAD_LINUX=keep|

    s|^#GRUB_SAVEDEFAULT=.*|GRUB_SAVEDEFAULT=true|
    s|^GRUB_SAVEDEFAULT=.*|GRUB_SAVEDEFAULT=true|

    s|^#GRUB_DISABLE_OS_PROBER=.*|GRUB_DISABLE_OS_PROBER=false|
    s|^GRUB_DISABLE_OS_PROBER=.*|GRUB_DISABLE_OS_PROBER=false|
    
    ' /etc/default/grub
    
    sudo grub-mkconfig -o /boot/grub/grub.cfg
else
    printf "$PREFIX It looks like you're not using grub on your system.$NEWLINE"
    read -r -p " Do you want to skip the grub configuration? [y/N] " response
    
    if [[ "$response" =~ ^[nN]$ ]]; then
        printf "$PREFIX Exiting...$NEWLINE"
        rm -rf "$BACKUP_DIR"
        exit 1
    fi
fi

# Check if an Nvidia GPU is installed, then prompt to install drivers
if detect_nvidia && ! is_pkg_installed nvidia-dkms; then
    printf "$PREFIX Nvidia Card detected.$NEWLINE"
    printf "$PREFIX"
    read -r -p " Do you want to nvidia-dkms drivers? [y/N] " response
    
    if [[ "$response" =~ ^[yY]$ ]]; then
        touch $CUSTOM_PACKAGES
        printf "${NEWLINE}nvidia-dkms${NEWLINE}nvidia-utils${NEWLINE}egl-wayland${NEWLINE}libva-nvidia-driver${NEWLINE}" >> $CUSTOM_PACKAGES
        
        if grep -qE "^\s*\[multilib\]" /etc/pacman.conf 2>/dev/null; then
            printf "lib32-nvidia-utils${NEWLINE}" >> "$CUSTOM_PACKAGES"
        fi
    fi
fi

#--------------------#
# Check Dependencies #
#--------------------#

DEPENDENCIES=("git" "base-devel" "stow" "unzip")
MISSING_DEPENDENCIES=($(check_missing_dependencies))

# Install missing dependencies
if [[ ${#MISSING_DEPENDENCIES} -gt 0 ]]; then
    printf "$PREFIX The following dependencies are missing:$NEWLINE"
    
    for dep in "${MISSING_DEPENDENCIES[@]}"; do
        echo "- $dep"
    done
    
    printf "$PREFIX"
    read -r -p " Do you want to install them? [y/N] " response
    
    if [[ "$response" =~ ^[yY]$ ]]; then
        install_missing_depedencies "${MISSING_DEPENDENCIES[@]}" "$response"
        
        if [[ $? -eq 0 ]]; then
            printf "$PREFIX Dependencies installed.$NEWLINE"
        else
            echo "$PREFIX Dependency installation failed.$NEWLINE"
            exit 1
        fi
    else
        printf "$PREFIX Exiting because required dependencies are not installed...$NEWLINE"
        exit 1
    fi
else
    printf "$PREFIX Dependencies are already installed.$NEWLINE"
fi

#-----------------#
# Init Submodules #
#-----------------#

git submodule update --init --recursive

#-------------#
# Install Yay #
#-------------#

if pacman -Qq "yay" &> /dev/null; then
    printf "$PREFIX yay is already installed.$NEWLINE"
else
    printf "$PREFIX Installing yay...$NEWLINE"
    install_yay &&
    printf "$PREFIX yay has been installed successfully.$NEWLINE"
fi

#------------------#
# Install Packages #
#------------------#

printf "$PREFIX Proceeding to package installation...$NEWLINE"

install_base "$BASE_PACKAGES" &&
install_aur "$AUR_PACKAGES" &&

if [[ -f "$CUSTOM_PACKAGES" ]]; then
    install_base "$CUSTOM_PACKAGES"
fi

printf "$PREFIX Finished installing all packages.$NEWLINE"

if [ "$BACKUPS" = true ]; then
    backup_user_dotfiles "$BACKUP_DIR" "$DRY_RUN"
else
    echo "Backups disabled by command line option"
fi

#-------------#
# Install OMZ #
#-------------#

if [ ! -d ".oh-my-zsh" ]; then
    if [ "$DRY_RUN" = true ]; then
        printf "$PREFIX [DRY RUN] Would install oh-my-zsh and set zsh as default shell.$NEWLINE"
    else
        if command -v zsh >/dev/null 2>&1; then
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            rm -f .zshrc*
            chsh -s "$(command -v zsh)" "$CURRENT_USER"
        else
            printf "$PREFIX ERROR: zsh not found, cannot change default shell.$NEWLINE"
        fi
    fi
fi

#------------------#
# Install Dotfiles #
#------------------#

printf "$PREFIX Installing dotfiles...$NEWLINE"

install_home_dir
install_root_dirs

printf "$PREFIX Finished installing dotfiles...$NEWLINE"
