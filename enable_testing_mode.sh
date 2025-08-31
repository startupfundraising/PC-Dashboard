#!/bin/bash

echo "🔒 Enabling TESTING MODE..."
echo ""

# Create testing mode file
cat > /home/alex/projects/active/PC-Dashboard/.testing_mode << 'EOF'
TESTING MODE ACTIVE
Remove this file to enable script execution
Created for safety to prevent accidental production changes
EOF

echo "✅ Testing mode ENABLED"
echo ""
echo "Scripts will NOT execute - they will only show what WOULD run"
echo "This protects against accidental production changes"
echo ""
echo "To disable testing mode, run: ./disable_testing_mode.sh"

# Restart service
sudo systemctl restart pc-dashboard

echo ""
echo "Dashboard restarted. Refresh your browser."