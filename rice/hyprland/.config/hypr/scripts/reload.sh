#!/usr/bin/env bash

hyprctl reload
hyprctl hyprpaper reload ,"~/.config/.current_wallpaper"
pkill waybar && hyprctl dispatch exec waybar
pkill swaync && hyprctl dispatch exec swaync
pkill rofi

exit 0
