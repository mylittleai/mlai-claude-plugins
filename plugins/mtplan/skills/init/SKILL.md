---
name: Initialize Multiturn Plan
description: >
  This skill should be used when the user invokes "/mtplan:init", asks to
  "set up multiturn", "initialize plan tracking", "create a PLAN.md and STATE.md",
  "set up context persistence", or wants to start using the multiturn plan
  protocol in their project.
argument-hint: "[optional: project description or first phase name]"
allowed-tools: ["Read", "Write", "Edit", "Bash", "AskUserQuestion"]
version: 0.1.0
---

# Initialize Multiturn Plan Protocol

Set up the Two-File Program Counter system in a project. This is an interactive process that scaffolds PLAN.md, STATE.md, CLAUDE.md bootstrap, and hooks.

## Prerequisites Check

Before scaffolding, verify:

1. Read the project's existing CLAUDE.md (if any) to avoid overwriting user content.
2. Check whether `docs/PLAN.md` or `docs/STATE.md` already exist. If they do, warn the user and ask whether to overwrite or abort.
3. Check whether `.claude/settings.json` exists (hooks may need to be merged, not replaced).

## Interactive Setup

If the user provided a project description or phase name as an argument, use it. Otherwise, ask the following questions using AskUserQuestion:

1. **Project description:** "What is this project about? (One sentence for the Active Contract in STATE.md)"
2. **First phase:** "What is the first phase of work? (e.g., 'Initial setup', 'Data migration', 'API integration')"
3. **Phase items:** "What are the items in this first phase? (List the work to be done)"

Use the answers to populate the templates below.

## Files to Create

### 1. docs/PLAN.md

Create using the plan template from `references/state-format.md` in the protocol skill. Populate with the user's first phase and items. Include the Deferred Decisions section.

```markdown
# Plan

## Phase 1: [User's Phase Name]

- [ ] [Item 1 from user]
- [ ] [Item 2 from user]
- [ ] [Item 3 from user]

## Deferred Decisions

(Observations to triage at the next phase transition.)
```

### 2. docs/STATE.md

Create using the structured key-value format (ADR-0006):

```
phase: Phase 1 — [User's Phase Name]
status: not started
next_action: 1) Begin Phase 1, Item 1: [description]
blocked: no
branch: [current git branch, detect with git]
last_updated: [current ISO 8601 timestamp]

## Active Contract
[User's project description]. Currently in Phase 1: [phase name].

## Context for Fresh Agent
Project initialized with multiturn plan protocol. Phase 1 defined with [N] items.
No work completed yet.
```

### 3. CLAUDE.md Bootstrap Addition

Append the bootstrap protocol to the project's CLAUDE.md. If CLAUDE.md does not exist, create it. If it exists, append to it — never overwrite existing content.

The bootstrap snippet to add:

```markdown
## Context Persistence Protocol (MANDATORY)

### On every session start and after every context compaction

BEFORE doing any other work:

1. Read `docs/PLAN.md` — this is the program. Identify the current phase and first unchecked item.
2. Read `docs/STATE.md` — this is the program counter. It tells you what was in progress and any partial-completion context.
3. **Do not proceed until you have verified state from disk.** Never assume prior context survived.

### Checkpoint discipline (atomic updates)

- **PLAN.md:** Check off each item immediately upon completion, in the same logical step as the work. Never batch multiple checkbox updates.
- **STATE.md:** Before starting an item, update "What's In Progress." After completing it, move to "What's Done." Update in the same commit as PLAN.md.
- **Bias early:** Any progress not on disk is lost on compaction. Write state before the work is perfect, not after.

### Phase boundaries

When all items in a phase are checked off:
1. Enter plan mode for the next phase.
2. Triage Deferred Decisions — incorporate relevant items or discard.
3. Get plan approved, then execute autonomously.
4. Do NOT ask "what should I do?" — the plan IS the direction.

### Before ending a session

Update `docs/STATE.md` with: current phase, status, next action, and context for a fresh agent.
```

### 4. Stop Hook

Create `.claude/hooks/check-state-freshness.sh` with the blocking stop hook script. Wire it into `.claude/settings.json` under the Stop event. Also add SessionStart, PreCompact, and UserPromptSubmit hooks.

The hook scripts are available at `${CLAUDE_PLUGIN_ROOT}/hooks/scripts/check-state-freshness.sh`. Copy them to the project's `.claude/hooks/` directory for portability, or reference them via the plugin path.

For the settings.json hooks configuration, merge with existing settings rather than overwriting. Read the existing file first, add the mtplan hooks, and write back.

## Post-Setup Verification

After creating all files:

1. Confirm all files were created successfully.
2. Display a summary: "Initialized mtplan protocol with Phase 1: [name] ([N] items)."
3. Remind the user: "The bootstrap protocol is in CLAUDE.md. On your next session start, the agent will automatically read PLAN.md and STATE.md before doing any work."
4. Suggest: "Run `/mtplan:checkpoint` after completing each item to maintain state."

## What NOT to Do

- Do not create observation-propagation rules (project-specific).
- Do not define phase content beyond what the user specified.
- Do not set up memory files (separate system).
- Do not assume project structure beyond `docs/PLAN.md` and `docs/STATE.md`.
