#!/bin/bash

# Claude Code Usage Monitor
# Provides real-time token usage monitoring for Claude AI

echo "🔍 Starting Claude Code Usage Monitor..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Add Python scripts to PATH
export PATH="/Users/alexander/Library/Python/3.9/bin:$PATH"

# Check if claude-monitor is available
if ! command -v claude-monitor &> /dev/null; then
    echo "❌ claude-monitor not found in PATH"
    echo "Please ensure it's installed: pip install claude-monitor"
    exit 1
fi

# Run the monitor with pro plan (adjust as needed)
echo "Starting Claude usage monitor..."
echo "Press Ctrl+C to stop monitoring"
echo ""

# Launch claude-monitor
claude-monitor --plan custom --view realtime