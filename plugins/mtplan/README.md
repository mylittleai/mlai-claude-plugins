# mtplan

Multiturn plan and state management for Claude Code. Implements the Two-File Program Counter pattern for maintaining coherent state across sessions and context compactions.

## What It Does

When working on multi-phase projects, agentic assistants lose state when their context window compacts or between sessions. This plugin provides:

- **Automatic state recovery** — Bootstrap protocol restores plan and execution state on every session start.
- **Atomic checkpoint discipline** — Enforces immediate plan updates to prevent drift.
- **Safe replanning** — Structured patterns for modifying plans mid-project.
- **Session save** — Clean state serialization for session boundaries.
- **Blocking safety net** — Stop hook prevents session end with stale state.
- **Confidential feedback** — Report issues without exposing project details.

## Installation

```bash
claude plugin install mtplan
```

## Usage

### Getting Started

```
/mtplan:init
```

Interactive setup that creates `docs/PLAN.md`, `docs/STATE.md`, adds the bootstrap protocol to CLAUDE.md, and configures hooks.

### During Work

```
/mtplan:checkpoint
```

Mark plan items complete and update state. Enforces atomic discipline — one item at a time.

### Restructuring the Plan

```
/mtplan:replan
```

Add phases, defer items, or restructure using safe insertion patterns with dependency validation.

### Diagnosing Issues

```
/mtplan:doctor
```

Check plan/state health and repair common problems. Concise output in the style of `brew doctor`.

### Ending a Session

```
/mtplan:save
```

Full STATE.md rewrite with everything a fresh agent needs to resume.

### Removing mtplan

```
/mtplan:teardown
```

Archive or discard PLAN.md and STATE.md, remove protocol integration from CLAUDE.md and hooks.

### Reporting Feedback

```
/mtplan:feedback
```

Submit anonymized feedback. You review the exact issue before it's sent.

## How It Works

The protocol uses two files:

- **`docs/PLAN.md`** — The program. Defines phases, items, and completion state via checkboxes. Grows monotonically.
- **`docs/STATE.md`** — The program counter. Tracks current execution position. Fully rewritten at session boundaries.

CLAUDE.md contains a mandatory bootstrap protocol that reads both files on every session start and after every context compaction.

Three hooks provide defense in depth:
- **Stop** — Blocks session end if STATE.md is stale and work remains.
- **SessionStart** — Re-injects state on resume/compact/clear events.
- **UserPromptSubmit** — Displays current phase/status on every prompt.

## Design Decisions

All protocol decisions are documented as ADRs in `docs/decisions/`:

| ADR | Decision |
|-----|----------|
| 0001 | Two-File Program Counter |
| 0002 | Atomic Checkpoint Discipline |
| 0003 | CLAUDE.md as Bootstrap Anchor |
| 0004 | Blocking Stop Hook |
| 0005 | SessionStart State Injection |
| 0006 | Structured Key-Value STATE.md Format |
| 0007 | Phase Execution Model |
| 0008 | Replanning Insertion Patterns |
| 0009 | Monotonic Plan Growth |
| 0010 | Pre-Work Contracts (Optional) |
| 0011 | Tasks Tool Demotion |
| 0012 | Deferred Decisions Section |
| 0013 | Feedback with User Confidentiality |

## Requirements

- Claude Code (or compatible agentic framework)
- `gh` CLI (for feedback submission only)

## License

MIT

## Author

Rens Troost — [MyLittle.AI](https://mylittle.ai)
Contact: rens@mylittle.ai
