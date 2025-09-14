#!/bin/bash
# Install PC Dashboard as systemd service

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Installing PC Dashboard as systemd service...${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ This script must be run as root (use sudo)${NC}"
    echo "Usage: sudo bash systemd-service-install.sh"
    exit 1
fi

# Get the actual user who invoked sudo
REAL_USER="${SUDO_USER:-$USER}"
if [ "$REAL_USER" = "root" ]; then
    echo -e "${RED}❌ Please run this script as a regular user with sudo${NC}"
    echo "Example: sudo bash systemd-service-install.sh"
    exit 1
fi

# Get user's home directory
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
DASHBOARD_PATH="$USER_HOME/projects/active/PC-Dashboard"

echo "User: $REAL_USER"
echo "Home: $USER_HOME"
echo "Dashboard: $DASHBOARD_PATH"

# Verify dashboard exists
if [ ! -f "$DASHBOARD_PATH/dashboard_server.py" ]; then
    echo -e "${RED}❌ Dashboard not found at: $DASHBOARD_PATH${NC}"
    echo "Please ensure the PC-Dashboard is installed correctly"
    exit 1
fi

# Create systemd service file
SERVICE_FILE="/etc/systemd/system/pc-dashboard.service"

echo -e "${YELLOW}Creating systemd service file: $SERVICE_FILE${NC}"

cat > "$SERVICE_FILE" << EOF
[Unit]
Description=PC Dashboard Server
After=network.target
Wants=network.target

[Service]
Type=simple
User=$REAL_USER
Group=$REAL_USER
WorkingDirectory=$DASHBOARD_PATH
Environment=PATH=/usr/bin:/usr/local/bin:/bin
Environment=PYTHONPATH=$DASHBOARD_PATH
ExecStart=/usr/bin/python3 $DASHBOARD_PATH/dashboard_server.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=pc-dashboard

# Security settings
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=$DASHBOARD_PATH/logs $USER_HOME/projects
ProtectKernelTunables=yes
ProtectKernelModules=yes
ProtectControlGroups=yes

[Install]
WantedBy=multi-user.target
EOF

# Set correct permissions
chmod 644 "$SERVICE_FILE"

# Fix log directory ownership
echo -e "${YELLOW}Fixing log directory permissions...${NC}"
chown -R "$REAL_USER:$REAL_USER" "$DASHBOARD_PATH/logs" 2>/dev/null || true

# Reload systemd and enable service
echo -e "${YELLOW}Reloading systemd daemon...${NC}"
systemctl daemon-reload

echo -e "${YELLOW}Enabling PC Dashboard service...${NC}"
systemctl enable pc-dashboard

echo -e "${GREEN}✅ PC Dashboard service installed successfully!${NC}"
echo ""
echo "Available commands:"
echo "  Start:   sudo systemctl start pc-dashboard"
echo "  Stop:    sudo systemctl stop pc-dashboard"
echo "  Status:  sudo systemctl status pc-dashboard"
echo "  Logs:    sudo journalctl -u pc-dashboard -f"
echo ""
echo "The service will start automatically on boot."