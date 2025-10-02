#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

run_install_oh_my_posh() {
    printf "$PREFIX Checking for Oh My Posh installation...$NEWLINE"
    
    local OMP_INSTALL_DIR="$HOME/.local/bin"
    local OMP_BINARY="$OMP_INSTALL_DIR/oh-my-posh"
    
    # Check if Oh My Posh is already installed
    if [ -f "$OMP_BINARY" ]; then
        printf "$PREFIX Oh My Posh is already installed at $OMP_BINARY.$NEWLINE"
        
        # Check for updates
        printf "$PREFIX Checking for Oh My Posh updates...$NEWLINE"
        local CURRENT_VERSION=$("$OMP_BINARY" version 2>/dev/null || echo "unknown")
        printf "$PREFIX Current version: $CURRENT_VERSION$NEWLINE"
        
        if [[ "$UPDATE_MODE" == true ]]; then
            printf "$PREFIX Update mode: Re-installing Oh My Posh...$NEWLINE"
        else
            printf "$PREFIX Skipping Oh My Posh installation (already exists).$NEWLINE"
            return 0
        fi
    fi
    
    printf "$PREFIX Installing Oh My Posh...$NEWLINE"
    
    # Create installation directory if it doesn't exist
    mkdir -p "$OMP_INSTALL_DIR"
    
    # Download and install Oh My Posh
    if curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$OMP_INSTALL_DIR"; then
        printf "$PREFIX Oh My Posh installed successfully.$NEWLINE"
        
        # Verify installation
        if [ -f "$OMP_BINARY" ]; then
            local NEW_VERSION=$("$OMP_BINARY" version 2>/dev/null || echo "unknown")
            printf "$PREFIX Installed version: $NEW_VERSION$NEWLINE"
            
            # Make sure it's executable
            chmod +x "$OMP_BINARY"
            
            printf "$PREFIX Oh My Posh is ready to use.$NEWLINE"
            printf "$PREFIX Add it to your PATH if not already done: export PATH=\"\$HOME/.local/bin:\$PATH\"$NEWLINE"
            return 0
        else
            printf "$PREFIX Warning: Oh My Posh binary not found after installation.$NEWLINE"
            return 1
        fi
    else
        printf "$PREFIX ERROR: Failed to install Oh My Posh.$NEWLINE"
        return 1
    fi
}
