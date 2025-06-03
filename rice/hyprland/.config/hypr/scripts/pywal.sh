#!/usr/bin/env bash

wallpaper_path=$(readlink "$HOME/.current_wallpaper")

check_file() {
    if [ ! -f "$1" ]; then
        echo "File $1 not found!"
        exit 1
    fi
}

check_file "$wallpaper_path"

for opt in $@; do
  case "$opt" in
      no-tty)
        sleep 0.2
        wal -i "$wallpaper_path" --contrast 4.5 --saturate 0.4 -s -t
      ;;
      *)
        sleep 0.2
        wal -i "$wallpaper_path" --contrast 4.5 --saturate 0.4
      ;;
  esac
done
