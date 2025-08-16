#!/bin/bash
# PC to Live: Push from local to production via GitHub

echo "🚀 Deploying N8N from PC → GitHub → Live..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  CAUTION: This will update PRODUCTION!"
echo ""

# Confirmation
read -p "Are you sure you want to deploy to production? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "❌ Deployment cancelled"
    exit 0
fi

# Step 1: Push PC to GitHub
echo ""
echo "📤 Step 1: Pushing PC to GitHub..."
cd /home/alex/projects/active/N8N
./scripts/pc_push_to_github.sh

if [ $? -ne 0 ]; then
    echo "❌ Failed to push PC to GitHub"
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
echo "✅ Successfully deployed: PC → GitHub → Live"
echo "Production N8N has been updated with your local changes!"