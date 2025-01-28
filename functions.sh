#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

get_highlight_color() {
    # Get a random color for our highlights that is not black (30) or bigger than white (37)
    HIGHLIGHT_COLOR=$((31 + $RANDOM % 6))
    echo $HIGHLIGHT_COLOR
}

print_ascii_art() {
    # ██████╗  ██████╗ ████████╗███████╗
    # ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝
    # ██║  ██║██║   ██║   ██║   ███████╗
    # ██║  ██║██║   ██║   ██║   ╚════██║
    # ██████╔╝╚██████╔╝   ██║   ███████║
    # ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝
    #
    # █████████████████████████████████╗
    # ╚════════════════════════════════╝

    # Print the ascii art from the comment above with a specified highlight color
    printf "\n"
    printf "    \e[0m██████\e[${1}m╗\e[0m  ██████\e[${1}m╗\e[0m ████████\e[${1}m╗\e[0m███████\e[${1}m╗\e[0m\n"
    printf "    \e[0m██\e[${1}m╔══\e[0m██\e[${1}m╗\e[0m██\e[${1}m╔═══\e[0m██\e[${1}m╗╚══\e[0m██\e[${1}m╔══╝\e[0m██\e[${1}m╔════╝\e[0m\n"
    printf "    \e[0m██\e[${1}m║\e[0m  ██\e[${1}m║\e[0m██\e[${1}m║\e[0m   ██\e[${1}m║\e[0m   ██\e[${1}m║\e[0m   ███████\e[${1}m╗\e[0m\n"
    printf "    \e[0m██\e[${1}m║\e[0m  ██\e[${1}m║\e[0m██\e[${1}m║\e[0m   ██\e[${1}m║\e[0m   ██\e[${1}m║\e[0m   \e[${1}m╚════\e[0m██\e[${1}m║\e[0m\n"
    printf "    \e[0m██████\e[${1}m╔╝╚\e[0m██████\e[${1}m╔╝\e[0m   ██\e[${1}m║\e[0m   ███████\e[${1}m║\e[0m\n"
    printf "    \e[${1}m╚═════╝\e[0m  \e[${1}m╚═════╝\e[0m    \e[${1}m╚═╝\e[0m   \e[${1}m╚══════╝\e[0m\n"
    printf "    █████████████████████████████████\e[${1}m╗\e[0m\n"
    printf "    \e[${1}m╚════════════════════════════════╝\n"
    printf "        \e[0mmade by\e[0m \e[4;${1}mFlorian Gillmann\n"
    printf "\e[0m\n"
}


check_dependencies() {
  local DEPENDENCIES=("$@")

  local MISSING_DEPENDENCIES=()
  for dep in "${DEPENDENCIES[@]}"; do
    if ! pacman -Qq "$dep" &> /dev/null; then
      MISSING_DEPENDENCIES+=("$dep")
    fi
  done

  # Return the missing dependencies
  echo "${MISSING_DEPENDENCIES[@]}"
}
