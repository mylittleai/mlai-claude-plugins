#!/bin/bash
# inject-state.sh
# Reads STATE.md and the current plan phase, outputs for context injection.
# Used by SessionStart hook. Stdout goes to model context.
# Touch docs/.mtplan-debug to echo to stderr (visible to user).

STATE_FILE="docs/STATE.md"
PLAN_FILE="docs/PLAN.md"
DEBUG_FLAG="docs/.mtplan-debug"

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

# Telemetry: log session start with STATE.md age.
TELEMETRY="docs/.mtplan-telemetry"
if stat -f %m "$STATE_FILE" >/dev/null 2>&1; then
    last_mod=$(stat -f %m "$STATE_FILE")
else
    last_mod=$(stat -c %Y "$STATE_FILE")
fi
age=$(( $(date +%s) - last_mod ))
phase=$(grep '^phase:' "$STATE_FILE" | head -1 | sed 's/^phase: *//')
echo "$(date +%H:%M:%S) [SessionStart] age=${age}s phase=$phase" >> "$TELEMETRY"

# Debug: append to the debug flag file itself.
if [ -f "$DEBUG_FLAG" ]; then
    echo "$(date +%H:%M:%S) [SessionStart] Injected state for $phase" >> "$DEBUG_FLAG"
fi
