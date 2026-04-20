---
description: Set up multiturn plan tracking in a project (interactive)
argument-hint: "[project description or first phase name]"
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# Initialize Multiturn Plan Protocol

Scaffold PLAN.md, STATE.md, CLAUDE.md bootstrap, and project-level hooks.

## Prerequisites

1. Read existing CLAUDE.md (if any) to avoid overwriting.
2. Check whether `docs/PLAN.md` or `docs/STATE.md` already exist. Warn and ask before overwriting.

## Interactive Setup

If the user provided a description or phase name as $ARGUMENTS, use it. Otherwise ask using AskUserQuestion:

1. **Project description:** one sentence for the Active Contract in STATE.md.
2. **Project scope:** "How many phases do you see? Name them." Get at least phase names for the full project — later phases can be sparse.
3. **First phase items:** list of items in the first phase. For later phases, accept whatever level of detail the user provides (full items, rough bullets, or just the phase name).

## Files to Create

### docs/PLAN.md

Scaffold ALL phases the user named. The first phase gets full items. Later phases get whatever detail the user provided — items if given, otherwise just the phase header with a precondition or scope note.

```markdown
# Plan

## Phase 1: [First Phase Name]

- [ ] 1.1 [Item 1]
- [ ] 1.2 [Item 2]
- [ ] 1.3 [Item 3]

## Phase 2: [Second Phase Name]

Precondition: [if any].

- [ ] 2.1 [Item or placeholder from user input]

## Phase N: [Nth Phase Name]

Not fully scoped. Triage at Phase N-1 boundary.

- [ ] N.1 [Item if provided]

## Deferred Decisions

(Observations to triage at the next phase transition.)
```

### docs/STATE.md

Structured key-value format (ADR-0006):

```
phase: Phase 1 — [User's Phase Name]
status: not started
next_action: Begin Phase 1, Item 1: [description]
blocked: no
branch: [current git branch]
last_updated: [ISO 8601 timestamp]

## Active Contract
[Project description]. Currently in Phase 1: [phase name].

## Context for Fresh Agent
Project initialized with multiturn plan protocol. Phase 1 defined with [N] items.
No work completed yet.
```

### CLAUDE.md Bootstrap

Append to existing CLAUDE.md (create if missing, never overwrite):

```markdown
## Context Persistence Protocol (MANDATORY)

### On every session start and after every context compaction

BEFORE doing any other work:

1. Read `docs/PLAN.md` — identify current phase and first unchecked item.
2. Read `docs/STATE.md` — resume from where the last session left off.
3. **Do not proceed until you have verified state from disk.**

### Checkpoint discipline (CRITICAL)

After completing ANY plan item, IMMEDIATELY run `/mtplan:checkpoint`.

- One item per checkpoint. Never batch multiple items.
- Do not ask permission — the protocol requires immediate updates.
- Unwritten progress is lost on compaction. Bias early.
- During long research or exploration without item completions, update STATE.md with interim findings every ~10 minutes. A crash or compaction with stale state loses context.

### Phase boundaries

When all items in a phase are checked:
1. Enter plan mode for the next phase.
2. Triage Deferred Decisions.
3. Execute autonomously once approved.

### Changing the plan

Use `/mtplan:replan` to add phases, defer items, or restructure.
Never edit PLAN.md checkboxes or phase structure directly.

### Before ending a session

Run `/mtplan:save` to update STATE.md with current phase, status, next action, and context for a fresh agent.

### Available commands

- `/mtplan:checkpoint` — mark items complete (use after EVERY completed item)
- `/mtplan:replan` — restructure the plan safely
- `/mtplan:save` — update state before ending session
- `/mtplan:doctor` — diagnose and repair state issues
```

### Hooks

Hooks are registered globally via the plugin's `hooks/hooks.json` and fire automatically. They guard on `docs/PLAN.md` existence, so they are no-ops in non-initialized projects. No per-project hook wiring is needed.

## Post-Setup

1. Confirm all files created and hooks wired.
2. Display: "Initialized mtplan with Phase 1: [name] ([N] items). Checkpoints are automatic."

## Constraints

- Do not create observation-propagation rules.
- Do not invent phase items the user did not specify. For later phases where the user gave only a name, use just the phase header with a scope note.
- Do not assume project structure beyond `docs/`.
