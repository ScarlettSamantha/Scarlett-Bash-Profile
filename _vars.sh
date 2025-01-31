#!/usr/bin/env bash

export CMD_FILE="/tmp/root_commands.sh"
export SC_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export USERNAME=$(get_username)
export USER_ID=$(get_user_id)
export USER_GROUPS=$(get_user_groups)

# Prevent collision with existing XDG_SESSION_TYPE variable
export X_PREFIX="[Sc-Toolbox]"

if is_root; then
    export USER_ROOT_COLOR="$RED"
else
    export USER_ROOT_COLOR="$GREEN"
fi

# Properly source .env to avoid parsing issues
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

# Check if DEBUG is set to '1' or 'true' in .env; unify DEBUG and SC_DEBUG
if echo "$DEBUG" | grep -qiE "^(1|true)$"; then
    export DEBUG=true
else
    export DEBUG=false
fi
export SC_DEBUG="$DEBUG"

# Assign SC_DEBUG_LEVEL depending on SC_DEBUG
if [ "$SC_DEBUG" = true ]; then
    export SC_DEBUG_LEVEL="${SC_DEBUG_LEVEL:-debug}"
else
    export SC_DEBUG_LEVEL="${SC_DEBUG_LEVEL:-warn}"
fi
