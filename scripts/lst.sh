#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

# Processing each list entry
process_lst_entry() {
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
            lst_backup $src
            ;;
        "S")
            lst_backup $src
            lst_sync $src $target
            ;;
        "O")
            lst_backup $src
            lst_overwrite $src $target
            ;;
        "P")
            lst_backup $src
            lst_populate $src $target
            ;;
        *)
            exit 1
            ;;
    esac
}

process_lst_file() {
    local lst_file="$1"
    printf "${PREFIX} Processing list \"$lst_file\"...$NEWLINE"
    
    while IFS="|" read -r type sourcepath targetpath target dependency || [[ -n "$type" ]]; do
        # Skip comments and headers
        [[ "$type" =~ ^# ]] && continue
        
        # Expand variables manually using eval
        eval sourcepath="$sourcepath"
        eval targetpath="$targetpath"
        
        # Handle empty or malformed lines
        [[ -z "$type" ]] && continue

        # Process the entry
        process_lst_entry "$type" "$sourcepath" "$targetpath" "$target" "$dependency"
    done < "$lst_file"
}
