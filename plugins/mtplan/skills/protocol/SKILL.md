---
name: protocol
description: >
  This skill should be used when the user asks about "context management",
  "multiturn sessions", "context compaction", "plan persistence", "state recovery",
  "session save", "checkpoint discipline", "two-file program counter",
  or discusses maintaining state across Claude Code sessions. Also triggers when
  the user references PLAN.md, STATE.md, or bootstrap protocols in the context
  of multi-session work.
version: 0.1.0
---

# Multiturn Plan Context Management Protocol

A battle-tested protocol for maintaining coherent state across agentic sessions and context compactions in multi-phase projects.

## Core Problem

Agentic coding assistants lose conversational state when their context window compacts mid-session or between sessions. Without a recovery protocol, three failure modes emerge:

1. **Re-work.** The agent repeats completed items because it cannot tell they are done.
2. **Direction-seeking.** The agent stops and asks "what should I do?" instead of following the plan.
3. **Drift.** The agent's understanding of progress diverges from reality, compounding over time.

This protocol eliminates all three by making plan and execution state fully disk-based. Nothing depends on the agent "remembering" anything.

## The Two-File Program Counter

Two files with distinct roles (see ADR-0001):

### docs/PLAN.md — The Program

Defines what work exists, its structure, and completion state.

- Phase definitions with descriptive headers
- Checkbox items within each phase (`- [x]` done, `- [ ]` pending)
- Deferred Decisions section for observations to triage at phase boundaries
- Grows monotonically — phases and checked items are never deleted (ADR-0009)

### docs/STATE.md — The Program Counter

Tracks current execution position using structured key-value format (ADR-0006):

```
phase: [current phase name]
status: [completion level]
next_action: [numbered next steps]
blocked: [yes/no + reason]
branch: [git branch]
last_updated: [ISO 8601 timestamp]
```

Followed by narrative sections: Active Contract, Context for Fresh Agent.

Fully rewritten at session boundaries. Content from previous sessions is not preserved — it is already captured in PLAN.md checkboxes and git history.

## Bootstrap Protocol (ADR-0003)

CLAUDE.md is the only artifact unconditionally loaded at session start and after compaction. The restore protocol MUST live there.

On every session start and after every context compaction, BEFORE any other work:

1. Read `docs/PLAN.md` — identify current phase and first unchecked item.
2. Read `docs/STATE.md` — determine what was in progress and any resume context.
3. Do not proceed until state is verified from disk. Never assume prior context survived.

## Checkpoint Discipline (ADR-0002)

The single most important rule: **check off each PLAN.md item immediately upon completion, in the same logical step as the work. Never batch.**

- Completing item 3.2 and about to start 3.3 → update PLAN.md first.
- Three items completed in rapid succession → three separate PLAN.md updates.
- **Bias-early principle:** Mark "in progress" before starting rather than "done" after finishing.

Update STATE.md in the same commit as PLAN.md changes to prevent divergence.

## Phase Execution Model (ADR-0007)

Plan approval = autonomous execution. When a phase plan is approved, execute all items without stopping for permission on each one.

**Phase transitions** trigger plan mode (not individual items). When all items in a phase are checked:
1. Enter plan mode for the next phase.
2. Triage Deferred Decisions — incorporate or discard.
3. Present plan, get approval, execute autonomously.

## Replanning (ADR-0008)

Three insertion patterns for modifying plans mid-project:

1. **Linear insertion** — New phase between completed and not-yet-started phases.
2. **Fan-out insertion** — New phases parallel to a running phase.
3. **Item deferral** — Pending item with explicit blocker note within a phase.

Critical safety rule: dependency changes must land in PLAN.md before any dependent phase starts executing.

## When to Use This Protocol

- Multi-phase projects spanning more than one session.
- Work where context compaction is likely (long autonomous runs, large codebases).
- Any project where resuming later without re-explaining state is valuable.

## When NOT to Use This Protocol

- Single-session tasks that complete in one sitting.
- Exploratory work without a defined plan (research, prototyping).
- Projects where maintaining two state files exceeds the value.

## Available Skills

- `/mtplan:init` — Set up the protocol for a new project (interactive).
- `/mtplan:checkpoint` — Mark plan items complete and update state.
- `/mtplan:replan` — Restructure the plan using safe insertion patterns.
- `/mtplan:save` — Update STATE.md for session end.
- `/mtplan:teardown` — Remove mtplan from a project (archives state files).
- `/mtplan:feedback` — Report feedback about this protocol.

## Additional Resources

### Reference Files

- **`references/failure-modes.md`** — Documented failure modes and mitigations from real projects.
- **`references/state-format.md`** — Detailed STATE.md and PLAN.md format specifications with examples.

### Design Decisions

All protocol design decisions are captured as ADRs in `docs/decisions/` of the mlai-mtplan repository.
