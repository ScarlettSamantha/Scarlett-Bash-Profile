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

# Function to get the current username
get_username() {
    echo "$(whoami)"
}

is_in_group() {
    local group="${1:-}"  # Default to empty if not provided
    if [[ -z "$group" ]]; then
        echo "Error: No group specified." >&2
        return 2  # Return a distinct error code for missing argument
    fi

    if id -nG "$(whoami)" | grep -qw "$group"; then
        return 0  # User is in group
    else
        return 1  # User is not in group
    fi
}

is_root() {
    if [[ "$EUID" -eq 0 ]]; then
        return 0  # Root user
    else
        return 1  # Not root
    fi
}

# Function to check if attached to a graphical display
is_graphical_session() {
    if [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" || -n "$XDG_SESSION_TYPE" ]]; then
        return 0  # Has graphical session
    else
        return 1  # No graphical session
    fi
}

# Function to display a GUI message using Zenity
show_gui_message() {
    local message="$1"
    zenity --info --text="$message"
}

# Function to get the current user ID
get_user_id() {
    id -u
}

get_username() {
    local uid="${1:-$(id -u)}"
    getent passwd "$uid" | cut -d: -f1
}

# Function to check if the user is in a specified group
is_in_group() {
    local group="$1"
    if id -nG "$(whoami)" | grep -qw "$group"; then
        return 0  # User is in group
    else
        return 1  # User is not in group
    fi
}

# Function to list all groups of the current user with their UIDs, optional
get_user_groups() {
    local show_uids="${1:-true}"
    groups=$(id -Gn)
    output=""
    for group in $groups; do
        if [[ "$show_uids" == "true" ]]; then
            gid=$(getent group "$group" | cut -d: -f3)
            output+="$group(GID:$gid) "
        else
            output+="$group "
        fi
    done
    echo "$output"
}

is_ssh_session() {
    [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]
}

binary_exists() {
    command -v "$1" >/dev/null 2>&1
}

package_installed() {
    local package="$1"
    
    if [[ -x "/bin/apt" ]]; then
        /bin/apt list --installed 2>/dev/null | grep -q "^$package/"
    elif command -v dpkg-query &>/dev/null; then
        dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "installed"
    else
        echo "Neither apt nor dpkg-query is available." >&2
        return 2
    fi
}

package_search() {
    local package="$1"
    
    if [[ -x "/bin/apt" ]]; then
        /bin/apt search "$package" 2>/dev/null | grep -E "^$package/"
    elif command -v dpkg-query &>/dev/null; then
        dpkg-query -W -f='${binary:Package}\n' 2>/dev/null | grep -E "^$package$"
    else
        echo "Neither apt nor dpkg-query is available." >&2
        return 2
    fi
}

# Function to detect the SSH connection details
get_ssh_details() {
    if is_ssh_session; then
        local client_ip=$(echo "$SSH_CLIENT" | awk '{print $1}')
        local client_port=$(echo "$SSH_CLIENT" | awk '{print $2}')
        local tty_session="$SSH_TTY"
        printf "%s %s %s" "$client_ip" "$client_port" "$tty_session"
    fi
}

# Function to use SSH details in another function
use_ssh_details() {
    if is_ssh_session; then
        read -r client_ip client_port tty_session < <(get_ssh_details)
        # Example: Use these values in another function
        some_other_function "$client_ip" "$client_port" "$tty_session"
    fi
}

should_skip_file() {
    local file="$1"

    [[ ! -f "$file" ]] && return 1  # Return early if not a file

    # Read the first line
    local first_line
    first_line=$(head -n 1 "$file")

    # Check for Ignore flags
    if [[ "$first_line" == "# Ignore: true" ]]; then
        return 0  # Skip the file
    elif [[ "$first_line" == "# Ignore: false" ]]; then
        return 1  # Do not skip the file
    fi

    return 1  # Default to not skipping
}

normalize_path() {
    local path="$1"
    # Remove duplicate slashes (except at the beginning for root paths)
    echo "$path" | sed -E 's|//+|/|g'
}

join_path() {
    local base_path="$1"
    shift # Remove first argument (base path)

    for segment in "$@"; do
        # Ensure we don't prefix an absolute segment ("/something")
        if [[ "$segment" == /* ]]; then
            base_path="$segment"
        else
            base_path="${base_path%/}/$segment"
        fi
    done

    # Normalize final path
    normalize_path "$base_path"
}

_trim_core() {
    local var="$1"
    local chars="${2:-[:space:]}"  # Default to whitespace
    local mode="$3"  # "both" for trim, "left" for ltrim, "right" for rtrim
    local pattern

    # Convert comma-separated list into a character class safely
    pattern="[""$(echo "$chars" | sed 's/,//g')""]"

    # Trim leading characters
    [[ "$mode" != "right" ]] && var="${var#"${var%%[!$pattern]*}"}"

    # Trim trailing characters
    [[ "$mode" != "left" ]] && var="${var%"${var##*[^$pattern]}"}"

    echo "$var"
}

trim() {
    _trim_core "$1" "$2" "both"
}

ltrim() {
    _trim_core "$1" "$2" "left"
}

rtrim() {
    _trim_core "$1" "$2" "right"
}
