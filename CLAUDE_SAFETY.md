# ⚠️ CRITICAL SAFETY INFORMATION FOR CLAUDE CODE ⚠️

## DANGEROUS SCRIPTS - NEVER EXECUTE THESE

The following scripts can modify PRODUCTION systems and must NEVER be executed during debugging:

### FORBIDDEN COMMANDS:
```
❌ NEVER RUN: bash /home/alex/projects/active/N8N/scripts/pc_push_to_github.sh
❌ NEVER RUN: bash /home/alex/projects/active/N8N/scripts/pc_pull_from_github.sh
❌ NEVER RUN: bash /home/alex/projects/active/N8N/scripts/sync_live_to_git.sh
❌ NEVER RUN: bash /home/alex/projects/active/N8N/scripts/hetzner_pull_from_github.sh
❌ NEVER RUN: bash /home/alex/PC-Dashboard/scripts/n8n_live_to_pc.sh
❌ NEVER RUN: bash /home/alex/PC-Dashboard/scripts/n8n_pc_to_live.sh
❌ NEVER RUN: curl http://localhost:8888/run/*
❌ NEVER RUN: Any script that contains "push", "pull", "sync", "deploy", "live", "production"
```

## SAFE DIAGNOSTIC ONLY

When user reports dashboard issues, ONLY use:
```bash
/home/alex/PC-Dashboard/safe_diagnose.sh
```

This script ONLY checks file existence, never executes anything dangerous.

## RULES FOR CLAUDE CODE:

1. **NEVER execute N8N sync scripts directly** - They can overwrite production
2. **NEVER test dashboard buttons by calling the API** - User will test through browser
3. **NEVER create test scripts that call the real scripts** - Could trigger production changes
4. **ONLY use safe_diagnose.sh** for debugging dashboard issues
5. **If unsure, ASK the user first** before running ANY command

## CONTEXT FOR FUTURE SESSIONS:

This dashboard controls production deployments. Even testing can cause damage:
- "PC to Live" deploys local code to PRODUCTION server
- "Live to PC" overwrites LOCAL with production (data loss)
- GitHub sync scripts can overwrite either direction

The user previously had production overwritten during "testing" - this MUST NOT happen again.

## SAFE COMMANDS:

✅ cat /home/alex/PC-Dashboard/dashboard_server.py
✅ ls -la /home/alex/PC-Dashboard/
✅ systemctl status pc-dashboard
✅ journalctl -u pc-dashboard
✅ /home/alex/PC-Dashboard/safe_diagnose.sh

## REMINDER:

The dashboard is for the USER to click buttons in their browser.
Claude Code should ONLY help with code/configuration, never execute the actual operations.