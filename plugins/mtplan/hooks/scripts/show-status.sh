#!/bin/bash
# show-status.sh
# Extracts phase, status, and next_action from STATE.md for prompt display.
# Used by UserPromptSubmit hook.
# See ADR-0005: SessionStart and PreCompact State Re-injection.

STATE_FILE="docs/STATE.md"

# Guard: if STATE.md doesn't exist, output nothing.
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
