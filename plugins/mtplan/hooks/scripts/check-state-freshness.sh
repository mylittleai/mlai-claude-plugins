#!/bin/bash
# check-state-freshness.sh
# Blocking stop hook: prevents session end if STATE.md is stale and work remains.
# Uses JSON stdout with decision:block to signal Claude Code.
# Touch docs/.mtplan-debug to echo to stderr (visible to user).
# See ADR-0004: Blocking Stop Hook.

STATE_FILE="docs/STATE.md"
PLAN_FILE="docs/PLAN.md"

# Check if PLAN.md has unchecked items (work remains).
unchecked=$(grep -c '^\- \[ \]' "$PLAN_FILE" 2>/dev/null || echo 0)
if [ "$unchecked" -eq 0 ]; then
    # All items checked — no state update required.
    exit 0
fi

# Work remains. Check STATE.md freshness.
if [ ! -f "$STATE_FILE" ]; then
    echo "{\"decision\":\"block\",\"reason\":\"docs/STATE.md does not exist but PLAN.md has $unchecked unchecked items. Run /mtplan:save before ending the session.\"}"
    exit 0
fi

# Get last modification time (portable: macOS and Linux).
if stat -f %m "$STATE_FILE" >/dev/null 2>&1; then
    last_modified=$(stat -f %m "$STATE_FILE")
else
    last_modified=$(stat -c %Y "$STATE_FILE")
fi

now=$(date +%s)
age=$(( now - last_modified ))

# 600 seconds = 10 minutes
if [ "$age" -gt 600 ]; then
    echo "$(date +%H:%M:%S) [Stop] age=${age}s unchecked=$unchecked allowed=no BLOCKED" >> "docs/.mtplan-telemetry"
    echo "{\"decision\":\"block\",\"reason\":\"STATE.md was last updated $(( age / 60 )) minutes ago with $unchecked unchecked items in PLAN.md. Run /mtplan:save before ending the session.\"}"
    exit 0
fi

# Telemetry: log stop event with freshness.
echo "$(date +%H:%M:%S) [Stop] age=${age}s unchecked=$unchecked allowed=yes" >> "docs/.mtplan-telemetry"

# Debug.
if [ -f "docs/.mtplan-debug" ]; then
    echo "$(date +%H:%M:%S) [Stop] STATE.md fresh (${age}s old), $unchecked unchecked — allowed" >> "docs/.mtplan-debug"
fi
exit 0
