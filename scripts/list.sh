#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

# Processing each list entry
process_list_entry() {
    local type=$1
    local sourcepath=$2
    local targetpath=$3
    local target=$4
    local dependency=$5

    # Resolve paths
    eval src="${sourcepath}/${target}"
    eval target="${targetpath}/${target}"

    # Check for dependency if specified
    if [[ -n "$dependency" ]]; then
        if ! is_pkg_installed "$dependency"; then
            printf "${PREFIX}Skipping due to missing dependency: $dependency.$NEWLINE"
            return
        fi
    fi

    # Perform the operation based on type
    case "$type" in
        "B")
            list_backup $src
            ;;
        "S")
            list_backup $src
            list_sync $src $target
            ;;
        "O")
            list_backup $src
            list_overwrite $src $target
            ;;
        "P")
            list_backup $src
            list_populate $src $target
            ;;
        *)
            exit 1
            ;;
    esac
}

process_list_file() {
    local list_file="$1"
    printf "${PREFIX} Processing list \"$list_file\"...$NEWLINE"
    
    while IFS="|" read -r type sourcepath targetpath target dependency || [[ -n "$type" ]]; do
        # Skip comments and headers
        [[ "$type" =~ ^# ]] && continue
        
        # Expand variables manually using eval
        eval sourcepath="$sourcepath"
        eval targetpath="$targetpath"
        
        # Handle empty or malformed lines
        [[ -z "$type" ]] && continue

        # Process the entry
        process_list_entry "$type" "$sourcepath" "$targetpath" "$target" "$dependency"
    done < "$list_file"
}
