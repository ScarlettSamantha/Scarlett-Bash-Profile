#!/bin/bash

# Define the SSH Agent socket path if not already set
SSH_AGENT_SOCK="$HOME/.ssh/ssh-agent.sock"

# Function to check if the SSH agent is running
is_ssh_agent_running() {
    if [[ -S "$SSH_AUTH_SOCK" ]]; then
        if ssh-add -l &>/dev/null; then
            return 0  # SSH agent is running
        fi
    fi
    return 1  # SSH agent is not running
}

fix_ssh_agent() {
    if ! is_ssh_agent_running; then
        # Remove stale socket file
        if [ -e "$SSH_AGENT_SOCK" ]; then
            echo "Removing stale SSH agent socket file..."
            rm -f "$SSH_AGENT_SOCK"
        fi

        # Start a new SSH agent and set socket path
        echo "Starting a new SSH agent..."
        eval "$(ssh-agent -s -a "$SSH_AGENT_SOCK")" > /dev/null

        # Ensure SSH_AUTH_SOCK is correctly exported
        export SSH_AUTH_SOCK="$SSH_AGENT_SOCK"
    fi
}

load_ssh_keys() {
    if ! is_ssh_agent_running; then
        echo "SSH agent is not running. Starting agent..."
        fix_ssh_agent
    fi
    
    if [ -n "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ]; then
        echo "Using SSH agent at: $SSH_AUTH_SOCK"
    else
        echo "No SSH agent detected."
    fi

    # Load SSH keys
    keys=$(find ~/.ssh -maxdepth 2 -type f \( -name "id_*" -o -name "ed25519-sk" \) ! -name "*.pub")
    
    if [ -n "$keys" ]; then
        echo "Loading SSH keys..."

        if command -v keychain >/dev/null 2>&1; then
            eval "$(keychain --eval --agents ssh $keys 2>/dev/null)"
        else
            for key in $keys; do
                ssh-add "$key" 2>/dev/null
            done
        fi
    else
        echo "No SSH keys found."
    fi
    
    # List currently loaded keys
    ssh-add -l 2>/dev/null || echo "No keys loaded."
}

fix_keychain() {
    keys=$(find ~/.ssh -maxdepth 2 -type f \( -name "id_*" -o -name "ed25519-sk" \) ! -name "*.pub")

    if [ -n "$keys" ]; then
        if command -v keychain >/dev/null 2>&1; then
            eval "$(keychain --eval --agents ssh $keys 2>/dev/null)"

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

check_yubikey() {
    if command -v ykman &>/dev/null; then
        if ykman info | grep -q "FIDO2"; then
            echo "✅ YubiKey detected."
            return 0
        else
            echo "❌ No YubiKey found. Please insert it."
            return 1
        fi
    else
        echo "❌ Error: 'ykman' is not installed. Install it with: sudo apt install yubikey-manager"
        return 1
    fi
}

set_yubikey_cache() {
    local timeout=$1
    local ssh_key

    ssh_key=$(git config --global user.signingkey || git config --local user.signingkey || echo "$HOME/.ssh/id_rsa")

    if ! check_yubikey; then
        return 1
    fi

    if [ ! -f "$ssh_key" ]; then
        echo "❌ Error: SSH key not found at $ssh_key."
        return 1
    fi

    if command -v gpg-connect-agent &>/dev/null; then
        echo "🔒 Setting YubiKey fingerprint cache timeout to $timeout seconds..."
        echo "SETENV SSH_AUTH_SOCK $SSH_AUTH_SOCK" | gpg-connect-agent updatestartuptty /bye
        echo "SETATTR AUTH-TIMEOUT $timeout" | gpg-connect-agent /bye
    elif command -v ykman &>/dev/null; then
        echo "🔒 Setting YubiKey fingerprint cache timeout to $timeout seconds using ykman..."
        ykman piv info | grep -q "PIN timeout" && ykman piv set-pin-retries 3 "$timeout"
    else
        echo "⚠️ No supported method found to set YubiKey fingerprint cache timeout."
    fi
    echo "✅ YubiKey fingerprint cache set to $timeout seconds for key: $ssh_key"
}

get_yubikey_cache() {
    ssh-add -l | grep -i "sk" &>/dev/null
    echo $?
}

# Execute the functions
fix_ssh_agent
fix_keychain
