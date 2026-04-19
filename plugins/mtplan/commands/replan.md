---
description: Restructure the plan using safe insertion patterns
argument-hint: "[what changed or what to add]"
allowed-tools: Read, Write, Edit, AskUserQuestion
---

# Replan

Modify PLAN.md using safe insertion patterns (ADR-0008). Validate dependencies and update STATE.md.

## Insertion Patterns

**Linear** — new phase between completed and not-started phases. Use decimal numbering (Phase 2.5).

**Fan-out** — new phase parallel to a running phase. Does not block current work.

**Item deferral** — mark item as `- [ ] Item — **Deferred:** [reason]`.

## Process

1. Read `docs/PLAN.md` and `docs/STATE.md`.
2. Identify which insertion pattern applies.
3. **Dependency check:** if inserting a blocker for an in-progress phase, warn the user and suggest fan-out instead. Proceed only with explicit confirmation.
4. Apply changes. Follow monotonic growth rules (ADR-0009): never delete phases, never uncheck items, use decimal numbering for inserts.
5. Update STATE.md: `phase`, `next_action`, `last_updated`, Context for Fresh Agent.
6. Create replan record in `docs/replans/`:

```markdown
# Replan: [Phase N.M] — [Short description]
Date: [YYYY-MM-DD]
Trigger: [what prompted this]

## Before
[dependency graph]

## After
[dependency graph with insertion]

## Items added
- [ ] [new items]
```

7. Validate: every phase has a dependency path, no checkboxes were unchecked, STATE.md references are valid.
