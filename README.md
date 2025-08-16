# PC Dashboard

A web-based dashboard for running automation scripts with a single click. Perfect for managing N8N workflows, Git repositories, and system maintenance tasks.

## Features

- **Web Interface** - Beautiful, responsive dashboard accessible from any browser
- **One-Click Scripts** - Execute complex automation with a single button click
- **Real-time Output** - See command execution results immediately in the terminal
- **Always Available** - Can be set up as a system service for 24/7 availability
- **Cross-Platform Ready** - Easily adaptable for Mac/Linux systems

## Quick Start

### 1. Basic Usage (Manual Start)

```bash
# Start the server
python3 dashboard_server.py

# Open index.html in your browser
# Or navigate to http://localhost:8888 after server starts
```

### 2. System Service Setup (Always Running)

For an always-available dashboard that starts with your system:

```bash
# Create service file
sudo nano /etc/systemd/system/pc-dashboard.service
```

Add the following content:
```ini
[Unit]
Description=PC Dashboard Server
After=network.target

[Service]
Type=simple
User=alex
WorkingDirectory=/home/alex/PC-Dashboard
ExecStart=/usr/bin/python3 /home/alex/PC-Dashboard/dashboard_server.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Then enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable pc-dashboard
sudo systemctl start pc-dashboard
```

Your dashboard will now be available at `http://localhost:8888` - bookmark it!

## Customization

### Adding New Scripts

1. Edit `dashboard_server.py` and add to the `SCRIPT_MAPPINGS` dictionary:

```python
'my-script': {
    'cmd': 'echo "Hello World"',
    'description': 'My custom script'
}
```

2. Add a button to `index.html`:

```html
<button class="script-btn" onclick="runScript('my-script')">
    <span class="icon">🎯</span>
    <span>My Script</span>
</button>
```

### Adapting for Mac

To adapt this dashboard for Mac:

1. Update script paths in `dashboard_server.py`:
   - Change `/home/alex/` to `/Users/YOUR_USERNAME/`
   - Update Docker commands if using Docker Desktop
   - Adjust system commands (e.g., `brew` instead of `apt`)

2. For system service on Mac, use `launchd` instead of `systemd`:
   - Create a `.plist` file in `~/Library/LaunchAgents/`
   - Use `launchctl` to manage the service

### Script Organization

- **Existing Scripts**: Link to scripts in other project directories
- **New Scripts**: Place in `PC-Dashboard/scripts/` directory
- **Shared Scripts**: Can reference scripts from any location

## Project Structure

```
PC-Dashboard/
├── index.html           # Dashboard UI
├── dashboard_server.py  # Python backend server
├── scripts/            # Dashboard-specific scripts
│   ├── backup_all.sh
│   ├── morning_sync.sh
│   └── evening_backup.sh
├── logs/               # Server logs
│   └── dashboard.log
└── README.md          # This file
```

## Available Scripts

### N8N Management
- **Status** - Check Docker container status
- **Start/Stop/Restart** - Control N8N services
- **Sync from Production** - Pull latest workflows
- **Backup** - Save to Dropbox

### Git Operations
- **Status All** - Check all repositories
- **Pull All** - Update all repos
- **Push All** - Push pending changes
- **Quick Commit** - Auto-commit with timestamp

### System Management
- **System Health** - CPU, memory, disk usage
- **Docker Cleanup** - Remove unused containers/images
- **Disk Usage** - Check storage space

## Security & Protection System

### Approval-Based Protection
This dashboard includes a sophisticated protection system that prevents accidental execution of dangerous scripts:

- **User Approval Required** - Dangerous scripts require you to type "yes" to proceed
- **Testing Mode** - Enable safe testing without affecting production systems
- **Claude Code Compatible** - Automation tools can request execution, but you maintain control
- **Clear Warnings** - See exactly what will happen before approving

### Protection Features

1. **Smart Detection** - Automatically identifies dangerous operations (deploy, push, sync, etc.)
2. **Testing Mode** - Create `.testing_mode` file to simulate without real changes
3. **Approval Prompts** - Type "yes" to approve or "no" to cancel dangerous operations
4. **Comprehensive Logging** - All script executions are logged for audit purposes

### How to Use

**With Claude Code or Automation:**
```bash
# Claude Code will request approval
./scripts/n8n_pc_to_live.sh
# You'll see: "APPROVAL REQUIRED: This will deploy to PRODUCTION"
# Type: yes (to approve) or no (to cancel)
```

**Enable Testing Mode:**
```bash
touch /home/alex/PC-Dashboard/.testing_mode
# Scripts will now run in simulation mode
```

**Disable Testing Mode:**
```bash
rm /home/alex/PC-Dashboard/.testing_mode
# Scripts will execute real operations (with approval)
```

### Network Security
- Only run on trusted networks
- Default configuration listens on localhost only
- To access from other devices, change `HOST = '0.0.0.0'` in `dashboard_server.py`
- Consider adding authentication for production use

## Troubleshooting

**Server won't start?**
```bash
# Check if port is in use
lsof -i :8888
# Kill process if needed
kill -9 PID
```

**Scripts not executing?**
- Check script paths in `dashboard_server.py`
- Ensure scripts have execute permissions: `chmod +x script.sh`
- Check logs: `tail -f logs/dashboard.log`

**Can't access dashboard?**
- Verify server is running: `ps aux | grep dashboard_server`
- Check firewall settings
- Try `http://localhost:8888` or `http://127.0.0.1:8888`

## Mac Duplication Guide

To create a Mac version:

1. Fork/clone this repository
2. Rename to `Mac-Dashboard`
3. Update all paths from `/home/` to `/Users/`
4. Replace Linux-specific commands with Mac equivalents
5. Update Docker commands for Docker Desktop
6. Create launchd configuration instead of systemd

## License

MIT - Feel free to customize and share!

---

Built for convenience and automation. Say goodbye to memorizing terminal commands!