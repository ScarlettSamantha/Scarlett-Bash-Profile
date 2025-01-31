#!/bin/bash

# Function to check if the SSH agent is running
is_ssh_agent_running() {
    if [[ -S "$SSH_AUTH_SOCK" ]]; then
        # Attempt to communicate with the agent
        if ssh-add -l &>/dev/null; then
            return 1 # SSH agent is running and accessible
        fi
    fi
    return 0  # SSH agent is not running or inaccessible
}

# Function to fix or start the SSH agent
fix_ssh_agent() {
    if ! is_ssh_agent_running; then
        # Remove any stale socket file
        if [ -e "$SSH_AGENT_SOCK" ]; then
            echo "Removing stale SSH agent socket file..." | indent_output 4
            rm -f "$SSH_AGENT_SOCK"
        fi

        # Start a new ssh-agent with the specified socket
        echo " * Starting a new SSH agent..." | indent_output 4

        # Capture ssh-agent output, filter out empty lines
        agent_output=$(ssh-agent -a "$SSH_AGENT_SOCK" -P libfido2.so 2>/dev/null | grep -v '^$')

        # Display the filtered output with indentation and icons
        #echo "$agent_output" | indent_output 4

        # Evaluate the ssh-agent output to set environment variables
        eval "$agent_output" | indent_output 4
    else
        echo " * SSH agent is already running." | indent_output 4
    fi
}

# Function to fix and display keychain information
fix_keychain() {
    # Check if the shell is interactive
    if [[ $- == *i* ]]; then
        keys=$(find ~/.ssh -maxdepth 2 -type f \( -name "*id_*" -o -name "ed25519-sk" \) ! -name "*.pub")

        if is_ssh_agent_running; then
            export SSH_AUTH_SOCK;
            printf "* SSH agent is running at %s\n" "$SSH_AUTH_SOCK" | indent_output 4
        else
            echo "* SSH agent is not running." | indent_output 4
        fi

        # If keys are found, load them using keychain
        if [[ -n "$keys" ]]; then
            # Initialize keychain without capturing output to set environment variables
            eval "$(keychain --eval --agents ssh $keys 2>/dev/null)"

            # Capture keychain output, filter out unwanted lines and empty lines
            keychain_output=$(keychain --eval --agents ssh $keys 2>&1 | \
                              grep -vE "SSH_AUTH_SOCK|SSH_AGENT_PID|export" | \
                              grep -v '^$')

            # Display the filtered output with indentation and icons
            echo "$keychain_output" | indent_output 4
        fi
    fi
}

# Function to check if YubiKey is connected
check_yubikey() {
    if command -v ykman 2>&1 /dev/null; then
        if ykman info | grep -q "FIDO2"; then
            echo "✅ YubiKey detected." | indent_output 4
            return 0
        else
            echo "❌ No YubiKey found. Please insert it." | indent_output 4
            return 1
        fi
    else
        echo "❌ Error: 'ykman' is not installed. Install it with: sudo apt install yubikey-manager" | indent_output 4
        return 1
    fi
}

set_yubikey_cache() {
    local timeout=$1
    local ssh_key

    # Get the SSH key from Git global config
    ssh_key=$(git config --global user.signingkey)

    # If no global key, check Git local config
    if [ -z "$ssh_key" ]; then
        ssh_key=$(git config --local user.signingkey)
    fi

    # If no Git key is found, default to ~/.ssh/id_rsa
    if [ -z "$ssh_key" ]; then
        ssh_key="$HOME/.ssh/id_rsa"
    fi

    if ! check_yubikey; then
        return 1
    fi

    if [ ! -f "$ssh_key" ]; then
        echo "❌ Error: SSH key not found at $ssh_key."
        return 1
    fi

    # Set YubiKey fingerprint cache timeout (for GPG-based SSH authentication)
    if command -v gpg-connect-agent &>/dev/null; then
        echo "🔒 Setting YubiKey fingerprint cache timeout to $timeout seconds..."
        echo "SETENV SSH_AUTH_SOCK $SSH_AUTH_SOCK" | gpg-connect-agent updatestartuptty /bye
        echo "SETATTR AUTH-TIMEOUT $timeout" | gpg-connect-agent /bye
    elif command -v ykman &>/dev/null; then
        echo "🔒 Setting YubiKey fingerprint cache timeout to $timeout seconds using ykman..."
        ykman piv info | grep -q "PIN timeout" && ykman piv set-pin-retries 3 "$timeout"  # This assumes a compatible YubiKey
    else
        echo "⚠️ No supported method found to set YubiKey fingerprint cache timeout."
    fi
    echo "✅ YubiKey fingerprint cache set to $timeout seconds for key: $ssh_key"

}

# Function to check if the SSH key is cached
get_yubikey_cache() {
    ssh-add -l | grep -i "sk" 2>&1 /dev/null
    if [ $? -eq 0 ]; then
        echo 1
    else
        echo 0
    fi
}

# Execute the functions
fix_ssh_agent
fix_keychain

# Create an alias with a force option
create_alias "fix_ssh_agent" "fix_ssh_agent" "yes" "Fix or start the SSH agent"
create_alias "set_yubikey_cache" "set_yubikey_cache" "yes" "Force set the YubiKey fingerprint cache timeout"