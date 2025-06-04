hyprctl reload
hyprctl hyprpaper reload ,"$wallpaper_path"
pkill waybar && hyprctl dispatch exec waybar
pkill swaync && hyprctl dispatch exec swaync
pkill rofi

exit 0