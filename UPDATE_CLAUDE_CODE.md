# Claude Code Update Guide

## Current Version Check
```bash
claude --version
```

## Check Latest Available Version
```bash
npm show @anthropic-ai/claude-code version
```

## Update Process

### For Mac with Homebrew Installation

Claude Code on this Mac is installed via npm in the Homebrew directory (`/opt/homebrew/lib/node_modules`).

To update:

```bash
# Temporarily change npm prefix to Homebrew location
npm config set prefix /opt/homebrew

# Install the latest version
npm install -g @anthropic-ai/claude-code@latest

# Restore npm prefix to fnm location
npm config set prefix /Users/alexander/.local/share/fnm/node-versions/v22.17.0/installation

# Verify the update
claude --version
```

### Alternative Method (if above fails)

```bash
# Force reinstall
npm install -g --force @anthropic-ai/claude-code@latest
```

## Troubleshooting

### If you get ENOTEMPTY errors

This happens when npm tries to install in the wrong location. The issue is that npm's default prefix points to fnm's directory, but Claude is installed in Homebrew's directory.

1. Check where Claude is actually installed:
```bash
ls -la /opt/homebrew/bin/claude
```

2. Clean up any conflicting directories:
```bash
rm -rf /Users/alexander/.local/share/fnm/node-versions/*/installation/lib/node_modules/@anthropic-ai/.claude-code-*
```

3. Follow the update process above

### Check Installation Location
```bash
which claude
# Should show: /opt/homebrew/bin/claude
```

### Check npm prefix
```bash
npm config get prefix
# Usually shows: /Users/alexander/.local/share/fnm/node-versions/v22.17.0/installation
```

## After Updating

1. Restart any active Claude sessions
2. Check MCP servers are still configured:
```bash
claude mcp list
```

## Version History
- **1.0.51**: Previous version (August 16, 2025)
- **1.0.92**: Current version (August 18, 2025)

## Quick One-Liner Update
```bash
npm config set prefix /opt/homebrew && npm install -g @anthropic-ai/claude-code@latest && npm config set prefix /Users/alexander/.local/share/fnm/node-versions/v22.17.0/installation && claude --version
```

Last updated: August 18, 2025