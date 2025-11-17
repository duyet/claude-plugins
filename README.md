# Duyet's Claude Plugins Marketplace

A collection of plugins for Claude Code to enhance productivity and workflow automation.

## Installation

### Add This Marketplace

Add this marketplace to your Claude Code to access all available plugins:

```bash
/plugin marketplace add duyet/claude-plugins
```

### Install Plugins

Once the marketplace is added, install plugins using:

```bash
# Install from this marketplace
/plugin install commit-commands@duyets-claude-plugins

# Or browse all available plugins interactively
/plugin
```

### Alternative: Direct Plugin Installation

You can also install individual plugins directly without adding the marketplace:

```bash
/plugin install https://github.com/duyet/claude-plugins/raw/main/plugins/commit-commands.md
```

## Available Plugins

### 🚀 Commit Commands

**Name:** `commit-commands`
**File:** [`plugins/commit-commands.md`](plugins/commit-commands.md)

Automatically creates semantic git commits by analyzing your staged changes.

**Usage:**
```bash
# Stage your changes
git add .

# Invoke the commit-commands plugin in Claude Code
# The plugin will analyze changes and create a semantic commit message
```

**Features:**
- Analyzes staged and unstaged changes
- Reviews recent commit history for consistency
- Follows semantic commit conventions (feat, fix, docs, etc.)
- Generates concise, meaningful commit messages

## For Teams

Set up automatic marketplace installation for team projects by adding to `.claude/settings.json`:

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

When team members trust the repository folder, Claude Code automatically installs this marketplace.

## Documentation

- **CLAUDE.md**: Repository structure and plugin format documentation
- **Marketplace Config**: `.claude-plugin/marketplace.json` contains all marketplace metadata

## License

MIT
