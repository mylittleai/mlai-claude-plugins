# glass

Browser observation, terminal interaction, and window orchestration for Claude Code. Give your agent eyes into the developer's workspace.

## What It Does

Glass coaches Claude to observe your running application through chrome-devtools MCP rather than relying on you to relay what's on screen. It handles configuration, window management, and teaches effective observation patterns.

- **Browser observation** — Screenshots, DOM snapshots, console logs, and network activity via chrome-devtools MCP.
- **Window orchestration** — Automated Chrome window positioning (macOS).
- **Coaching** — Auto-activating skill teaches Claude when to screenshot vs snapshot, how to compare images, and how to debug across browser and terminal.
- **Health checks** — Diagnose MCP connection, Chrome process, and configuration issues.

## Installation

```bash
claude plugin install glass
```

## Usage

### Setup

```
/glass:init
```

Install the chrome-devtools MCP configuration for your project. Idempotent. Restart Claude Code after running so the MCP tools become available.

### Health Check

```
/glass:doctor
```

Verify all dependencies and configuration are working. Reports remediation hints for any failing checks.

### Removal

```
/glass:teardown
```

Remove the chrome-devtools MCP configuration from the project.

### Feedback

```
/glass:feedback
```

Submit anonymized feedback. You review the exact issue before it's sent.

## Requirements

- Claude Code
- Google Chrome
- `gh` CLI (for feedback submission only)

## License

MIT

## Author

Rens Troost -- [MyLittle.AI](https://mylittle.ai)
Contact: rens@mylittle.ai
