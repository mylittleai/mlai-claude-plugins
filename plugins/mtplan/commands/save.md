---
description: Audit PLAN.md checkboxes and rewrite STATE.md before ending a session
argument-hint: ""
allowed-tools: Read, Write, Edit
---

# Save Session State

Full STATE.md rewrite so a fresh agent can resume without loss. Includes a mandatory PLAN.md checkbox audit to prevent divergence.

## Process

1. Read `docs/PLAN.md` and `docs/STATE.md`.
2. **Audit PLAN.md checkboxes.** Compare what you know was completed this session (from STATE.md status/context and your session knowledge) against the checkbox state in PLAN.md. Build a **PLAN_UPDATES** list:
   - For each item that is complete but still shows `- [ ]` in PLAN.md, add its number (e.g., "2.1, 2.3, 2.5").
   - If no items need updating, PLAN_UPDATES is `none`.
   - Also note any unrecorded Deferred Decisions to add.
3. **Compose full STATE.md content:**

```
phase: [current phase]
status: [precise completion level]
next_action: [numbered, actionable steps]
blocked: [no, or specific reason]
branch: [current git branch]
last_updated: [ISO 8601 timestamp]

## Active Contract
[What is being built, why, current approach. Written for a fresh agent.]

## Context for Fresh Agent
[Completed phases, current progress, failed approaches, relevant paths, user directives, branch state.]
```

4. **Delegate to state-writer** with both outputs from steps 2 and 3:
   ```
   MODE: save
   PLAN_UPDATES: [list from step 2, or "none"]
   STATE_CONTENT: [composed content from step 3]
   ```
   Never omit PLAN_UPDATES — pass `none` explicitly if no items need checking off.
   For user-invoked `/mtplan:save`, you may perform the edits directly instead of delegating.
5. Display summary: items checked off, STATE.md timestamp, and confirm the stop hook will pass.

## Quality Check

A fresh agent reading only CLAUDE.md, PLAN.md, and STATE.md must be able to:
- Identify where work left off.
- Know what to do next without asking.
- Understand any blockers or context.

## Pitfalls

- Vague next_action ("continue working") is useless — write specific steps.
- Missing failed approaches means the next session may retry them.
- Delegating to state-writer without PLAN_UPDATES causes checkbox drift — the audit in step 2 MUST produce the list that step 4 consumes.
