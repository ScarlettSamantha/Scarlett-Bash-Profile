#!/bin/bash
# Bootstrapper Script to Source All *.sh Files in the Directory
# Ensures it does not source itself
# Author Scarlett Samanttha Verheul <scarlett.verheul@gmail.com>

LOG_FILE="$HOME/.ssh_agent_log"

get_script_path() {
    local SOURCE="${BASH_SOURCE[0]}"
    while [ -h "$SOURCE" ]; do # Resolve $SOURCE until the file is no longer a symlink
        DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
        SOURCE="$(readlink "$SOURCE")"
        [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    done
    DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
    echo "$DIR/$(basename "$SOURCE")"
}

BOOTSTRAPPER_PATH="$(get_script_path)"
BOOTSTRAPPER_DIR="$(dirname "$BOOTSTRAPPER_PATH")"
source "$BOOTSTRAPPER_DIR/_vars.sh"
source "$BOOTSTRAPPER_DIR/_debug.sh"
source "$BOOTSTRAPPER_DIR/_precheck.sh"
source "$BOOTSTRAPPER_DIR/_functions.sh"

if [ ${#MISSING_COMMANDS[@]} -ne 0 ]; then
    echo "The following required commands are missing: ${MISSING_COMMANDS[*]}"
    echo "Please install the corresponding packages:"
    echo "  - lsb_release: lsb-release"
    echo "  - free, top: procps"
    echo "  - nproc: coreutils"
    echo "You can install them using:"
    echo "  sudo apt-get update && sudo apt-get install procps lsb-release coreutils"
    exit
fi

# We have got the basic commands, now we can proceed with the bootstrapping process

current_tty=$(tty)
iterator=0 # Initialize iterator without 'global'

# Enable nullglob to handle no *.sh files gracefully
shopt -s nullglob

# Get the directory containing the bootstrapper script

source "$BOOTSTRAPPER_DIR/_colors.sh"
source "$BOOTSTRAPPER_DIR/_emoji.sh"
source "$BOOTSTRAPPER_DIR/_vars.sh"

echo -e "${CYAN}${BOLD}${X_PREFIX}${RESET} Bootstrapper started in ${BOOTSTRAPPER_DIR}"

echo -e "${USER_COLOR}${BOLD}${X_PREFIX}${RESET} Running as ${USER_COLOR}$(get_username) (UID: ${USER_ID}, Groups: ${USER_GROUPS})${RESET}"

if is_ssh_session; then
    echo -e "${colors["red"]}${X_PREFIX}⚠️ WARNING: You are running this script over SSH! (IP: $(echo "$SSH_CLIENT" | awk '{print $1}'))${colors["reset"]}"
else
    echo -e "${colors["green"]}${X_PREFIX} ✅ Safe: You are running this script locally.${colors["reset"]}"
fi

if [[ $DEBUG == "true" ]]  ; then
    echo -e "${colors["yellow"]}${X_PREFIX} 🐞 Debug mode enabled.${colors["reset"]}"
else
    echo -e "$DEBUG"
fi

# Initialize iterator if not already done
iterator=0

# Loop through all .sh files in the directory
# Loop through all .sh files in the directory
for script in "$BOOTSTRAPPER_DIR"/*.sh; do
    # Check if the glob didn't match any files
    if [[ ! -e "$script" ]]; then
        echo -e "${YELLOW}No .sh scripts found in ${BOOTSTRAPPER_DIR}.${RESET}"
        break
    fi

    # Get the basename of the script (e.g., 'script.sh' from '/path/to/script.sh')
    basename=$(basename "$script")

    # Extract the first character of the basename
    first_char="${basename:0:1}"

    # **Skip `_`-prefixed or files that want to be skipped files immediately**
    if [ "$first_char" == "_" ] || [ "$(should_skip_file "$script")" == 0 ]; then
        if [ "$DEBUG" = 1 ] && [ "$SC_DEBUG_LEVEL" = 'info' ]; then
            echo -e "  ↳ Skipped (matches exclude rule for _-prefix): ${basename}"
        fi
        continue
    fi

    # Skip the bootstrapper script itself
    if [[ "$script" != "$BOOTSTRAPPER_PATH" ]]; then
        iterator=$((iterator+1)) # Increment the iterator
        echo -e "  ↳ Sourcing: ${LOADING_EMOJI}${GREEN}  ${basename}${RESET}"

        # Source the script and capture the exit status
        # shellcheck source=/dev/null
        if source "$script"; then
            echo -e "  ↳ Sourced:  ${SUCCESS_EMOJI}${GREEN} ${basename}${RESET}"
        else
            echo -e "  ↳ Sourced: ${FAILURE_EMOJI}${RED} ${basename} FAILED${RESET}"
            # Log the failure
            echo "$(date): Failed to source $basename" >>"$LOG_FILE"
        fi
    fi
done

# Check if a graphical session is available
is_graphical_session() {
    [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" || -n "$XDG_SESSION_TYPE" ]]
}

# Ask user for permission via GUI if available
ask_user_permission_gui() {
    if command -v zenity &>/dev/null; then
        zenity --question --title="Root Access Required" --text="This command requires root privileges. Proceed?"
        return $?
    elif command -v kdialog &>/dev/null; then
        kdialog --yesno "This command requires root privileges. Proceed?"
        return $?
    fi
    return 1 # GUI failed, fallback to CLI
}

# Ask user for permission via CLI
ask_user_permission_cli() {
    read -rp "⚠️  This command requires root privileges. Proceed? (y/N): " response
    [[ "$response" =~ ^[Yy]$ ]]
}

# Run a command as root if necessary
run_as_root() {
    local command="$1"

    # Check if the command requires root privileges
    if [[ "$command" =~ ">> /etc/" || "$command" =~ "sysctl" || "$command" =~ "echo " ]]; then
        echo -e "\n⚠️  Root privileges required."

        # Ask for user confirmation
        if is_graphical_session; then
            ask_user_permission_gui || {
                echo "❌ Operation cancelled."
                return 1
            }
        else
            ask_user_permission_cli || {
                echo "❌ Operation cancelled."
                return 1
            }
        fi

        echo -e "🔑 Elevating to root with sudo...\n"
        command="sudo bash -c \"$command\""
    fi

    # Execute the command
    if output=$(eval "$command" 2>&1); then
        echo -e "✅ Command output:\n$output"
    else
        echo -e "\n❌ Error executing command:\n$output" >&2
        return 1
    fi
}

source "$BOOTSTRAPPER_DIR/_motd.sh"
echo -e "${CYAN}${BOLD}[Sc-Toolbox]${RESET} Bootstrapper: ${SUCCESS_EMOJI} Sourced all [${YELLOW}${iterator}${RESET}] .sh files in ${BOOTSTRAPPER_DIR}/*.sh"
