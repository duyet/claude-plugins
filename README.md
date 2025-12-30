# Claude Plugins Marketplace

A collection of plugins for Claude Code to enhance productivity and workflow automation. This marketplace includes agent plugins and slash commands that extend Claude Code's capabilities.

## Installation

### Quick Start (Recommended)

Add this marketplace to Claude Code and install plugins:

```bash
# Add the marketplace
/plugin marketplace add duyet/claude-plugins

# Install plugins
/plugin install team-agents@duyet-claude-plugins
/plugin install commit-commands@duyet-claude-plugins
/plugin install terminal-ui-design@duyet-claude-plugins
/plugin install ralph-wiggum@duyet-claude-plugins
/plugin install frontend-design@duyet-claude-plugins
/plugin install interview@duyet-claude-plugins
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
    "team-agents@duyet-claude-plugins": true,
    "commit-commands@duyet-claude-plugins": true,
    "terminal-ui-design@duyet-claude-plugins": true,
    "ralph-wiggum@duyet-claude-plugins": true,
    "frontend-design@duyet-claude-plugins": true,
    "interview@duyet-claude-plugins": true
  }
}
```

Then restart Claude Code.

## Available Plugins

### Agent Plugins

#### Team Agents (Leader + Senior Engineer)

**Plugin:** `team-agents`
**Description:** Coordinated agent team for parallel task execution. Includes leader and senior-engineer agents.

**How it works:**
```
┌─────────────────────────────────────────────────────────────┐
│                        Leader Agent                          │
│  - Analyzes complex requirements                             │
│  - Designs architecture and solution approach                │
│  - Breaks work into independent, parallelizable tasks        │
│  - Delegates to multiple senior engineers                    │
│  - Reviews completed work and ensures quality                │
└──────────────────────┬───────────────────────────────────────┘
                       │ delegates tasks
       ┌───────────────┼───────────────┐
       ▼               ▼               ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ Senior Eng 1 │ │ Senior Eng 2 │ │ Senior Eng 3 │
│  (Task A)    │ │  (Task B)    │ │  (Task C)    │
│  parallel    │ │  parallel    │ │  parallel    │
└──────────────┘ └──────────────┘ └──────────────┘
```

**Use when:**
- Complex features requiring multiple components
- Large refactoring spanning many files
- Tasks that benefit from parallel execution
- Need both architectural planning AND implementation

**Included Agents:**
- **`leader`** (uses Opus): Coordinates complex tasks, breaks down requirements, delegates work
- **`senior-engineer`** (uses Haiku): Implements delegated tasks with high quality

**Usage Example:**
```
We need to implement a user authentication system with OAuth2, JWT tokens,
and role-based access. Can you plan and coordinate the implementation?
```

The leader will:
1. Analyze requirements and design the architecture
2. Break work into parallel tasks (e.g., OAuth flow, JWT middleware, RBAC)
3. Delegate each task to a senior-engineer running in parallel
4. Review completed work and ensure quality gates pass

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

### Skills

#### Terminal UI Design

**Plugin:** `terminal-ui-design`
**Description:** Create distinctive, production-grade terminal user interfaces with high design quality

**Use when:**
- Building CLI tools with custom interfaces
- Creating TUI (Terminal UI) applications
- Designing terminal-based dashboards
- Need creative, polished terminal aesthetics beyond generic output

**Key Features:**
- Bold aesthetic direction (cyberpunk, retro-computing, minimalist zen, etc.)
- Custom box drawing & borders
- Cohesive color palettes (ANSI 16, 256-color, true color)
- Typography & text styling techniques
- Layout & spatial composition patterns
- Motion & animation patterns (spinners, progress bars, typing effects)
- Decorative elements and anti-patterns to avoid

**Supported Libraries:**
- Python: Rich, Textual
- Go: Bubbletea, Lipgloss
- Rust: Ratatui
- Node.js: Ink, Blessed

#### Ralph Wiggum

**Plugin:** `ralph-wiggum`
**Description:** Continuous self-referential AI loops for iterative development - run Claude with the same prompt until task completion.

Originally created by Daisy Hollman (Anthropic).

**Use when:**
- Well-defined tasks with clear success criteria
- Tasks requiring iteration and refinement (TDD, getting tests to pass)
- Greenfield projects where you can walk away
- Tasks with automatic verification (tests, linters)

**Not good for:**
- Tasks requiring human judgment or design decisions
- One-shot operations
- Tasks with unclear success criteria
- Production debugging

**Commands:**
- `/ralph-loop "<prompt>" [--max-iterations N] [--completion-promise "TEXT"]` - Start a loop
- `/cancel-ralph` - Cancel active loop
- `/help` - Show Ralph Wiggum help

**How it works:**
1. You provide a prompt and optional completion criteria
2. Claude works on the task
3. When Claude tries to exit, the stop hook intercepts
4. Same prompt fed back to Claude
5. Claude sees its previous work in files and git history
6. Iterates until completion promise detected or max iterations reached

**Usage Example:**
```bash
/ralph-loop "Build a REST API for todos. Requirements: CRUD operations, input validation, tests. Output <promise>COMPLETE</promise> when done." --completion-promise "COMPLETE" --max-iterations 50
```

**Philosophy:**
- **Iteration > Perfection**: Don't aim for perfect on first try
- **Failures Are Data**: Use predictable failures to tune prompts
- **Persistence Wins**: Keep trying until success

## Plugin Structure

Each plugin directory contains:
```
plugin-name/
├── .claude-plugin/
│   └── plugin.json     # Plugin manifest (name, description, version, author)
├── agents/             # Agent definitions (.md files with YAML frontmatter)
├── commands/           # Slash commands (.md files)
└── skills/             # Skill definitions (.md files)
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
