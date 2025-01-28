git() {
    if [[ "$1" == "commit" ]]; then
        shift
        command git commit -s -S "$@"
    else
        command git "$@"
    fi
}