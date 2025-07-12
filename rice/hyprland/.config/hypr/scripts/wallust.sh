#!/usr/bin/env bash

set -e # exit immediately if a command fails.

wallpaper_path="$1"

if [ -z "$wallpaper_path" ] || [ ! -f "$wallpaper_path" ]; then
    echo "Error: You must provide a valid path to a wallpaper file."
    echo "Usage: $0 /path/to/wallpaper.png"
    exit 1
fi

wallust run "$wallpaper_path" && source "$HOME/.config/hypr/scripts/reload.sh"
