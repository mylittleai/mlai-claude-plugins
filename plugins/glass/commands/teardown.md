---
description: Remove all glass configuration from this project
allowed-tools: Bash, AskUserQuestion
---

# glass:teardown

Remove the glass configuration from this project.

## Process

1. Ask the user to confirm: "This will remove the chrome-devtools MCP configuration from .mcp.json. Continue?"
2. If confirmed, run `${CLAUDE_PLUGIN_ROOT}/bin/glass teardown` via Bash.
3. Report the result.
4. Tell the user to restart Claude Code for changes to take effect.
