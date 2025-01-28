#!/bin/bash

# Function to check if the SSH agent is running
is_ssh_agent_running() {
    if [ -S "$SSH_AGENT_SOCK" ]; then
        # Attempt to communicate with the agent
        if ssh-add -l > /dev/null 2>&1; then
            return 0
        else
            # If ssh-add fails, the agent might not be running
            return 1
        fi
    else
        return 1
    fi
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
        echo "   * Starting a new SSH agent..." | indent_output 4

        # Capture ssh-agent output, filter out empty lines
        agent_output=$(ssh-agent -a "$SSH_AGENT_SOCK" 2>/dev/null | grep -v '^$')

        # Display the filtered output with indentation and icons
        echo "$agent_output" | indent_output 4

        # Evaluate the ssh-agent output to set environment variables
        eval "$agent_output"
    else
        echo " * SSH agent is already running." | indent_output 4
    fi
}

# Generic function to indent the output and prefix with an icon
indent_output() {
    local indent_level=$1
    local prefix_icon="├─ "  # Icon for tree-like structure; you can change this as desired
    local prefix

    # Generate indentation spaces based on the indent level
    prefix=$(printf ' %.0s' $(seq 1 "$indent_level"))
    prefix="${prefix}${prefix_icon}"

    # Read each line, remove empty lines, and add the prefix
    while IFS= read -r line; do
        # Skip empty lines
        if [[ -n "$line" ]]; then
            echo "${prefix}${line}"
        fi
    done
}

# Function to fix and display keychain information
fix_keychain() {
    # Check if the shell is interactive
    if [[ $- == *i* ]]; then
        # Find all private keys in ~/.ssh that have a corresponding .pub file
        keys=$(find ~/.ssh -maxdepth 1 -type f -name "*.pub" | sed 's/\.pub$//')

        # If no paired keys are found, fall back to matching common SSH key suffixes
        if [[ -z "$keys" ]]; then
            keys=$(find ~/.ssh -maxdepth 1 -type f \( -name "*id_*" -o -name "*.dsa" -o -name "*.ed25519" \) ! -name "*.pub")
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

# Execute the functions
fix_ssh_agent
fix_keychain
