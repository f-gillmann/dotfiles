#!/usr/bin/env bash

hyprctl reload
hyprctl dispatch exec waypaper --restore
pkill quickshell && hyprctl dispatch quickshell -p ~/.config/quickshell/shell.qml
pkill rofi

exit 0
