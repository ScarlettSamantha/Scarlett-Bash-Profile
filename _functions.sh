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