#!/bin/bash

cd /home/alex/PC-Dashboard

echo "Creating GitHub repository..."
gh repo create PC-Dashboard --public --description "Web dashboard for running automation scripts with one click"

echo "Setting up remote..."
git remote remove origin 2>/dev/null
git remote add origin https://github.com/startupfundraising/PC-Dashboard.git

echo "Pushing to GitHub..."
git push -u origin master

echo "✅ Repository created and pushed!"
echo "View at: https://github.com/startupfundraising/PC-Dashboard"