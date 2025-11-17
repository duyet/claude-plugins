# Duyet's Claude Plugins Marketplace

This repository is a Claude Code plugin marketplace, providing a collection of plugins to enhance productivity and workflow automation.

## Repository Structure

```
claude-plugins/
├── .claude-plugin/
│   └── marketplace.json    # Marketplace configuration (required)
├── plugins/                # Plugin files
│   └── commit-commands.md  # Individual plugin definitions
├── CLAUDE.md              # This file - Claude-specific information
└── README.md              # User-facing documentation
```

## Marketplace Configuration

### marketplace.json Schema

The `.claude-plugin/marketplace.json` file follows the official Claude Code marketplace schema:

```json
{
  "name": "string (kebab-case, required)",
  "owner": {
    "name": "string (required)",
    "email": "string (optional)",
    "url": "string (optional)"
  },
  "metadata": {
    "description": "string",
    "version": "string",
    "homepage": "string",
    "pluginRoot": "string (base path for relative sources)"
  },
  "plugins": [
    {
      "name": "string (required, kebab-case)",
      "source": "string|object (required)",
      "description": "string",
      "version": "string",
      "author": { "name": "string", "url": "string" },
      "repository": "string",
      "license": "string (SPDX identifier)",
      "keywords": ["array of strings"],
      "category": "string",
      "strict": boolean
    }
  ]
}
```

**Key Points:**
- `name`: Marketplace identifier in kebab-case
- `owner`: Maintainer information (replaces old `author` field)
- `metadata`: Contains description, version, homepage, and pluginRoot
- `plugins[]`: Array of plugin entries
- `source`: Can be relative path, GitHub repo, or git URL
- `strict`: When `false`, plugin.json is optional (marketplace entry is the manifest)

### Plugin Source Types

**Relative paths** (plugins in same repository):
```json
{ "source": "./plugins/my-plugin" }
```

**GitHub repositories:**
```json
{
  "source": {
    "source": "github",
    "repo": "owner/plugin-repo"
  }
}
```

**Git repositories:**
```json
{
  "source": {
    "source": "git",
    "url": "https://gitlab.com/team/plugin.git"
  }
}
```

## Plugin Format

### Single-File Plugins (used in this marketplace)

For simple plugins, use a single markdown file with YAML frontmatter:

```markdown
---
allowed-tools: Bash(command:*), Read, Write
description: Plugin description
---

## Context

Instructions and context for Claude...

## Your task

Clear task description...
```

**When using single-file format:**
- Set `"strict": false` in marketplace.json
- The marketplace entry serves as the complete manifest
- No separate `plugin.json` file needed

### Multi-File Plugins

For complex plugins with multiple components:
- Create a plugin directory
- Include `plugin.json` manifest file
- Set `"strict": true` (or omit, as it's default)
- Can include: commands/, agents/, hooks/, mcpServers/

## Available Plugins

### commit-commands

**Location:** `plugins/commit-commands.md`
**Type:** Single-file command plugin
**Format:** Markdown with YAML frontmatter

**Purpose:** Creates semantic git commits by analyzing staged/unstaged changes and following conventional commit format.

**Allowed Tools:** Bash (for git operations)

**Usage:** Install via marketplace or directly invoke after marketplace is added.

## How Users Access This Marketplace

### Add the Marketplace

```bash
/plugin marketplace add duyet/claude-plugins
```

### Install Plugins

```bash
# Install specific plugin
/plugin install commit-commands@duyets-claude-plugins

# Browse all plugins interactively
/plugin
```

### Team Configuration

Teams can auto-install this marketplace via `.claude/settings.json`:

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

## Contributing New Plugins

### For Single-File Plugins

1. Create a markdown file in `plugins/` directory
2. Add YAML frontmatter with `allowed-tools` and `description`
3. Write clear instructions in the content
4. Update `.claude-plugin/marketplace.json`:
   ```json
   {
     "name": "plugin-name",
     "source": "./plugins/plugin-name.md",
     "description": "Clear description",
     "version": "1.0.0",
     "author": { "name": "Your Name" },
     "keywords": ["relevant", "tags"],
     "strict": false
   }
   ```
5. Test the plugin locally
6. Submit a pull request

### For Multi-File Plugins

1. Create a directory in `plugins/`
2. Add `plugin.json` manifest
3. Organize commands, agents, hooks as needed
4. Update marketplace.json with `"strict": true` (or omit)
5. Test and submit PR

### Best Practices

- Use kebab-case for plugin names
- Provide clear, concise descriptions
- Add relevant keywords for discoverability
- Specify accurate version numbers
- Test plugins before submitting
- Follow semantic versioning
- Document plugin usage in README.md

## Marketplace Management

### Validation

Test your marketplace locally:

```bash
# Validate marketplace JSON
claude plugin validate .

# Add local marketplace
/plugin marketplace add ./path/to/claude-plugins

# Test plugin installation
/plugin install commit-commands@duyets-claude-plugins
```

### Versioning

- Marketplace version in `metadata.version`
- Individual plugin versions in each plugin entry
- Follow semantic versioning (MAJOR.MINOR.PATCH)

## References

- [Official Plugin Marketplaces Documentation](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces)
- [Plugin Development Guide](https://docs.claude.com/en/docs/claude-code/plugins)
- [Plugin Reference](https://docs.claude.com/en/docs/claude-code/plugins-reference)

## License

MIT - See individual plugin entries for specific licensing information.
