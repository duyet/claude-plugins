#!/bin/bash

# Ralph Wiggum Stop Hook
# Intercepts exit attempts and feeds the same prompt back for iterative development

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
LIB_DIR="$PLUGIN_ROOT/lib"

# Load utilities for session isolation
[[ -f "$LIB_DIR/utils.sh" ]] && source "$LIB_DIR/utils.sh"

export RALPH_STATE_DIR
RALPH_STATE_DIR=$(get_ralph_state_dir)

load_modules() {
  local modules_loaded=0
  [[ -f "$LIB_DIR/circuit_breaker.sh" ]] && source "$LIB_DIR/circuit_breaker.sh" && ((modules_loaded++)) || true
  [[ -f "$LIB_DIR/response_analyzer.sh" ]] && source "$LIB_DIR/response_analyzer.sh" && ((modules_loaded++)) || true
  [[ -f "$LIB_DIR/api_limit_handler.sh" ]] && source "$LIB_DIR/api_limit_handler.sh" && ((modules_loaded++)) || true
  [[ -f "$LIB_DIR/task_manager.sh" ]] && source "$LIB_DIR/task_manager.sh" && ((modules_loaded++)) || true
  echo "$modules_loaded"
}

HOOK_INPUT=$(cat)

# Parse session_id from input (gracefully handle invalid JSON)
HOOK_SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // empty' 2>/dev/null || echo "")

# Get current session ID from env file if not in hook input
if [[ -z "$HOOK_SESSION_ID" ]] || [[ "$HOOK_SESSION_ID" == "null" ]]; then
  HOOK_SESSION_ID=$(get_session_id)
fi

RALPH_STATE_FILE=$(get_state_file_path "ralph-loop" "md")

# No active loop in this session - allow exit
if [[ ! -f "$RALPH_STATE_FILE" ]]; then
  exit 0
fi

# Verify state file belongs to this session
STATE_SESSION_ID=$(grep '^session_id:' "$RALPH_STATE_FILE" 2>/dev/null | sed 's/session_id: *//' || echo "")
if [[ -n "$STATE_SESSION_ID" ]] && [[ "$STATE_SESSION_ID" != "$HOOK_SESSION_ID" ]]; then
  # State file belongs to different session - ignore it
  exit 0
fi

MODULES_LOADED=$(load_modules)

# Parse state file frontmatter
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$RALPH_STATE_FILE")
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//')
COMPLETION_PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')

ENABLE_CIRCUIT_BREAKER=$(echo "$FRONTMATTER" | grep '^circuit_breaker:' | sed 's/circuit_breaker: *//' || echo "true")
ENABLE_SMART_EXIT=$(echo "$FRONTMATTER" | grep '^smart_exit:' | sed 's/smart_exit: *//' || echo "true")
ENABLE_RATE_LIMIT=$(echo "$FRONTMATTER" | grep '^rate_limit_handler:' | sed 's/rate_limit_handler: *//' || echo "true")

# Validate state file
if [[ ! "$ITERATION" =~ ^[0-9]+$ ]]; then
  echo "Ralph loop: Invalid iteration in state file" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

if [[ ! "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
  echo "Ralph loop: Invalid max_iterations in state file" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Check max iterations
if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  echo "Ralph loop: Max iterations ($MAX_ITERATIONS) reached"
  rm "$RALPH_STATE_FILE"
  [[ $MODULES_LOADED -gt 0 ]] && {
    type cleanup_circuit_breaker &>/dev/null && cleanup_circuit_breaker
    type cleanup_response_analyzer &>/dev/null && cleanup_response_analyzer
    type cleanup_limit_handler &>/dev/null && cleanup_limit_handler
    type cleanup_task_manager &>/dev/null && cleanup_task_manager
  }
  exit 0
fi

# Get transcript
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")

if [[ ! -f "$TRANSCRIPT_PATH" ]]; then
  echo "Ralph loop: Transcript not found" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

if ! grep -q '"role":"assistant"' "$TRANSCRIPT_PATH"; then
  echo "Ralph loop: No assistant messages in transcript" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

LAST_LINE=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -1)
if [[ -z "$LAST_LINE" ]]; then
  echo "Ralph loop: Failed to extract assistant message" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

LAST_OUTPUT=$(echo "$LAST_LINE" | jq -r '
  .message.content |
  map(select(.type == "text")) |
  map(.text) |
  join("\n")
' 2>/dev/null || echo "")

if [[ -z "$LAST_OUTPUT" ]]; then
  echo "Ralph loop: Failed to parse assistant message" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# API Rate Limit Detection
if [[ "$ENABLE_RATE_LIMIT" == "true" ]] && type detect_rate_limit &>/dev/null; then
  IS_RATE_LIMITED=$(detect_rate_limit "$LAST_OUTPUT")
  if [[ "$IS_RATE_LIMITED" == "true" ]]; then
    handle_rate_limit "$LAST_OUTPUT" >&2
    LIMIT_TYPE=$(determine_limit_type "$LAST_OUTPUT")
    WAIT_TIME=$(calculate_wait_time "$LIMIT_TYPE")

    echo "" >&2
    echo "API LIMIT: $LIMIT_TYPE" >&2
    echo "Wait: $(format_duration "$WAIT_TIME")" >&2
    echo "Ralph loop pausing." >&2

    jq -n \
      --arg reason "API limit: $LIMIT_TYPE. Wait $(format_duration "$WAIT_TIME")." \
      '{"decision": "block", "reason": $reason, "systemMessage": "Rate limit - loop paused"}'
    exit 0
  fi
fi

# Circuit Breaker Check
if [[ "$ENABLE_CIRCUIT_BREAKER" == "true" ]] && type can_execute &>/dev/null; then
  if ! can_execute; then
    HALT_REASON=$(get_halt_reason)
    echo "" >&2
    echo "CIRCUIT BREAKER OPEN" >&2
    echo "Reason: $HALT_REASON" >&2
    echo "To resume: /ralph-loop --reset-circuit" >&2
    rm "$RALPH_STATE_FILE"
    exit 0
  fi

  ERROR_DETECTED=""
  echo "$LAST_OUTPUT" | grep -qiE "error|failed|exception|traceback" && ERROR_DETECTED="error_in_output"

  FILES_CHANGED=0
  if command -v git &>/dev/null && git rev-parse --git-dir &>/dev/null; then
    FILES_CHANGED=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
  fi

  NEW_STATE=$(record_loop_result "$LAST_OUTPUT" "$ERROR_DETECTED" "$FILES_CHANGED")

  if [[ "$NEW_STATE" == "OPEN" ]]; then
    HALT_REASON=$(get_halt_reason)
    echo "" >&2
    echo "CIRCUIT BREAKER TRIPPED" >&2
    echo "Reason: $HALT_REASON" >&2
    show_circuit_status >&2
    rm "$RALPH_STATE_FILE"
    exit 0
  fi
fi

# Intelligent Exit Detection
if [[ "$ENABLE_SMART_EXIT" == "true" ]] && type analyze_response &>/dev/null; then
  ANALYSIS_RESULT=$(analyze_response "$LAST_OUTPUT" "$ITERATION")
  EXIT_RECOMMENDED=$(echo "$ANALYSIS_RESULT" | jq -r '.exit_recommended')
  CONFIDENCE=$(echo "$ANALYSIS_RESULT" | jq -r '.confidence')

  if [[ "$EXIT_RECOMMENDED" == "true" ]]; then
    EXIT_REASON=$(get_exit_reason)
    echo "" >&2
    echo "SMART EXIT" >&2
    echo "Confidence: $CONFIDENCE" >&2
    echo "Reason: $EXIT_REASON" >&2
    rm "$RALPH_STATE_FILE"
    cleanup_response_analyzer 2>/dev/null || true
    cleanup_circuit_breaker 2>/dev/null || true
    exit 0
  fi
fi

# Completion Promise Check
if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  PROMISE_TEXT=$(echo "$LAST_OUTPUT" | perl -0777 -pe 's/.*?<promise>(.*?)<\/promise>.*/$1/s; s/^\s+|\s+$//g; s/\s+/ /g' 2>/dev/null || echo "")

  if [[ -n "$PROMISE_TEXT" ]] && [[ "$PROMISE_TEXT" = "$COMPLETION_PROMISE" ]]; then
    echo "Ralph loop: Promise fulfilled <promise>$COMPLETION_PROMISE</promise>"
    rm "$RALPH_STATE_FILE"
    [[ $MODULES_LOADED -gt 0 ]] && {
      type cleanup_circuit_breaker &>/dev/null && cleanup_circuit_breaker
      type cleanup_response_analyzer &>/dev/null && cleanup_response_analyzer
      type cleanup_limit_handler &>/dev/null && cleanup_limit_handler
      type cleanup_task_manager &>/dev/null && cleanup_task_manager
    }
    exit 0
  fi
fi

# Continue loop
NEXT_ITERATION=$((ITERATION + 1))

PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$RALPH_STATE_FILE")

if [[ -z "$PROMPT_TEXT" ]]; then
  echo "Ralph loop: No prompt in state file" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Update iteration
TEMP_FILE="${RALPH_STATE_FILE}.tmp.$$"
sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$RALPH_STATE_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$RALPH_STATE_FILE"

# Build status message
CIRCUIT_STATUS=""
if [[ "$ENABLE_CIRCUIT_BREAKER" == "true" ]] && type get_circuit_state &>/dev/null; then
  CIRCUIT_STATE=$(get_circuit_state)
  [[ "$CIRCUIT_STATE" == "HALF_OPEN" ]] && CIRCUIT_STATUS=" | Circuit: MONITORING"
fi

ANALYSIS_STATUS=""
if [[ "$ENABLE_SMART_EXIT" == "true" ]] && type should_exit &>/dev/null; then
  ANALYSIS_FILE=$(get_state_file_path "ralph-analysis.json")
  [[ -f "$ANALYSIS_FILE" ]] && {
    LAST_CONF=$(jq -r '.last_confidence // 0' "$ANALYSIS_FILE")
    ANALYSIS_STATUS=" | Confidence: ${LAST_CONF}/40"
  }
fi

if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  SYSTEM_MSG="Ralph iteration $NEXT_ITERATION$CIRCUIT_STATUS$ANALYSIS_STATUS | Complete: <promise>$COMPLETION_PROMISE</promise>"
else
  SYSTEM_MSG="Ralph iteration $NEXT_ITERATION$CIRCUIT_STATUS$ANALYSIS_STATUS"
fi

jq -n \
  --arg prompt "$PROMPT_TEXT" \
  --arg msg "$SYSTEM_MSG" \
  '{"decision": "block", "reason": $prompt, "systemMessage": $msg}'

exit 0
