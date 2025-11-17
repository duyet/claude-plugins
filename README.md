# Duyet's Claude Plugins Marketplace

A collection of plugins for Claude Code to enhance productivity and workflow automation.

## Installation

To use plugins from this marketplace, you can install them in Claude Code:

### Option 1: Direct Installation (Recommended)

1. Copy the plugin file URL from this repository
2. In Claude Code, use the plugin installation command:
   ```bash
   # Install a specific plugin
   claude plugin install <plugin-url>
   ```

### Option 2: Manual Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/duyet/claude-plugins.git
   ```

2. Copy the desired plugin file from `plugins/` to your Claude Code plugins directory

3. Reference the plugin in your Claude Code configuration

## Usage

Once installed, you can use plugins by referencing them in your Claude Code sessions or workflows. Each plugin provides specific functionality as described below.

## Available Plugins

### Commit Commands Plugin

**File:** `plugins/commit-commands.md`
**Description:** Create a git commit with semantic commit message format

This plugin helps you create well-formatted git commits by analyzing staged and unstaged changes, reviewing recent commits, and following semantic commit conventions.

**How to use:**
1. Stage your changes: `git add .`
2. Invoke the plugin in Claude Code
3. The plugin will analyze your changes and create a semantic commit message

## Plugin Structure

Each plugin is a markdown file with:
- **Frontmatter**: YAML configuration including allowed tools and description
- **Content**: Instructions and context for Claude to follow

### Marketplace Configuration

The `.claude-plugin/marketplace.json` file contains metadata about this marketplace:
- Marketplace name and description
- List of available plugins with their metadata
- Plugin categories and tags
- Repository information

## Contributing

Feel free to add new plugins by creating markdown files in the `plugins/` directory following the established format. Don't forget to update `.claude-plugin/marketplace.json` when adding new plugins.
