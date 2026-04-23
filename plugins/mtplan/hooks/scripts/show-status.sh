#!/bin/bash
# show-status.sh
# Extracts phase and status from STATE.md for prompt display.
# Only emits when the status has changed since the last emission, to avoid
# cluttering every prompt with identical output.
# Used by UserPromptSubmit hook. Stdout goes to model context.

STATE_FILE="docs/STATE.md"
LAST_STATUS_FILE="docs/.mtplan-last-status"
DEBUG_FLAG="docs/.mtplan-debug"

# Guard: if STATE.md doesn't exist, nothing to show.
if [ ! -f "$STATE_FILE" ]; then
    exit 0
fi

# Extract key-value fields from the header.
phase=$(grep '^phase:' "$STATE_FILE" | head -1 | sed 's/^phase: *//')
status=$(grep '^status:' "$STATE_FILE" | head -1 | sed 's/^status: *//')
blocked=$(grep '^blocked:' "$STATE_FILE" | head -1 | sed 's/^blocked: *//')

# Build the output string.
output=""
if [ -n "$phase" ]; then
    output="[mtplan] Phase: $phase | Status: $status"
    if [ "$blocked" != "no" ] && [ -n "$blocked" ]; then
        output="$output | BLOCKED: $blocked"
    fi
fi

# Only emit if the status changed since last emission.
last_output=""
if [ -f "$LAST_STATUS_FILE" ]; then
    last_output=$(cat "$LAST_STATUS_FILE")
fi

if [ -n "$output" ] && [ "$output" != "$last_output" ]; then
    echo "$output"
    echo "$output" > "$LAST_STATUS_FILE"
fi

# Telemetry: always log STATE.md age.
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

# Debug.
if [ -f "$DEBUG_FLAG" ] && [ -n "$phase" ]; then
    echo "$(date +%H:%M:%S) [UserPromptSubmit] Phase: $phase | Status: $status" >> "$DEBUG_FLAG"
fi
