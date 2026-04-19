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
4. Draft issue body:

```markdown
## Type
[Bug / Improvement / Positive / Question]

## Description
[Anonymized feedback]

## Context (if opted in)
- Plan complexity: [X phases, ~Y items]
- Component: [checkpoint / replan / save / teardown / bootstrap / hook]

## Environment
- Plugin version: [from plugin.json]
---
*Submitted via `/mtplan:feedback`. User approved before submission.*
```

5. Anonymization check: remove project names, paths, usernames, company names, item content, repo URLs, code quotes.
6. Show draft. Allow approve, edit, or cancel.
7. Submit: `gh issue create --repo mylittleai/mlai-claude-plugins --title "[mtplan] [Type] [short title]" --body "[body]"`
8. Show issue URL.
