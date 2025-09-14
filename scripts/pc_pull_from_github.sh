#!/bin/bash
# PC Pull from GitHub: Pull N8N workflows from GitHub to local PC

# Load environment and common functions
source "$(dirname "$0")/lib/common.sh"

echo "📥 Pulling N8N workflows from GitHub to PC..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Navigate to N8N directory
cd "$N8N_PATH" || {
    echo "❌ Error: N8N path not found: $N8N_PATH"
    exit 1
}

# Check if N8N directory has git repo
if [ ! -d ".git" ]; then
    echo "❌ Error: N8N directory is not a git repository"
    echo "Please initialize git in $N8N_PATH first"
    exit 1
fi

# Execute the actual pull command
safe_execute "bash scripts/pc_pull_from_github.sh" "Pull N8N workflows from GitHub to PC"

exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo "✅ Successfully pulled workflows from GitHub to PC"
else
    echo "❌ Failed to pull workflows from GitHub"
fi

cleanup_script $exit_code
exit $exit_code