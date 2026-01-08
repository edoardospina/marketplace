# Edinho's Claude Code Plugin Marketplace

A curated collection of Claude Code plugins for enhanced development workflows.

## About This Marketplace

This marketplace provides custom plugins for [Claude Code](https://claude.com/claude-code) that extend its capabilities with specialized commands, agents, and skills.

## Installation

To install plugins from this marketplace in Claude Code:

```bash
claude-code plugin install https://github.com/yourusername/marketplace
```

Once installed, plugins will automatically update when you push changes to this repository.

## Available Plugins

See **marketplace.json** for [available plugins →](./.claude-plugin/marketplace.json)

## Work In Progress

We are working on **multiple new plugins** and our github repo tracks them in [our .wip folder →](./.wip/)

## Plugin Structure

Each plugin in this marketplace follows the standard Claude Code plugin structure:

```
plugin-name/
├── .claude-plugin/
│   ├── plugin.json          # Plugin manifest
│   ├── commands/            # Slash commands (optional)
│   ├── agents/              # Autonomous agents (optional)
│   ├── skills/              # Reusable prompts (optional)
│   ├── .mcp.json            # MCP servers connections (optional)
│   └── hooks/               # Event hooks (optional)
├── README.md                # Plugin documentation
└── LICENSE                  # MIT License
```

## Development

### Adding a New Plugin

1. Create a new directory in the marketplace root
2. Add `.claude-plugin/plugin.json` with metadata
3. Create your commands, agents, skills, or hooks
4. Add README.md and LICENSE files
5. Update `.claude-plugin/marketplace.json` to reference the new plugin

### Testing Locally

Test plugins locally before publishing:

```bash
claude-code plugin install /path/to/marketplace
```

## Contributing

Contributions are welcome! To add a plugin to this marketplace:

1. Fork this repository
2. Create a new plugin directory with proper structure
3. Ensure it passes validation
4. Submit a pull request

## License

Each plugin is individually licensed under the MIT License. See the LICENSE file in each plugin directory.

## Resources

- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [Plugin Development Guide](https://docs.anthropic.com/claude-code/plugins)
- [Plugin Examples](https://github.com/anthropics/claude-code-plugins)

## Support

For issues or questions:

- Open an issue in this repository
- Refer to individual plugin READMEs for plugin-specific help

---

**Maintained by:** Edinho
