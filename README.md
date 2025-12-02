# Claude Plugins Marketplace

A collection of plugins for Claude Code to enhance productivity and workflow automation. This marketplace includes slash commands, skill plugins, and agent plugins that extend Claude Code's capabilities.

## Available Plugins

### Slash Commands & Tools

#### Commit Commands Plugin

**File:** `plugins/commit-commands.md`
**Description:** Create a git commit with semantic commit message format

This plugin helps you create well-formatted git commits by analyzing staged and unstaged changes, reviewing recent commits, and following semantic commit conventions.

**Usage:** Reference in workflows or configure in Claude Code settings.

### Agent Plugins

Agent plugins expose specialized engineering personas that can be invoked for specific development tasks.

#### Senior Engineer Agent

**File:** `plugins/senior-engineer-agent.md`
**Category:** Agent
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

#### Leader Agent

**File:** `plugins/leader-agent.md`
**Category:** Agent
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

## Using Plugins

### Installation & Configuration

1. **Slash Commands**: Reference directly in your Claude Code configuration or workflows
2. **Agent Plugins**: Invoke using Claude Code's agent calling mechanisms
3. **Skill Plugins**: Install through Claude Code's plugin marketplace

### Basic Usage Examples

**Senior Engineer Agent:**
```
I have a specification for [feature/component]. Can you implement this following our project patterns and best practices?
```

**Leader Agent:**
```
We need to implement [complex feature/refactoring]. Can you analyze requirements, design the solution, plan the work, and coordinate the implementation?
```

## Plugin Structure

Each plugin is a markdown file with:
- **Frontmatter**: YAML configuration including plugin metadata
  - `name`: Plugin identifier
  - `description`: Human-readable description
  - `category`: Plugin type (agent, command, skill, etc.)
  - `tags`: Searchable tags for discovery
  - `allowed-tools`: (for slash commands) Permitted tool access
- **Content**: Detailed instructions and context for Claude to follow

## Contributing

To add new plugins to this marketplace:

1. Create a markdown file in the `plugins/` directory
2. Include proper frontmatter with metadata
3. Provide clear, detailed content
4. Update this README with the new plugin
5. Follow the established format and conventions

### Plugin Development Guidelines

- **Be specific about use cases**: Clearly document when to use the plugin
- **Include examples**: Provide concrete examples of how to invoke/use
- **Define constraints**: Specify any limitations or prerequisites
- **Ensure quality**: Test plugins thoroughly before publishing
- **Document patterns**: Show how the plugin follows project patterns
- **Version compatibility**: Specify Claude Code version requirements if applicable

## Plugin Categories

- **Agent**: Specialized engineering personas for specific development roles
- **Command**: Slash commands for workflow automation
- **Skill**: Reusable skills and capabilities
- **Tool**: Extensions providing new functionality
- **Template**: Boilerplate and starting points for common tasks
