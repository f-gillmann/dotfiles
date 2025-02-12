#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

lst_backup() {
    local src=$1
    printf "${PREFIX} Backing up $src.$NEWLINE"

    # Check if source exists
    if [ ! -e "$src" ]; then
        printf "${PREFIX} Warning: Source '$src' does not exist.$NEWLINE"
        return 1
    fi

    # If source is a file, back up the file to the src dir, otherwise back up the entire directory
    # This uses the same file path as present on the host machine so it's easier to recover the backup
    if [ -f "$src" ]; then
        mkdir -p "$(dirname "$BACKUP_DIR/$src")"
        cp -p "$src" "$BACKUP_DIR/$src"
    elif [ -d "$src" ]; then
        cp -rp "$src" "$BACKUP_DIR/"
    fi
}

lst_sync() {
    local src=$1
    local target=$2
    printf "${PREFIX} Synchronising $src and $target.$NEWLINE"
    
    # Check if source exists
    if [ ! -e "$src" ]; then
        printf "${PREFIX} Warning: Source '$src' does not exist.$NEWLINE"
        return 1
    fi
    
    # Compare files and sync if needed
    if cmp --silent "$src" "$target"; then
        printf "${PREFIX} Files are identical, no synchronization needed.$NEWLINE"
        return 0
    fi
    
    # Perform synchronization
    if [ -f "$src" ]; then
        mkdir -p "$(dirname "$target")"
        cp -p "$src" "$target"
    elif [ -d "$src" ]; then
        cp -rp "$src" "$target"
    fi
}

lst_overwrite() {
    local src=$1
    local target=$2
    printf "${PREFIX} Writing $src over $target.$NEWLINE"
    
    # Check if source exists
    if [ ! -e "$src" ]; then
        printf "${PREFIX} Warning: Source '$src' does not exist.$NEWLINE"
        return 1
    fi
    
    # Overwrite target with source
    if [ -f "$src" ]; then
        mkdir -p "$(dirname "$target")"
        cp -pf "$src" "$target"
    elif [ -d "$src" ]; then
        cp -rpf "$src" "$target"
    fi
}

lst_populate() {
    local src=$1
    local target=$2
    printf "${PREFIX} Populating $src into $target.$NEWLINE"
    
    # Check if source exists
    if [ ! -e "$src" ]; then
        printf "${PREFIX} Warning: Source '$src' does not exist.$NEWLINE"
        return 1
    fi
    
    # Check if target exists, skip if it does
    if [ -e "$target" ]; then
        printf "${PREFIX} Target '$target' already exists, skipping population.$NEWLINE"
        return 0
    fi
    
    # Copy source to target
    if [ -f "$src" ]; then
        mkdir -p "$(dirname "$target")"
        cp -p "$src" "$target"
    elif [ -d "$src" ]; then
        cp -rp "$src" "$target"
    fi
}
