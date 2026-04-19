#!/bin/bash
# check-state-freshness.sh
# Blocking stop hook: prevents session end if STATE.md is stale and work remains.
# Exit code 2 = block the action. Exit code 0 = allow.
# See ADR-0004: Blocking Stop Hook.

STATE_FILE="docs/STATE.md"
PLAN_FILE="docs/PLAN.md"

# Guard: if PLAN.md doesn't exist, this project doesn't use mtplan. Allow exit.
if [ ! -f "$PLAN_FILE" ]; then
    exit 0
fi

# Check if PLAN.md has unchecked items (work remains).
unchecked=$(grep -c '^\- \[ \]' "$PLAN_FILE" 2>/dev/null || echo 0)
if [ "$unchecked" -eq 0 ]; then
    # All items checked — no state update required.
    exit 0
fi

# Work remains. Check STATE.md freshness.
if [ ! -f "$STATE_FILE" ]; then
    echo "BLOCKED: docs/STATE.md does not exist but PLAN.md has $unchecked unchecked items."
    echo "Run /mtplan:save to create STATE.md before ending the session."
    exit 2
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
    echo "BLOCKED: STATE.md was last updated $(( age / 60 )) minutes ago."
    echo "There are $unchecked unchecked items in PLAN.md."
    echo "Run /mtplan:save to update STATE.md before ending the session."
    exit 2
fi

# STATE.md is fresh. Allow exit.
exit 0
