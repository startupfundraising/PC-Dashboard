#!/bin/bash

echo "Testing N8N scripts..."
echo ""

echo "1. Checking if scripts exist:"
ls -la /home/alex/projects/active/N8N/scripts/pc_pull_from_github.sh
ls -la /home/alex/projects/active/N8N/scripts/pc_push_to_github.sh

echo ""
echo "2. Testing PC to GitHub:"
cd /home/alex/projects/active/N8N && bash scripts/pc_push_to_github.sh --help 2>&1 | head -5

echo ""
echo "3. Testing GitHub to PC:"
cd /home/alex/projects/active/N8N && bash scripts/pc_pull_from_github.sh --help 2>&1 | head -5

echo ""
echo "Done!"