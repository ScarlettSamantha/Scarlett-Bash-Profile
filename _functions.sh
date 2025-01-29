# Function to display sourcing text with emoji, color, and indentation
function sourcing_text() {
    local emoji="🔧"
    local color="\e[32m"
    local reset="\e[0m"
    local text="Sourcing"             # Default text
    local source_name="$1"            # Name to display
    local indentation_level="${2:-2}" # Number of spaces for indentation

    # Generate proper indentation
    local indentation
    indentation=$(printf "%*s" "$indentation_level" "")

    # Return formatted sourcing text with proper indentation
    printf "%s%s %s %s%s%s" "${indentation}" "${emoji}" "${text}" "${color}" "${source_name}" "${reset}"
}

#!/bin/bash

# Function to echo text with color
# Arguments:
#   1: The text to display
#   2: The color code (e.g., "red", "green", "yellow", etc.)
echo_colored_text() {
    local text="$1"
    local color="$2"

    # Define color codes
    local colors=(
        ["black"]="\033[0;30m"
        ["red"]="\033[0;31m"
        ["green"]="\033[0;32m"
        ["yellow"]="\033[0;33m"
        ["blue"]="\033[0;34m"
        ["magenta"]="\033[0;35m"
        ["cyan"]="\033[0;36m"
        ["white"]="\033[0;37m"
    )

    # Get the color code or default to white if the color is invalid
    local color_code="${colors[$color]}"
    if [ -z "$color_code" ]; then
        echo "Invalid color. Supported colors are: ${!colors[@]}"
        return 1
    fi

    # Echo text with the specified color and reset
    echo -e "${color_code}${text}\033[0m"
}

# Function to display sourcing text with emoji, color, and indentation
alias_text() {
    local alias_name="$1"             # Alias name
    local indentation_level="${2:-2}" # Number of spaces for indentation
    local description="$3"            # Description of the alias (optional)

    local emoji="🔧"
    local color="\e[32m" # Green color
    local reset="\e[0m"  # Reset color

    # Generate proper indentation
    local indentation
    indentation=$(printf "%*s" "$indentation_level" "")

    # Print formatted text with emoji, alias name, and color (interpreted properly)
    printf "%b↳ %s Aliasing: %b%s%b\n" \
        "$indentation" "$emoji" "$color" "$alias_name" "$reset"

    # If a description is provided and not just "yes", display it with further indentation
    if [[ -n "$description" && "$description" != "yes" ]]; then
        printf "%b↳ %s: %s\n" "$indentation  " "$alias_name" "$description"
    fi
}

# Main generic_echo function
generic_echo() {
    # Arguments with defaults
    local indents="${1:-4}"    # Number of indents, default: 4
    local emoji="${2:-ow}"     # Emoji, default: "ow"
    local do_reset="${4:-yes}" # Reset behavior, default: "yes"
    local do_enter="${5:-no}"  # Enter behavior, default: "no"

    # Formatting
    local indentation
    indentation=$(printf "%*s" "$indents" "")

    # Sourcing text
    sourcing_output=$(sourcing_text "$emoji" "$3")

    # Output logic
    echo -e "${indentation}${sourcing_output}"

    # Handle "do_enter" and "do_reset"
    if [[ "$do_enter" == "yes" ]]; then
        echo ""
    fi

    if [[ "$do_reset" == "yes" ]]; then
        tput sgr0 # Reset terminal formatting
    fi
}

is_interactive_terminal() {
    # Check if the shell is interactive
    if [[ "$-" != *i* ]]; then
        return 1 # Not interactive
    fi

    # Check if stdout is connected to a terminal
    if ! [ -t 1 ]; then
        return 1 # Not connected to a terminal
    fi

    return 0 # Interactive terminal
}

var_dump() {
    local var_name="$1"
    if declare -p "$var_name" &>/dev/null; then
        declare -p "$var_name"
    else
        echo "Variable '$var_name' does not exist."
    fi
}

handle_interactive_output() {
    local command_output
    local is_interactive
    local current_tty

    # Determine if the shell is interactive
    case "$-" in
    *i*) is_interactive=true ;;
    *) is_interactive=false ;;
    esac

    # Execute the command passed as arguments
    # Capture both stdout and stderr
    command_output=$("$@" 2>&1)
    local exit_status=$?

    # Log the output
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $*" >>"$LOG_FILE"
    echo "$command_output" >>"$LOG_FILE"

    if $is_interactive; then
        # Detect current TTY
        if current_tty=$(tty 2>/dev/null); then
            # Output to the terminal
            echo "$command_output" >"$current_tty"
        else
            # Fallback if TTY is not available
            echo "$command_output"
        fi
    fi

    return $exit_status
}

indent_message() {
    local num_indents=$1
    local message=$2
    local indent=""
    local indent_emoji="${3:-$INDENT_EMOJI}"

    for ((i = 0; i < num_indents; i++)); do
        indent+="  " # Add two spaces per indent
    done
    echo -e "${indent}$indent_emoji ${message}"
}
