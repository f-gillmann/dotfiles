#!/usr/bin/env bash

current_wallpaper_path=$(readlink "$HOME/.current_wallpaper")
new_wallpaper_path=$(readlink -f "$1")

check_file() {
    if [ ! -f "$1" ]; then
        exit 1
    fi
}

main() {
    check_file "$new_wallpaper_path"

    ln -sf "$new_wallpaper_path" "$HOME/.current_wallpaper" &&
    hellwal -i "$current_wallpaper_path" -f "$HOME/.config/hellwal/templates/" -o "$HOME/.cache/hellwal/" &&
    source "$HOME/.config/hypr/scripts/reload.sh"
}

main "$@"
