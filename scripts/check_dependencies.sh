#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

run_dependency_check() {
    printf "$PREFIX Checking for required dependencies...$NEWLINE"
    
    DEPENDENCIES=("git" "base-devel" "stow" "unzip")
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
                return 0
            else
                echo "$PREFIX Dependency installation failed.$NEWLINE"
                return 1
            fi
        else
            printf "$PREFIX Exiting because required dependencies are not installed...$NEWLINE"
            return 1
        fi
    else
        printf "$PREFIX All dependencies are already installed.$NEWLINE"
        return 0
    fi
}
