---
description: "Start Ralph Wiggum loop in current session"
argument-hint: "PROMPT [--max-iterations N] [--completion-promise TEXT] [--no-circuit-breaker] [--no-smart-exit]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh)"]
hide-from-slash-command-tool: "true"
---

# Ralph Loop Command

Execute the setup script to initialize the Ralph loop:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" $ARGUMENTS

# Display completion promise if set
if [ -f .claude/ralph-loop.local.md ]; then
  PROMISE=$(grep '^completion_promise:' .claude/ralph-loop.local.md | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')
  if [ -n "$PROMISE" ] && [ "$PROMISE" != "null" ]; then
    echo ""
    echo "==============================================================="
    echo "COMPLETION PROMISE: $PROMISE"
    echo "==============================================================="
    echo ""
    echo "To complete this loop, output:"
    echo "  <promise>$PROMISE</promise>"
    echo ""
    echo "RULES:"
    echo "  - Use <promise> tags exactly as shown"
    echo "  - The statement MUST be true when you output it"
    echo "  - Do NOT output false statements to exit"
    echo "==============================================================="
  fi
fi
```

Work on the task. When you try to exit, the stop-hook feeds the same prompt back. You see previous work in files and git history, enabling iterative improvement.

## Active Safety Features

- **Circuit Breaker**: Stops after 3 iterations without file changes, or 5 consecutive errors
- **Intelligent Exit**: Analyzes responses for completion signals, exits at high confidence
- **API Limit Handler**: Pauses gracefully on rate limits

## Rules

If a completion promise is set, output `<promise>TEXT</promise>` ONLY when the statement is true. Do not lie to escape the loop.
