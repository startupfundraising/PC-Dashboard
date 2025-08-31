#!/bin/bash

echo "⚠️  WARNING: Disabling testing mode will allow scripts to execute!"
echo ""
read -p "Are you SURE you want to enable script execution? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Cancelled. Testing mode remains active."
    exit 0
fi

echo ""
echo "🔓 Disabling TESTING MODE..."

# Remove testing mode file
rm -f /home/alex/projects/active/PC-Dashboard/.testing_mode

echo "✅ Testing mode DISABLED"
echo ""
echo "⚠️  Scripts will NOW EXECUTE when buttons are clicked!"
echo "Be careful - scripts can modify production systems"
echo ""
echo "To re-enable testing mode, run: ./enable_testing_mode.sh"

# Restart service
sudo systemctl restart pc-dashboard

echo ""
echo "Dashboard restarted. Refresh your browser."