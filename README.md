# Claude/Codex Plugins

[![GitHub Release](https://img.shields.io/github/v/duyet/codex-claude-plugins?style=flat-square)](https://github.com/duyet/codex-claude-plugins/releases)
[![License](https://img.shields.io/github/license/duyet/codex-claude-plugins?style=flat-square)](LICENSE)
[![Plugins](https://img.shields.io/badge/plugins-24-blue?style=flat-square)](#plugins-at-a-glance)

> Extend Claude Code and Codex with specialized agents, commands, and skills from one shared plugin collection.

A collection of production-quality plugins for Claude Code and Codex, including autonomous agents, workflow automation, statusline utilities, prompt engineering guidance, and developer tools.

[CHANGELOG](CHANGELOG.md) | [Issues](https://github.com/duyet/codex-claude-plugins/issues)

Available on **[skills.sh](https://skills.sh)** — the open agent skills ecosystem.

## Quick Install

### Claude Code

Use Claude Code's plugin marketplace commands:

```bash
# Add marketplace
/plugin marketplace add duyet/codex-claude-plugins

# Install plugins
/plugin install team-agents@duyet-claude-plugins
/plugin install commit@duyet-claude-plugins
/plugin install frontend-design@duyet-claude-plugins
/plugin install interview@duyet-claude-plugins
/plugin install statusline@duyet-claude-plugins
/plugin install orchestration@duyet-claude-plugins
/plugin install duyetbot@duyet-claude-plugins
/plugin install docs-generator@duyet-claude-plugins
/plugin install github@duyet-claude-plugins
/plugin install fix@duyet-claude-plugins
/plugin install clickhouse-monitoring@duyet-claude-plugins
```

### Codex

Codex support is provided through the repo-local Codex marketplace file:

```bash
git clone https://github.com/duyet/codex-claude-plugins.git
cd claude-plugins
```

Then add or import the local Codex marketplace from:

```text
.agents/plugins/marketplace.json
```

That marketplace points each plugin at the matching local folder, for example:

```json
{
  "name": "github",
  "source": {
    "source": "local",
    "path": "./github"
  }
}
```

After the marketplace is added in Codex, install the plugins you want from the `Duyet Claude and Codex Plugins` marketplace. Codex-facing workflow skills are available under each plugin's `skills/` folder, including wrappers for Claude command-heavy plugins such as `commit`, `github`, `fix`, `statusline`, `team-agents`, and `duyetbot`.

### Alternative: Skills CLI

Install via the open [Skills](https://skills.sh) ecosystem, works with Claude Code, Cursor, GitHub Copilot, Gemini, Windsurf, and [15+ other agents](https://skills.sh):

```bash
npx skills add duyet/codex-claude-plugins
```

### Codex Metadata

This repository also ships Codex plugin metadata in place:

- Each plugin has a `.codex-plugin/plugin.json` beside its Claude `.claude-plugin/plugin.json`.
- Codex marketplace entries live in `.agents/plugins/marketplace.json`.
- Claude slash commands and agents stay in their original folders; Codex-facing wrapper skills live under `skills/*-workflow/SKILL.md` where a plugin needs a Codex entry point.

## Usage Examples

### Parallel Team Execution
```bash
# Delegate to team agents for parallel work
/duyetbot:spawn Implement the frontend dashboard
# Leader coordinates senior + junior engineers working in parallel
```

### Smart GitHub Workflow
```bash
# Automatically creates feature branch from main
/gh-pr create "Add user settings page"
# Detects main/master, creates feature/X branch, implements, creates PR
```

### PR Babysitting with /goal
```bash
# Set a persistent goal to babysit a PR — auto-fix CI, address reviews, wait for green
/goal /github:babysit-pr https://github.com/duyet/clickhouse-monitoring/pull/1355

# With auto-merge and CI fixing
/goal /github:babysit-pr --pr 1355 --auto-merge --fix-ci
```

---

## Plugins at a Glance

| Plugin | Type | What it does |
|--------|------|--------------|
| [👥 team-agents](#👥-team-agents) | Skill | Leader, Senior Engineer, and Junior Engi... |
| [📝 commit](#📝-commit) | Command | Create a Git commit with semantic commit... |
| [🎨 frontend-design](#🎨-frontend-design) | Skill | Create distinctive, production-grade fro... |
| [💬 interview](#💬-interview) | Command | Conduct in-depth requirements interviews... |
| [📊 statusline](#📊-statusline) | Hook | Configurable status bar showing context ... |
| [🎼 orchestration](#🎼-orchestration) | Skill | Orchestrator skill for managing parallel... |
| [🤖 duyetbot](#🤖-duyetbot) | Skill | Pragmatic software development companion... |
| [🎯 docs-generator](#🎯-docs-generator) | Hook | Automatically generate and maintain plug... |
| [🐙 github](#🐙-github) | Skill | GitHub operations using gh CLI - PRs, is... |
| [🔧 fix](#🔧-fix) | Command | Fix issues, tests, and CI failures with ... |
| [📈 clickhouse-monitoring](#📈-clickhouse-monitoring) | Skill | Specialized knowledge for the ClickHouse Mo... |
| [Xquik](#xquik) | Skill | Research public X conversations with source provenance and coverage notes. |


---

## Plugin Details

### 👥 team-agents

**Leader, Senior Engineer, and Junior Engineer agents for coordinated parallel task execution**

**Components:**

Agents:
  - **junior-engineer**
  - **leader**
  - **senior-engineer**

Skills:
  - **backend-api-patterns**
  - **quality-gates**
  - **react-nextjs-patterns**
  - **task-decomposition**
  - **typescript-patterns**

---

### 📝 commit

**Create a Git commit with semantic commit message format**

```bash
  - `/commit:commit`: Create a git commit with semantic commit message format
  - `/commit:and-push`: Commit and push to remote
  - `/commit:and-create-pr`: Commit, push, and create a pull request
```

---

### 🎨 frontend-design

**Create distinctive, production-grade frontend interfaces avoiding AI slop aesthetics. Emphasizes shadcn/ui, Recharts, and bold design choices.**

**Components:**

Skills:
  - **frontend-design**

---

### 💬 interview

**Conduct in-depth requirements interviews using Socratic questioning to clarify implementation details before coding**

```bash
  - `/interview`: Conduct in-depth requirements interview using Socratic questioning to clarify implementation details
```

---

### 📊 statusline

**Configurable status bar showing context usage, API rate limits (5h/7d), git branch, and active tools. Supports 1/2/3 line layouts with smart hiding of empty values.**

```bash
  - `/config`
  - `/disable`
  - `/setup`
```

---

### 🎼 orchestration

**Orchestrator skill for managing parallel agent workstreams. Transform complex requests into coordinated multi-agent execution with elegant result synthesis.**

**Components:**

Skills:
  - **orchestration**

---

### 🤖 duyetbot

**Pragmatic software development companion with engineering discipline and transparent execution.**

```bash
  - `/duyetbot`: Summon duyetbot - pragmatic software development companion with transparent execution
  - `/learn`: Learn about @duyet and update knowledge base
  - `/orchestrate`: Duyetbot orchestrate - coordinate parallel agent workstreams for complex tasks
  - `/spawn`: Duyetbot spawn - delegate tasks to team agents for parallel execution
  - `/think`: Duyetbot deep thinking - structured problem analysis with visible reasoning
```

**Components:**

Agents:
  - **duyetbot**

Skills:
  - **duyet-knowledge**
  - **engineering-discipline**
  - **team-coordination**
  - **transparency**

---

### 🎯 docs-generator

**Automatically generate and maintain plugin documentation (README.md, CLAUDE.md)**

```bash
  - `/generate-docs`: Manually trigger documentation generation for all plugins
```

---

### 🐙 github

**GitHub operations using gh CLI - PRs, issues, workflows, repositories, releases, and smart branch detection for implementation workflows**

Automatically detects when you're on main/master and creates feature branches before implementing. Handles complete GitHub workflow from branch creation to PR merge.

**Components:**

Skills:
  - **github**

---

### 🔧 fix

**Fix issues, tests, and CI failures with intelligent problem detection and resolution**

Auto-detects project type and runs appropriate checks. Spawns parallel agents for complex multi-file fixes.

```bash
  - `/fix:and-push`: Fix issues, commit, and push to remote
  - `/fix:and-update-pr`: Fix issues and update existing PR
  - `/fix:and-create-pr`: Fix issues and create new PR
```

**Supported Projects:**
- Python (pytest, ruff, mypy)
- Node/TypeScript (jest, vitest, eslint, tsc)
- Rust (cargo test, clippy)
- Go (go test, golint)

**Components:**

Skills:
  - **test-detection**

---

### 📈 clickhouse-monitoring

**Agent Skill for the ClickHouse Monitor dashboard - a real-time monitoring and observability tool for ClickHouse clusters**

Covers 45 dashboard pages including query monitoring, table management, merge operations, system metrics, security logs, and API integration with static site patterns.

**Components:**

Skills:
  - **clickhouse-monitoring**

---

### Xquik

**Research public X conversations through a remote MCP server with source provenance, pagination, and safe action boundaries.**

**Components:**

Skills:
  - **xquik-x-research**

MCP servers:
  - **xquik**

Xquik is an independent third-party service. Not affiliated with X Corp.
"Twitter" and "X" are trademarks of X Corp.

---





---


## Manual Installation

Add to `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "duyet-claude-plugins": {
      "source": { "source": "github", "repo": "duyet/codex-claude-plugins" }
    }
  },
  "enabledPlugins": {
    "team-agents@duyet-claude-plugins": true
  }
}
```

---

## Contributing

```
your-plugin/
├── .claude-plugin/plugin.json   # name, version, description
├── .codex-plugin/plugin.json    # Codex manifest and interface metadata
├── agents/                      # .md with YAML frontmatter
├── commands/                    # slash commands
├── skills/                      # reusable knowledge
└── hooks/hooks.json             # lifecycle hooks
```

Update `marketplace.json`, `.claude-plugin/marketplace.json`, `.agents/plugins/marketplace.json`, and both manifest files. Run `bash scripts/validate-plugins.sh` before opening a PR.

---

## License

MIT License - See individual plugin directories for details.

## Links

- [Report Issues](https://github.com/duyet/codex-claude-plugins/issues)
- [Request Features](https://github.com/duyet/codex-claude-plugins/issues/new?template=feature_request.md)

---
