#!/bin/bash

echo "Opening Claude Code with Mac Dashboard context..."

# Create a context file with all the important information
cat > /tmp/dashboard_context.md << 'EOF'
# ⚠️ CRITICAL SAFETY WARNING ⚠️

READ /Users/alexander/Mac-Dashboard/CLAUDE_SAFETY.md FIRST!

NEVER execute the actual N8N scripts during debugging.
ONLY use /Users/alexander/Mac-Dashboard/safe_diagnose.sh for diagnostics.

# Mac Dashboard Context

You are editing the Mac Dashboard located at: /Users/alexander/Mac-Dashboard/

## Key Files:
- index.html - Dashboard UI (buttons, layout, styling)
- dashboard_server.py - Backend server (script mappings, execution)

## Current Button Structure:

### Dashboard Tab
- N8N: Mac to Github, GitHub to Mac
- Admin: Edit Dashboard

### N8N Tab
Daily: Mac to Github, GitHub to Mac
Github: Live to GitHub, GitHub to live
Caution: Live to Mac, Mac to live

### GitHub Tab
Same as N8N tab structure

### How to Add/Edit Buttons:

1. To add a button in index.html:
```html
<button class="script-btn" onclick="runScript('script-name')" data-tooltip="Description">
    <span class="icon">📦</span>
    <span>Button Text</span>
</button>
```

2. To add script mapping in dashboard_server.py:
```python
'script-name': {
    'cmd': 'bash command here',
    'description': 'What it does'
}
```

## N8N Script Paths:
- Live to GitHub: /Users/alexander/projects/N8N/scripts/sync_live_to_git.sh
- GitHub to Live: /Users/alexander/projects/N8N/scripts/hetzner_pull_from_github.sh
- Mac to GitHub: /Users/alexander/projects/N8N/scripts/mac_push_to_github.sh
- GitHub to Mac: /Users/alexander/projects/N8N/scripts/mac_pull_from_github.sh
- Live to Mac: Creates new script that runs sync_live_to_git.sh then mac_pull_from_github.sh
- Mac to Live: Creates new script that runs mac_push_to_github.sh then hetzner_pull_from_github.sh

## Design Guidelines:
- Card sections with #0f3460 background
- Tooltips on all buttons
- Terminal scrolls to top
- Popup notifications for 7 seconds
- Max 100 lines in terminal output

The user wants to edit the dashboard. Ask what changes they need.
EOF

# Open Claude Code with the context
echo "Context file created. Opening Claude Code..."
echo ""
echo "PASTE THIS COMMAND IN A NEW TERMINAL:"
echo ""
echo "cat /tmp/dashboard_context.md && cd /Users/alexander/Mac-Dashboard && echo 'Ready to edit dashboard. What changes would you like?'"
echo ""
echo "Then tell Claude what you want to change!"