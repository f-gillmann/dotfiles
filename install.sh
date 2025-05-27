#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

#----------------#
# Source Scripts #
#----------------#

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
BACKUP_NAME="backup_dotfiles_f-gillmann_${DATE_TIME}"
BACKUP_DIR="./$BACKUP_NAME"
mkdir -p "$BACKUP_DIR"

#-----------------#
# Print Ascii Art #
#-----------------#

print_ascii_art $COLOR $LIGHT_COLOR

#--------------#
# System Check #
#--------------#

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

# Check if we're running grub and configure it if so
if is_pkg_installed grub && [ -f /boot/grub/grub.cfg ]; then
    # Backup grub files
    mkdir -p ${BACKUP_DIR}/etc/default
    mkdir -p ${BACKUP_DIR}/boot/grub
    sudo cp /etc/default/grub ${BACKUP_DIR}/etc/default/grub
    sudo cp /boot/grub/grub.cfg ${BACKUP_DIR}/boot/grub/grub.cfg
    
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
    
    sudo sed -i "/^GRUB_DEFAULT=/c\GRUB_DEFAULT=saved
    /^GRUB_GFXMODE=/c\GRUB_GFXMODE=1280x1024x32,auto
    /^GRUB_DISABLE_OS_PROBER=/c\GRUB_DISABLE_OS_PROBER=false,auto
    /^#GRUB_SAVEDEFAULT=true/c\GRUB_SAVEDEFAULT=true" /etc/default/grub
    
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

DEPENDENCIES=("git" "base-devel" "stow")
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

#-------------------------------------#
# Init submodules if not done already #
#-------------------------------------#

git submodule update --init --recursive

#-------------#
# Install yay #
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

#--------------#
# Backup files #
#--------------#

mkdir -p $BACKUP_DIR/.config/
cp -r ~/.config/hypr "$BACKUP_DIR/.config"
cp -r ~/.config/kitty "$BACKUP_DIR/.config"
cp -r ~/.config/rofi "$BACKUP_DIR/.config"
cp -r ~/.config/waybar "$BACKUP_DIR/.config"
cp -r ~/.config/kitty "$BACKUP_DIR/.config"
cp -r ~/.config/wallpapers "$BACKUP_DIR/.config"

#------------------#
# Install dotfiles #
#------------------#

printf "$PREFIX Installing dotfiles...$NEWLINE"

install_home_dir
install_root_dirs

printf "$PREFIX Finished installing dotfiles...$NEWLINE"
