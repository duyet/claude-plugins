#!/usr/bin/env bash
# Cancel active Ralph Wiggum loop

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
LIB_DIR="$PLUGIN_ROOT/lib"

# Load utilities for session isolation
[[ -f "$LIB_DIR/utils.sh" ]] && source "$LIB_DIR/utils.sh"

SESSION_ID=$(get_session_id)
CLAUDE_ENV_FILE="${CLAUDE_ENV_FILE:-${CLAUDE_PLUGIN_ROOT}/.env}"

RALPH_LOOP_FILE=$(get_state_file_path "ralph-loop" "md")

if [[ -f "$RALPH_LOOP_FILE" ]]; then
    ITERATION=$(grep '^iteration:' "$RALPH_LOOP_FILE" 2>/dev/null | sed 's/iteration: *//')
    rm -f "$RALPH_LOOP_FILE"

    # Clean up all session state
    cleanup_session_state

    if [[ -n "$ITERATION" ]]; then
        echo "Ralph loop cancelled at iteration $ITERATION"
    else
        echo "Ralph loop cancelled"
    fi
else
    echo "No active Ralph loop found in this session"
fi
