#!/bin/bash

cd /home/alex/PC-Dashboard

echo "Adding files to git..."
git add .

echo "Creating commit..."
git commit -m "Initial commit: PC Dashboard for automation scripts

- Web-based dashboard for one-click script execution
- Support for N8N, Git, and system management tasks
- Real-time terminal output
- Can be run as system service for 24/7 availability
- Ready to duplicate for Mac version"

echo "Pushing to GitHub..."
git push -u origin master

echo "✅ Done! Your repository is now live at:"
echo "https://github.com/startupfundraising/PC-Dashboard"