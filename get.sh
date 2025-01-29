#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

# Check if the f-gillmann-dots directory exists
if [ -d "f-gillmann-dots" ]; then
  read -p "\$/> f-gillmann-dots already exists. Do you want to overwrite it? [y/N]: " overwrite
  if [[ $overwrite =~ ^[Yy]$ ]]; then
    # Remove existing directory
    rm -rf f-gillmann-dots
  else
    printf "\$/> Exiting...\n"
    exit 1
  fi
fi

# Download the repository from github
TEMP_DIR=$(mktemp -d) &&
curl -L -o master.zip "https://github.com/f-gillmann/dotfiles/archive/refs/heads/master.zip" &&
unzip master.zip -d $TEMP_DIR &&
mkdir f-gillmann-dots &&
mv $TEMP_DIR/dotfiles-master/* f-gillmann-dots/ &&
rm -rf $TEMP_DIR master.zip &&

printf "\$/> Dotfiles have been downloaded and extracted into f-gillmann-dots."

# Prompt if we wanna run the install script
read -p "\$/> Do you want to run the install script now? [y/N]: " overwrite
if [[ $overwrite =~ ^[Yy]$ ]]; then
  cd ./f-gillmann-dots &&
  chmod +x ./install.sh
  bash ./install.sh
else
  printf "\$/> Exiting...\n"
  exit 1
fi
