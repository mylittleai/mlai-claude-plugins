# MyLittle.AI Claude Code Plugins

Small tools for large models. A curated collection of [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugins by [MyLittle.AI](https://mylittle.ai).

## Installation

Add the marketplace once:

```bash
claude plugin marketplace add mylittleai/mlai-claude-plugins
```

Then install any plugin:

```bash
claude plugin install mtplan
claude plugin install glass
```

## Plugins

| Plugin | Description |
|--------|-------------|
| [mtplan](plugins/mtplan/) | Multiturn plan and state management. Maintains coherent state across sessions and context compactions. |
| [glass](plugins/glass/) | Browser observation and window orchestration via Chrome DevTools. |

See each plugin's README for usage details.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT
