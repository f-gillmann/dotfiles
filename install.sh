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
BACKUP_ARCHIVE="$BACKUP_NAME\.tar.gz"
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

#--------------------#
# Check Dependencies #
#--------------------#

DEPENDENCIES=("git" "base-devel")
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

DOTS_DIRS=(
  "dots/home/archuser/.config/hypr"
)

{
  for dot_dir in "${DOTS_DIRS[@]}"; do
    backup_directory "$dot_dir" "$BACKUP_DIR" "$CURRENT_USER"
  done
} > $BACKUP_DIR\/backup_log.txt

printf "$PREFIX Backup process complete. Temporary backup directory: $BACKUP_DIR\.$NEWLINE"

tar -czvf "$BACKUP_ARCHIVE" "$BACKUP_DIR"

if [[ $? -eq 0 ]]; then
  echo "Created archive: $BACKUP_ARCHIVE"
  rm -rf "$BACKUP_DIR"
  echo "Removed temporary directory: $BACKUP_DIR"
else
  echo "Error creating archive: $BACKUP_ARCHIVE"
fi
