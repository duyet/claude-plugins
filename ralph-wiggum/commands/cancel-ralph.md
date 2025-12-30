---
description: "Cancel active Ralph Wiggum loop"
allowed-tools: ["Bash"]
hide-from-slash-command-tool: "true"
---

# Cancel Ralph

```!
if [[ -f .claude/ralph-loop.local.md ]]; then
  ITERATION=$(grep '^iteration:' .claude/ralph-loop.local.md | sed 's/iteration: *//')
  echo "FOUND_LOOP=true"
  echo "ITERATION=$ITERATION"
else
  echo "FOUND_LOOP=false"
fi
```

Check the output:

1. **If FOUND_LOOP=false**: Say "No active Ralph loop."

2. **If FOUND_LOOP=true**:
   - Run: `rm .claude/ralph-loop.local.md`
   - Say: "Ralph loop cancelled (was at iteration N)"
