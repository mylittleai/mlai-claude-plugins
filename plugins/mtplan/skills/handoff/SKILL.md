---
name: Session Handoff
description: >
  This skill should be used when the user invokes "/mtplan:handoff", asks to
  "end session", "update state for handoff", "prepare for session end",
  "write handoff state", or wants to update STATE.md before ending a work session.
argument-hint: ""
allowed-tools: ["Read", "Write", "Edit"]
version: 0.1.0
---

# Session Handoff

Perform the session-end routine: full STATE.md rewrite with current state, ensuring a fresh agent can resume without loss.

## Process

### 1. Read Current State

Read both `docs/PLAN.md` and `docs/STATE.md` to assess:
- Current phase and item progress (PLAN.md checkboxes)
- What STATE.md currently says vs what is actually true
- Any uncommitted work or pending changes

### 2. Audit Checkpoint Currency

Before writing the handoff, verify PLAN.md is current:
- Are there items completed this session that are not checked off? If so, check them off first (atomic checkpoint discipline, ADR-0002).
- Are there Deferred Decisions observed this session that are not recorded? Add them to PLAN.md.

This step prevents the most common handoff failure: STATE.md says "done" but PLAN.md checkboxes disagree.

### 3. Full STATE.md Rewrite

Rewrite STATE.md completely with current state. Previous session content is not preserved — PLAN.md checkboxes and git history serve as the durable record.

**Key-value header:**
```
phase: [current phase from PLAN.md]
status: [precise completion level]
next_action: [numbered, actionable next steps]
blocked: [no, or yes — specific reason]
branch: [current git branch]
last_updated: [current ISO 8601 timestamp]
```

**Active Contract section:**
One paragraph covering what is being built, why, and the current approach. Written for a fresh agent that has never seen this project.

**Context for Fresh Agent section:**
Include everything a new agent needs to resume:
- Which phases are complete and key outcomes.
- Current phase status and what has been done.
- Any failed approaches and why they failed.
- Relevant file paths, test counts, metrics.
- User directives to carry forward.
- Branch state and any pending PRs.

### 4. Quality Criteria

The handoff is complete when a hypothetical fresh agent reading only CLAUDE.md, PLAN.md, and STATE.md could:
- Identify exactly where work left off.
- Understand what to do next without asking.
- Know about any blockers, warnings, or context that affects the next session.
- Resume mid-item if work was interrupted partway.

### 5. Confirmation

After writing STATE.md:
- Display a summary of the handoff state.
- Note the next action for the following session.
- Confirm STATE.md timestamp is fresh (satisfies the stop hook, ADR-0004).

## Common Pitfalls

- **Vague next_action:** "Continue working" is useless. Write specific steps: "1) Run test suite. 2) Fix failing assertion in test_parser.py. 3) Check off item 3.4."
- **Missing context:** Omitting a failed approach means the next session may retry it. Document what was tried and why it did not work.
- **Stale PLAN.md:** Writing a handoff without first updating PLAN.md checkboxes creates divergence. Always audit checkpoints first.
- **Forgetting directives:** If the user gave instructions to carry forward (e.g., "use library X, not Y"), include them in Context for Fresh Agent.
