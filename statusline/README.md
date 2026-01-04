# Statusline

A Claude Code plugin that provides real-time visibility into your coding session. Track context usage, active tools, running agents, and task progress at a glance.

**Inspired by [claude-hud](https://github.com/jarrodwatts/claude-hud) — enhanced for the claude-plugins ecosystem.**

## Overview

Statusline keeps you informed about what's happening during your Claude Code session without interrupting your workflow. Get immediate feedback on:

| Metric | Purpose |
|--------|---------|
| **Context Health** | Know exactly how much of your token window is in use |
| **Active Tools** | See which tools Claude is using right now |
| **Agent Tracking** | Monitor running agents and their execution time |
| **Task Progress** | Track todo completion in real-time |

## Installation

Add the plugin to your Claude Code instance:

```bash
/plugin install statusline
```

Then enable monitoring:

```bash
/statusline:enable
```

## Quick Start

### View Current Status
Check your session metrics anytime:
```bash
/statusline:status
```

### Continuous Monitoring
Enable automatic status updates (5-second interval by default):
```bash
/statusline:enable
```

### Custom Update Interval
Set a custom monitoring interval (in seconds):
```bash
/statusline:enable 10
```

### Stop Monitoring
Pause background updates while keeping the plugin active:
```bash
/statusline:disable
```

## Commands

| Command | Purpose |
|---------|---------|
| `/statusline:status` | Display current session metrics immediately |
| `/statusline:enable [interval]` | Enable real-time monitoring with optional custom interval |
| `/statusline:disable` | Pause automatic status updates |

## What Each Metric Shows

### Context Window
A visual progress bar showing your token usage with color coding:
- 🟢 Green: 0-60% — Comfortable usage
- 🟡 Yellow: 60-85% — Getting full
- 🔴 Red: 85%+ — Approaching limit

Example:
```
Context: ████░░░░░░ 45% (90,000 / 200,000 tokens)
```

### Active Tools
Lists tools currently in use with operation counts:
```
Active Tools:
  • Read (2 instances)
  • Bash (1 instance)
  • Glob (1 instance)
```

### Completed Tools
Aggregated summary of completed tool operations:
```
Completed: ✓ Glob ×4 | ✓ Bash ×8 | ✓ Read ×12 | ✓ Edit ×3
```

### Running Agents
Shows active agents with elapsed time:
```
Agents Running:
  • Explore: Analyzing codebase structure (12s)
  • code-reviewer: Reviewing authentication module (5s)
```

### Task Progress
Real-time todo tracking:
```
Tasks: ⏳ 2 pending | 🔄 1 in progress | ✓ 5 completed (5/8 total)
```

### Session Duration
Tracks how long your current session has been active:
```
Duration: 12m 34s
```

## Features

✅ **Real-time Updates** — Status refreshes automatically at your chosen interval

✅ **Non-intrusive** — Displays without interrupting your workflow

✅ **Customizable** — Set monitoring frequency that works for you

✅ **Manual Control** — Check status anytime with `/statusline:status`

✅ **Plugin Integration** — Works seamlessly with other Claude Code plugins

✅ **Token Awareness** — Shows actual token counts from Claude Code

## Use Cases

- **Monitor Context** — Know when you're approaching context limits before running out
- **Track Progress** — See how many tasks have been completed in your session
- **Debug Workflows** — Understand tool and agent activity during complex operations
- **Optimize Sessions** — Identify bottlenecks and adjust your approach
- **Stay Informed** — Keep awareness of background operations

## How It Works

The plugin reads session data from Claude Code's internal state and displays aggregated metrics about:

1. **Token Usage** — Real counts from Claude Code's context window
2. **Tool Activity** — Tracked from tool invocations in your session
3. **Agent Operations** — Monitored from subagent execution
4. **Task Management** — Read from your TodoWrite operations

Updates happen at a regular interval (default 5 seconds) without blocking your work.

## Requirements

- Claude Code v1.0.80+
- Node.js 18+ or Bun (if running custom build)

## Inspiration

This plugin is inspired by [claude-hud](https://github.com/jarrodwatts/claude-hud) but optimized for the claude-plugins marketplace with enhanced integration and customization options.

## Development

Session Monitor is built with:
- TypeScript for type safety
- Claude Code's native APIs
- Minimal dependencies for quick performance

### Source Structure

```
session-monitor/
├── .claude-plugin/
│   └── plugin.json         # Plugin manifest
├── commands/
│   ├── status.md          # Status command documentation
│   ├── enable.md          # Enable command documentation
│   └── disable.md         # Disable command documentation
└── README.md              # This file
```

## Contributing

Found an issue or have a feature idea? Contributions are welcome! This plugin is part of the [claude-plugins](https://github.com/duyet/claude-plugins) marketplace.

## License

MIT License — see LICENSE file

## Related Plugins

- **[team-agents](../team-agents)** — Coordinated parallel task execution
- **[commit](../commit)** — Semantic Git commit automation
- **[ralph-wiggum](../ralph-wiggum)** — Self-referential development loops

---

**Questions?** Open an issue on the [claude-plugins repository](https://github.com/duyet/claude-plugins/issues)
