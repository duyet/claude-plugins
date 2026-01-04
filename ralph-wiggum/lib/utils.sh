#!/bin/bash

# Session isolation utilities for Ralph Wiggum
# Provides session-specific state management to prevent cross-session interference

# Set CLAUDE_PLUGIN_ROOT with fallback to script location
# Use ${VAR-default} (without colon) to avoid unbound variable error with set -u
if [[ -z "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
  CLAUDE_PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

CLAUDE_ENV_FILE="${CLAUDE_ENV_FILE:-${CLAUDE_PLUGIN_ROOT}/.env}"
RALPH_SESSION_DIR=".claude/ralph-session.local"

# Get current session ID from environment or env file
get_session_id() {
  if [[ -n "${CLAUDE_SESSION_ID:-}" ]]; then
    echo "$CLAUDE_SESSION_ID"
    return 0
  fi

  if [[ -f "$CLAUDE_ENV_FILE" ]]; then
    if grep -q "^CLAUDE_SESSION_ID=" "$CLAUDE_ENV_FILE"; then
      source "$CLAUDE_ENV_FILE"
      echo "${CLAUDE_SESSION_ID:-}"
    fi
  fi

  # Always return 0 even when no session found (caller handles empty string)
  return 0
}

# Get state directory (always .claude/ralph-session in project directory)
get_ralph_state_dir() {
  echo "$RALPH_SESSION_DIR"
}

# Ensure state directory exists
ensure_state_dir() {
  mkdir -p "$RALPH_SESSION_DIR"
}

# Get session-specific state file path with session_id suffix
# Usage: get_state_file_path "basename" "extension"
# Example: get_state_file_path "ralph-loop" "md" -> .claude/ralph-session/ralph-loop.{session_id}.md
get_state_file_path() {
  local basename="$1"
  local extension="$2"
  local session_id
  session_id=$(get_session_id)

  if [[ -n "$session_id" ]]; then
    echo "${RALPH_SESSION_DIR}/${basename}.${session_id}.${extension}"
  else
    # Fallback for legacy/migration scenarios
    echo ".claude/${basename}.local.${extension}"
  fi
}

# Clean up session state files
cleanup_session_state() {
  local session_id
  session_id=$(get_session_id)

  if [[ -n "$session_id" ]]; then
    # Remove all files matching this session_id
    rm -f "${RALPH_SESSION_DIR}"/*."${session_id}".* 2>/dev/null || true
    rm -f "$CLAUDE_ENV_FILE"
  fi
}

# Load session ID from hook input
load_session_from_hook_input() {
  local hook_input="$1"
  local session_id
  session_id=$(echo "$hook_input" | jq -r '.session_id // empty')

  if [[ -n "$session_id" ]] && [[ "$session_id" != "null" ]]; then
    export CLAUDE_SESSION_ID="$session_id"
    echo "CLAUDE_SESSION_ID=$session_id" > "$CLAUDE_ENV_FILE"
  fi
}

export -f get_session_id get_ralph_state_dir ensure_state_dir
export -f get_state_file_path cleanup_session_state load_session_from_hook_input
