---
name: Replan — Restructure the Plan
description: >
  This skill should be used when the user invokes "/mtplan:replan", asks to
  "add a phase", "insert a remediation phase", "restructure the plan",
  "defer an item", "replan", "add parallel work", or wants to modify PLAN.md
  to add, restructure, or defer phases and items.
argument-hint: "[description of what changed or what to add]"
allowed-tools: ["Read", "Write", "Edit", "AskUserQuestion"]
version: 0.1.0
---

# Replan — Restructure the Plan

Modify PLAN.md using safe insertion patterns (ADR-0008). Validate dependency safety and create a replan record.

## Process

### 1. Read Current State

Read `docs/PLAN.md` and `docs/STATE.md` to understand:
- All existing phases and their completion state
- Which phase is currently in progress
- Any existing Deferred Decisions

### 2. Identify the Insertion Pattern

Based on the user's request, determine which pattern applies:

**Linear insertion** — A new phase between a completed and not-yet-started phase.
```
Before:  Phase 2 (done) → Phase 3 (not started)
After:   Phase 2 (done) → Phase 2.5 (new) → Phase 3 (not started)
```
Use when: Remediation or prerequisite work discovered after a phase completes.

**Fan-out insertion** — New phases parallel to a running phase.
```
Before:  Phase 3 (done) → Phase 4 (running)
After:   Phase 3 (done) → Phase 4 (running)
                         → Phase 4.5 (new, parallel)
```
Use when: New work discovered that does not block the current phase.

**Item deferral** — Mark an item as pending with a blocker note.
```
- [ ] Item 5 — **Deferred:** requires user input on preferred method
```
Use when: A specific item within a phase cannot proceed but the rest of the phase can.

### 3. Dependency Safety Check

**Critical rule:** If a new phase is inserted as a dependency of Phase X, verify Phase X has NOT started execution.

Check STATE.md: is the target downstream phase marked as in-progress? If so:
- Warn the user: "Phase [X] is already in progress. Inserting a blocker will require pausing it."
- Suggest alternatives: restructure as fan-out (parallel) instead of linear (blocking).
- Proceed only with explicit user confirmation.

### 4. Apply the Change to PLAN.md

Insert the new phase or defer the item. Follow monotonic growth rules (ADR-0009):
- Never delete existing phases.
- Never uncheck completed items.
- If renumbering, annotate: "Phase 9 (was Phase 10)".
- Number new phases with decimal notation: Phase 2.5, Phase 8.5, Phase 9.5M.

### 5. Optional: Pre-Work Contract

Offer to create a pre-work contract for the new phase (ADR-0010):
- Target: What this phase aims to achieve.
- Acceptance criteria: Specific "done" conditions.
- Budget: Resource limits if applicable.

Include only if the user opts in — do not require it.

### 6. Update STATE.md

Update STATE.md to reflect the new plan structure:
- If the current phase changed, update `phase` field.
- Update `next_action` if affected.
- Update `last_updated` timestamp.
- Add note to Context for Fresh Agent about the replan.

### 7. Create Replan Record

Create a replan record in `docs/replans/` (auto-created):

```markdown
# Replan: [Phase N.M] — [Short description]

**Date:** [YYYY-MM-DD]
**Trigger:** [What observation or failure prompted this replan]

## Dependency graph before

Phase A (done) → Phase B (status) → Phase C (status)

## Dependency graph after

Phase A (done) → Phase B (status) → Phase B.5 (new) → Phase C (status)

## Items added

- [ ] B.5.1 Description
- [ ] B.5.2 Description

## Risk assessment

- [Assessment of impact on in-progress work]
```

### 8. Validation

After applying changes, verify:
- Every phase (except the first) has a clear dependency path.
- No `[x]` checkboxes were changed to `[ ]`.
- No phases were deleted.
- STATE.md references point to valid phase numbers.

## Additional Resources

For detailed format specifications, consult `references/state-format.md` in the protocol skill.
