#!/bin/bash

# Circuit Breaker for Ralph Wiggum
# Prevents runaway loops by detecting stagnation, errors, and duplicate outputs

set -eo pipefail

CIRCUIT_STATE_FILE="${RALPH_STATE_DIR:-.claude}/ralph-circuit.json"
MAX_NO_PROGRESS_LOOPS=${RALPH_MAX_NO_PROGRESS:-3}
MAX_CONSECUTIVE_ERRORS=${RALPH_MAX_ERRORS:-5}
MAX_IDENTICAL_OUTPUTS=${RALPH_MAX_IDENTICAL:-3}
HALF_OPEN_THRESHOLD=${RALPH_HALF_OPEN_THRESHOLD:-2}

# Cross-platform hash function (works on macOS, Linux, WSL)
_hash() {
  if command -v md5sum &>/dev/null; then
    md5sum | cut -d' ' -f1
  elif command -v md5 &>/dev/null; then
    md5 -q
  else
    # Fallback: use cksum if neither available
    cksum | cut -d' ' -f1
  fi
}

init_circuit_breaker() {
  [[ -f "$CIRCUIT_STATE_FILE" ]] && return
  cat > "$CIRCUIT_STATE_FILE" <<EOF
{
  "state": "CLOSED",
  "no_progress_count": 0,
  "error_count": 0,
  "identical_output_count": 0,
  "last_file_hash": "",
  "last_output_hash": "",
  "last_error": "",
  "history": [],
  "opened_at": null,
  "opened_reason": null,
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
}

get_circuit_state() {
  init_circuit_breaker
  jq -r '.state' "$CIRCUIT_STATE_FILE"
}

can_execute() {
  [[ "$(get_circuit_state)" != "OPEN" ]]
}

calculate_file_hash() {
  local project_dir="${1:-.}"
  # Find all relevant files and hash their contents
  local file_list
  file_list=$(find "$project_dir" -type f \
    \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" \
       -o -name "*.rs" -o -name "*.java" -o -name "*.sh" -o -name "*.md" \
       -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" \) \
    ! -path "*node_modules*" ! -path "*/.git/*" ! -path "*/.claude/*" \
    2>/dev/null | sort)

  if [[ -z "$file_list" ]]; then
    echo "no_files"
    return
  fi

  # Hash file contents (cross-platform)
  echo "$file_list" | xargs cat 2>/dev/null | _hash || echo "no_files"
}

calculate_output_hash() {
  echo -n "$1" | _hash 2>/dev/null || echo "no_output"
}

record_loop_result() {
  local output="${1:-}"
  local error="${2:-}"
  local files_changed="${3:-0}"

  init_circuit_breaker

  local current_state=$(jq -r '.state' "$CIRCUIT_STATE_FILE")
  local current_file_hash=$(calculate_file_hash)
  local current_output_hash=$(calculate_output_hash "$output")
  local last_file_hash=$(jq -r '.last_file_hash' "$CIRCUIT_STATE_FILE")
  local last_output_hash=$(jq -r '.last_output_hash' "$CIRCUIT_STATE_FILE")
  local no_progress_count=$(jq -r '.no_progress_count' "$CIRCUIT_STATE_FILE")
  local error_count=$(jq -r '.error_count' "$CIRCUIT_STATE_FILE")
  local identical_output_count=$(jq -r '.identical_output_count' "$CIRCUIT_STATE_FILE")

  local new_state="$current_state"
  local transition_reason=""

  # Check progress
  local has_progress=false
  [[ "$current_file_hash" != "$last_file_hash" ]] || [[ "$files_changed" -gt 0 ]] && has_progress=true

  # Check identical output
  local is_identical_output=false
  [[ "$current_output_hash" == "$last_output_hash" ]] && [[ -n "$last_output_hash" ]] && is_identical_output=true

  # Update counters
  if [[ "$has_progress" == "true" ]]; then
    no_progress_count=0
    identical_output_count=0
  else
    ((no_progress_count++)) || true
  fi

  [[ "$is_identical_output" == "true" ]] && ((identical_output_count++)) || identical_output_count=0
  [[ -n "$error" ]] && ((error_count++)) || error_count=0

  # State transitions
  case "$current_state" in
    CLOSED)
      if [[ $error_count -ge $MAX_CONSECUTIVE_ERRORS ]]; then
        new_state="OPEN"; transition_reason="consecutive_errors_exceeded"
      elif [[ $identical_output_count -ge $MAX_IDENTICAL_OUTPUTS ]]; then
        new_state="OPEN"; transition_reason="identical_outputs_exceeded"
      elif [[ $no_progress_count -ge $MAX_NO_PROGRESS_LOOPS ]]; then
        new_state="OPEN"; transition_reason="no_progress_exceeded"
      elif [[ $no_progress_count -ge $HALF_OPEN_THRESHOLD ]]; then
        new_state="HALF_OPEN"; transition_reason="monitoring_for_recovery"
      fi
      ;;
    HALF_OPEN)
      if [[ "$has_progress" == "true" ]]; then
        new_state="CLOSED"; transition_reason="progress_detected_recovery"
      elif [[ $no_progress_count -ge $MAX_NO_PROGRESS_LOOPS ]]; then
        new_state="OPEN"; transition_reason="no_recovery_detected"
      elif [[ $error_count -ge $MAX_CONSECUTIVE_ERRORS ]]; then
        new_state="OPEN"; transition_reason="errors_during_recovery"
      fi
      ;;
  esac

  # Build history entry
  local history_entry=$(jq -n \
    --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg state "$current_state" \
    --arg new_state "$new_state" \
    --argjson progress "$has_progress" \
    --argjson error "${has_error:-false}" \
    --argjson identical "$is_identical_output" \
    '{timestamp: $timestamp, from_state: $state, to_state: $new_state, progress: $progress, error: $error, identical_output: $identical}')

  # Update state file
  local opened_at="null"
  local opened_reason="null"
  if [[ "$new_state" == "OPEN" ]] && [[ "$current_state" != "OPEN" ]]; then
    opened_at="\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
    opened_reason="\"$transition_reason\""
  elif [[ "$current_state" == "OPEN" ]]; then
    opened_at=$(jq -r '.opened_at' "$CIRCUIT_STATE_FILE")
    opened_reason=$(jq -r '.opened_reason' "$CIRCUIT_STATE_FILE")
    [[ "$opened_at" != "null" ]] && opened_at="\"$opened_at\""
    [[ "$opened_reason" != "null" ]] && opened_reason="\"$opened_reason\""
  fi

  local history=$(jq --argjson entry "$history_entry" '.history = (.history + [$entry])[-10:]' "$CIRCUIT_STATE_FILE")

  echo "$history" | jq \
    --arg state "$new_state" \
    --argjson no_progress "$no_progress_count" \
    --argjson errors "$error_count" \
    --argjson identical "$identical_output_count" \
    --arg file_hash "$current_file_hash" \
    --arg output_hash "$current_output_hash" \
    --arg last_error "$error" \
    --argjson opened_at "$opened_at" \
    --argjson opened_reason "$opened_reason" \
    '.state = $state | .no_progress_count = $no_progress | .error_count = $errors |
     .identical_output_count = $identical | .last_file_hash = $file_hash |
     .last_output_hash = $output_hash | .last_error = $last_error |
     .opened_at = $opened_at | .opened_reason = $opened_reason |
     .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))' > "${CIRCUIT_STATE_FILE}.tmp"

  mv "${CIRCUIT_STATE_FILE}.tmp" "$CIRCUIT_STATE_FILE"
  echo "$new_state"
}

get_halt_reason() {
  init_circuit_breaker
  local reason=$(jq -r '.opened_reason // "unknown"' "$CIRCUIT_STATE_FILE")
  case "$reason" in
    consecutive_errors_exceeded) echo "Too many consecutive errors ($MAX_CONSECUTIVE_ERRORS)" ;;
    identical_outputs_exceeded) echo "Identical outputs ($MAX_IDENTICAL_OUTPUTS consecutive)" ;;
    no_progress_exceeded) echo "No file changes for $MAX_NO_PROGRESS_LOOPS iterations" ;;
    no_recovery_detected) echo "Failed to recover during monitoring" ;;
    errors_during_recovery) echo "Errors during recovery attempt" ;;
    *) echo "Circuit breaker triggered: $reason" ;;
  esac
}

show_circuit_status() {
  init_circuit_breaker
  local state=$(jq -r '.state' "$CIRCUIT_STATE_FILE")
  local no_progress=$(jq -r '.no_progress_count' "$CIRCUIT_STATE_FILE")
  local errors=$(jq -r '.error_count' "$CIRCUIT_STATE_FILE")
  local identical=$(jq -r '.identical_output_count' "$CIRCUIT_STATE_FILE")

  echo "Circuit Breaker:"
  echo "  State: $state"
  echo "  No Progress: $no_progress/$MAX_NO_PROGRESS_LOOPS"
  echo "  Errors: $errors/$MAX_CONSECUTIVE_ERRORS"
  echo "  Identical: $identical/$MAX_IDENTICAL_OUTPUTS"

  [[ "$state" == "OPEN" ]] && echo "  Reason: $(get_halt_reason)"
}

reset_circuit_breaker() {
  init_circuit_breaker
  jq '.state = "CLOSED" | .no_progress_count = 0 | .error_count = 0 |
      .identical_output_count = 0 | .opened_at = null | .opened_reason = null |
      .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))' \
    "$CIRCUIT_STATE_FILE" > "${CIRCUIT_STATE_FILE}.tmp"
  mv "${CIRCUIT_STATE_FILE}.tmp" "$CIRCUIT_STATE_FILE"
  echo "Circuit breaker reset"
}

cleanup_circuit_breaker() {
  rm -f "$CIRCUIT_STATE_FILE"
}

export -f _hash calculate_file_hash calculate_output_hash
export -f init_circuit_breaker get_circuit_state can_execute record_loop_result
export -f get_halt_reason show_circuit_status reset_circuit_breaker cleanup_circuit_breaker
