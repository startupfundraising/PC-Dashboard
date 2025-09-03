# Memory Bank MCP Setup

## Overview
The Memory Bank MCP server provides remote access to project memory banks, enabling centralized storage and management of AI project contexts across different development environments.

## Installation
Memory Bank MCP has been installed and configured on this Mac system.

### Package Details
- **Package**: `@allpepper/memory-bank-mcp`
- **Version**: 0.2.1
- **Repository**: https://github.com/alioshr/memory-bank-mcp

### Configuration
```json
{
  "memory-bank": {
    "command": "npx -y @allpepper/memory-bank-mcp",
    "env": {
      "MEMORY_BANK_ROOT": "/Users/alexander/memory-bank"
    }
  }
}
```

## Directory Structure
Memory banks are stored at: `/Users/alexander/memory-bank/`

This directory contains:
- Project-specific memory bank files
- AI context and conversation history
- Project documentation and notes

## Capabilities
The Memory Bank MCP provides these functions:
- **Read**: Access existing memory bank files
- **Write**: Create new memory bank files
- **Update**: Modify existing memory bank entries
- **List Projects**: Browse available memory bank projects
- **List Project Files**: View files within specific projects
- **Validate**: Check project existence and structure

## Usage in Claude Sessions
Once configured, the Memory Bank MCP allows Claude to:
1. Store project context between sessions
2. Retrieve historical information about projects
3. Maintain continuity across different development tasks
4. Access centralized project documentation

## Integration with Existing Setup
The Memory Bank MCP works alongside your existing MCP servers:
- **N8N**: Workflow automation context
- **GitHub**: Repository and code management
- **Filesystem**: Local file operations
- **Memory Bank**: Project memory and context storage

## Directory Location
- **Root**: `/Users/alexander/memory-bank/`
- **Access**: Available to all Claude sessions
- **Backup**: Include in your regular backup routines

## Next Steps
1. Memory Bank MCP will be available in your next Claude session
2. Start using it to store project contexts and important information
3. Build up project memory banks for your N8N, dashboard, and other development work

Last updated: September 1, 2025