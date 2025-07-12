#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

install_home_dir() {
    local rice_dir="$SCRIPT_DIR/rice"
    cd "$rice_dir"
    printf "$PREFIX Installing dotfiles to $HOME...$NEWLINE"

    local stow_pkgs="hyprcursor hyprland quickshell kitty rofi wallpapers wallust xdg-dirs zsh"
    local nvidia_pkg="hyprland-nvidia"
    local non_nvidia_pkg="hyprland-no-nvidia"

    if [[ "$DRY_RUN" == true ]]; then
        printf "$PREFIX [DRY_RUN] Would run: mkdir -p \$HOME/.config$NEWLINE"
        printf "$PREFIX [DRY_RUN] Would run: mkdir -p \$HOME/.local/share/icons$NEWLINE"

        printf "$PREFIX [DRY_RUN] Would run: stow --target=\"$HOME\" $stow_pkgs$NEWLINE"

        if detect_nvidia; then
            printf "$PREFIX [DRY_RUN] Would run: stow --target=\"$HOME\" $nvidia_pkg$NEWLINE"
        else
            printf "$PREFIX [DRY_RUN] Would run: stow --target=\"$HOME\" $non_nvidia_pkg$NEWLINE"
        fi
        
        printf "$PREFIX [DRY_RUN] Would run: xdg-user-dirs-update$NEWLINE"
        printf "$PREFIX [DRY_RUN] Would run: mkdir -p \$HOME/.local/bin$NEWLINE"
        printf "$PREFIX [DRY_RUN] Would run: cp ./update-rice.sh \$HOME/.local/bin$NEWLINE"
        printf "$PREFIX [DRY_RUN] Would run: chmod +x \$HOME/.local/bin/update-rice.sh$NEWLINE"
    else
        # Create some dirs in case they don't exist to make sure
        # that we don't have an ugly linking problem with stow
        mkdir -p "$HOME/.config"
        mkdir -p "$HOME/.local/share/icons"

        stow --target="$HOME" $stow_pkgs

        if detect_nvidia; then
            stow --target="$HOME" $nvidia_pkg
        else
            stow --target="$HOME" $non_nvidia_pkg
        fi

        xdg-user-dirs-update

        mkdir -p $HOME/.local/bin
        cp ./update-rice.sh $HOME/.local/bin
        chmod +x $HOME/.local/bin/update-rice.sh
    fi

    cd ".."
    printf "$PREFIX Finished installing home directory dotfiles.$NEWLINE"
}

install_root_dirs() {
    local rice_dir="$SCRIPT_DIR/rice"
    local grub_theme="/usr/share/grub/themes/catppuccin-mocha-grub-theme/theme.txt"
    
    cd "$rice_dir"
    printf "$PREFIX Installing dotfiles to root directories...$NEWLINE"
    
    # Install grub theme
    if is_pkg_installed grub && [ -f /boot/grub/grub.cfg ]; then
        printf "$PREFIX Installing grub theme...$NEWLINE"
        
        if [[ "$DRY_RUN" == true ]]; then
            printf "$PREFIX [DRY_RUN] Would run: sudo cp -r catppuccin-grub/src/* /usr/share/grub/themes/$NEWLINE"
            printf "$PREFIX [DRY_RUN] Would run: update GRUB_THEME in /etc/default/grub$NEWLINE"
            printf "$PREFIX [DRY_RUN] Would run: sudo grub-mkconfig -o /boot/grub/grub.cfg$NEWLINE"
        else
            sudo cp -r catppuccin-grub/src/* /usr/share/grub/themes/
            
            # Check if GRUB_THEME is already set and correct
            if grep -q "^GRUB_THEME=\"${grub_theme}\"" /etc/default/grub; then
                echo "GRUB_THEME is already correctly set in /etc/default/grub."
                # Check if GRUB_THEME is set but to something else
                elif grep -q "^GRUB_THEME=" /etc/default/grub; then
                echo "Updating GRUB_THEME in /etc/default/grub..."
                sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"${grub_theme}\"|" /etc/default/grub
                # Check if GRUB_THEME is commented out
                elif grep -q "^#GRUB_THEME=" /etc/default/grub; then
                echo "Uncommenting and setting GRUB_THEME in /etc/default/grub..."
                sudo sed -i "s|^#GRUB_THEME=.*|GRUB_THEME=\"${grub_theme}\"|" /etc/default/grub
                # Else, add GRUB_THEME
            else
                echo "Adding GRUB_THEME to /etc/default/grub..."
                echo "GRUB_THEME=\"${grub_theme}\"" | sudo tee -a /etc/default/grub > /dev/null
            fi
            
            sudo grub-mkconfig -o /boot/grub/grub.cfg
        fi
    fi
    
    # Install sddm theme
    if is_pkg_installed sddm; then
        printf "$PREFIX Installing sddm theme...$NEWLINE"
        
        if [[ "$DRY_RUN" == true ]]; then
            printf "$PREFIX [DRY_RUN] Would run: sddm --example-config | sudo tee /etc/sddm.conf$NEWLINE"
            printf "$PREFIX [DRY_RUN] Would run: curl -L ...catppuccin-mocha.zip$NEWLINE"
            printf "$PREFIX [DRY_RUN] Would run: sudo unzip ...$NEWLINE"
            printf "$PREFIX [DRY_RUN] Would run: sudo sed ...$NEWLINE"
            printf "$PREFIX [DRY_RUN] Would run: sudo systemctl enable sddm.service$NEWLINE"
        else
            
            if [[ ! -f "/etc/sddm.conf" ]]; then
                printf "$PREFIX Generating new sddm config because it didn't exist yet...$NEWLINE"
                sddm --example-config | sudo tee /etc/sddm.conf > /dev/null
            fi
            
            TEMP_ZIP=$(mktemp --suffix=.zip)
            printf "$PREFIX Downloading theme...$NEWLINE"
            if ! curl -L "https://github.com/catppuccin/sddm/releases/download/v1.0.0/catppuccin-mocha.zip" -o "${TEMP_ZIP}"; then
                printf "Error: Failed to download theme. Exiting.${NEWLINE}"
                rm -f "$TEMP_ZIP"
                exit 1
            fi
            
            printf "$PREFIX Unzipping theme to /usr/share/sddm/themes/...${NEWLINE}"
            sudo mkdir -p "/usr/share/sddm/themes/"
            if ! sudo unzip -o "${TEMP_ZIP}" -d "/usr/share/sddm/themes/"; then
                printf "Error: Failed to unzip theme. Exiting.${NEWLINE}"
                rm -f "$TEMP_ZIP"
                exit 1
            fi
            rm -f "$TEMP_ZIP"
            
            # Ensure [Theme] section header exists. If not, append it.
            if ! sudo grep -q "\[Theme\]" "/etc/sddm.conf" 2>/dev/null; then
                echo -e "${NEWLINE}[Theme]" | sudo tee -a "/etc/sddm.conf" > /dev/null
            fi
            
            sudo sed -i \
            -e "/^\s*\[Theme\]\s*$/,/^\s*\[/ { /^\s*Current\s*=/d; }" \
            -e "/^\s*\[Theme\]\s*$/a Current=catppuccin-mocha" \
            "/etc/sddm.conf"
            
            printf "$PREFIX Enabled sddm service, active on next reboot.$NEWLINE"
            sudo systemctl enable sddm.service
        fi
    fi
    
    cd ".."
    printf "$PREFIX Finished installing root directory dotfiles (if any were specified).$NEWLINE"
}
