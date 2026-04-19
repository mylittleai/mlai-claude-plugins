# State File Format Specifications

## docs/PLAN.md Format

### Structure

```markdown
# Plan

## Phase 1: [Phase Name]

- [x] Item 1 description
- [x] Item 2 description
- [ ] Item 3 description

## Phase 2: [Phase Name]

- [ ] Item 1 description
- [ ] Item 2 description

## Deferred Decisions

(Observations to triage at the next phase transition.)
- Observation about X — noticed during Phase 1, Item 2
- ~~Observation about Y~~ → RESOLVED (Phase 1): Not applicable because Z
```

### Rules

- Phases are never deleted. Completed phases serve as audit trail.
- Items are never unchecked. If work needs revisiting, create a new item.
- Phase renumbering must annotate old number: "Phase 9 (was Phase 10)".
- Deferred Decisions are struck through when resolved, not deleted.

### Optional Pre-Work Contract

When formal acceptance criteria benefit the phase:

```markdown
## Phase 3: [Phase Name]

Pre-work contract:
target: [what this phase aims to achieve]
acceptance: [specific criteria for "done"]
budget: [resource limits if applicable]

- [ ] Item 1
- [ ] Item 2
```

## docs/STATE.md Format

### Key-Value Header

```
phase: Implementation — search failure handling
status: implemented and tested, not yet committed
next_action: 1) Commit changes. 2) Run test suite. 3) Update PLAN.md.
blocked: no
branch: feature/search-handling
last_updated: 2026-04-18T14:30Z
```

**Required fields:**
- `phase` — Current phase name (must match a phase header in PLAN.md)
- `status` — Free-text completion level
- `next_action` — Numbered next steps (actionable, specific)
- `blocked` — `no` or `yes — [reason]`
- `branch` — Current git branch
- `last_updated` — ISO 8601 timestamp (used by freshness hook)

### Narrative Sections

```markdown
## Active Contract
Executive summary of current work. One paragraph covering what is being built,
why, and the current approach.

## Context for Fresh Agent
Full history needed to resume without exploring git:
- What phases are complete and their key outcomes
- What the current phase is doing
- Any failed approaches and why they failed
- Relevant file paths, test counts, or metrics
- User directives to carry forward
```

### Session-End Full Rewrite

At session end, STATE.md gets a complete rewrite covering:
1. Updated key-value header with current timestamp
2. What was accomplished this session
3. What is in progress (with enough detail to resume mid-item)
4. What comes next
5. Any volatile context (test results, branch state, warnings)

Previous session content is not preserved — it is captured in PLAN.md checkboxes and git history.

## How the Files Work Together

| Question | Source |
|----------|--------|
| What phases exist? | PLAN.md |
| Which items are done? | PLAN.md checkboxes |
| What is being worked on right now? | STATE.md `status` + Active Contract |
| What context is needed to resume? | STATE.md Context for Fresh Agent |
| What should happen next? | STATE.md `next_action` + PLAN.md first unchecked item |
| What happened in the last session? | STATE.md narrative sections |
| What observations are pending triage? | PLAN.md Deferred Decisions |
