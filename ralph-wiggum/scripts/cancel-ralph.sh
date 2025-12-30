#!/usr/bin/env bash
# Cancel active Ralph Wiggum loop

LOOP_FILE=".claude/ralph-loop.local.md"

if [[ -f "$LOOP_FILE" ]]; then
    ITERATION=$(grep '^iteration:' "$LOOP_FILE" 2>/dev/null | sed 's/iteration: *//')
    rm -f "$LOOP_FILE"
    if [[ -n "$ITERATION" ]]; then
        echo "Ralph loop cancelled at iteration $ITERATION"
    else
        echo "Ralph loop cancelled"
    fi
else
    echo "No active Ralph loop found"
fi
