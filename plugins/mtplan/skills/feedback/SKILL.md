---
name: Submit Protocol Feedback
description: >
  This skill should be used when the user invokes "/mtplan:feedback", asks to
  "report a problem with mtplan", "give feedback on the protocol", "suggest an
  improvement to mtplan", "file an issue with the plan management", or wants to
  share their experience using the multiturn plan protocol.
argument-hint: "[feedback description]"
allowed-tools: ["Read", "Bash", "AskUserQuestion"]
version: 0.1.0
---

# Submit Protocol Feedback

Collect user feedback about the mtplan protocol and file it as a GitHub issue on the mlai-mtplan repository. User confidentiality is the top priority (ADR-0013).

## Privacy Guarantees

Communicate these guarantees to the user before collecting feedback:

1. **Default anonymous:** All identifying information is stripped — project names, file paths, usernames, repository URLs, internal terminology.
2. **You review before send:** The exact issue body is shown for review and editing before submission. Nothing is sent without explicit approval.
3. **Opt-in detail sharing:** Structural context (e.g., "10-phase plan, Phase 3 affected") can be included only if the user explicitly opts in.
4. **Never automatic:** Specific content (file contents, plan text, business logic) is never included automatically.

## Process

### 1. Collect Feedback

If the user provided feedback as an argument, use it. Otherwise, ask:

"What feedback do you have about the mtplan protocol? This could be a bug, a suggestion, something that worked well, or something that was confusing."

### 2. Classify the Feedback

Determine the feedback type:
- **Bug:** Something that did not work as expected.
- **Improvement:** A suggestion for making the protocol better.
- **Positive:** Something that worked well (important for knowing what to preserve).
- **Question:** Confusion about how something works.

### 3. Ask About Detail Sharing

Ask the user using AskUserQuestion:

"Would you like to include structural context about your project? This helps us understand the conditions under which the issue occurred."

Options:
- **Abstract only (default):** "Only include protocol-level observations (e.g., 'checkpoint drift after compaction with 6+ batched updates')."
- **Include structural context:** "Include anonymous structural details (e.g., '10-phase plan, Phase 3 affected, ~50 items total')."

### 4. Draft the Issue

Create the issue body with the following structure:

```markdown
## Feedback Type
[Bug / Improvement / Positive / Question]

## Description
[User's feedback, anonymized]

## Context (if opted in)
- Plan complexity: [X phases, ~Y items]
- Phase affected: [phase number, no name]
- Protocol component: [checkpoint / replan / save / teardown / bootstrap / hook]

## Environment
- Plugin version: [from plugin.json]
- Framework: [Claude Code / Codex / other]

---
*Submitted via `/mtplan:feedback`. User reviewed and approved this content before submission.*
```

### 5. Anonymization Checklist

Before showing the draft, verify removal of:
- [ ] Project names or descriptions
- [ ] File paths (except docs/PLAN.md and docs/STATE.md references)
- [ ] Usernames, email addresses, URLs
- [ ] Company or organization names
- [ ] Specific plan item content or phase names
- [ ] Business logic or domain-specific terminology
- [ ] Repository URLs (except mlai-mtplan itself)
- [ ] Any quoted code or configuration from the user's project

### 6. Show Before Send

Present the complete issue body to the user:

"Here is the issue that will be filed. Review it and let me know if you want to change anything before submission."

Allow the user to:
- Approve as-is
- Edit specific parts
- Add more context
- Cancel submission

### 7. Submit

Verify `gh` CLI is authenticated:
```bash
gh auth status
```

If not authenticated, guide the user: "The `gh` CLI needs to be authenticated. Run `! gh auth login` to authenticate."

File the issue:
```bash
gh issue create --repo mylittleai/mlai-claude-plugins --title "[mtplan] [Feedback] [short title]" --body "[approved body]" --label "user-feedback"
```

Note: If the label does not exist, omit it and create the issue without labels.

### 8. Confirm

Show the user the issue URL and thank them for the feedback.

## What NOT to Include

- Never include file contents from the user's project.
- Never include git log output or commit messages.
- Never include environment variables or API keys.
- Never include information the user did not explicitly approve.
- Never auto-submit without the show-before-send step.
