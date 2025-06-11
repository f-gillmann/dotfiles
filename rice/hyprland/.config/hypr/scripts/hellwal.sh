#!/usr/bin/env bash

default_wallpaper="$HOME/.config/.default_wallpaper"
current_wallpaper_path=$(readlink "$HOME/.config/.current_wallpaper" || echo "")
new_wallpaper_path="$(readlink -f $1)"

check_file() {
    if [ ! -f "$1" ]; then
        return 1
    fi
}

main() {
    if [ -z "$1" ] || [ "$(check_file "$new_wallpaper_path"; echo $?)" != "0" ]; then
        if [ ! -f "$default_wallpaper" ]; then
            echo "Error: Default wallpaper '$default_wallpaper' does not exist"
            exit 1
        fi

        ln -sf "$default_wallpaper" "$HOME/.config/.current_wallpaper"
    else
        ln -sf "$new_wallpaper_path" "$HOME/.config/.current_wallpaper"
    fi

    current_wallpaper_path=$(readlink "$HOME/.config/.current_wallpaper")

    mkdir -p $HOME/.cache/hellwal/ &&
    hellwal -i "$current_wallpaper_path" -f "$HOME/.config/hellwal/templates/" -o "$HOME/.cache/hellwal/" &&
    source "$HOME/.config/hypr/scripts/reload.sh"
}

main "$@"
