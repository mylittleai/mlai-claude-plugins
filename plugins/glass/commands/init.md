---
description: Install chrome-devtools-mcp config and verify dependencies
allowed-tools: Bash, Read
---

# glass:init

Install the chrome-devtools-mcp configuration for this project. Idempotent — safe to run multiple times.

## Process

1. Run `${CLAUDE_PLUGIN_ROOT}/bin/glass init` via Bash.
2. If the binary is not found, tell the user: "The glass binary is not built. Run `make build` in the mlai-glass repo root."
3. Report the output to the user.
4. If all checks passed, tell the user to restart Claude Code so the MCP tools become available.
5. After restart, chrome-devtools MCP tools (take_screenshot, navigate_page, evaluate_script, etc.) will be available for browser observation.

## Note on macOS permissions

Window positioning requires macOS Automation access. The first time glass moves a Chrome window, macOS will show a permission dialog. Tell the user to click Allow. If they need to grant it later: System Settings → Privacy & Security → Automation → enable Google Chrome under the terminal app.
