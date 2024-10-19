#!/bin/bash
# Bootstrapper Script to Source All *.sh Files in the Directory
# Ensures it does not source itself
# Author Scarlett Samanttha Verheul <scarlett.verheul@gmail.com>

LOG_FILE="$HOME/.ssh_agent_log"

get_script_path() {
    local SOURCE="${BASH_SOURCE[0]}"
    while [ -h "$SOURCE" ]; do # Resolve $SOURCE until the file is no longer a symlink
        DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
        SOURCE="$(readlink "$SOURCE")"
        [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    done
    DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
    echo "$DIR/$(basename "$SOURCE")"
}

BOOTSTRAPPER_PATH="$(get_script_path)"
BOOTSTRAPPER_DIR="$(dirname "$BOOTSTRAPPER_PATH")"
source "$BOOTSTRAPPER_DIR/_precheck.sh"

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

echo -e "${CYAN}${BOLD}[Sc-Toolbox]${RESET} Bootstrapper started in ${BOOTSTRAPPER_DIR}"

# Initialize iterator if not already done
iterator=0

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

    # Debugging: Uncomment the following line to see which files are being processed
    # echo "Processing file: $basename, First character: $first_char"

    # Skip the bootstrapper script itself and any files starting with '_'
    if [[ "$script" != "$BOOTSTRAPPER_PATH" && "$first_char" != '_' ]]; then
        ((iterator++)) # Increment the iterator

        # Source the script
        source "$script"

        echo -e "  ↳ Sourced: ${GREEN}${basename}${RESET}"
    else
        # Optionally, you can log skipped files for debugging
        # echo -e "  ↳ Skipped: ${basename}"
        :
    fi
done

source "$BOOTSTRAPPER_DIR/_motd.sh"
echo -e "${CYAN}${BOLD}[Sc-Toolbox]${RESET} Bootstrapper: ${SUCCESS_EMOJI} Sourced all [${YELLOW}${iterator}${RESET}] .sh files in ${BOOTSTRAPPER_DIR}/*.sh"