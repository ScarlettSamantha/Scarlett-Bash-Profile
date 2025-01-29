#!/bin/bash

# Define individual color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'
BOLD='\033[1m'

# Define associative array for color codes
declare -A colors=(
    ["black"]='\033[0;30m'
    ["red"]='\033[0;31m'
    ["green"]='\033[0;32m'
    ["yellow"]='\033[1;33m'
    ["blue"]='\033[0;34m'
    ["magenta"]='\033[0;35m'
    ["cyan"]='\033[0;36m'
    ["white"]='\033[0;37m'
    ["bold"]='\033[1m'
    ["reset"]='\033[0m'
)

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
        echo -e "${RED}Invalid color. Supported colors are: ${!colors[@]}${RESET}"
        return 1
    fi

    # Echo text with the specified color and reset
    echo -e "${color_code}${text}${RESET}"
}