#!/bin/bash
# Script to update the systemd service file with new paths

echo "Updating systemd service file..."
sudo cp /home/alex/projects/active/PC-Dashboard/pc-dashboard.service /etc/systemd/system/pc-dashboard.service

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Starting PC Dashboard service..."
sudo systemctl start pc-dashboard

echo "Service updated and started!"
echo "Check status with: systemctl status pc-dashboard"