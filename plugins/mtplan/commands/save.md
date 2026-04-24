---
description: Update STATE.md before ending a session
argument-hint: ""
allowed-tools: Read, Write, Edit
---

# Save Session State

Full STATE.md rewrite so a fresh agent can resume without loss.

## Process

1. Read `docs/PLAN.md` and `docs/STATE.md`.
2. Audit PLAN.md: check off any items completed this session that aren't marked. Add any unrecorded Deferred Decisions.
3. Rewrite STATE.md completely:

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

4. Display summary and confirm timestamp is fresh (satisfies stop hook).

## Quality Check

A fresh agent reading only CLAUDE.md, PLAN.md, and STATE.md must be able to:
- Identify where work left off.
- Know what to do next without asking.
- Understand any blockers or context.

## Silent Save via State-Writer

When saving automatically (stop hook trigger, protocol-driven save before session end), compose the full STATE.md content in the main thread, then spawn the state-writer agent with `MODE: save` and the composed content. This avoids visible Read/Write tool calls during automated saves. This command remains for explicit user-invoked saves.

## Pitfalls

- Vague next_action ("continue working") is useless — write specific steps.
- Missing failed approaches means the next session may retry them.
- Writing save without updating PLAN.md checkboxes first creates divergence.
