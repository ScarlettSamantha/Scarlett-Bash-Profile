#!/bin/bash

# Function to create an alias with additional options

touch_safe() {
    local path create_dirs=0 owner user group
    
    # Default ownership to the current user and group
    user=$(id -u -n)
    group=$(id -g -n)
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p) create_dirs=1; shift ;;
            -o) 
                if [[ -n "$2" ]]; then
                    owner="$2"
                    user=$(echo "$owner" | cut -d: -f1)
                    group=$(echo "$owner" | cut -d: -f2)
                    [[ -z "$group" ]] && group="$user"
                    shift 2
                else
                    echo "Error: -o requires an argument (user[:group])" >&2
                    return 1
                fi
                ;;
            --) shift; break ;;  # End of options
            -*)
                echo "Unknown option: $1" >&2
                return 1
                ;;
            *)
                path="$1"
                shift
                ;;
        esac
    done
    
    [[ -z "$path" ]] && { echo "Usage: touch_safe [-p] [-o user[:group]] <file>"; return 1; }

    # Create parent directories if -p is used
    if [[ "$create_dirs" -eq 1 ]]; then
        mkdir -p "$(dirname "$path")" || return 1
    fi

    # Ensure the file exists
    [[ -e "$path" ]] || touch "$path" || return 1

    # Set ownership if specified
    chown "$user:$group" "$path" || return 1

    return 0
}

function truncate_file() {
  local file="$1"
  local bytes="${2:-10}"

  # Ensure required arguments are provided
  if [[ -z "$file" ]]; then
    echo "Usage: truncate_file <file> [bites]"
    return 1
  fi

  # Truncate the file to the specified number of bites
  truncate -s "$bytes" "$file"
}


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

# Function to execute all commands as root
run_as_root() {
    if [[ ! -s "$CMD_FILE" ]]; then
        echo "ℹ️ No commands to execute."
        return 1
    fi

    # Check if we are already root
    if [[ $EUID -ne 0 ]]; then
        echo -e "\n⚠️  Root privileges required. Asking for sudo..."
        sudo bash "$CMD_FILE"
    else
        bash "$CMD_FILE"
    fi

    # Clean up after execution
    truncate_file "$CMD_FILE" 0
}


# Default aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Docker Stuff

alias d='docker'
alias dc='docker compose'
alias dce='docker compose exec'
alias dcr='docker compose run'
alias dcb='docker compose build'
alias dcd='docker compose down'
alias dcu='docker compose up'
alias dcp='docker compose ps'
alias dcl='docker compose logs'
alias dclf='docker compose logs -f'

alias d-up='docker-compose up -d'
alias d-down='docker compose down'
alias d-status='docker compose ps'

alias d-force-rebuild='docker compose up --build --force-recreate -d'

# Create an alias for group_tables
create_alias "group_tables" "group_tables" "yes" 'Display group/users rights.'
create_alias "disable_ipv6" "disable_ipv6" "yes" 'Disable IPv6'
create_alias "enable_ipv6" "enable_ipv6" "yes" 'Enable IPv6'
create_alias "touch_safe" "touch_safe" "yes" 'Safely create or update a file with specified ownership.'
create_alias "truncate_file" "truncate_file" "yes" 'Truncate a file to a specified number of bytes.'
create_alias "run_as_root" "run_as_root" "yes" 'Execute all commands in a file as root.'
