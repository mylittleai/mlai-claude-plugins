---
description: Show the current plan and state
allowed-tools: Read
---

# mtplan:status

Display the full plan and current execution state. Output the content directly — do not summarize, paraphrase, or ask follow-up questions.

## Process

1. Read `docs/PLAN.md` and output its full content.
2. Read `docs/STATE.md` and output the header fields (phase, status, next_action, blocked, branch, last_updated).
3. Stop. Do not offer next steps or ask what to do — the user asked to see the status, not for advice.
