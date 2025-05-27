#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

install_home_dir() {
    local rice_dir="$SCRIPT_DIR/rice"
    
    cd "$rice_dir"
    printf "$PREFIX Installing dotfiles to $HOME...$NEWLINE"
    
    stow --target="$HOME" hypr-catppuccin hyprland hyprlock hyprpaper kitty rofi waybar
    
    if detect_nvidia; then
        stow --target="$HOME" hypr-nvidia
        
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
    
    # Install sddm theme
    if is_pkg_installed sddm; then
        printf "$PREFIX Installing sddm theme...$NEWLINE"
        
        if [[ ! -f "/etc/sddm.conf" ]]; then
            sudo sddm --example-config > /etc/sddm.conf
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
    fi
    
    cd ".."
    printf "$PREFIX Finished installing root directory dotfiles (if any were specified).$NEWLINE"
}
