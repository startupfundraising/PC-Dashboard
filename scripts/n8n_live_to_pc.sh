#!/bin/bash
# Live to PC: Pull from production to local via GitHub

# SAFETY CHECK: Require approval for dangerous operations
if [ "$SKIP_SAFETY_CHECK" != "true" ]; then
    
    # Check if testing mode is active
    if [ -f "/home/alex/projects/active/PC-Dashboard/.testing_mode" ]; then
        echo "⚠️  TESTING MODE ACTIVE"
        echo "This script will simulate syncing but not make actual changes."
        echo "Remove /home/alex/projects/active/PC-Dashboard/.testing_mode to enable real sync"
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
        echo "Claude Code is requesting to run: n8n_live_to_pc.sh"
        echo "This will sync N8N workflows from production to your PC!"
        echo ""
        echo "To approve, type: yes"
        echo "To cancel, type: no (or press Ctrl+C)"
        echo ""
        if [ -t 0 ]; then
            # Interactive terminal available
            read -p "Do you approve this sync? " -r confirm
            if [ "$confirm" != "yes" ]; then
                echo "❌ Sync cancelled by user"
                exit 1
            fi
        else
            # Non-interactive mode (web API) - auto-approve in testing mode
            if [ "$TEST_MODE" = "true" ]; then
                echo "✅ Auto-approved for testing mode"
                confirm="yes"
            else
                echo "❌ Non-interactive sync from production not allowed"
                echo "Use the dashboard web interface for manual approval"
                exit 1
            fi
        fi
        echo "✅ Sync approved by user"
        echo ""
    fi
fi

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