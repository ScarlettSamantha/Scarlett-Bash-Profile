alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'


# Git aliases so that I don't have to remember to sign commits
git() {
    if [[ "$1" == "commit" ]]; then
        shift
        command git commit -s -S "$@"
    else
        command git "$@"
    fi
}