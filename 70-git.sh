function re_sign_my_commits() {
    local repo_path="${1:-.}"

    # Use default email from global git config if not explicitly set
    local default_email
    default_email="$(git config --global user.email)"
    local author_email="${2:-$default_email}"

    # Fail if no email is detected
    if [[ -z "$author_email" ]]; then
        echo "❌ Error: No email provided and none found in global git config."
        return 1
    fi

    # Move into the repository
    cd "$repo_path" || {
        echo "❌ Error: Can't cd into $repo_path"
        return 1
    }

    # 🚨 EXTREME DANGER WARNING 🚨
    echo -e "\n⚠️🚨 WARNING 🚨⚠️"
    echo "This script will **REWRITE YOUR GIT HISTORY AND FORCE PUSH** your re-signed commits!"
    echo "💀 This is EXTREMELY DANGEROUS and can cause IRREVERSIBLE changes to the repository."
    echo "💣 Ensure you know what you're doing before proceeding!"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo -e "Press [Y] to continue or [n] to abort: \c"
    read -r confirm
    confirm=${confirm:-Y}
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "❌ Aborted. No changes made."
        return 0
    fi

    # Fetch all remote refs and create a new local branch for the resign process
    git fetch --all
    local branch_name
    branch_name="resign-commits-$(date +%s)"
    git checkout -b "$branch_name"

    # Check if GPG signing is enabled globally for commits
    local gpg_sign
    gpg_sign="$(git config --get commit.gpgsign)"

    # Decide how to re-sign (signoff vs GPG sign)
    local re_sign_cmd="git commit --amend --no-edit -s"
    if [[ "$gpg_sign" == "true" ]]; then
        re_sign_cmd="git commit --amend --no-edit -s -S"
    fi

    # Re-sign only commits from the specified author
    git rebase --exec "if [ \"\$(git log -1 --pretty=format:%ae)\" = \"$author_email\" ]; then $re_sign_cmd; fi" -i --root

    echo "✅ Re-signing completed! Checking status..."

    # Detect the default branch name from git config
    local default_branch
    default_branch="$(git config --get init.defaultbranch)"

    # Fallback if no default branch is found
    if [[ -z "$default_branch" ]]; then
        default_branch="main"
    fi

    # Detect the remote that tracks the default branch
    local default_remote
    default_remote="$(git config --get "branch.${default_branch}.remote")"
    if [[ -z "$default_remote" ]]; then
        default_remote="origin"
    fi

    # Ask for confirmation before force-merging into main
    echo -e "\n🚨 WARNING: This will overwrite '$default_branch' on '$default_remote' with your re-signed commits."
    read -rp "Are you sure you want to proceed? (yes/no) [default: no]: " confirm_merge
    confirm_merge=${confirm_merge:-no}
    if [[ "$confirm_merge" != "yes" ]]; then
        echo "❌ Force-merge aborted. No changes pushed."
        return 0
    fi

    # Check if script is running as root
    if [[ "$(id -u)" -ne 0 ]]; then
        echo "🔐 Warning: This script is not running as root."
        read -p "❓ Do you want to continue without root privileges? (y/N) " -r
        if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
            echo "❌ Exiting... Root privileges required."
            exit 1
        fi
    else
        echo "✅ Running as root."
    fi

    # Perform root operations here
    sleep 2 # Simulating a root task

    # Switch back to normal user
    ORIGINAL_USER=$(logname)
    echo "🔄 Switching back to user: $ORIGINAL_USER"

    echo "🚀 Force-merging '$branch_name' into '$default_remote/$default_branch'..."
    git checkout "$default_branch"
    git pull --ff-only "$default_remote" "$default_branch"  # Ensure it's up to date
    git reset --hard "$branch_name"  # Merge branch into main
    git push --force "$default_remote" "$default_branch"

    echo "✅ Force-merge complete! '$default_branch' is now updated with re-signed commits."
}

create_alias "re_sign_my_commits" "re_sign_my_commits" "yes" "Re-sign all commits authored by your email (GPG signing)."
