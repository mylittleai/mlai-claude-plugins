#!/bin/bash
# check-state-freshness.sh
# Blocking stop hook: prevents session end if STATE.md is stale and work remains.
# Uses JSON stdout with decision:block to signal Claude Code.
# Blocks once per cooldown window to avoid cascading on every turn boundary.
# See ADR-0004: Blocking Stop Hook.

STATE_FILE="docs/STATE.md"
PLAN_FILE="docs/PLAN.md"
COOLDOWN_FILE="docs/.mtplan-stop-cooldown"
COOLDOWN_SECONDS=1800  # 30 minutes

# Check if PLAN.md has unchecked items (work remains).
unchecked=$(grep -c '^\- \[ \]' "$PLAN_FILE" 2>/dev/null || echo 0)
if [ "$unchecked" -eq 0 ]; then
    rm -f "$COOLDOWN_FILE"
    exit 0
fi

# Work remains. Check STATE.md freshness.
if [ ! -f "$STATE_FILE" ]; then
    echo "{\"decision\":\"block\",\"reason\":\"docs/STATE.md does not exist but PLAN.md has $unchecked unchecked items. Run /mtplan:save before ending the session.\"}"
    exit 0
fi

# Portable mtime helper.
get_mtime() {
    if stat -f %m "$1" >/dev/null 2>&1; then
        stat -f %m "$1"
    else
        stat -c %Y "$1"
    fi
}

now=$(date +%s)
state_mtime=$(get_mtime "$STATE_FILE")
age=$(( now - state_mtime ))

# STATE.md is fresh enough — allow and clear any cooldown.
# 600 seconds = 10 minutes.
if [ "$age" -le 600 ]; then
    rm -f "$COOLDOWN_FILE"
    echo "$(date +%H:%M:%S) [Stop] age=${age}s unchecked=$unchecked allowed=yes" >> "docs/.mtplan-telemetry"
    if [ -f "docs/.mtplan-debug" ]; then
        echo "$(date +%H:%M:%S) [Stop] STATE.md fresh (${age}s old), $unchecked unchecked — allowed" >> "docs/.mtplan-debug"
    fi
    exit 0
fi

# STATE.md is stale. Check cooldown before blocking.
if [ -f "$COOLDOWN_FILE" ]; then
    cooldown_mtime=$(get_mtime "$COOLDOWN_FILE")

    # If STATE.md was updated after the cooldown was set, the user responded.
    # Reset cooldown and re-evaluate (will block again since we know age > 600).
    if [ "$state_mtime" -gt "$cooldown_mtime" ]; then
        rm -f "$COOLDOWN_FILE"
    else
        # Cooldown is active. Check if it has expired.
        cooldown_age=$(( now - cooldown_mtime ))
        if [ "$cooldown_age" -lt "$COOLDOWN_SECONDS" ]; then
            # Still in cooldown — allow silently.
            echo "$(date +%H:%M:%S) [Stop] age=${age}s unchecked=$unchecked allowed=yes (cooldown active, ${cooldown_age}s/${COOLDOWN_SECONDS}s)" >> "docs/.mtplan-telemetry"
            exit 0
        fi
        # Cooldown expired — fall through to block again.
        rm -f "$COOLDOWN_FILE"
    fi
fi

# Block and start cooldown.
touch "$COOLDOWN_FILE"
echo "$(date +%H:%M:%S) [Stop] age=${age}s unchecked=$unchecked allowed=no BLOCKED (cooldown started)" >> "docs/.mtplan-telemetry"
echo "{\"decision\":\"block\",\"reason\":\"STATE.md was last updated $(( age / 60 )) minutes ago with $unchecked unchecked items in PLAN.md. Run /mtplan:save before ending the session.\"}"
exit 0
