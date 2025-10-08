#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

detect_update_mode() {
    local INSTALL_MARKER="$HOME/.local/.flg-installed"
    
    if [ -f "$INSTALL_MARKER" ]; then
        printf "$PREFIX Previous installation detected.$NEWLINE"
        printf "$PREFIX Last installed: $(cat "$INSTALL_MARKER")$NEWLINE"
        printf "$PREFIX Running in ${LIGHT_COLOR}UPDATE MODE${RESET_COLOR}.$NEWLINE"
        return 0
    else
        printf "$PREFIX No previous installation detected.$NEWLINE"
        printf "$PREFIX Running in ${LIGHT_COLOR}INSTALL MODE${RESET_COLOR}.$NEWLINE"
        return 1
    fi
}

mark_installation_complete() {
    local INSTALL_MARKER="$HOME/.local/.flg-installed"
    local TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    
    echo "$TIMESTAMP" > "$INSTALL_MARKER"
    printf "$PREFIX Installation marker created.$NEWLINE"
}

update_dotfiles_repo() {
    printf "$PREFIX Updating dotfiles repository...$NEWLINE"
    
    cd "$SCRIPT_DIR" || return 1
    
    # Check if we have a git repository
    if [ ! -d .git ]; then
        printf "$PREFIX Warning: Not a git repository, skipping update.$NEWLINE"
        return 1
    fi
    
    # Stash any local changes
    local STASH_OUTPUT=$(git stash 2>&1)
    local STASHED=false
    if [[ "$STASH_OUTPUT" != *"No local changes to save"* ]]; then
        STASHED=true
        printf "$PREFIX Stashed local changes.$NEWLINE"
    fi
    
    # Pull latest changes
    printf "$PREFIX Pulling latest changes from remote...$NEWLINE"
    if git pull --recurse-submodules origin master; then
        printf "$PREFIX Repository updated successfully.$NEWLINE"
        
        # Restore stashed changes if any
        if [ "$STASHED" = true ]; then
            printf "$PREFIX Restoring local changes...$NEWLINE"
            git stash pop
        fi
        
        return 0
    else
        printf "$PREFIX Warning: Failed to update repository.$NEWLINE"
        
        # Restore stashed changes even on failure
        if [ "$STASHED" = true ]; then
            git stash pop
        fi
        
        return 1
    fi
}

run_update_mode() {
    printf "${NEWLINE}${PREFIX} ${LIGHT_COLOR}=== UPDATING DOTFILES ===${RESET_COLOR}${NEWLINE}"
    
    # Update the repository
    update_dotfiles_repo
    
    # Skip system checks in update mode (already validated during install)
    printf "$PREFIX Skipping system checks (already validated).$NEWLINE"
    
    # Check dependencies (in case new ones were added)
    run_dependency_check || exit 1
    
    # Update packages
    printf "$PREFIX Updating packages...$NEWLINE"
    run_package_install || exit 1
    
    # Update Oh My Zsh if installed
    if [ -d "$HOME/.oh-my-zsh" ]; then
        printf "$PREFIX Updating Oh My Zsh...$NEWLINE"
        "$HOME/.oh-my-zsh/tools/upgrade.sh" || printf "$PREFIX Warning: Oh My Zsh update failed.$NEWLINE"
    fi
    
    # Update/Install Oh My Posh
    run_install_oh_my_posh || printf "$PREFIX Warning: Oh My Posh installation/update failed.$NEWLINE"
    
    # Re-install dotfiles (in case configurations changed)
    printf "$PREFIX Updating dotfiles...$NEWLINE"
    run_dotfiles_install || exit 1
    
    # Update installation marker
    mark_installation_complete
    
    printf "${NEWLINE}${PREFIX} ${LIGHT_COLOR}Update completed successfully!${RESET_COLOR}${NEWLINE}"
}
