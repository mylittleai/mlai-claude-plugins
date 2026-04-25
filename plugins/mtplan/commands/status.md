---
description: Show the current plan and state, fix any checkbox drift
allowed-tools: Read, Edit, Bash
---

# mtplan:status

Display the full plan and current execution state. Also check for and fix any divergence between PLAN.md checkboxes and STATE.md status.

## Process

1. Read `docs/PLAN.md` and `docs/STATE.md`.
2. **Consistency check.** Compare STATE.md status and context against PLAN.md checkboxes:
   - If STATE.md says items are complete but PLAN.md still shows them as `- [ ]`, edit PLAN.md to check them off (`- [x]`).
   - Report any corrections inline: "Fixed checkbox drift: checked off items X, Y, Z."
3. Output PLAN.md content (with any corrections applied).
4. Output STATE.md header fields (phase, status, next_action, blocked, branch, last_updated).
5. **Refresh timestamp.** Run: `printf '<current STATE.md content with updated last_updated>' | mtplan write-state`
   This prevents the stop hook from triggering a save cycle after a read-only status check.
6. Stop. Do not offer next steps or ask what to do — the user asked to see the status, not for advice.
