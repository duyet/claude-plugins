---
description: "Cancel active Ralph Wiggum loop"
allowed-tools: ["Bash"]
hide-from-slash-command-tool: "true"
---

# Cancel Ralph

Check if a Ralph loop is active and cancel it:

```!
if [[ -f .claude/ralph-loop.local.md ]]; then ITERATION=$(grep '^iteration:' .claude/ralph-loop.local.md | sed 's/iteration: *//'); rm .claude/ralph-loop.local.md; echo "Ralph loop cancelled (was at iteration $ITERATION)"; else echo "No active Ralph loop"; fi
```
