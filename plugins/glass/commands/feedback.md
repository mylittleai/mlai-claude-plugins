---
description: Submit anonymized feedback about glass
allowed-tools: Bash, AskUserQuestion
---

# glass:feedback

Collect and submit anonymized feedback about the glass plugin.

## Process

1. Ask the user for their feedback. Prompt for:
   - **What happened?** (brief description)
   - **Category** (optional): bug, feature request, coaching gap, or other
2. Strip any project-identifying information from the feedback text. Do not include file paths, project names, or usernames.
3. Submit via Bash:
   ```
   gh issue create --repo renstroost/mlai-glass --title "<category>: <short summary>" --body "<feedback text>" --label feedback
   ```
4. Report the issue URL to the user on success.
5. If `gh` is not available or not authenticated, tell the user to install/authenticate the GitHub CLI: `gh auth login`.
