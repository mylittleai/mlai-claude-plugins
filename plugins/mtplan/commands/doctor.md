---
description: Diagnose and repair mtplan state issues
argument-hint: "[--check-only]"
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion, Grep, Glob
---

# Doctor

Diagnose mtplan health and fix issues. Be concise — report what was fixed and what needs the user's attention. Do not explain implementation details, internal version numbers, cache paths, or hook mechanics.

## Tone

Write like `brew doctor` — short, actionable, no jargon. Say what's wrong and what was done about it. Example:

- Good: "Removed stale hooks from settings.json — plugin handles these now."
- Bad: "Orphaned hooks in .claude/settings.json point to 0.1.0-alpha.3 cache which no longer exists on disk. The plugin's hooks.json (alpha.5) now uses ${CLAUDE_PLUGIN_ROOT}..."

## Modes

If $ARGUMENTS contains `--check-only`, report findings but do not modify files. Otherwise fix safe issues automatically and ask about anything that requires judgment.

## Before Starting

Update STATE.md `last_updated` timestamp to now. This prevents the stop hook from blocking during the doctor session itself.

## Checks and Repairs

Run all checks, collect results, then present a single summary. Do not stream findings one at a time.

### 1. File Existence

- Verify `docs/PLAN.md` and `docs/STATE.md` exist.
- If STATE.md missing but PLAN.md exists: create STATE.md from PLAN.md (infer phase from first unchecked item).
- If PLAN.md missing: report and stop.

### 2. Checkpoint Drift

- Compare STATE.md `phase` and `status` against PLAN.md checkboxes.
- If STATE.md is behind PLAN.md: update STATE.md to match.
- If PLAN.md is behind STATE.md: check off the item in PLAN.md.

### 3. STATE.md Format

- Verify structured header fields exist: `phase`, `status`, `next_action`, `blocked`, `branch`, `last_updated`.
- If any missing: add with sensible defaults inferred from PLAN.md.

### 4. CLAUDE.md Bootstrap

- Check if CLAUDE.md contains `## Context Persistence Protocol (MANDATORY)`.
- If missing: append the bootstrap template.
- If present but outdated (missing replan section, missing command reference, missing CRITICAL checkpoint): ask if user wants the bootstrap updated to the current template.

### 5. Stale Hook Wiring

- Check `.claude/settings.json` for mtplan hook references (paths containing `check-state-freshness.sh`, `inject-state.sh`, `show-status.sh`).
- If found: remove them silently. The plugin handles hooks automatically.

### 6. Monotonicity and Numbering

- Check for items out of order, missing phase references, deleted phases.
- Report only — these require human judgment.

### 7. Telemetry

- If `docs/.mtplan-telemetry` exists: summarize (sessions, prompts, max state age in human-readable time).

## Output Format

Present results in a single block. Use human-readable time (e.g., "2 hours" not "7948s"). Keep it short.

```
## Doctor

### Fixed
- [one line per fix]

### Needs Attention
- [one line per issue needing user judgment]

### Healthy
[one line summary: "Plan, state, and bootstrap are consistent. N phases, M items."]
```

If everything is healthy: "All clear. N phases, M items, state is current."
