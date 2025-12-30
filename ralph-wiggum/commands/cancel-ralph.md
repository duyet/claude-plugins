---
description: "Cancel active Ralph Wiggum loop"
allowed-tools: ["Bash"]
hide-from-slash-command-tool: "true"
---

# Cancel Ralph

Check if a Ralph loop is active and cancel it:

```!
test -f .claude/ralph-loop.local.md && grep -q . .claude/ralph-loop.local.md && { grep '^iteration:' .claude/ralph-loop.local.md; rm .claude/ralph-loop.local.md; echo "Loop cancelled"; } || echo "No active Ralph loop"
```
