# Claude Code Usage Monitor

## Overview
Real-time token usage monitoring for Claude AI interactions. Track consumption, burn rate, cost analysis, and get intelligent predictions about session limits.

## Installation
Claude Usage Monitor has been installed on this Mac system.

### Package Details
- **Package**: `claude-monitor`
- **Version**: 3.1.0
- **Repository**: https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor
- **Installation Location**: `/Users/alexander/Library/Python/3.9/bin/`

## Configuration
Added to dashboard as an admin tool:
- **Dashboard Button**: "Claude Monitor" in Admin section
- **Script Location**: `/Users/alexander/Mac-Dashboard/scripts/claude_monitor.sh`
- **Direct Command**: `claude-monitor`

## Features
- **Real-time Monitoring**: Live token usage tracking
- **Multiple Plans**: Support for Pro, Max5, Max20, and Custom plans
- **Intelligent Predictions**: ML-based usage forecasting
- **Cost Analytics**: Track spending and burn rates
- **Multiple Views**: Real-time, daily, monthly, session views
- **Timezone Detection**: Automatic system timezone detection
- **Theme Support**: Light, dark, classic, auto themes

## Usage Options

### Via Dashboard
Click the "Claude Monitor" button in the Admin section of your Mac Dashboard.

### Direct Command Line
```bash
# Basic monitoring
export PATH="/Users/alexander/Library/Python/3.9/bin:$PATH"
claude-monitor

# With specific plan
claude-monitor --plan pro

# Different view modes
claude-monitor --view daily
claude-monitor --view monthly
claude-monitor --view session

# Custom refresh rate
claude-monitor --refresh-rate 5

# Debug mode
claude-monitor --debug
```

### Plan Configuration
Choose based on your Claude subscription:
- `--plan pro` - Claude Pro subscription
- `--plan max5` - Claude Teams (5x limit)
- `--plan max20` - Claude Teams (20x limit)  
- `--plan custom` - Custom limits (specify with --custom-limit-tokens)

## Capabilities
- **Token Tracking**: Monitor input/output tokens in real-time
- **Limit Detection**: Intelligent detection of plan limits
- **Burn Rate Analysis**: See how quickly you're using tokens
- **Session Analytics**: Track usage across Claude sessions
- **Cost Estimation**: Understand spending patterns
- **Predictions**: ML-based forecasting of usage patterns

## Integration with Mac Dashboard
The monitor integrates seamlessly with your existing dashboard:
- Available as a one-click button
- Runs in terminal with rich text interface
- Provides immediate visibility into Claude usage
- Helps optimize token consumption

## PATH Configuration
The monitor is installed in `/Users/alexander/Library/Python/3.9/bin/`. The dashboard script automatically adds this to PATH when running.

To use from terminal:
```bash
# Add to your shell profile (.zshrc, .bash_profile, etc.)
export PATH="/Users/alexander/Library/Python/3.9/bin:$PATH"
```

## Troubleshooting

### Command Not Found
If you get "command not found" errors:
```bash
# Check installation
pip list | grep claude-monitor

# Reinstall if needed
pip install --upgrade claude-monitor

# Verify PATH
echo $PATH | grep "Library/Python/3.9/bin"
```

### Permission Issues
```bash
# Fix permissions if needed
chmod +x /Users/alexander/Library/Python/3.9/bin/claude-monitor
```

## Use Cases
- **Development**: Monitor token usage during coding sessions
- **Cost Management**: Track spending and optimize usage
- **Performance**: Understand which operations consume the most tokens
- **Planning**: Predict when you'll hit plan limits
- **Analytics**: Analyze usage patterns over time

Last updated: September 1, 2025