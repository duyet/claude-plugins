# Duyet's Claude Plugins Marketplace

A collection of plugins for Claude Code to enhance productivity and workflow automation.

## How to Use

### Installation

**Option 1: Direct Installation (Recommended)**

```bash
# Install from this repository
claude plugin install https://github.com/duyet/claude-plugins/raw/main/plugins/commit-commands.md
```

**Option 2: Manual Installation**

1. Clone this repository:
   ```bash
   git clone https://github.com/duyet/claude-plugins.git
   ```

2. Copy the plugin file you need from `plugins/` directory to your Claude Code plugins directory

3. Reference the plugin in your Claude Code configuration

### Using Plugins

Once installed, invoke plugins directly in your Claude Code sessions. Each plugin is context-aware and will guide you through its specific workflow.

## Available Plugins

### 🚀 Commit Commands Plugin

**File:** [`plugins/commit-commands.md`](plugins/commit-commands.md)

Automatically creates semantic git commits by analyzing your staged changes.

**Usage:**
```bash
# Stage your changes
git add .

# Invoke the plugin in Claude Code
# The plugin will analyze changes and create a semantic commit message
```

**Features:**
- Analyzes staged and unstaged changes
- Reviews recent commit history for consistency
- Follows semantic commit conventions (feat, fix, docs, etc.)
- Generates concise, meaningful commit messages
