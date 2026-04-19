#!/bin/bash
# inject-state.sh
# Reads STATE.md and the current plan phase, outputs for context injection.
# Used by SessionStart and PreCompact hooks.
# See ADR-0005: SessionStart and PreCompact State Re-injection.

STATE_FILE="docs/STATE.md"
PLAN_FILE="docs/PLAN.md"

# Guard: if state files don't exist, nothing to inject.
if [ ! -f "$STATE_FILE" ] || [ ! -f "$PLAN_FILE" ]; then
    exit 0
fi

echo "=== MTPLAN STATE (auto-injected) ==="
echo ""
cat "$STATE_FILE"
echo ""
echo "=== CURRENT PLAN PHASE ==="
echo ""
# Find the first phase that has unchecked items and display it.
awk '
/^## Phase/ { phase=$0; printing=0 }
/^- \[ \]/ { if (phase != "") { print phase; phase=""; printing=1 } }
printing { print }
/^## / && !/^## Phase/ { if (printing) exit }
' "$PLAN_FILE" | head -40
echo ""
echo "=== END MTPLAN STATE ==="
