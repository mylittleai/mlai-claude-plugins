---
description: Report feedback about the mtplan protocol
argument-hint: "[feedback description]"
allowed-tools: Read, Bash, AskUserQuestion
---

# Submit Feedback

Collect feedback and file as a GitHub issue on mlai-mtplan. User reviews before send (ADR-0013).

## Privacy

Tell the user before collecting:
- Default anonymous: project names, paths, usernames stripped.
- Full draft shown for review before submission.
- Structural context (plan size, phase numbers) only with opt-in.

## Process

1. Collect feedback from $ARGUMENTS or ask.
2. Classify: bug, improvement, positive, question.
3. Ask about structural context sharing (abstract only vs anonymous details).
4. If `docs/.mtplan-telemetry` exists, read it and compute summary statistics:
   - Session count (number of SessionStart entries)
   - Median and max STATE.md age at UserPromptSubmit (staleness indicator)
   - Stop events: allowed vs blocked count
   - Total prompts tracked
   Ask the user if they want to include these anonymized stats.
5. Draft issue body:

```markdown
## Type
[Bug / Improvement / Positive / Question]

## Description
[Anonymized feedback]

## Context (if opted in)
- Plan complexity: [X phases, ~Y items]
- Component: [checkpoint / replan / save / teardown / bootstrap / hook]

## Telemetry (if opted in)
- Sessions: [N]
- Prompts tracked: [N]
- STATE.md age at prompt: median [X]s, max [Y]s
- Stop: [N] allowed, [M] blocked

## Environment
- Plugin version: [from plugin.json]
---
*Submitted via `/mtplan:feedback`. User approved before submission.*
```

6. Anonymization check: remove project names, paths, usernames, company names, item content, repo URLs, code quotes. Telemetry stats are already anonymous (counts and durations only).
7. Show draft. Allow approve, edit, or cancel.
8. Submit: `gh issue create --repo mylittleai/mlai-claude-plugins --title "[mtplan] [Type] [short title]" --body "[body]"`
9. Show issue URL.
