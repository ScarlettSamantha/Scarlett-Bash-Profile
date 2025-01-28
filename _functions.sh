# Function to display sourcing text with emoji, color, and indentation
function sourcing_text() {
    local emoji="🔧"
    local color="\e[32m"
    local reset="\e[0m"
    local text="Sourcing"            # Default text
    local source_name="$1"           # Name to display
    local indentation_level="${2:-2}" # Number of spaces for indentation

    # Generate proper indentation
    local indentation
    indentation=$(printf "%*s" "$indentation_level" "")

    # Return formatted sourcing text with proper indentation
    printf "%s%s %s %s%s%s" "${indentation}" "${emoji}" "${text}" "${color}" "${source_name}" "${reset}"
}

# Function to display sourcing text with emoji, color, and indentation
function alias_text() {
    local emoji="🔧"
    local color="\e[32m"
    local reset="\e[0m"
    local text="Aliasing: "            # Default text
    local source_name="$1"           # Name to display
    local indentation_level="${2:-2}" # Number of spaces for indentation
    local description="$3"   # Description of the alias

    # Generate proper indentation
    local indentation
    indentation=$(printf "%*s" "$indentation_level" "")

    local description_text
    description_text=$(printf "%s" "$description")

    # Print formatted sourcing text with proper indentation
    printf "%s%s %s%s%s %s" "${indentation}" "${emoji}" "${text}" "${color}" "${source_name}": "${description_text}""${reset}" 
}

# Main generic_echo function
generic_echo() {
    # Arguments with defaults
    local indents="${1:-4}"           # Number of indents, default: 4
    local emoji="${2:-ow}"            # Emoji, default: "ow"
    local do_reset="${4:-yes}"        # Reset behavior, default: "yes"
    local do_enter="${5:-no}"         # Enter behavior, default: "no"

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
        tput sgr0  # Reset terminal formatting
    fi
}


is_interactive_terminal() {
    # Check if the shell is interactive
    if [[ "$-" != *i* ]]; then
        return 1  # Not interactive
    fi

    # Check if stdout is connected to a terminal
    if ! [ -t 1 ]; then
        return 1  # Not connected to a terminal
    fi

    return 0  # Interactive terminal
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
    command_output=$( "$@" 2>&1 )
    local exit_status=$?

    # Log the output
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $*" >> "$LOG_FILE"
    echo "$command_output" >> "$LOG_FILE"

    if $is_interactive; then
        # Detect current TTY
        if current_tty=$(tty 2>/dev/null); then
            # Output to the terminal
            echo "$command_output" > "$current_tty"
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

  for ((i=0; i<num_indents; i++)); do
    indent+="  "  # Add two spaces per indent
  done
  echo -e "${indent}$indent_emoji ${message}"
}