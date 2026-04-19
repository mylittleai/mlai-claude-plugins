---
name: Checkpoint Plan Progress
description: >
  This skill should be used when the user invokes "/mtplan:checkpoint", asks to
  "mark items done", "update plan progress", "checkpoint state", "check off plan items",
  or wants to record completed work in PLAN.md and STATE.md.
argument-hint: "[item reference, e.g., '3.2' or 'Phase 2, Item 3']"
allowed-tools: ["Read", "Edit", "Write"]
version: 0.1.0
---

# Checkpoint Plan Progress

Record completed work by updating PLAN.md checkboxes and STATE.md state. Enforces atomic checkpoint discipline (ADR-0002).

## Process

### 1. Read Current State

Read both `docs/PLAN.md` and `docs/STATE.md` to understand:
- Current phase and its items
- Which items are already checked
- What STATE.md says is in progress

### 2. Determine What to Checkpoint

If the user specified an item reference (e.g., "3.2"), use it directly.

If no specific item was given, identify what to checkpoint by:
1. Checking STATE.md "next_action" — is this item now complete?
2. Looking at the first unchecked item in the current phase — has it been completed?
3. Asking the user if ambiguous.

### 3. Update PLAN.md (Atomic)

For each completed item, change `- [ ]` to `- [x]` in PLAN.md. Update ONE item at a time. If multiple items are complete, make separate edits — never batch.

```
Before: - [ ] Implement the parser
After:  - [x] Implement the parser
```

### 4. Update STATE.md

Update the key-value header:
- `status`: Reflect the new state after this checkpoint.
- `next_action`: Point to the next unchecked item in the phase.
- `last_updated`: Current ISO 8601 timestamp.

If all items in the current phase are now checked:
- Set `status` to "Phase [N] complete"
- Set `next_action` to "Enter plan mode for Phase [N+1]"

Update the Active Contract and Context for Fresh Agent sections to reflect the completed work.

### 5. Phase Completion Detection

If all items in the current phase are checked after this update:

1. Notify the user: "Phase [N] complete. All [X] items checked."
2. Suggest: "Enter plan mode to define Phase [N+1]. Triage Deferred Decisions first."
3. List any pending Deferred Decisions for triage.

## Checkpoint Discipline Rules

These rules are non-negotiable (ADR-0002):

- **Atomic:** One checkbox per update. Never batch multiple items.
- **Immediate:** Update PLAN.md in the same logical step as completing the work.
- **Bias-early:** Mark "in progress" in STATE.md before starting an item. Mark "done" in PLAN.md immediately after completing it.
- **Co-committed:** PLAN.md and STATE.md changes belong in the same git commit as the work they track.

## Monotonic Growth Rules (ADR-0009)

- Never uncheck a `[x]` item. If work needs revisiting, create a new item.
- Never delete a phase.
- When striking through a Deferred Decision, add a resolution note.

## Error Conditions

- If `docs/PLAN.md` does not exist: "Plan not initialized. Run `/mtplan:init` first."
- If `docs/STATE.md` does not exist: "State not initialized. Run `/mtplan:init` first."
- If the specified item is already checked: "Item [ref] is already marked complete."
- If the specified item does not exist: "Item [ref] not found in PLAN.md."
