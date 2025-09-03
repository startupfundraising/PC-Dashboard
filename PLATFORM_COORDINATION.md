# Platform Coordination Guide

## Branch Strategy

- **master**: Mac-optimized branch
- **pc-main**: PC-optimized branch with unified environment system

## Environment System

Both platforms now use the same codebase with environment-aware configuration:

### First-time Setup
1. Copy `.env.template` to `.env`
2. Customize paths for your platform
3. System auto-detects Mac vs PC/WSL

### Syncing Improvements

#### Mac → PC:
```bash
# On Mac (master branch)
git push origin master

# On PC (pc-main branch)  
git pull origin master
git merge master  # Merge improvements
git push origin pc-main
```

#### PC → Mac:
```bash
# On PC (pc-main branch)
git push origin pc-main

# On Mac (master branch)
git pull origin pc-main  
git merge pc-main  # Merge improvements
git push origin master
```

## Conflict Resolution

The new configuration system eliminates path conflicts:
- Platform-specific paths in `.env` (gitignored)
- Shared code uses environment variables
- Auto-detection handles platform differences

## Features Available on Both Platforms

- ✅ Environment-aware dashboard
- ✅ Cross-platform script execution
- ✅ Claude Code integration
- ✅ Testing mode utilities
- ✅ Usage monitoring
- ✅ Memory Bank MCP support

## Platform-Specific Files

These remain platform-specific:
- `.env` - Local configuration (gitignored)
- Service files - systemd (PC) vs launchd (Mac)
- Launch commands - Different terminal handling