#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

install_dotfiles() {
    local rice_dir="$SCRIPT_DIR/rice"
    cd "$rice_dir"
    printf "$PREFIX Installing dotfiles to $HOME...$NEWLINE"
    
    local stow_pkgs="hyprland kitty matugen quickshell walker wallpapers wallust waypaper"
    
    # Handle hyprcursor installation manually
    printf "$PREFIX Installing hyprcursor themes...$NEWLINE"
    local hyprcursor_src="$rice_dir/hyprcursor/.local/share/icons"
    local hyprcursor_dest="$HOME/.local/share/icons"
    local cursor_themes=("Bibata-Modern-Ice" "Bibata-Modern-Ice-Hypr" "default")
    
    mkdir -p "$hyprcursor_dest"
    
    for theme in "${cursor_themes[@]}"; do
        if [ ! -d "$hyprcursor_dest/$theme" ]; then
            printf "$PREFIX Copying $theme cursor theme...$NEWLINE"
            cp -r "$hyprcursor_src/$theme" "$hyprcursor_dest/"
        else
            printf "$PREFIX $theme cursor theme already exists, skipping...$NEWLINE"
        fi
    done
    
    printf "$PREFIX Hyprcursor themes installation completed.$NEWLINE"
    
    # Handle zsh files manually
    printf "$PREFIX Installing zsh configuration files...$NEWLINE"
    local zsh_src="$rice_dir/zsh"
    local zsh_files=(".zshrc" ".omp.json")
    
    for file in "${zsh_files[@]}"; do
        if [ -f "$HOME/$file" ]; then
            printf "$PREFIX Existing $file found at $HOME/$file$NEWLINE"
            printf "$PREFIX What would you like to do with $file?$NEWLINE"
            printf "  1) Backup existing $file and use FLG dotfiles version$NEWLINE"
            printf "  2) Keep existing $file$NEWLINE"
            printf "  3) Show content of existing $file first$NEWLINE"
            printf "$PREFIX Enter your choice (1-3): "
            
            read -r choice
            case $choice in
                1)
                    local backup_name="$HOME/$file.pre-flg-dots.$(date +%Y%m%d-%H%M%S)"
                    printf "$PREFIX Backing up existing $file to $(basename "$backup_name")...$NEWLINE"
                    mv "$HOME/$file" "$backup_name"
                    cp "$zsh_src/$file" "$HOME/$file"
                    printf "$PREFIX $file backup created and FLG version installed.$NEWLINE"
                    ;;
                2)
                    printf "$PREFIX Keeping existing $file.$NEWLINE"
                    ;;
                3)
                    printf "$PREFIX Content of existing $file:$NEWLINE"
                    printf "%s$NEWLINE" "----------------------------------------"
                    cat "$HOME/$file"
                    printf "%s$NEWLINE" "----------------------------------------"
                    printf "$PREFIX Now choose: (1) Backup and replace, (2) Keep existing: "
                    read -r second_choice
                    case $second_choice in
                        1)
                            local backup_name="$HOME/$file.pre-flg-dots.$(date +%Y%m%d-%H%M%S)"
                            printf "$PREFIX Backing up existing $file to $(basename "$backup_name")...$NEWLINE"
                            mv "$HOME/$file" "$backup_name"
                            cp "$zsh_src/$file" "$HOME/$file"
                            printf "$PREFIX $file backup created and FLG version installed.$NEWLINE"
                            ;;
                        2)
                            printf "$PREFIX Keeping existing $file.$NEWLINE"
                            ;;
                        *)
                            printf "$PREFIX Invalid choice, keeping existing $file.$NEWLINE"
                            ;;
                    esac
                    ;;
                *)
                    printf "$PREFIX Invalid choice, keeping existing $file.$NEWLINE"
                    ;;
            esac
        else
            # File doesn't exist, just copy it
            printf "$PREFIX Installing $file...$NEWLINE"
            cp "$zsh_src/$file" "$HOME/$file"
            printf "$PREFIX $file installed successfully.$NEWLINE"
        fi
    done

    # Create some dirs in case they don't exist to make sure
    # that we don't have an ugly linking problem with stow
    mkdir -p "$HOME/.config/hypr"
    mkdir -p "$HOME/.config/kitty"
    mkdir -p "$HOME/.config/matugen"
    mkdir -p "$HOME/.config/quickshell"
    mkdir -p "$HOME/.config/walker"
    mkdir -p "$HOME/.config/wallust"
    mkdir -p "$HOME/.config/waypaper"
    mkdir -p "$HOME/.local/share/icons"
    mkdir -p "$HOME/Pictures"
    
    stow --target="$HOME" $stow_pkgs
    
    cd "$SCRIPT_DIR"

    printf "$PREFIX Finished installing home directory dotfiles.$NEWLINE"
}
