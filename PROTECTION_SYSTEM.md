# PC Dashboard Protection System

## Overview
This dashboard implements a **user-approval protection system** that allows Claude Code and other automation tools to request script execution, but requires your explicit approval for dangerous operations.

## Protection Layers

### Layer 1: Dashboard Server Protection
The dashboard server (`dashboard_server.py`) checks:
- ✅ Testing mode file (`.testing_mode`)
- ✅ User agent for automation tools
- ✅ Referer header to verify browser execution

### Layer 2: Script-Level Protection
Individual scripts check for:
- ✅ Claude Code environment variables
- ✅ Interactive terminal (TTY) requirement
- ✅ Testing mode status
- ✅ User confirmation for dangerous operations

### Layer 3: Safe Execute Wrapper
The `safe_execute.sh` wrapper provides:
- ✅ Random verification codes
- ✅ Time-based validation (prevents fast automated responses)
- ✅ Multiple confirmation steps
- ✅ Comprehensive logging

## How It Works

### For Safe Scripts
Scripts without dangerous patterns run normally without extra checks.

### For Dangerous Scripts
Scripts with patterns like `push`, `pull`, `deploy`, `live`, `production`:

1. **Approval Required** - Claude Code can request to run, but you must type "yes" to approve
2. **Testing Mode** - When `.testing_mode` exists, scripts run in simulation mode (no real changes)
3. **Clear Warnings** - Shows exactly what will happen before you approve
4. **Simple Approval** - Just type "yes" to proceed or "no" to cancel

## Testing Mode

### Enable Testing Mode
```bash
./enable_testing_mode.sh
```
Creates `.testing_mode` file that blocks all dangerous script execution.

### Disable Testing Mode
```bash
./disable_testing_mode.sh
```
Removes `.testing_mode` file to allow script execution (with confirmations).

## Protected Scripts

The following scripts are protected:
- `n8n_pc_to_live.sh` - Deploys to production
- `n8n_live_to_pc.sh` - Syncs from production
- `pc_push_to_github.sh` - Pushes to GitHub
- Any script with production/deployment keywords

## Running Scripts

### With Claude Code
When Claude Code tries to run a dangerous script:
1. You'll see an approval prompt
2. Type "yes" to approve or "no" to cancel
3. Script executes with your approval

### Manual Execution
To run a script manually in terminal:
```bash
cd /home/alex/projects/active/PC-Dashboard/scripts
./n8n_pc_to_live.sh
# Type "yes" when prompted
```

### Skip Safety (Emergency Only)
```bash
SKIP_SAFETY_CHECK=true ./script_name.sh
```

## Dashboard Execution

When clicking buttons in the web dashboard:
1. Dashboard checks testing mode
2. Dashboard verifies request source
3. Script executes with dashboard privileges

## Logging

All script executions are logged to:
- `/home/alex/projects/active/PC-Dashboard/logs/script_executions.log`
- System logger (viewable with `journalctl`)

## Troubleshooting

### Script Won't Run
1. Check if testing mode is active: `ls -la /home/alex/projects/active/PC-Dashboard/.testing_mode`
2. Ensure you're in an interactive terminal
3. Check you're not running through Claude Code

### Need to Force Execution
**⚠️ DANGEROUS - Only for emergencies:**
```bash
SAFE_EXECUTE_VERIFIED=true ./script_name.sh
```

## Security Notes

- Never share terminal sessions with automation tools
- Always review scripts before execution
- Keep testing mode enabled when not deploying
- Check logs regularly for unauthorized attempts

## Environment Variables

The system checks for these automation indicators:
- `CLAUDE_CODE_SESSION`
- `CLAUDE_CODE`
- `ANTHROPIC_SESSION`
- Parent process patterns

---

**Remember:** This protection system is designed to prevent accidents. Always be cautious when working with production systems.