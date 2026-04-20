---
description: Remove mtplan from a project (archives state files)
argument-hint: ""
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# Teardown

Remove the multiturn plan protocol, archiving state for future reference.

## Process

1. Verify mtplan is active: check for `docs/PLAN.md`, `docs/STATE.md`, or bootstrap section in CLAUDE.md. If none exist: "mtplan is not active. Nothing to tear down."

2. Ask with AskUserQuestion: "Archive or discard?" with options:
   - **Archive** — move files to `docs/archive/mtplan/`, preserve history
   - **Discard** — delete files, no archive

3. If Archive:
   ```
   mkdir -p docs/archive/mtplan
   ```
   Move `docs/PLAN.md` → `docs/archive/mtplan/PLAN-[YYYY-MM-DD].md` (use `git mv` if tracked).
   Move `docs/STATE.md` → `docs/archive/mtplan/STATE-[YYYY-MM-DD].md`.

   If Discard: delete `docs/PLAN.md` and `docs/STATE.md`.

4. Remove `## Context Persistence Protocol (MANDATORY)` section and everything below it from CLAUDE.md. If CLAUDE.md is then empty, ask whether to delete it.

5. Display summary. Hooks are global (via plugin hooks.json) and guard on file existence — they become no-ops automatically when PLAN.md is removed.
