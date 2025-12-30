---
description: "Show Ralph Wiggum loop status"
allowed-tools: ["Bash"]
hide-from-slash-command-tool: "true"
---

# Ralph Status

```!
echo ""
echo "Ralph Loop Status"
echo "============================================="

if [[ -f .claude/ralph-loop.local.md ]]; then
  ITERATION=$(grep '^iteration:' .claude/ralph-loop.local.md | sed 's/iteration: *//')
  MAX_ITER=$(grep '^max_iterations:' .claude/ralph-loop.local.md | sed 's/max_iterations: *//')
  PROMISE=$(grep '^completion_promise:' .claude/ralph-loop.local.md | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')
  echo "Active: YES"
  echo "Iteration: $ITERATION"
  echo "Max: $(if [[ $MAX_ITER -gt 0 ]]; then echo $MAX_ITER; else echo 'unlimited'; fi)"
  [[ -n "$PROMISE" ]] && [[ "$PROMISE" != "null" ]] && echo "Promise: $PROMISE"
else
  echo "Active: NO"
fi

if [[ -f .claude/ralph-circuit.json ]]; then
  echo ""
  echo "Circuit Breaker:"
  jq -r '"  State: \(.state)\n  No Progress: \(.no_progress_count)\n  Errors: \(.error_count)"' .claude/ralph-circuit.json
fi

if [[ -f .claude/ralph-analysis.json ]]; then
  echo ""
  echo "Response Analysis:"
  jq -r '"  Confidence: \(.last_confidence)\n  Trend: \(.output_trend)\n  Exit: \(.exit_recommended)"' .claude/ralph-analysis.json
fi

echo "============================================="
```

Report the status to the user.
