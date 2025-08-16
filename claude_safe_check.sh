#!/bin/bash

# Safety wrapper to prevent accidental execution of dangerous scripts
# This should be sourced in .bashrc or checked before operations

DANGEROUS_PATTERNS=(
    "pc_push_to_github"
    "pc_pull_from_github" 
    "sync_live_to_git"
    "hetzner_pull_from_github"
    "n8n_live_to_pc"
    "n8n_pc_to_live"
    "localhost:8888/run"
    "deploy"
    "production"
)

check_dangerous_command() {
    local cmd="$1"
    
    for pattern in "${DANGEROUS_PATTERNS[@]}"; do
        if [[ "$cmd" == *"$pattern"* ]]; then
            echo "⛔ BLOCKED: This command could modify production!"
            echo "Command: $cmd"
            echo "Pattern matched: $pattern"
            echo ""
            echo "If you really need to run this:"
            echo "1. Have the USER run it through the dashboard browser interface"
            echo "2. Or explicitly confirm with user first"
            return 1
        fi
    done
    
    return 0
}

# If running directly, check the argument
if [ "$1" ]; then
    check_dangerous_command "$1"
fi