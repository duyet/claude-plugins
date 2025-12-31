#!/bin/bash
# Ralph Wiggum Status Script
# Shows current loop status, circuit breaker state, and response analysis

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
LIB_DIR="$PLUGIN_ROOT/lib"

# Load utilities for session isolation
[[ -f "$LIB_DIR/utils.sh" ]] && source "$LIB_DIR/utils.sh"

RALPH_STATE_DIR=$(get_ralph_state_dir)
SESSION_ID=$(get_session_id)

echo ""
echo "Ralph Loop Status"
echo "Session: ${SESSION_ID:-unknown}"
echo "============================================="

RALPH_LOOP_FILE=$(get_state_file_path "ralph-loop" "md")
RALPH_CIRCUIT_FILE=$(get_state_file_path "ralph-circuit" "json")
RALPH_ANALYSIS_FILE=$(get_state_file_path "ralph-analysis" "json")

if [[ -f "$RALPH_LOOP_FILE" ]]; then
  ITERATION=$(grep '^iteration:' "$RALPH_LOOP_FILE" | sed 's/iteration: *//')
  MAX_ITER=$(grep '^max_iterations:' "$RALPH_LOOP_FILE" | sed 's/max_iterations: *//')
  PROMISE=$(grep '^completion_promise:' "$RALPH_LOOP_FILE" | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')
  echo "Active: YES"
  echo "Iteration: $ITERATION"
  echo "Max: $(if [[ $MAX_ITER -gt 0 ]]; then echo $MAX_ITER; else echo 'unlimited'; fi)"
  [[ -n "$PROMISE" ]] && [[ "$PROMISE" != "null" ]] && echo "Promise: $PROMISE"
else
  echo "Active: NO"
fi

if [[ -f "$RALPH_CIRCUIT_FILE" ]]; then
  echo ""
  echo "Circuit Breaker:"
  jq -r '"  State: \(.state)\n  No Progress: \(.no_progress_count)\n  Errors: \(.error_count)"' "$RALPH_CIRCUIT_FILE"
fi

if [[ -f "$RALPH_ANALYSIS_FILE" ]]; then
  echo ""
  echo "Response Analysis:"
  jq -r '"  Confidence: \(.last_confidence)\n  Trend: \(.output_trend)\n  Exit: \(.exit_recommended)"' "$RALPH_ANALYSIS_FILE"
fi

echo "============================================="
