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

fix_ssh_agent() {
    if ! is_ssh_agent_running; then
        # Remove any stale socket file
        if [ -e "$SSH_AGENT_SOCK" ]; then
            rm -f "$SSH_AGENT_SOCK"
        fi

        # Start a new ssh-agent with the specified socket
        eval "$(ssh-agent -a "$SSH_AGENT_SOCK")"
    fi
}

fix_keychain() {
    if [[ $- == *i* ]]; then
        # Find all SSH keys in ~/.ssh that end with _rsa, _dsa, or _ed25519 (common SSH key suffixes)
        keys=$(find ~/.ssh -maxdepth 1 -type f -name "*.rsa" -o -name "*.dsa" -o -name "*.ed25519")

        # If keys are found, load them using keychain
        if [[ -n "$keys" ]]; then
            eval "$(keychain --eval --agents ssh $keys)"
        fi
    fi
}
