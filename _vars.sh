export CMD_FILE="/tmp/root_commands.sh"
export USERNAME=$(get_username)
export USER_ID=$(get_user_id)
export USER_GROUPS=$(get_user_groups)
# To prevent a collision with the existing XDG_SESSION_TYPE variable, we will prefix our variable with X_
export X_PREFIX="[Sc-Toolbox]"
if is_root; then
    export USER_ROOT_COLOR="$RED"
else
    export USER_ROOT_COLOR="$GREEN"
fi