# Agent Loop Plugin

Continuous overnight/day repository maintenance with autonomous agent loops.

```text
Wake every 5m ──► Triage repos ──► Dispatch threads ──► Track & land
```

## Version

0.3.0

## Overview

The agent-loop plugin runs a persistent automation cycle that keeps repositories
healthy without human supervision. It is designed for overnight and day-long
autonomous upkeep: triaging issues, reviewing PRs, applying fixes, and landing
changes — all through parallel agent threads.

Inspired by Peter Steinberger's maintainer-orchestrator pattern: tell Codex to
maintain your repos, wake up every 5 minutes, and direct work to threads.
That makes it easy to parallelize + steer work as needed.

## Components

### Skills

| Skill                       | Purpose                                                |
| --------------------------- | ------------------------------------------------------ |
| **agent-loop-orchestrator** | Core loop: wait → triage → dispatch → monitor → report |
| **agent-loop-triage**       | GitHub issue/PR queue scanning and classification      |
| **agent-loop-autoreview**   | Autonomous PR review, fix application, and merging     |
| **agent-loop-browser**      | Browser automation for live UI proof and verification  |

### Commands

#### Loop Control

| Command              | Description                                     |
| -------------------- | ----------------------------------------------- |
| `/agent-loop:start`  | Start or resume the continuous maintenance loop |
| `/agent-loop:stop`   | Gracefully stop the loop and persist state      |
| `/agent-loop:resume` | Resume from persisted state (explicit resume)   |

#### State Management

| Command               | Description                                              |
| --------------------- | -------------------------------------------------------- |
| `/agent-loop:status`  | Quick status check (running, cycles, metrics)            |
| `/agent-loop:inspect` | Deep inspection of state file (history, errors, details) |
| `/agent-loop:reset`   | Clear state and start fresh (backs up old state)         |
| `/agent-loop:restore` | Recover state from a backup                              |

#### One-Shot Operations

| Command                  | Description                                     |
| ------------------------ | ----------------------------------------------- |
| `/agent-loop:triage`     | One-shot repo queue triage (doesn't start loop) |
| `/agent-loop:autoreview` | One-shot PR review and fix (doesn't start loop) |

## Skill Sources

Sources adapted for the agent-loop plugin:

- **agent-loop-triage** — adapted from [steipete/agent-scripts github-project-triage](https://github.com/steipete/agent-scripts/tree/main/skills/github-project-triage)
- **agent-loop-browser** — adapted from [steipete/agent-scripts browser-use](https://github.com/steipete/agent-scripts/tree/main/skills/browser-use)
- **agent-loop-autoreview** — adapted from local autofix skill + CodeRabbit workflow patterns
- **agent-loop-orchestrator** — original orchestrator pattern inspired by maintainer-orchestrator concept

## Quick Start

```bash
# Start the loop (auto-prompts to resume if state exists)
/agent-loop:start

# Check status
/agent-loop:status

# Inspect state details
/agent-loop:inspect

# One-shot triage (doesn't start loop)
/agent-loop:triage

# Review a specific PR
/agent-loop:autoreview --pr 123 --merge

# Stop the loop gracefully
/agent-loop:stop

# Resume from saved state (explicit)
/agent-loop:resume

# Reset and start fresh (backs up old state)
/agent-loop:reset

# Restore from backup
/agent-loop:restore --list
```

## State Management & Recovery

The agent-loop automatically saves state to `.agent-loop/state.json` and supports robust recovery:

### Startup Behavior

When you run `/agent-loop:start`:

1. **Checks for existing state** — detects `.agent-loop/state.json`
2. **Prompts if found** — asks to resume or start fresh
3. **Backs up on reset** — saves old state to `.agent-loop/backups/` if starting fresh

### State Operations

| Operation          | Command                          | Purpose                                    |
| ------------------ | -------------------------------- | ------------------------------------------ |
| **Check status**   | `/agent-loop:status`             | Quick summary (running, cycles, metrics)   |
| **Deep inspect**   | `/agent-loop:inspect`            | View thread history, errors, state details |
| **Validate state** | `/agent-loop:inspect --validate` | Check state file integrity                 |
| **Reset state**    | `/agent-loop:reset`              | Clear state, backs up old state            |
| **Restore state**  | `/agent-loop:restore --list`     | Recover from backup                        |
| **Resume loop**    | `/agent-loop:resume`             | Continue from saved state                  |

### Recovery Scenarios

**If state is corrupted:**

```bash
/agent-loop:inspect --validate        # Identify the problem
/agent-loop:restore --list            # List available backups
/agent-loop:restore state-XXXX.json   # Restore from backup
/agent-loop:start --resume            # Continue from restored state
```

**If you want to start fresh:**

```bash
/agent-loop:reset                     # Backs up old state automatically
/agent-loop:start --fresh             # Starts with clean state
```

**If you accidentally reset:**

```bash
/agent-loop:restore --list            # List backups
/agent-loop:restore --select          # Interactive menu
/agent-loop:start --resume            # Resume from backup
```

## Configuration

| Env Variable                 | Default                | Description                    |
| ---------------------------- | ---------------------- | ------------------------------ |
| `AGENT_LOOP_INTERVAL`        | 300                    | Sleep between cycles (seconds) |
| `AGENT_LOOP_MAX_CONCURRENCY` | 3                      | Max parallel worker threads    |
| `AGENT_LOOP_SCOPE`           | current                | Default triage scope           |
| `AGENT_LOOP_LOG_DIR`         | .agent-loop/logs       | Log output directory           |
| `AGENT_LOOP_STATE_FILE`      | .agent-loop/state.json | Persisted loop state           |
| `AGENT_LOOP_BACKUP_DIR`      | .agent-loop/backups    | Timestamped state backups      |
| `AGENT_LOOP_REPOS`           | (from git remote)      | Comma-separated repo list      |

## Plugin Structure

```text
agent-loop/
├── .antigravity-plugin/
│   └── plugin.json          # Antigravity manifest
├── .claude-plugin/
│   └── plugin.json          # Claude manifest
├── .codex-plugin/
│   └── plugin.json          # Codex manifest
├── .grok-plugin/
│   └── plugin.json          # Grok Bot / Grok Build manifest
├── .grok-build-plugin/
│   └── plugin.json          # Grok Build interface metadata
├── assets/
│   └── logo.svg
├── commands/                # Slash commands
│   ├── start.md
│   ├── stop.md
│   ├── status.md
│   ├── triage.md
│   └── autoreview.md
├── skills/                  # Reusable knowledge
│   ├── agent-loop-orchestrator/
│   │   └── SKILL.md
│   ├── agent-loop-triage/
│   │   └── SKILL.md
│   ├── agent-loop-autoreview/
│   │   └── SKILL.md
│   └── agent-loop-browser/
│       └── SKILL.md
└── README.md
```

## Versioning

Follow semantic versioning (semver):

| Change Type               | Version Bump | Example       |
| ------------------------- | ------------ | ------------- |
| Bug fix, docs             | Patch        | 0.2.0 → 0.2.1 |
| New feature, minor change | Minor        | 0.2.0 → 0.3.0 |
| Breaking change           | Major        | 0.2.0 → 1.0.0 |

## Commit Convention

Use semantic commits with plugin scope:

```text
feat(agent-loop): add new feature
fix(agent-loop): fix bug
docs(agent-loop): update documentation
```

Co-author: `Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>`

---

**Based on concepts from [steipete/agent-scripts](https://github.com/steipete/agent-scripts)**
