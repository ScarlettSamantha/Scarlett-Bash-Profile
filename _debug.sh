#!/bin/bash

# Set default debug level if not set
: "${SC_DEBUG_LEVEL:=error}"  # Default to 'error' if SC_DEBUG_LEVEL is not set

declare -A _WARN_LOGGED  # Track warnings to prevent duplicates

warn() {
  local message="$*"
  local file="${BASH_SOURCE[1]:-unknown}"
  local line="${BASH_LINENO[0]:-unknown}"
  local func="${FUNCNAME[1]:-global}"
  local warning_id="${file}:${line}:${func}:${message}"

  # Prevent duplicate warnings
  if [[ "${_WARN_LOGGED[$warning_id]}" == "1" ]]; then
    return
  fi
  _WARN_LOGGED[$warning_id]=1

  echo -e "\e[1;33m⚠️ WARNING:\e[0m [$file:$line in $func] $message" >&2
}

is_debug_mode() {
    [[ "${DEBUG,,}" == "true" ]]  # Case-insensitive check for "true"
}

if [[ "$DEBUG" != "false" ]]; then
    set -o pipefail  # Return exit status of the last failed command in a pipeline

    case "$SC_DEBUG_LEVEL" in
        info)
            #set -v  # Enable verbose mode (prints shell input lines)
            ;;
        debug)
            #set -E  # Ensure ERR traps work inside functions and subshells
            #set -u  # Treat unset variables as an error
            #set -o errtrace  # Enable ERR traps in functions and subshells
            #set -x  # Enable debug mode
            ;;
        error)
            # Default error handling (only trap ERR)
            ;;
        warn)
            # Default error handling (only trap ERR)
            #rap 'warn "Command failed at ${BASH_SOURCE[0]}:${LINENO} in ${FUNCNAME[0]:-MAIN}"' ERR
            ;;
        *)
            #echo "[ WARNING] Invalid SC_DEBUG_LEVEL: ""$SC_DEBUG_LEVEL"". Using 'error' level." >&2
            ;;
    esac

    # Enhanced debug prompt for stack tracing
    #export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

    # Capture and print stack traces on errors
    #trap 'echo "[ERROR] Command failed at ${BASH_SOURCE[0]}:${LINENO} in ${FUNCNAME[0]:-MAIN}" >&2' ERR
fi


