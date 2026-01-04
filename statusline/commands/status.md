# /statusline:status

Display real-time metrics about your current Claude Code session.

## Usage

```
/statusline:status
```

## What It Shows

This command displays a live overview of your session:

- **Context Window** — Visual health meter showing token usage (green → yellow → red)
- **Model Info** — Current model and available context window size
- **Tool Activity** — Count of active and completed tools during this session
- **Agent Status** — Running agents with their execution time
- **Task Progress** — Completed vs total todos tracking
- **Session Duration** — How long the current session has been active

## Output Example

```
Statusline — Claude Code Session Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Model         Opus 4.5
Context       ████░░░░░░ 45% (90,000 / 200,000 tokens)
Duration      12m 34s
Config Files  2 loaded

Active Tools  3 running
               • Read (2 instances)
               • Bash (1 instance)

Completed     ✓ Glob ×4 | ✓ Bash ×8 | ✓ Read ×12

Running Tasks ⏳ 2 pending | 🔄 1 in progress | ✓ 5 completed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Related Commands

- `/statusline:enable` — Enable real-time status updates
- `/statusline:disable` — Disable status monitoring
