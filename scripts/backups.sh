#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

backup_user_dotfiles() {
    local BACKUP_DIR="$1"
    local DRY_RUN="$2"

    declare -A DIRS_TO_BACKUP=(
        ["~/.zshrc"]="$BACKUP_DIR/home"
        ["~/.config/hypr"]="$BACKUP_DIR/.config"
        ["~/.config/kitty"]="$BACKUP_DIR/.config"
        ["~/.config/quickshell"]="$BACKUP_DIR/.config"
        ["~/.config/rofi"]="$BACKUP_DIR/.config"
        ["~/.config/wallust"]="$BACKUP_DIR/.config"
        ["~/.config/.current-wallpaper"]="$BACKUP_DIR/.config"
        ["~/.local/share/icons"]="$BACKUP_DIR/.local/share"
    )

    local SDDM_SRC="/etc/sddm.conf"
    local SDDM_DEST="$BACKUP_DIR/sddm/sddm.conf"

    for SRC in "${!DIRS_TO_BACKUP[@]}"; do
        DEST="${DIRS_TO_BACKUP[$SRC]}"
        if [ "$DRY_RUN" = true ]; then
            printf "$PREFIX [DRY RUN] Would copy $SRC to $DEST$NEWLINE"
        else
            if [[ -f $SRC || -d $SRC ]]; then
                mkdir -p "$DEST"
                cp -rL $SRC "$DEST"
            fi
        fi
    done

    if is_pkg_installed sddm; then
        if [ "$DRY_RUN" = true ]; then
            printf "$PREFIX [DRY RUN] Would copy $SDDM_SRC to $SDDM_DEST (sudo required)$NEWLINE"
        else
            mkdir -p "$(dirname "$SDDM_DEST")"
            sudo cp "$SDDM_SRC" "$SDDM_DEST"
        fi
    fi
}
