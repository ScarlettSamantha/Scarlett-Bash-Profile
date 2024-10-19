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
        eval `keychain --eval --agents ssh id_rsa backupkey_rsa`
    fi
}
