#!/bin/bash

# Define SSH Agent socket path
SSH_AGENT_SOCK="$HOME/.ssh/ssh-agent.sock"

# Function to find all private SSH keys
find_ssh_keys() {
    find ~/.ssh -maxdepth 2 -type f \( -name "id_*" -o -name "ed25519-sk" \) ! -name "*.pub"
}

# Function to check if SSH agent is running
is_ssh_agent_running() {
    if [[ -S "$SSH_AUTH_SOCK" ]]; then
        if ssh-add -l &>/dev/null; then
            return 0  # SSH agent is running
        fi
    fi
    return 1  # SSH agent is not running
}

# Function to start or reuse SSH agent
fix_ssh_agent() {
    if pgrep -u "$USER" ssh-agent > /dev/null; then
        echo "SSH agent is already running. Reusing existing agent."
        export SSH_AUTH_SOCK=$(find /tmp/ssh-* -user "$USER" -name agent.* 2>/dev/null | head -n 1)
    else
        echo "Starting a new SSH agent..."
        eval "$(ssh-agent -s -a "$SSH_AGENT_SOCK")" > /dev/null
        export SSH_AUTH_SOCK="$SSH_AGENT_SOCK"
    fi
}

# Function to load SSH keys into the agent and keychain
load_ssh_keys() {
    keys=$(find_ssh_keys)
    
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

    ssh-add -l 2>/dev/null || echo "No keys loaded."
}

# Function to fix keychain in case of issues
fix_keychain() {
    keys=$(find_ssh_keys)

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

# Function to check if a YubiKey is present
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

# Function to import SSH_AUTH_SOCK from the SSH client and link it
import_ssh_client_socket() {
    if [[ -n "$SSH_CONNECTION" ]]; then
        echo "Detected SSH client connection. Using forwarded agent socket."
        export SSH_AUTH_SOCK="$SSH_AUTH_SOCK"
        echo "Using SSH_AUTH_SOCK: $SSH_AUTH_SOCK"
    fi
}

# Execute functions
import_ssh_client_socket
fix_ssh_agent
fix_keychain
