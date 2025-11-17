# Duyet's Claude Plugins Marketplace

A curated collection of plugins for Claude Code to enhance productivity and workflow automation.

## Quick Start

### 1. Add This Marketplace

Add this marketplace to your Claude Code:

```bash
/plugin marketplace add duyet/claude-plugins
```

### 2. Install Plugins

Once the marketplace is added, install plugins:

```bash
# Install specific plugin from this marketplace
/plugin install commit-commands@duyets-claude-plugins

# Or browse all available plugins interactively
/plugin
```

### Alternative: Direct Installation

Install individual plugins directly without adding the marketplace:

```bash
/plugin install https://github.com/duyet/claude-plugins/raw/main/plugins/commit-commands.md
```

## Available Plugins

### 🚀 Commit Commands

**Plugin Name:** `commit-commands`
**Source:** [`plugins/commit-commands.md`](plugins/commit-commands.md)
**Category:** Git & Version Control

Automatically creates semantic git commits by analyzing your staged changes and commit history.

**How to use:**
```bash
# Stage your changes
git add .

# Invoke the plugin (after installation)
# The plugin analyzes changes and creates a semantic commit
```

**Features:**
- ✓ Analyzes staged and unstaged changes
- ✓ Reviews recent commit history for consistency
- ✓ Follows semantic commit conventions (feat, fix, docs, refactor, etc.)
- ✓ Generates concise, meaningful commit messages
- ✓ Works with git hooks and pre-commit validation

## For Teams

### Auto-Install Marketplace for Team Projects

Configure automatic marketplace installation by adding to your project's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "duyets-plugins": {
      "source": {
        "source": "github",
        "repo": "duyet/claude-plugins"
      }
    }
  }
}
```

When team members trust the repository, Claude Code automatically installs this marketplace.

### Enable Specific Plugins

You can also pre-install specific plugins for your team:

```json
{
  "extraKnownMarketplaces": {
    "duyets-plugins": {
      "source": {
        "source": "github",
        "repo": "duyet/claude-plugins"
      }
    }
  },
  "enabledPlugins": [
    "commit-commands@duyets-claude-plugins"
  ]
}
```

## Contributing

We welcome contributions! To add a new plugin:

1. Fork this repository
2. Create a new plugin file in `plugins/` directory
3. Update `.claude-plugin/marketplace.json` with your plugin entry
4. Test your plugin locally
5. Submit a pull request

See [CLAUDE.md](CLAUDE.md) for detailed contribution guidelines and plugin format specifications.

## Documentation

- **[CLAUDE.md](CLAUDE.md)** - Complete marketplace documentation, schema reference, and contribution guide
- **[.claude-plugin/marketplace.json](.claude-plugin/marketplace.json)** - Marketplace configuration and plugin registry
- **[Official Docs](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces)** - Claude Code plugin marketplaces documentation

## Marketplace Information

**Marketplace ID:** `duyets-claude-plugins`
**Owner:** [Duyet](https://github.com/duyet)
**Version:** 1.0.0
**License:** MIT

## Support

- **Issues:** [GitHub Issues](https://github.com/duyet/claude-plugins/issues)
- **Discussions:** [GitHub Discussions](https://github.com/duyet/claude-plugins/discussions)
- **Official Docs:** [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code)

---

Made with ❤️ for the Claude Code community
