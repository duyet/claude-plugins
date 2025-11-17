# Claude Plugins Marketplace

This repository contains a collection of plugins designed for Claude Code to enhance productivity and workflow automation.

## Repository Structure

```
claude-plugins/
├── plugins/          # Plugin files
│   └── *.md         # Individual plugin definitions
├── README.md        # User-facing documentation
└── CLAUDE.md        # This file - Claude-specific information
```

## Plugin Format

Each plugin is a markdown file with:

1. **YAML Frontmatter**: Configuration metadata
   - `allowedTools`: Array of tools Claude can use with this plugin
   - `description`: Brief description of the plugin's purpose

2. **Content**: Instructions and context for Claude to follow

## Available Plugins

### Commit Commands Plugin
- **Location**: `plugins/commit-commands.md`
- **Purpose**: Creates semantic git commits by analyzing changes and following conventional commit format
- **Allowed Tools**: Bash (for git operations)

## Usage Context

When users reference plugins from this marketplace, they expect:
- Consistent behavior following the plugin's instructions
- Use of semantic commit conventions where applicable
- Following best practices for the specific domain (git, code analysis, etc.)

## Contributing New Plugins

When creating new plugins:
1. Place them in the `plugins/` directory
2. Use descriptive filenames (kebab-case)
3. Include proper YAML frontmatter
4. Provide clear, actionable instructions
5. Specify required tools in `allowedTools`
6. Test the plugin before committing
