#!/bin/bash
# Bootstrapper Script to Source All *.sh Files in the Directory
# Ensures it does not source itself
# Author Scarlett Samanttha Verheul <scarlett.verheul@gmail.com>

# Exit immediately if a command exits with a non-zero status
set -e

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

# Loop through all .sh files in the directory
shopt -s nullglob # Enable nullglob to handle no *.sh files gracefully
for script in "$(dirname "$BOOTSTRAPPER_PATH")"/*.sh; do
    # Skip the bootstrapper script itself to avoid recursive sourcing
    if [[ "$script" != "$BOOTSTRAPPER_PATH" ]]; then
        # Source the script
        source "$script"
    fi
done

echo "[Sc-Toolbox] Bootstrapper: Sourced all .sh files in $(dirname "$BOOTSTRAPPER_PATH")"
