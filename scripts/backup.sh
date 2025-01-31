#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

backup_directory() {
  local DOT_DIR="$1"
  local BACKUP_DIR="$2"
  local CURRENT_USER="$3"

  local NEW_DIR_PATH="${dot_dir/archuser/$current_user}"
  local BACKUP_PATH="${BACKUP_DIR}$NEW_DIR_PATH"

  mkdir -p "$(dirname "$BACKUP_PATH")"
  cp -r "$NEW_DIR_PATH" "$BACKUP_PATH"

  if [[ $? -eq 0 ]]; then
    printf "$PREFIX Backed up: $NEW_DIR_PATH to $BACKUP_PATH\.$NEWLINE"
    return 0
  else
    printf "$PREFIX Error backing up: $NEW_DIR_PATH\.$NEWLINE"
    return 1
  fi
}
