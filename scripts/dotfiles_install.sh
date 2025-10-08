#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

dotfiles_install() {
    local rice_dir="$SCRIPT_DIR/rice"
    cd "$rice_dir"
    printf "$PREFIX Installing dotfiles to $HOME...$NEWLINE"
    
    local stow_pkgs="hyprcursor hyprland kitty quickshell wallpapers zsh"
    
    # Check for existing .zshrc and handle it interactively
    if [ -f "$HOME/.zshrc" ]; then
        printf "$PREFIX Existing .zshrc found at $HOME/.zshrc$NEWLINE"
        printf "$PREFIX What would you like to do?$NEWLINE"
        printf "  1) Backup existing .zshrc and use FLG dotfiles version$NEWLINE"
        printf "  2) Keep existing .zshrc (skip stowing zsh)$NEWLINE"
        printf "  3) Show content of existing .zshrc first$NEWLINE"
        printf "$PREFIX Enter your choice (1-3): "
        
        read -r choice
        case $choice in
            1)
                local backup_name="$HOME/.zshrc.pre-flg-dots.$(date +%Y%m%d-%H%M%S)"
                printf "$PREFIX Backing up existing .zshrc to $(basename "$backup_name")...$NEWLINE"
                mv "$HOME/.zshrc" "$backup_name"
                printf "$PREFIX Backup created successfully.$NEWLINE"
                ;;
            2)
                printf "$PREFIX Keeping existing .zshrc, excluding zsh from stow packages.$NEWLINE"
                stow_pkgs="hyprcursor hyprland kitty quickshell wallpapers"
                ;;
            3)
                printf "$PREFIX Content of existing .zshrc:$NEWLINE"
                printf "----------------------------------------$NEWLINE"
                cat "$HOME/.zshrc"
                printf "----------------------------------------$NEWLINE"
                printf "$PREFIX Now choose: (1) Backup and replace, (2) Keep existing: "
                read -r second_choice
                case $second_choice in
                    1)
                        local backup_name="$HOME/.zshrc.pre-flg-dots.$(date +%Y%m%d-%H%M%S)"
                        printf "$PREFIX Backing up existing .zshrc to $(basename "$backup_name")...$NEWLINE"
                        mv "$HOME/.zshrc" "$backup_name"
                        printf "$PREFIX Backup created successfully.$NEWLINE"
                        ;;
                    2)
                        printf "$PREFIX Keeping existing .zshrc, excluding zsh from stow packages.$NEWLINE"
                        stow_pkgs="hyprcursor hyprland kitty quickshell wallpapers"
                        ;;
                    *)
                        printf "$PREFIX Invalid choice, keeping existing .zshrc.$NEWLINE"
                        stow_pkgs="hyprcursor hyprland kitty quickshell wallpapers"
                        ;;
                esac
                ;;
            *)
                printf "$PREFIX Invalid choice, keeping existing .zshrc.$NEWLINE"
                stow_pkgs="hyprcursor hyprland kitty quickshell wallpapers"
                ;;
        esac
    fi
    
    # Create some dirs in case they don't exist to make sure
    # that we don't have an ugly linking problem with stow
    mkdir -p "$HOME/.config/hypr"
    mkdir -p "$HOME/.config/kitty"
    mkdir -p "$HOME/.config/quickshell"
    mkdir -p "$HOME/.local/share/icons"
    
    stow --target="$HOME" $stow_pkgs
    
    cd "$SCRIPT_DIR"

    printf "$PREFIX Finished installing home directory dotfiles.$NEWLINE"
}
