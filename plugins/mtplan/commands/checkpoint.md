---
description: Mark plan items complete and update state
argument-hint: "[item reference, e.g. '3.2' or 'Phase 2, Item 3']"
allowed-tools: Read, Edit, Write
---

# Checkpoint Plan Progress

Update PLAN.md checkboxes and STATE.md atomically (ADR-0002).

## Process

1. Read `docs/PLAN.md` and `docs/STATE.md`.
2. If $ARGUMENTS specifies an item, use it. Otherwise identify the next completed item from STATE.md context.
3. Change `- [ ]` to `- [x]` in PLAN.md. One item per edit — never batch.
4. Update STATE.md: `status`, `next_action`, `last_updated`. Update Active Contract and Context sections.
5. If all items in the current phase are now checked: notify "Phase [N] complete" and suggest entering plan mode for the next phase with Deferred Decisions triage.

## Rules

- **Atomic:** one checkbox per update.
- **Immediate:** update in the same step as the work.
- **Monotonic:** never uncheck a `[x]` item — create a new item instead (ADR-0009).
- **Co-committed:** PLAN.md and STATE.md changes belong in the same commit as the work.

## Relationship to State-Writer Agent

During autonomous execution, checkpoints are performed silently by the state-writer agent to reduce UI noise. This command exists for explicit user-invoked checkpoints and as a fallback when the agent is unavailable.

## Errors

- No PLAN.md/STATE.md: "Not initialized. Run `/mtplan:init` first."
- Item already checked: "Item [ref] is already complete."
- Item not found: "Item [ref] not found in PLAN.md."
