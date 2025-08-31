# ⚠️ SAFETY INFORMATION FOR CLAUDE CODE ⚠️

## NEW: Approval-Based Protection System

### How It Works
Claude Code CAN now request to run dangerous scripts, but user approval is required:

1. **Request Execution** - Claude Code can attempt to run any script
2. **Approval Prompt** - User sees clear warning about what will happen
3. **User Decision** - Type "yes" to approve or "no" to cancel
4. **Safe Testing** - Testing mode allows simulation without real changes

### Example Interaction
```bash
# Claude Code runs:
./scripts/n8n_pc_to_live.sh

# User sees:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚨 APPROVAL REQUIRED: This will deploy to PRODUCTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Claude Code is requesting to run: n8n_pc_to_live.sh
This will push your local N8N workflows to production!

To approve, type: yes
To cancel, type: no (or press Ctrl+C)

Do you approve this deployment? 

# User types: yes (or no)
```

## Protected Scripts (Require Approval)

### N8N Deployment Scripts
- `n8n_pc_to_live.sh` - Deploys local to PRODUCTION ⚠️
- `n8n_live_to_pc.sh` - Syncs PRODUCTION to local ⚠️
- `pc_push_to_github.sh` - Pushes changes to GitHub
- `sync_live_to_git.sh` - Syncs production to Git
- Any script with keywords: "push", "pull", "sync", "deploy", "live", "production"

### Dashboard API Calls
- `http://localhost:8888/run/*` - Protected by server-side checks
- Dashboard detects automation and blocks dangerous operations in testing mode

## Testing Mode

### Enable Safe Testing
```bash
touch /home/alex/projects/active/PC-Dashboard/.testing_mode
```
- Scripts show warnings but continue in SIMULATION mode
- No real changes to production systems
- Safe for Claude Code to test workflows

### Disable Testing Mode
```bash
rm /home/alex/projects/active/PC-Dashboard/.testing_mode
```
- Scripts execute REAL operations (still require approval)
- Production changes are possible
- User must approve each dangerous operation

## Safe Operations (No Approval Needed)

These are always safe to run:
- ✅ `cat` any file
- ✅ `ls -la` any directory
- ✅ `git status`, `docker ps`
- ✅ `systemctl status pc-dashboard`
- ✅ `journalctl -u pc-dashboard`
- ✅ `/home/alex/projects/active/PC-Dashboard/safe_diagnose.sh`
- ✅ Reading logs
- ✅ Checking file existence

## Best Practices for Claude Code

1. **Explain Intent First**
   - Tell user WHY you want to run a script
   - Example: "I need to test the sync script to verify it works"

2. **Check Testing Mode**
   - Suggest enabling testing mode for safety
   - Example: "Let me enable testing mode first for safety"

3. **Respect User Decisions**
   - If user types "no", stop and ask for guidance
   - Never try to bypass approval system

4. **Read Output Carefully**
   - Pay attention to warnings and errors
   - Report issues to user clearly

## Emergency Override (User Only)

For emergencies, users can bypass all checks:
```bash
SKIP_SAFETY_CHECK=true ./script_name.sh
```
**Note:** This is for manual use only, not for Claude Code

## Implementation Details

The protection system checks:
1. **Environment Variables** - Detects `CLAUDE_CODE_SESSION`
2. **Testing Mode File** - Checks for `.testing_mode`
3. **User Approval** - Requires "yes" input for dangerous operations
4. **TTY Detection** - Identifies automated vs manual execution

## Historical Context

Previously, Claude Code was completely blocked from running dangerous scripts due to an incident where production was accidentally overwritten. The new approval system maintains safety while allowing Claude Code to be more helpful with user consent.

## Summary

- **Old System:** Claude Code BLOCKED from dangerous scripts
- **New System:** Claude Code can REQUEST, user must APPROVE
- **Testing Mode:** Safe simulation without real changes
- **User Control:** Always maintained through approval prompts

The dashboard is now safer AND more flexible!