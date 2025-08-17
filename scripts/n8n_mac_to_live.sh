#!/bin/bash
# Mac to Live: Push from Mac to production via GitHub

# SAFETY CHECK: Require approval for dangerous operations
if [ "$SKIP_SAFETY_CHECK" != "true" ]; then
    
    # Check if testing mode is active
    if [ -f "/Users/alexander/Mac-Dashboard/.testing_mode" ]; then
        echo "⚠️  TESTING MODE ACTIVE"
        echo "This script will not actually deploy to production."
        echo "Remove /Users/alexander/Mac-Dashboard/.testing_mode to enable real deployment"
        echo ""
        echo "Running in TEST MODE (no actual changes will be made)..."
        echo ""
        # Continue but in test mode
        TEST_MODE=true
    fi
    
    # If Claude Code or automation detected, require explicit approval
    if [ -n "$CLAUDE_CODE_SESSION" ] || [ -n "$CLAUDE_CODE" ] || [ ! -t 0 ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🚨 APPROVAL REQUIRED: This will deploy to PRODUCTION"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Claude Code is requesting to run: n8n_mac_to_live.sh"
        echo "This will push your Mac N8N workflows to production!"
        echo ""
        echo "To approve, type: yes"
        echo "To cancel, type: no (or press Ctrl+C)"
        echo ""
        read -p "Do you approve this deployment? " -r confirm
        if [ "$confirm" != "yes" ]; then
            echo "❌ Deployment cancelled by user"
            exit 1
        fi
        echo "✅ Deployment approved by user"
        echo ""
    fi
fi

echo "🚀 Deploying N8N from Mac → GitHub → Live..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  CAUTION: This will update PRODUCTION!"
echo ""

# Confirmation
read -p "Are you sure you want to deploy to production? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "❌ Deployment cancelled"
    exit 0
fi

# Step 1: Push Mac to GitHub
echo ""
echo "📤 Step 1: Pushing Mac to GitHub..."
cd /Users/alexander/projects/N8N
./scripts/mac_push_to_github.sh

if [ $? -ne 0 ]; then
    echo "❌ Failed to push Mac to GitHub"
    exit 1
fi

# Step 2: Deploy from GitHub to Live
echo ""
echo "📥 Step 2: Deploying from GitHub to Live..."
./scripts/hetzner_pull_from_github.sh

if [ $? -ne 0 ]; then
    echo "❌ Failed to deploy to Live"
    exit 1
fi

echo ""
echo "✅ Successfully deployed: Mac → GitHub → Live"
echo "Production N8N has been updated with your local changes!"