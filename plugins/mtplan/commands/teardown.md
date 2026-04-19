---
description: Remove mtplan from a project (archives state files)
argument-hint: ""
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# Teardown

Remove the multiturn plan protocol, archiving state for future reference.

## Process

1. Verify mtplan is active: check for `docs/PLAN.md`, `docs/STATE.md`, bootstrap section in CLAUDE.md, or mtplan hooks in `.claude/settings.json`. If none exist: "mtplan is not active. Nothing to tear down."

2. Confirm with AskUserQuestion: "Archive PLAN.md and STATE.md, remove bootstrap from CLAUDE.md, remove hooks?"

3. Archive:
   ```
   mkdir -p docs/archive/mtplan
   ```
   Move `docs/PLAN.md` → `docs/archive/mtplan/PLAN-[YYYY-MM-DD].md` (use `git mv` if tracked).
   Move `docs/STATE.md` → `docs/archive/mtplan/STATE-[YYYY-MM-DD].md`.

4. Remove `## Context Persistence Protocol (MANDATORY)` section from CLAUDE.md. If CLAUDE.md is then empty, ask whether to delete it.

5. Remove mtplan hooks from `.claude/settings.json`. Identify entries by references to `check-state-freshness.sh`, `inject-state.sh`, `show-status.sh`. Preserve all other hooks. If a hook event array becomes empty after removal, remove the event key.

6. Display summary and remind: "History preserved in `docs/archive/mtplan/` and git."
