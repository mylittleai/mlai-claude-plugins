---
description: Health check all glass dependencies and configuration
allowed-tools: Bash
---

# glass:doctor

Run a health check on all glass dependencies and configuration.

## Process

1. Run `${CLAUDE_PLUGIN_ROOT}/bin/glass doctor` via Bash.
2. Present the results to the user.
3. For any failing checks, highlight the remediation hint.
4. If all checks pass, confirm the system is healthy and ready for browser observation.
