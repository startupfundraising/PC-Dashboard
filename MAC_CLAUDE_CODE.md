# Claude Code on Mac - Quick Reference

## The Approval System

When you click dashboard buttons, Claude Code helper may trigger approval prompts for dangerous scripts.

## Your Options:

### 🟢 Option 1: Just Use Approval (Easiest)
- Click button in dashboard
- When prompted, type `yes` to approve
- Simple and safe

### 🟡 Option 2: Testing Mode (For Development)
```bash
# Enable testing mode - scripts run but don't change anything
touch ~/PC-Dashboard/.testing_mode

# Disable when ready for real operations
rm ~/PC-Dashboard/.testing_mode
```

### 🔴 Option 3: Disable Protection (If You Trust Claude Code)

Add this to your `~/.zshrc`:
```bash
# Tell scripts to skip Claude Code checks on Mac
export SKIP_SAFETY_CHECK=true
```

Or modify individual scripts to remove the approval check.

## Quick Decision Guide

**Q: Do you want Claude Code to help with development?**
- Yes, with safety → Use Option 1 (approval prompts)
- Yes, for testing only → Use Option 2 (testing mode)
- Yes, I trust it completely → Use Option 3 (disable protection)

**Q: Are you working on production systems?**
- Yes → Keep approval system (Option 1)
- No, just testing → Use testing mode (Option 2)

## Examples

### With Approval (Default)
```
You: *click N8N: PC → Live button*
System: "APPROVAL REQUIRED: Deploy to production?"
You: *type "yes"*
System: *deploys*
```

### With Testing Mode
```
You: *click N8N: PC → Live button*
System: "TESTING MODE - simulating deployment"
System: *shows what would happen, but doesn't do it*
```

### With Protection Disabled
```
You: *click N8N: PC → Live button*
System: *deploys immediately without asking*
```

## Recommendation

Start with **testing mode** for development, then use **approval prompts** for real operations. This gives you the best balance of safety and convenience.

## Commands Summary

```bash
# Enable testing mode (safe development)
touch ~/PC-Dashboard/.testing_mode

# Disable testing mode (real operations with approval)
rm ~/PC-Dashboard/.testing_mode

# Skip all safety checks (one-time)
SKIP_SAFETY_CHECK=true ./scripts/script_name.sh

# Skip all safety checks (permanent - add to ~/.zshrc)
export SKIP_SAFETY_CHECK=true
```

The approval system is there to protect you, but you can adjust it based on your comfort level!