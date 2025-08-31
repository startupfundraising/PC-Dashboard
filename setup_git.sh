#!/bin/bash

echo "Setting up PC Dashboard GitHub repository..."

cd /home/alex/projects/active/PC-Dashboard

# Initialize git
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: PC Dashboard for automation scripts

- Web-based dashboard for one-click script execution
- Support for N8N, Git, and system management tasks
- Real-time terminal output
- Can be run as system service for 24/7 availability
- Ready to duplicate for Mac version"

# Create GitHub repository using gh CLI
gh repo create PC-Dashboard --private --description "Web dashboard for running automation scripts with one click" --source=. --remote=origin --push

echo "✅ Repository created and pushed to GitHub!"
echo ""
echo "🌐 View your repository at: https://github.com/$(gh api user --jq .login)/PC-Dashboard"
echo ""
echo "To create Mac version:"
echo "1. Clone this repository on your Mac"
echo "2. Update paths in dashboard_server.py from /home/alex to /Users/YOUR_USERNAME"
echo "3. Update Docker and system commands for macOS"
echo "4. Push to a new repository called Mac-Dashboard"