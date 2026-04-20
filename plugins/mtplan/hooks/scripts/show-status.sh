#!/bin/bash
# show-status.sh
# Extracts phase, status, and next_action from STATE.md for prompt display.
# Used by UserPromptSubmit hook. Stdout goes to model context.
# Touch docs/.mtplan-debug to echo to stderr (visible to user).

STATE_FILE="docs/STATE.md"
DEBUG_FLAG="docs/.mtplan-debug"

# Guard: if STATE.md doesn't exist, nothing to show.
if [ ! -f "$STATE_FILE" ]; then
    exit 0
fi

# Extract key-value fields from the header.
phase=$(grep '^phase:' "$STATE_FILE" | head -1 | sed 's/^phase: *//')
status=$(grep '^status:' "$STATE_FILE" | head -1 | sed 's/^status: *//')
next_action=$(grep '^next_action:' "$STATE_FILE" | head -1 | sed 's/^next_action: *//')
blocked=$(grep '^blocked:' "$STATE_FILE" | head -1 | sed 's/^blocked: *//')

if [ -n "$phase" ]; then
    echo "[mtplan] Phase: $phase | Status: $status"
    if [ "$blocked" != "no" ] && [ -n "$blocked" ]; then
        echo "[mtplan] BLOCKED: $blocked"
    fi
    if [ -n "$next_action" ]; then
        echo "[mtplan] Next: $next_action"
    fi
fi

# Telemetry: always log STATE.md age to docs/.mtplan-telemetry if it exists.
TELEMETRY="docs/.mtplan-telemetry"
if [ -f "$STATE_FILE" ]; then
    if stat -f %m "$STATE_FILE" >/dev/null 2>&1; then
        last_mod=$(stat -f %m "$STATE_FILE")
    else
        last_mod=$(stat -c %Y "$STATE_FILE")
    fi
    age=$(( $(date +%s) - last_mod ))
    echo "$(date +%H:%M:%S) [UserPromptSubmit] age=${age}s phase=$phase" >> "$TELEMETRY"
fi

# Debug: append to the debug flag file itself.
if [ -f "$DEBUG_FLAG" ] && [ -n "$phase" ]; then
    echo "$(date +%H:%M:%S) [UserPromptSubmit] Phase: $phase | Status: $status" >> "$DEBUG_FLAG"
fi
