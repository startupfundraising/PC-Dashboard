# PC Dashboard - Complete Usage Guide

## Table of Contents
1. [Quick Start](#quick-start)
2. [Using the Dashboard](#using-the-dashboard)
3. [Working with Claude Code](#working-with-claude-code)
4. [Protection System](#protection-system)
5. [Common Workflows](#common-workflows)
6. [Troubleshooting](#troubleshooting)

## Quick Start

### Access the Dashboard
```bash
# Check if dashboard is running
systemctl status pc-dashboard

# Access in browser
http://localhost:5000  # or port 8888
```

### Basic Operations
- **Click buttons** in web interface to run scripts
- **View output** in terminal section below buttons
- **Check status** with green/red indicators

## Using the Dashboard

### N8N Workflow Management

#### Sync from Production to Local
1. Click "N8N: Live → PC" button
2. If using Claude Code, type "yes" when prompted
3. Wait for sync to complete
4. Check local N8N at http://localhost:5678

#### Deploy Local to Production
1. **⚠️ CAUTION:** This affects production!
2. Click "N8N: PC → Live" button
3. Confirm with "yes" when prompted
4. Monitor output for success

#### Push to GitHub
1. Click "PC → GitHub" button
2. Changes are committed and pushed automatically

### System Management

#### Check Docker Status
- Click "Docker Status" to see running containers
- Green = running, Red = stopped

#### View Logs
- Dashboard logs: `/home/alex/projects/active/PC-Dashboard/logs/`
- Script execution logs: Check terminal output

## Working with Claude Code

### Safe Testing Workflow

1. **Enable Testing Mode First**
```bash
touch /home/alex/projects/active/PC-Dashboard/.testing_mode
```

2. **Let Claude Code Test**
```bash
# Claude Code can now safely test scripts
./scripts/n8n_pc_to_live.sh
# Will run in simulation mode - no real changes
```

3. **Disable Testing Mode When Done**
```bash
rm /home/alex/projects/active/PC-Dashboard/.testing_mode
```

### Approval System

When Claude Code runs dangerous scripts:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚨 APPROVAL REQUIRED: This will deploy to PRODUCTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Claude Code is requesting to run: n8n_pc_to_live.sh

To approve, type: yes
To cancel, type: no

Do you approve this deployment? [Type your response]
```

**Your Options:**
- Type `yes` - Approve and execute
- Type `no` - Cancel operation
- Press `Ctrl+C` - Force stop

## Protection System

### Three Levels of Protection

1. **Testing Mode**
   - File: `.testing_mode`
   - Effect: Scripts simulate but don't execute
   - Use: Safe testing and development

2. **Approval Prompts**
   - Triggered by: Claude Code or automation
   - Requires: Manual "yes" confirmation
   - Protects: Production deployments

3. **Dashboard Checks**
   - Server validates requests
   - Blocks automation in testing mode
   - Logs all executions

### Managing Protection

#### Full Protection (Recommended)
```bash
# Enable testing mode
touch /home/alex/projects/active/PC-Dashboard/.testing_mode

# Scripts require approval AND run in test mode
```

#### Approval Only
```bash
# Remove testing mode
rm /home/alex/projects/active/PC-Dashboard/.testing_mode

# Scripts require approval but execute real operations
```

#### Emergency Override (Use Carefully!)
```bash
# Bypass all checks - DANGEROUS
SKIP_SAFETY_CHECK=true ./scripts/n8n_pc_to_live.sh
```

## Common Workflows

### Morning Sync Routine
```bash
# 1. Pull latest from production to local
./scripts/n8n_live_to_pc.sh

# 2. Work on local N8N
http://localhost:5678

# 3. Push changes back when ready
./scripts/n8n_pc_to_live.sh
```

### Safe Development with Claude Code
```bash
# 1. Enable testing mode
touch .testing_mode

# 2. Let Claude Code help with development
# All dangerous operations will be simulated

# 3. When ready to deploy, disable testing
rm .testing_mode

# 4. Run deployment with approval
./scripts/n8n_pc_to_live.sh
# Type "yes" to confirm
```

### GitHub Backup
```bash
# Manual backup to GitHub
cd /home/alex/projects/active/PC-Dashboard/scripts
./pc_push_to_github.sh

# Or use dashboard button
# Click "PC → GitHub"
```

## Troubleshooting

### Script Won't Run

**Check Testing Mode:**
```bash
ls -la /home/alex/projects/active/PC-Dashboard/.testing_mode
# If exists, scripts run in test mode only
```

**Check Permissions:**
```bash
ls -la scripts/
# All scripts should be executable (rwxr-xr-x)
chmod +x scripts/*.sh  # Fix if needed
```

### Approval Not Working

**Ensure Running in Terminal:**
- Approval requires interactive terminal
- Won't work in background processes
- Must type response manually

**Check Environment:**
```bash
echo $CLAUDE_CODE_SESSION
# If set, approval will be required
```

### Dashboard Not Accessible

**Check Service Status:**
```bash
systemctl status pc-dashboard
sudo systemctl restart pc-dashboard  # Restart if needed
```

**Check Port:**
```bash
lsof -i :5000  # or :8888
# Should show python3 process
```

### Logs and Debugging

**View Dashboard Logs:**
```bash
tail -f /home/alex/projects/active/PC-Dashboard/logs/dashboard.log
```

**View Script Execution Logs:**
```bash
tail -f /home/alex/projects/active/PC-Dashboard/logs/script_executions.log
```

**System Journal:**
```bash
journalctl -u pc-dashboard -f
```

## Best Practices

1. **Always Test First**
   - Enable testing mode before trying new things
   - Verify output before running on production

2. **Read Warnings Carefully**
   - Approval prompts explain what will happen
   - Make sure you understand before typing "yes"

3. **Keep Backups**
   - Regular GitHub pushes
   - Testing mode for experiments

4. **Monitor Logs**
   - Check execution logs regularly
   - Watch for failed attempts or errors

5. **Claude Code Collaboration**
   - Let Claude Code help with testing
   - Maintain control through approval system
   - Use testing mode for safety

## Quick Reference

### File Locations
- Dashboard: `/home/alex/projects/active/PC-Dashboard/`
- Scripts: `/home/alex/projects/active/PC-Dashboard/scripts/`
- Logs: `/home/alex/projects/active/PC-Dashboard/logs/`
- N8N Project: `/home/alex/projects/active/N8N/`

### Key Commands
```bash
# Testing mode
touch .testing_mode  # Enable
rm .testing_mode     # Disable

# Service management
systemctl status pc-dashboard
sudo systemctl restart pc-dashboard

# Direct script execution
./scripts/n8n_pc_to_live.sh  # Deploy to production
./scripts/n8n_live_to_pc.sh  # Sync from production

# Emergency bypass
SKIP_SAFETY_CHECK=true ./scripts/script_name.sh
```

### URLs
- Dashboard: http://localhost:5000 (or :8888)
- Local N8N: http://localhost:5678
- Production N8N: https://n8n.50folds.com

---

**Remember:** The approval system is your friend! It prevents accidents while keeping you in control.