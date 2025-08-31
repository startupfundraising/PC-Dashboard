# Mac Setup Guide for PC Dashboard

## Getting the Latest Updates from PC

### 1. Pull Both Repositories

```bash
# PC Dashboard
cd ~/projects  # or your projects directory
git clone https://github.com/startupfundraising/PC-Dashboard.git
# OR if already exists:
cd PC-Dashboard && git pull origin master

# N8N Project
cd ~/projects/N8N  # or your N8N directory
git pull origin main
```

### 2. Update Paths for Mac

The dashboard uses Linux paths (`/home/alex/`). Update these for Mac:

#### In `dashboard_server.py`:

```python
# Change all instances of:
/home/alex/projects/active/N8N
# To:
/Users/YOUR_USERNAME/projects/N8N

# Change:
/home/alex/projects/active/PC-Dashboard
# To:
/Users/YOUR_USERNAME/PC-Dashboard
```

#### In Protection Scripts:

Update paths in these files:
- `scripts/n8n_live_to_pc.sh`
- `scripts/n8n_pc_to_live.sh`
- `safe_execute.sh`

### 3. Mac-Specific Script Updates

#### For `scripts/mac_push_to_github.sh`:

Add the same TTY detection we added to PC scripts:

```bash
# Handle non-interactive mode
if [ -t 0 ]; then
    read -p "Enter commit message (or press Enter for default): " COMMIT_MSG
else
    echo "Using default commit message (non-interactive mode)"
    COMMIT_MSG=""
fi
```

### 4. Service Setup on Mac

Instead of systemd, use launchd:

#### Create `~/Library/LaunchAgents/com.pc-dashboard.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" 
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.pc-dashboard</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/python3</string>
        <string>/Users/YOUR_USERNAME/PC-Dashboard/dashboard_server.py</string>
    </array>
    <key>WorkingDirectory</key>
    <string>/Users/YOUR_USERNAME/PC-Dashboard</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/Users/YOUR_USERNAME/PC-Dashboard/logs/stdout.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/YOUR_USERNAME/PC-Dashboard/logs/stderr.log</string>
</dict>
</plist>
```

#### Load the service:

```bash
launchctl load ~/Library/LaunchAgents/com.pc-dashboard.plist
```

### 5. Test the Protection System

The approval-based protection system works the same on Mac:

```bash
# Enable testing mode
touch ~/PC-Dashboard/.testing_mode

# Test a script
cd ~/PC-Dashboard/scripts
./n8n_pc_to_live.sh
# Should ask for approval
```

### 6. Verify Everything Works

1. Access dashboard: http://localhost:8888
2. Test buttons with testing mode enabled
3. Check that scripts require approval when needed

## Key Features Now on Mac

- ✅ Approval-based protection system
- ✅ Testing mode for safe development
- ✅ Non-interactive dashboard execution
- ✅ Claude Code compatibility with approval prompts
- ✅ Comprehensive logging

## Working with Claude Code on Mac

### Understanding the Approval System

When Claude Code tries to run dangerous scripts, you'll see:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚨 APPROVAL REQUIRED: This will deploy to PRODUCTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Claude Code is requesting to run: script_name
Do you approve? [yes/no]
```

### Option 1: Keep Approval System (Recommended)
This is the safest approach - Claude Code can help but you maintain control:
- When prompted, type `yes` to approve or `no` to cancel
- Protects against accidental production changes
- Works well with Claude Code's assistance

### Option 2: Disable Claude Code Detection (Less Safe)
If you trust Claude Code completely on your Mac, you can disable the detection:

In each protected script (`n8n_pc_to_live.sh`, `n8n_live_to_pc.sh`), comment out the Claude Code check:

```bash
# SAFETY CHECK: Require approval for dangerous operations
if [ "$SKIP_SAFETY_CHECK" != "true" ]; then
    
    # Check if testing mode is active
    if [ -f "/Users/username/PC-Dashboard/.testing_mode" ]; then
        echo "⚠️  TESTING MODE ACTIVE"
        TEST_MODE=true
    fi
    
    # COMMENT OUT THIS SECTION TO DISABLE CLAUDE CODE DETECTION:
    # if [ -n "$CLAUDE_CODE_SESSION" ] || [ -n "$CLAUDE_CODE" ] || [ ! -t 0 ]; then
    #     echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    #     echo "🚨 APPROVAL REQUIRED"
    #     ...
    # fi
fi
```

### Option 3: Use Testing Mode (Safest for Development)
Enable testing mode to allow Claude Code to work without real changes:

```bash
# Enable testing mode
touch ~/PC-Dashboard/.testing_mode

# Now Claude Code can run scripts safely
# They'll show warnings but won't make real changes
```

### Option 4: Environment Variable Override
Set an environment variable to tell scripts you're on a trusted Mac:

```bash
# Add to ~/.zshrc or ~/.bash_profile
export TRUSTED_ENVIRONMENT=mac

# Then modify scripts to check:
if [ "$TRUSTED_ENVIRONMENT" = "mac" ]; then
    echo "Running on trusted Mac - skipping approval"
else
    # Normal approval flow
fi
```

## Differences from PC Version

- Paths: `/home/alex/` → `/Users/username/`
- Service: systemd → launchd
- Scripts: May need to update Docker commands for Docker Desktop

## Keeping Mac and PC in Sync

### From Mac to PC:
```bash
# On Mac
cd ~/projects/N8N
./scripts/mac_push_to_github.sh

# On PC
cd /home/alex/projects/active/N8N
./scripts/pc_pull_from_github.sh
```

### From PC to Mac:
```bash
# On PC
cd /home/alex/projects/active/N8N
./scripts/pc_push_to_github.sh

# On Mac
cd ~/projects/N8N
./scripts/mac_pull_from_github.sh
```

Both systems now share the same protection system and improvements!