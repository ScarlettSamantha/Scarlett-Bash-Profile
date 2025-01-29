#!/bin/bash

BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
RESET='\033[0m'

# Declare an associative array and populate it using existing variables
declare -A colors
colors["black"]="$BLACK"
colors["red"]="$RED"
colors["green"]="$GREEN"
colors["yellow"]="$YELLOW"
colors["blue"]="$BLUE"
colors["magenta"]="$MAGENTA"
colors["cyan"]="$CYAN"
colors["white"]="$WHITE"
colors["bold"]="$BOLD"
colors["reset"]="$RESET"

export color_list="${!colors[*]}"

# Function to echo text with color
# Arguments:
#   1: The text to display
#   2: The color name (e.g., "red", "green", "yellow", etc.)
echo_colored_text() {
    local text="$1"
    local color="$2"

    # Get the color code or default to reset if invalid
    local color_code="${colors[$color]}"
    if [ -z "$color_code" ]; then
        echo -e "${RED}Invalid color. Supported colors are: ${color_list}${RESET}"
        return 1
    fi

    # Echo text with the specified color and reset
    echo -e "${color_code}${text}${RESET}"
}