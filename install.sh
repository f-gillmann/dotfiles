#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

#----------------#
# Source Scripts #
#----------------#

source ./scripts/functions.sh
source ./scripts/install_packages.sh
source ./scripts/install_dependencies.sh
source ./scripts/backup.sh

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

BASE_PACKAGES="packages/base.list"
AUR_PACKAGES="packages/aur.list"

CURRENT_USER=$(whoami)
DATE_TIME=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="backup_dotfiles_f-gillmann_${DATE_TIME}"
BACKUP_DIR="./$BACKUP_NAME"
BACKUP_ARCHIVE="$BACKUP_NAME.tar.gz"
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
  mkdir -p ${BACKUP_DIR}/etc/default/grub
  mkdir -p ${BACKUP_DIR}/boot/grub/grub.cfg
  sudo cp /etc/default/grub ${BACKUP_DIR}/etc/default/grub
  sudo cp /boot/grub/grub.cfg ${BACKUP_DIR}/boot/grub/grub.cfg

  # Thanks to
  # https://github.com/HyDE-Project/HyDE/blob/a1ed62411cd86426002bb3b0b968ebc0cac9da18/Scripts/install_pre.sh#L27-L28
  if detect_nvidia; then
    printf "$PREFIX Adding nvidia_drm.modeset=1 to /etc/default/grub...$NEWLINE"

    GCLD=$(grep "^GRUB_CMDLINE_LINUX_DEFAULT=" "/etc/default/grub" | cut -d'"' -f2 | sed 's/\b nvidia_drm.modeset=.\b//g')
    sudo sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT=\"${GCLD} nvidia_drm.modeset=1\"" /etc/default/grub
  fi

  # TODO: Add grub themes
  sudo sed -i "/^GRUB_DEFAULT=/c\GRUB_DEFAULT=saved
               /^GRUB_GFXMODE=/c\GRUB_GFXMODE=1280x1024x32,auto
               /^#GRUB_SAVEDEFAULT=true/c\GRUB_SAVEDEFAULT=true" /etc/default/grub

  sudo grub-mkconfig -o /boot/grub/grub.cfg
else
  printf "$PREFIX It looks like you're not using grub on your system.$NEWLINE"
  printf "$PREFIX Exiting...$NEWLINE"
  exit 1
fi

# Check if an Nvidia GPU is installed, then prompt to install drivers
if detect_nvidia && ! is_pkg_installed nvidia-dkms; then
  printf "$PREFIX Nvidia Card detected.$NEWLINE"
  printf "$PREFIX"
  read -r -p " Do you want to nvidia-dkms drivers? [y/N] " response

  if [[ "$response" =~ ^[yY]$ ]]; then
    INSTALL_NVIDIA_DKMS=1
  else
    INSTALL_NVIDIA_DKMS=0
  fi
fi

#--------------------#
# Check Dependencies #
#--------------------#

DEPENDENCIES=("git" "base-devel")
MISSING_DEPENDENCIES=($(check_missing_dependencies))

if detect_nvidia && [[ $INSTALL_NVIDIA_DKMS -eq 1 ]]; then
  DEPENDENCIES+=("nvidia-dkms")
fi

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

printf "$PREFIX Finished installing all packages.$NEWLINE"

#------------------------#
# Backup Existing Config #
#------------------------#

# TODO: Write a better way of backup up files, maybe with a list of files in a seperate file
# Similar to this: https://github.com/HyDE-Project/HyDE/blob/master/Scripts/restore_cfg.psv

USER_DIRS=(
  "/home/archuser/.config/hypr"
)

for usr_dir in "${USER_DIRS[@]}"; do
  backup_directory "$usr_dir" "$BACKUP_DIR" "$CURRENT_USER"
done

printf "$PREFIX Backup process complete. Temporary backup directory: ${BACKUP_DIR}.$NEWLINE"

tar -czvf "$BACKUP_ARCHIVE" "$BACKUP_DIR"

if [[ $? -eq 0 ]]; then
  echo "Created archive: $BACKUP_ARCHIVE"
  rm -rf "$BACKUP_DIR"
  echo "Removed temporary directory: $BACKUP_DIR"
else
  echo "Error creating archive: $BACKUP_ARCHIVE"
fi
