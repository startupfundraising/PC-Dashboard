#!/bin/bash

# Load environment and common functions
source "$(dirname "$0")/lib/common.sh"

echo "🔒 Enabling TESTING MODE..."
echo ""

# Create testing mode file
cat > $DASHBOARD_PATH/.testing_mode << 'EOF'
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