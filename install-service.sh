#!/bin/bash

echo "📦 Installing PC Dashboard as system service..."
echo ""

# Copy service file
sudo cp /home/alex/projects/active/PC-Dashboard/pc-dashboard.service /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable service to start on boot
sudo systemctl enable pc-dashboard

# Start the service
sudo systemctl start pc-dashboard

# Check status
sleep 2
if systemctl is-active --quiet pc-dashboard; then
    echo "✅ Service installed and running!"
    echo ""
    echo "🌐 Dashboard is now ALWAYS available at:"
    echo "   http://localhost:8888"
    echo ""
    echo "📌 Bookmark this URL in your browser!"
    echo ""
    echo "The dashboard will:"
    echo "  • Start automatically when computer boots"
    echo "  • Restart automatically if it crashes"
    echo "  • Always be available at the same URL"
    echo ""
    echo "Useful commands:"
    echo "  • Check status:  systemctl status pc-dashboard"
    echo "  • View logs:     journalctl -u pc-dashboard -f"
    echo "  • Restart:       sudo systemctl restart pc-dashboard"
    echo "  • Stop:          sudo systemctl stop pc-dashboard"
else
    echo "❌ Service failed to start. Check logs with:"
    echo "   journalctl -u pc-dashboard -n 50"
fi