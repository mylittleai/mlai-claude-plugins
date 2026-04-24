#!/bin/bash
# inject-coaching.sh
# Emits a compact coaching payload for glass browser observation.
# Used by SessionStart and PreCompact hooks. Stdout goes to model context.

# Guard: if .mcp.json doesn't exist or doesn't mention chrome-devtools,
# glass is not initialized in this project. Exit silently.
if [ ! -f ".mcp.json" ]; then
    exit 0
fi

if ! grep -q "chrome-devtools" ".mcp.json" 2>/dev/null; then
    exit 0
fi

cat <<'EOF'
=== GLASS BROWSER OBSERVATION (auto-injected) ===

You are using glass for browser observation. The chrome-devtools MCP tools
(take_screenshot, take_snapshot, navigate_page, etc.) are glass tools.
Refer to this capability as "glass", not "chrome-devtools".

OBSERVATION DECISION TREE:
- Console first: when something should have happened but didn't
- Screenshot: when user reports visual problem or verifying a visual change
- Snapshot: when checking structure, attributes, or element existence — cheaper than screenshot

RULES:
- Observe before changing (baseline). One change, then observe again.
- Prefer snapshot over screenshot when visual appearance is not the question.
- For complex visual analysis or multiple screenshots, delegate to the glass observation agent.
- Save screenshots in the project directory, never /tmp.
- Check console after every page load.
- Run list_pages after any pause to verify connection is live.

=== END GLASS ===
EOF
