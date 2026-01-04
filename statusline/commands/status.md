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

Compact single-line format showing only relevant metrics:

```
📊 🟡 45% | Model: Opus 4.5 | 12m 34s | Tools: Glob×4 Bash×8 Read×12 | Agents: Explore(8s) | Tasks: 🔄 1 ⏳ 2 ✓ 5 | Context: 5 prompts
```

**Hidden values:**
- ✓ Model omitted if not available
- ✓ Tools hidden if none active
- ✓ Agents hidden if none running
- ✓ Tasks hidden if none exist
- ✓ Context details show included system prompts + matching tools
- ✓ Claude Code version hidden (just shows model name)

## Related Commands

- `/statusline:enable` — Enable real-time status updates
- `/statusline:disable` — Disable status monitoring
