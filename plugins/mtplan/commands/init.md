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
3. Read `.claude/settings.json` if it exists (hooks must be merged, not replaced).

## Interactive Setup

If the user provided a description or phase name as $ARGUMENTS, use it. Otherwise ask using AskUserQuestion:

1. **Project description:** one sentence for the Active Contract in STATE.md.
2. **First phase:** name of the first phase of work.
3. **Phase items:** list of items in the first phase.

## Files to Create

### docs/PLAN.md

```markdown
# Plan

## Phase 1: [User's Phase Name]

- [ ] [Item 1]
- [ ] [Item 2]
- [ ] [Item 3]

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

### Checkpoint discipline

- Check off PLAN.md items immediately upon completion. Never batch.
- Update STATE.md before and after each item.
- Bias early: unwritten progress is lost on compaction.

### Phase boundaries

When all items in a phase are checked:
1. Enter plan mode for the next phase.
2. Triage Deferred Decisions.
3. Execute autonomously once approved.

### Before ending a session

Update STATE.md with: current phase, status, next action, context for a fresh agent.
```

### .claude/settings.json — Hook Wiring

Read the existing `.claude/settings.json` (create if missing). Merge the following hooks into it, preserving any existing hooks the user has:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/check-state-freshness.sh",
            "timeout": 10
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/inject-state.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/inject-state.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/show-status.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

If `.claude/settings.json` already has hooks for the same events, append the mtplan entries to the existing arrays — do not replace them.

## Post-Setup

1. Confirm all files created and hooks wired.
2. Display: "Initialized mtplan with Phase 1: [name] ([N] items)."
3. Suggest: "Use `/mtplan:checkpoint` after completing each item."

## Constraints

- Do not create observation-propagation rules.
- Do not define phase content beyond what the user specified.
- Do not assume project structure beyond `docs/`.
