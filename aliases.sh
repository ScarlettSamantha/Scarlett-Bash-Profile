#!/bin/bash

# Function to create an alias with additional options
function create_alias() {
  local function_name="$1"  # The function or command to alias
  local alias_name="$2"     # The alias name
  local prefix_message="$3" # Prefix message (optional)

  # Ensure required arguments are provided
  if [[ -z "$function_name" || -z "$alias_name" ]]; then
    echo "Usage: create_alias <function_name> <alias_name> [prefix_message]"
    return 1
  fi

  # Set default values for optional arguments
  prefix_message="${prefix_message:-""}"

  # Construct the alias command
  alias_command="alias $alias_name='$function_name'"

  # Evaluate the constructed alias command
  eval "$alias_command"

  # Display success message with optional prefix
  alias_text "$alias_name" 4 "$prefix_message"
}

# Git alias to sign commits automatically
git() {
  if [[ "$1" == "commit" ]]; then
    shift
    command git commit -s -S "$@"
  else
    command git "$@"
  fi
}

function group_tables() {
  # Default GID and UID range
  GID_MIN=200
  GID_MAX=2000
  UID_MIN=100
  UID_MAX=2000

  # Default view type and output format
  VIEW="group"
  OUTPUT="table"

  # Parse command-line arguments
  while getopts "l:h:L:H:v:o:" opt; do
    case $opt in
    l) GID_MIN=$OPTARG ;;
    h) GID_MAX=$OPTARG ;;
    L) UID_MIN=$OPTARG ;;
    H) UID_MAX=$OPTARG ;;
    v) VIEW=$OPTARG ;;
    o) OUTPUT=$OPTARG ;;
    *)
      echo "Usage: $0 [-l <min_gid>] [-h <max_gid>] [-L <min_uid>] [-H <max_uid>] [-v <view_type>] [-o <output_format>]"
      exit 1
      ;;
    esac
  done

  # Function to output data in table format
  _output_table() {
    if [[ "$VIEW" == "group" ]]; then
      printf "%-25s | %-8s | %-50s\n" "Group" "GID" "Users (UID)"
      printf "%-25s-+-%-8s-+-%-50s\n" "-------------------------" "--------" "--------------------------------------------------"

      while IFS=: read -r group _ gid users; do
        if [[ $gid -ge $GID_MIN && $gid -le $GID_MAX ]]; then
          user_details=()
          for user in ${users//,/ }; do
            uid=$(id -u "$user" 2>/dev/null || echo "Unknown")
            user_details+=("$user (UID: $uid)")
          done
          user_list=$(
            IFS=,
            echo "${user_details[*]:-None}"
          )
          printf "%-25s | %-8s | %-50s\n" "$group" "$gid" "$user_list"
        fi
      done < <(getent group)
    elif [[ "$VIEW" == "user" ]]; then
      printf "%-20s | %-8s | %-25s\n" "User (UID)" "UID" "Primary Group"
      printf "%-20s-+-%-8s-+-%-25s\n" "--------------------" "--------" "-------------------------"

      while IFS=: read -r user _ uid gid _ home shell; do
        if [[ $uid -ge $UID_MIN && $uid -le $UID_MAX ]]; then
          group_name=$(getent group "$gid" | cut -d: -f1)
          printf "%-20s | %-8s | %-25s\n" "$user (UID: $uid)" "$uid" "$group_name (GID: $gid)"
        fi
      done < <(getent passwd)
    else
      echo "Invalid view type: $VIEW"
      exit 1
    fi
  }

  # Main logic to select output format
  if [[ "$OUTPUT" == "table" ]]; then
    _output_table
  else
    echo "Invalid output format: $OUTPUT"
    exit 1
  fi
}

# Default aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Create an alias for group_tables
create_alias "group_tables" "group_tables" "yes" 'Display group/users rights.'
