---
name: Teardown Multiturn Plan
description: >
  This skill should be used when the user invokes "/mtplan:teardown", asks to
  "stop using mtplan", "remove plan tracking", "teardown the plan protocol",
  "decommission mtplan", or wants to stop using the multiturn plan protocol
  in their project.
argument-hint: ""
allowed-tools: ["Read", "Write", "Edit", "Bash", "AskUserQuestion"]
version: 0.1.0
---

# Teardown Multiturn Plan Protocol

Remove the Two-File Program Counter system from a project, archiving state files for future reference.

## Process

### 1. Verify mtplan Is Active

Check that the protocol is currently set up:
- `docs/PLAN.md` exists
- `docs/STATE.md` exists
- CLAUDE.md contains the "Context Persistence Protocol (MANDATORY)" section

If none of these exist: "mtplan is not active in this project. Nothing to tear down."

### 2. Confirm With User

Ask the user using AskUserQuestion:

"This will archive PLAN.md and STATE.md, remove the protocol section from CLAUDE.md, and remove mtplan hooks. Proceed?"

Options:
- **Yes, tear down:** "Archive state files and remove protocol integration."
- **Cancel:** "Keep everything as-is."

Do not proceed without explicit confirmation.

### 3. Archive PLAN.md and STATE.md

Create the archive directory and move both files with a date suffix:

```bash
mkdir -p docs/archive/mtplan
```

Move files with ISO 8601 date suffix:
- `docs/PLAN.md` → `docs/archive/mtplan/PLAN-[YYYY-MM-DD].md`
- `docs/STATE.md` → `docs/archive/mtplan/STATE-[YYYY-MM-DD].md`

Use `git mv` if the files are tracked, plain `mv` otherwise.

If an archive with the same date already exists, append a sequence number (e.g., `PLAN-2026-04-19-2.md`).

### 4. Remove CLAUDE.md Bootstrap Section

Read the project's CLAUDE.md and remove the section starting with `## Context Persistence Protocol (MANDATORY)` through to the next `##` heading or end of file.

If CLAUDE.md contains only the bootstrap section (nothing else meaningful), ask the user whether to delete the file entirely or leave it empty.

### 5. Remove Hook Wiring

Read `.claude/settings.json` and remove mtplan hook entries. These are identifiable by references to:
- `check-state-freshness.sh`
- `inject-state.sh`
- `show-status.sh`

Remove only the mtplan entries — preserve any other hooks the user has configured.

If the hooks array for an event becomes empty after removal, remove the event key entirely.

### 6. Remove Copied Hook Scripts

If init copied hook scripts to `.claude/hooks/`, remove them:
- `.claude/hooks/check-state-freshness.sh`
- `.claude/hooks/inject-state.sh`
- `.claude/hooks/show-status.sh`

If `.claude/hooks/` is empty after removal, remove the directory.

### 7. Confirmation

Display a summary:
- "Archived PLAN.md and STATE.md to `docs/archive/mtplan/`"
- "Removed protocol section from CLAUDE.md"
- "Removed mtplan hooks from `.claude/settings.json`"
- "Removed hook scripts from `.claude/hooks/`" (if applicable)

Remind the user: "Your plan history is preserved in `docs/archive/mtplan/` and in git history."

## Error Conditions

- If `docs/PLAN.md` does not exist: Skip archiving, warn "No PLAN.md found."
- If `docs/STATE.md` does not exist: Skip archiving, warn "No STATE.md found."
- If CLAUDE.md does not contain the bootstrap section: Skip removal, warn "No protocol section found in CLAUDE.md."
- If `.claude/settings.json` does not exist or has no mtplan hooks: Skip hook removal, warn "No mtplan hooks found."
