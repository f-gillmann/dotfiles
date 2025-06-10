hyprctl reload
hyprctl hyprpaper reload ,"~/.current_wallpaper"
pkill waybar && hyprctl dispatch exec waybar
pkill swaync && hyprctl dispatch exec swaync
pkill rofi

exit 0
