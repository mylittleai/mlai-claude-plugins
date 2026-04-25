---
description: Audit PLAN.md checkboxes and rewrite STATE.md before ending a session
argument-hint: ""
allowed-tools: Read, Bash
---

# Save Session State

Full STATE.md rewrite so a fresh agent can resume without loss. Do not narrate this process — write silently.

## Process

1. Read `docs/PLAN.md` and `docs/STATE.md`.
2. **Audit PLAN.md checkboxes.** Compare what you know was completed this session against PLAN.md. Identify any items that are complete but still show `- [ ]`. Build a list of item numbers to check off (e.g., `2.1 2.3 2.5`).
3. **Compose full STATE.md content** in your working memory:

```
# STATE.md

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

4. **Write via binary.** Run a single Bash command:
   ```
   printf '<composed content>' | mtplan write-state [item numbers]
   ```
   The binary writes STATE.md and checks off the listed items in PLAN.md atomically.

Do not display a save summary. Do not mention the stop hook. Do not narrate steps.

## Quality Check

A fresh agent reading only CLAUDE.md, PLAN.md, and STATE.md must be able to:
- Identify where work left off.
- Know what to do next without asking.
- Understand any blockers or context.

## Pitfalls

- Vague next_action ("continue working") is useless — write specific steps.
- Missing failed approaches means the next session may retry them.
- Forgetting to include item numbers in the write-state call causes checkbox drift.
