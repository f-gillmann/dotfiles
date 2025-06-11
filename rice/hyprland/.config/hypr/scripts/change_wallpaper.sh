#!/usr/bin/env bash

WALLPAPER_DIR=~/Pictures/wallpapers/

wallpapers=$(fd -tf -e jpg -e png "$WALLPAPER_DIR")
selected=$(echo "$wallpapers" | rofi -dmenu -p "Select wallpaper:")

if [ -n "$selected" ]; then
    ~/.config/hypr/scripts/hellwal.sh "$selected"
else
    exit 0
fi
