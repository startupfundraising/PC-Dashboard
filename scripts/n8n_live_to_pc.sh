#!/bin/bash
# Live to PC: Pull from production to local via GitHub

echo "🔄 Syncing N8N from Live → GitHub → PC..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Step 1: Push Live to GitHub
echo ""
echo "📤 Step 1: Pushing Live to GitHub..."
cd /home/alex/projects/active/N8N
./scripts/sync_live_to_git.sh

if [ $? -ne 0 ]; then
    echo "❌ Failed to sync Live to GitHub"
    exit 1
fi

# Step 2: Pull from GitHub to PC
echo ""
echo "📥 Step 2: Pulling from GitHub to PC..."
./scripts/pc_pull_from_github.sh

if [ $? -ne 0 ]; then
    echo "❌ Failed to pull from GitHub to PC"
    exit 1
fi

echo ""
echo "✅ Successfully synced: Live → GitHub → PC"
echo "Your local N8N now has the latest production workflows!"