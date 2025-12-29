# Claude Plugins Marketplace

A collection of plugins for Claude Code to enhance productivity and workflow automation. This marketplace includes agent plugins and slash commands that extend Claude Code's capabilities.

## Installation

### Quick Start (Recommended)

Add this marketplace to Claude Code and install plugins:

```bash
# Add the marketplace
/plugin marketplace add duyet/claude-plugins

# Install plugins
/plugin install senior-engineer-agent@duyet-claude-plugins
/plugin install leader-agent@duyet-claude-plugins
/plugin install commit-commands@duyet-claude-plugins
```

### Manual Installation via Settings

Add to your `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "duyet-claude-plugins": {
      "source": {
        "source": "github",
        "repo": "duyet/claude-plugins"
      }
    }
  },
  "enabledPlugins": {
    "senior-engineer-agent@duyet-claude-plugins": true,
    "leader-agent@duyet-claude-plugins": true,
    "commit-commands@duyet-claude-plugins": true
  }
}
```

Then restart Claude Code.

## Available Plugins

### Agent Plugins

#### Senior Engineer Agent

**Plugin:** `senior-engineer-agent`
**Description:** Elite implementation engineer specializing in translating plans and specifications into high-performance, maintainable production code.

**Use when:**
- Implementing features from specifications
- Building UI/frontend components with performance focus
- Developing backend services and APIs
- Quality-critical implementation work
- Performance optimization is a priority
- Adhering to strict project patterns

**Key Features:**
- Performance-first implementation approach
- Comprehensive testing strategies (unit, integration, E2E)
- Clean architecture following SOLID principles
- Consistent pattern application across codebase
- Proactive optimization and improvement suggestions

**Usage Example:**
```
I have a specification for [feature/component]. Can you implement this following our project patterns and best practices?
```

#### Leader Agent

**Plugin:** `leader-agent`
**Description:** Technical Lead and Engineering Manager for coordinating complex development tasks, architectural planning, and quality assurance.

**Use when:**
- Implementing multi-faceted features requiring architectural planning
- Coordinating critical bug fixes across multiple components
- Planning and executing large-scale refactoring
- Designing solutions aligned with existing architecture
- Need comprehensive code review and quality assurance
- Breaking down work for parallel team execution

**Key Features:**
- Requirements analysis and clarification
- Solution design and architectural alignment
- Task planning with parallel execution optimization
- Comprehensive code review and quality gates
- Team coordination and delegation
- Evidence-based delivery reporting

**Usage Example:**
```
We need to implement [complex feature/refactoring]. Can you analyze requirements, design the solution, plan the work, and coordinate the implementation?
```

### Slash Commands

#### Commit Commands

**Plugin:** `commit-commands`
**Description:** Create a Git commit with semantic commit message format

**Features:**
- Analyzes staged and unstaged changes
- Reviews recent commits for context
- Follows semantic commit conventions
- Automatic commit message generation

**Usage:**
```
/commit
```

## Plugin Structure

Each plugin directory contains:
```
plugin-name/
└── .claude-plugin/
    ├── agents/      # Agent definitions (.md files)
    ├── commands/    # Slash commands (.md files)
    └── skills/      # Skill definitions (.md files)
```

### Agent File Format

```markdown
---
name: agent-name
description: When to use this agent
model: haiku|opus|sonnet
color: purple|red|blue|green
---

# Agent content here...
```

### Command File Format

```markdown
---
description: What this command does
allowed-tools: Tool1, Tool2
---

# Command content here...
```

## Contributing

To add new plugins to this marketplace:

1. Create a new directory for your plugin: `plugin-name/.claude-plugin/`
2. Add appropriate subdirectories (`agents/`, `commands/`, `skills/`)
3. Create your plugin files with proper frontmatter
4. Update `marketplace.json` with your plugin entry
5. Update this README with documentation

### Plugin Development Guidelines

- **Be specific about use cases**: Clearly document when to use the plugin
- **Include examples**: Provide concrete examples of how to invoke/use
- **Define constraints**: Specify any limitations or prerequisites
- **Ensure quality**: Test plugins thoroughly before publishing
- **Follow conventions**: Use established patterns from existing plugins

## Marketplace Configuration

The `marketplace.json` file defines available plugins:

```json
{
  "name": "duyet-claude-plugins",
  "owner": {
    "name": "duyet"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "source": "./plugin-directory",
      "description": "Plugin description"
    }
  ]
}
```

## Troubleshooting

### Plugins not appearing after installation

1. Verify marketplace was added: `/plugin marketplace list`
2. Check Claude Code logs for errors
3. Ensure `marketplace.json` is valid JSON
4. Restart Claude Code

### Agent not being invoked

1. Check agent file has valid frontmatter (`name`, `description`, `model`)
2. Ensure agent is in `.claude-plugin/agents/` directory
3. Verify description clearly explains when to use the agent

### Permission errors with slash commands

1. Check command file has `allowed-tools` in frontmatter
2. Verify tools are permitted in your settings
3. Use `/permissions` to review allowed tools

## License

MIT
