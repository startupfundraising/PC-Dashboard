#!/bin/bash
# Live to Mac: Pull from production to Mac via GitHub

# SAFETY CHECK: Require approval for dangerous operations
if [ "$SKIP_SAFETY_CHECK" != "true" ]; then
    
    # Check if testing mode is active
    if [ -f "/Users/alexander/Mac-Dashboard/.testing_mode" ]; then
        echo "⚠️  TESTING MODE ACTIVE"
        echo "This script will simulate syncing but not make actual changes."
        echo "Remove /Users/alexander/Mac-Dashboard/.testing_mode to enable real sync"
        echo ""
        echo "Running in TEST MODE..."
        echo ""
        TEST_MODE=true
    fi
    
    # If Claude Code or automation detected, require explicit approval
    if [ -n "$CLAUDE_CODE_SESSION" ] || [ -n "$CLAUDE_CODE" ] || [ ! -t 0 ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🔄 APPROVAL REQUIRED: Sync from PRODUCTION"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Claude Code is requesting to run: n8n_live_to_mac.sh"
        echo "This will sync N8N workflows from production to your Mac!"
        echo ""
        
        # Check if running interactively
        if [ -t 0 ]; then
            echo "To approve, type: yes"
            echo "To cancel, type: no (or press Ctrl+C)"
            echo ""
            read -p "Do you approve this sync? " -r confirm
            if [ "$confirm" != "yes" ]; then
                echo "❌ Sync cancelled by user"
                exit 1
            fi
            echo "✅ Sync approved by user"
        else
            echo "❌ Non-interactive mode - cannot get approval"
            echo "This script requires manual approval to sync from production"
            exit 1
        fi
        echo ""
    fi
fi

echo "🔄 Syncing N8N from Live → GitHub → Mac..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Step 1: Push Live to GitHub
echo ""
echo "📤 Step 1: Pushing Live to GitHub..."
cd /Users/alexander/projects/N8N
./scripts/sync_live_to_git.sh

if [ $? -ne 0 ]; then
    echo "❌ Failed to sync Live to GitHub"
    exit 1
fi

# Step 2: Pull from GitHub to Mac
echo ""
echo "📥 Step 2: Pulling from GitHub to Mac..."
./scripts/mac_pull_from_github.sh

if [ $? -ne 0 ]; then
    echo "❌ Failed to pull from GitHub to Mac"
    exit 1
fi

echo ""
echo "✅ Successfully synced: Live → GitHub → Mac"
echo "Your local N8N now has the latest production workflows!"