#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

backup_directory() {
  local USR_DIR="$1"
  local BACKUP_DIR="$2"
  local CURRENT_USER="$3"

  local USR_DIR_PATH="${USR_DIR/user/$CURRENT_USER}"
  local BACKUP_PATH="${BACKUP_DIR/USR_DIR_PATH}"

  mkdir -p "$(dirname "$BACKUP_PATH")"
  cp -r "$USR_DIR_PATH" "$BACKUP_PATH"

  if [[ $? -eq 0 ]]; then
    printf "$PREFIX Backed up: $USR_DIR_PATH to ${BACKUP_PATH}.$NEWLINE"
    return 0
  else
    printf "$PREFIX Error backing up: ${USR_DIR_PATH}.$NEWLINE"
    return 1
  fi
}
