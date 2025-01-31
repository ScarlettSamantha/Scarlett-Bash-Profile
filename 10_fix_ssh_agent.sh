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


fix_ssh_agent() {
    if ! is_ssh_agent_running; then
        # Remove stale socket file
        if [ -e "$SSH_AGENT_SOCK" ]; then
            echo "Removing stale SSH agent socket file..."
            rm -f "$SSH_AGENT_SOCK"
        fi

        # Start new ssh-agent
        echo "Starting a new SSH agent..."
        eval "$(ssh-agent -s -a "$SSH_AGENT_SOCK" -P libfido2.so)" > /dev/null
    fi

    export SSH_AUTH_SOCK
}


load_ssh_keys() {
    # Check if SSH agent is running
    if ! is_ssh_agent_running; then
        echo "SSH agent is not running. Starting agent..."
        fix_ssh_agent
    fi
    
    # Detect if a forwarded agent is available
    if [ -n "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ]; then
        echo "Using forwarded SSH agent."
    else
        echo "No forwarded SSH agent detected."
    fi
    
    # Find private keys (excluding .pub files)
    keys=$(find ~/.ssh -maxdepth 2 -type f \( -name "id_*" -o -name "ed25519-sk" \) ! -name "*.pub")
    
    if [ -n "$keys" ]; then
        echo "Loading SSH keys..."

        if command -v keychain >/dev/null 2>&1; then
            # Use keychain for persistent key management
            eval "$(keychain --eval --agents ssh $keys 2>/dev/null)"
        else
            # Add keys manually if keychain is not installed
            for key in $keys; do
                ssh-add "$key" 2>/dev/null
            done
        fi
    else
        echo "No SSH keys found in ~/.ssh. Checking forwarded agent..."
    fi
    
    # List currently loaded keys
    ssh-add -l 2>/dev/null || echo "No keys loaded."
}


# Function to fix and display keychain information
fix_keychain() {
    if is_ssh_agent_running; then
        export SSH_AUTH_SOCK
        printf " * SSH agent is running at %s\n" "$SSH_AUTH_SOCK"
    else
        echo " * SSH agent is not running."
    fi

    # Find SSH keys
    keys=$(find ~/.ssh -maxdepth 2 -type f \( -name "id_*" -o -name "ed25519-sk" \) ! -name "*.pub")

    if [ -n "$keys" ]; then
        if command -v keychain >/dev/null 2>&1; then
            # Initialize keychain and capture its output
            eval "$(keychain --eval --agents ssh $keys 2>/dev/null)"

            # Capture keychain output, filter out unwanted lines
            keychain_output=$(keychain --eval --agents ssh $keys 2>&1 | \
                              grep -vE "SSH_AUTH_SOCK|SSH_AGENT_PID|export" | \
                              grep -v '^$')

            echo "$keychain_output"
        else
            echo " * Keychain not found, using ssh-add manually."
            load_ssh_keys
        fi
    else
        echo " * No SSH keys found."
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