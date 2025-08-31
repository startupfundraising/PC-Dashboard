#!/bin/bash

echo "🔍 SAFE DIAGNOSTIC - This ONLY checks files, does NOT run any scripts"
echo "================================================================"
echo ""

echo "Checking N8N script files exist and permissions:"
echo ""

# Just check if files exist - DO NOT EXECUTE
scripts=(
    "/home/alex/projects/active/N8N/scripts/pc_push_to_github.sh"
    "/home/alex/projects/active/N8N/scripts/pc_pull_from_github.sh"
    "/home/alex/projects/active/N8N/scripts/sync_live_to_git.sh"
    "/home/alex/projects/active/N8N/scripts/hetzner_pull_from_github.sh"
    "/home/alex/projects/active/PC-Dashboard/scripts/n8n_live_to_pc.sh"
    "/home/alex/projects/active/PC-Dashboard/scripts/n8n_pc_to_live.sh"
    "/home/alex/projects/active/PC-Dashboard/scripts/edit_dashboard.sh"
)

for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
        echo "✅ EXISTS: $script"
        # Check if readable
        if [ -r "$script" ]; then
            echo "   └─ Readable: Yes"
        else
            echo "   └─ ❌ NOT READABLE"
        fi
    else
        echo "❌ MISSING: $script"
    fi
done

echo ""
echo "Checking dashboard server is running:"
if systemctl is-active --quiet pc-dashboard; then
    echo "✅ Dashboard service is running"
else
    echo "❌ Dashboard service is NOT running"
fi

echo ""
echo "Recent dashboard errors (if any):"
journalctl -u pc-dashboard -n 10 --no-pager | grep -i error || echo "No recent errors"

echo ""
echo "================================================================"
echo "This diagnostic ONLY checked files. It did NOT run any scripts."
echo "================================================================"