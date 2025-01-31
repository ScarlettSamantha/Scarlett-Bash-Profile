#!/bin/bash

# Function to create an alias with additional options

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
alias docker-compose='docker compose'
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
alias fstab='sudo vim /etc/fstab'
alias hosts='sudo vim /etc/hosts'
alias sysctl='sudo vim /etc/sysctl.conf'

# Create an alias for group_tables
create_alias "group_tables" "group_tables" "yes" 'Display group/users rights.'
create_alias "disable_ipv6" "disable_ipv6" "yes" 'Disable IPv6'
create_alias "enable_ipv6" "enable_ipv6" "yes" 'Enable IPv6'
create_alias "touch_safe" "touch_safe" "yes" 'Safely create or update a file with specified ownership.'
create_alias "truncate_file" "truncate_file" "yes" 'Truncate a file to a specified number of bytes.'
create_alias "run_as_root" "run_as_root" "yes" 'Execute all commands in a file as root.'


# Overrides for nala

if (command_exists "nala"); then
  alias apt="nala"
else
  echo "Go install nala"
fi
