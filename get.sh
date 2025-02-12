#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

RESET_COLOR="\e[0m"
COLOR="\e[36m"
LIGHT_COLOR="\e[96m"
UNDERLINE="\e[4m"
NEWLINE="\n"
PREFIX="${COLOR}\$${RESET_COLOR}/${LIGHT_COLOR}>${RESET_COLOR}"

# Check if dependencies are missing
DEPENDENCIES=("unzip" "curl")
MISSING_DEPENDENCIES=()
for dep in "${DEPENDENCIES[@]}"; do
  if ! pacman -Qq "$dep" &> /dev/null; then
    MISSING_DEPENDENCIES+=("$dep")
  fi
done

if [[ ${#MISSING_DEPENDENCIES} -gt 0 ]]; then
  printf "$PREFIX The following dependencies are missing:$NEWLINE"

  for dep in "${MISSING_DEPENDENCIES[@]}"; do
    echo "- $dep"
  done

  printf "$PREFIX Exiting...$NEWLINE"
  exit 1
fi

printf "$PREFIX Downloading files from ${LIGHT_COLOR}${UNDERLINE}https://github.com/f-gillmann/dotfiles${RESET_COLOR}.$NEWLINE"

# Check if the f-gillmann-dots directory exists
if [ -d "f-gillmann-dots" ]; then
  printf "$PREFIX"
  read -r -p " f-gillmann-dots already exists. Do you want to overwrite it? [y/N]: " overwrite
  if [[ $overwrite =~ ^[Yy]$ ]]; then
    # Remove existing directory
    rm -rf f-gillmann-dots
  else
    printf "$PREFIX Exiting...$NEWLINE"
    exit 1
  fi
fi

# Download the repository from github
TEMP_DIR=$(mktemp -d) &&
curl -sS -L -o master.zip "https://github.com/f-gillmann/dotfiles/archive/refs/heads/master.zip" &&
unzip -qq master.zip -d $TEMP_DIR &&
mkdir f-gillmann-dots &&
mv $TEMP_DIR/dotfiles-master/* f-gillmann-dots/ &&
rm -rf $TEMP_DIR master.zip &&

printf "$PREFIX Dotfiles have been downloaded and extracted into f-gillmann-dots.$NEWLINE"

# Prompt if we wanna run the install script
printf "$PREFIX"
read -r -p " Do you want to run the install script now? [y/N]: " overwrite
if [[ $overwrite =~ ^[yY]$ ]]; then
  cd ./f-gillmann-dots &&
  chmod +x ./install.sh
  bash ./install.sh
else
  printf "$PREFIX Exiting...$NEWLINE"
  exit 1
fi
