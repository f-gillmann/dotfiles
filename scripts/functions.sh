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

  RESET="\e[0m"
  NEWLINE="\n"

  # Print the ascii art from the comment above with a specified color and light color
  printf "${NEWLINE}"
  printf "    ${RESET}██████${1}╗${RESET}  ██████${1}╗${RESET} ████████${1}╗${RESET}███████${1}╗${RESET}${NEWLINE}"
  printf "    ${RESET}██${1}╔══${RESET}██${1}╗${RESET}██${1}╔═══${RESET}██${1}╗╚══${RESET}██${1}╔══╝${RESET}██${1}╔════╝${RESET}${NEWLINE}"
  printf "    ${RESET}██${1}║${RESET}  ██${1}║${RESET}██${1}║${RESET}   ██${1}║${RESET}   ██${1}║${RESET}   ███████${1}╗${RESET}${NEWLINE}"
  printf "    ${RESET}██${1}║${RESET}  ██${1}║${RESET}██${1}║${RESET}   ██${1}║${RESET}   ██${1}║${RESET}   ${1}╚════${RESET}██${1}║${RESET}${NEWLINE}"
  printf "    ${RESET}██████${1}╔╝╚${RESET}██████${1}╔╝${RESET}   ██${1}║${RESET}   ███████${1}║${RESET}${NEWLINE}"
  printf "    ${1}╚═════╝${RESET}  ${1}╚═════╝${RESET}    ${1}╚═╝${RESET}   ${1}╚══════╝${RESET}${NEWLINE}"
  printf "    █████████████████████████████████${2}╗${RESET}${NEWLINE}"
  printf "    ${2}╚════════════════════════════════╝${NEWLINE}"
  printf "        ${RESET}made by${RESET} ${2}Florian Gillmann${RESET}${NEWLINE}${NEWLINE}"
}
