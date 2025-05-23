#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

list_backup() {
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
        eval srcDir="$BACKUP_DIR/$src"
        mkdir -p "$srcDir"
        cp -rp "$src" "$srcDir"
    fi
}

list_sync() {
    local src="$1"
    local target="$2"

    printf "${PREFIX} Synchronising '$src' and '$target'.${NEWLINE}"

    if [ ! -e "$src" ]; then
        printf "${PREFIX} Warning: Source '$src' does not exist.${NEWLINE}"
        return 1
    fi

    if [ -f "$src" ]; then # Source is a file
        if [[ "$target" == */ ]] || [ -d "$target" ]; then # Target is a directory (or path ends with /)
            if ! mkdir -p "$target"; then
                printf "${PREFIX} Error creating target directory '$target'.${NEWLINE}"; return 1;
            fi
        else # Target is a file path
            if ! mkdir -p "$(dirname "$target")"; then
                printf "${PREFIX} Error creating parent directory for target file '$target'.${NEWLINE}"; return 1;
            fi
        fi
    elif [ -d "$src" ]; then # Source is a directory
        if [ -f "$target" ]; then # Target is an existing file (conflict)
            printf "${PREFIX} Warning: Source '$src' is a directory but target '$target' is an existing file. Removing conflicting target file.${NEWLINE}"
            if ! rm -f "$target"; then
                printf "${PREFIX} Error: Failed to remove conflicting target file '$target'.${NEWLINE}"
                return 1
            fi
        fi

        local target_parent
        target_parent=$(dirname "$target")
        if ! mkdir -p "$target_parent"; then
            printf "${PREFIX} Error creating parent directory '$target_parent' for target '$target'.${NEWLINE}"; return 1;
        fi

        if [[ "$target" == */ ]] && [ ! -d "$target" ]; then
             if ! mkdir -p "$target"; then
                printf "${PREFIX} Error creating target directory '$target' as specified by trailing slash.${NEWLINE}"; return 1;
             fi
        fi
    fi

    local rsync_opts_base=("-ac")
    local rsync_opts_check_additions=("-ni")

    # Prepare the source path for rsync: add trailing slash if it's a directory
    local rsync_src_path="$src"
    if [ -d "$src" ]; then
        rsync_src_path="${src%/}/"
    fi

    local dry_run_output
    dry_run_output=$(rsync "${rsync_opts_base[@]}" "${rsync_opts_check_additions[@]}" "$rsync_src_path" "$target" 2>&1)
    local rsync_check_exit_code=$?

    if [ "$rsync_check_exit_code" -ne 0 ]; then
        if echo "$dry_run_output" | grep -q "rsync error:"; then
            printf "${PREFIX} rsync dry-run command failed (exit code $rsync_check_exit_code).${NEWLINE}"
            printf "Details:%s%s${NEWLINE}" "$NEWLINE" "$dry_run_output"
            return 1
        fi
        # Corrected $NL to $NEWLINE (assuming $NEWLINE is your standard newline variable)
        printf "${PREFIX} Warning: rsync dry-run exited with code $rsync_check_exit_code. Output:%s%s${NEWLINE}" "$NEWLINE" "$dry_run_output"
    fi

    if echo "$dry_run_output" | grep -qE '^[<>ch*]'; then
        printf "${PREFIX} Differences found. Performing synchronization.${NEWLINE}"
        if ! rsync "${rsync_opts_base[@]}" "$rsync_src_path" "$target"; then
            local sync_exit_code=$?
            printf "${PREFIX} rsync failed during actual synchronization (exit code $sync_exit_code).${NEWLINE}"
            return 1
        fi
        printf "${PREFIX} Synchronization complete.${NEWLINE}"
    else
        printf "${PREFIX} No synchronization needed (source and target appear identical based on rsync dry run).${NEWLINE}"
    fi

    return 0
}

list_overwrite() {
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

list_populate() {
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
