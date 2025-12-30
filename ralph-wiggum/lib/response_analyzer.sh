#!/bin/bash

# Response Analyzer for Ralph Wiggum
# Intelligent exit detection through semantic analysis of Claude's responses

set -euo pipefail

ANALYSIS_STATE_FILE="${RALPH_STATE_DIR:-.claude}/ralph-analysis.json"
COMPLETION_CONFIDENCE_THRESHOLD=${RALPH_COMPLETION_THRESHOLD:-40}
MAX_TEST_ONLY_LOOPS=${RALPH_MAX_TEST_ONLY:-5}
MAX_STUCK_LOOPS=${RALPH_MAX_STUCK:-3}

declare -A COMPLETION_KEYWORDS=(
  ["done"]=10 ["complete"]=15 ["completed"]=15 ["finished"]=12
  ["success"]=10 ["successful"]=10 ["all tests pass"]=20
  ["tests passing"]=18 ["implementation complete"]=20
  ["task complete"]=20 ["project complete"]=25
  ["ready for review"]=15 ["ready to deploy"]=15
)

declare -A STUCK_KEYWORDS=(
  ["stuck"]=1 ["blocked"]=1 ["cannot proceed"]=1 ["unable to"]=1
  ["failed repeatedly"]=1 ["same error"]=1 ["infinite loop"]=1 ["going in circles"]=1
)

init_response_analyzer() {
  [[ -f "$ANALYSIS_STATE_FILE" ]] && return
  cat > "$ANALYSIS_STATE_FILE" <<EOF
{
  "total_iterations": 0,
  "completion_signals": [],
  "test_only_loops": [],
  "stuck_signals": [],
  "confidence_scores": [],
  "last_confidence": 0,
  "last_output_length": 0,
  "output_trend": "stable",
  "exit_recommended": false,
  "exit_reason": null,
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
}

detect_completion_signals() {
  local output="$1"
  local output_lower=$(echo "$output" | tr '[:upper:]' '[:lower:]')
  local confidence=0
  local signals_found=()

  for keyword in "${!COMPLETION_KEYWORDS[@]}"; do
    if echo "$output_lower" | grep -qi "$keyword"; then
      ((confidence += ${COMPLETION_KEYWORDS[$keyword]})) || true
      signals_found+=("$keyword")
    fi
  done

  echo "$output" | grep -q "---RALPH_STATUS---" && { ((confidence += 15)) || true; signals_found+=("structured_status"); }
  echo "$output" | grep -qE '\[DONE\]|\[COMPLETE\]|\[FINISHED\]' && { ((confidence += 20)) || true; signals_found+=("explicit_marker"); }

  jq -n --argjson confidence "$confidence" --arg signals "$(IFS=,; echo "${signals_found[*]}")" \
    '{confidence: $confidence, signals: ($signals | split(","))}'
}

detect_test_only_loop() {
  local output="$1"
  local output_lower=$(echo "$output" | tr '[:upper:]' '[:lower:]')
  local test_commands=0
  local implementation_mentions=0

  for pattern in "npm test" "pytest" "jest" "cargo test" "go test" "bun test" "vitest" "mocha"; do
    echo "$output_lower" | grep -qi "$pattern" && ((test_commands++)) || true
  done

  for pattern in "creating" "writing" "implementing" "adding" "building" "function" "class" "component"; do
    echo "$output_lower" | grep -qi "$pattern" && ((implementation_mentions++)) || true
  done

  [[ $test_commands -gt 0 ]] && [[ $implementation_mentions -eq 0 ]] && echo "true" || echo "false"
}

detect_stuck_state() {
  local output="$1"
  local output_lower=$(echo "$output" | tr '[:upper:]' '[:lower:]')
  local stuck_count=0

  for keyword in "${!STUCK_KEYWORDS[@]}"; do
    echo "$output_lower" | grep -qi "$keyword" && ((stuck_count++)) || true
  done

  local error_mentions=$(echo "$output_lower" | grep -c "error\|failed\|exception" || echo "0")
  [[ $error_mentions -gt 5 ]] || [[ $stuck_count -ge 2 ]] && echo "true" || echo "false"
}

analyze_response() {
  local output="$1"
  local iteration="${2:-0}"

  init_response_analyzer

  local total_iterations=$(jq -r '.total_iterations' "$ANALYSIS_STATE_FILE")
  ((total_iterations++)) || true

  local last_output_length=$(jq -r '.last_output_length' "$ANALYSIS_STATE_FILE")
  local current_output_length=${#output}

  local completion_result=$(detect_completion_signals "$output")
  local completion_confidence=$(echo "$completion_result" | jq -r '.confidence')

  local is_test_only=$(detect_test_only_loop "$output")
  local is_stuck=$(detect_stuck_state "$output")

  # Output trend bonus
  local output_trend="stable"
  local trend_bonus=0
  if [[ $last_output_length -gt 0 ]]; then
    local ratio=$((current_output_length * 100 / last_output_length))
    [[ $ratio -lt 50 ]] && { output_trend="declining_fast"; trend_bonus=10; }
    [[ $ratio -ge 50 ]] && [[ $ratio -lt 80 ]] && { output_trend="declining"; trend_bonus=5; }
    [[ $ratio -gt 150 ]] && output_trend="increasing"
  fi

  # File changes bonus
  local files_changed=0
  command -v git &>/dev/null && git rev-parse --git-dir &>/dev/null && \
    files_changed=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
  [[ $files_changed -gt 0 ]] && ((completion_confidence += 20)) || true

  local total_confidence=$((completion_confidence + trend_bonus))

  # Update rolling windows
  local state=$(jq --argjson conf "$total_confidence" '.completion_signals = (.completion_signals + [$conf])[-5:]' "$ANALYSIS_STATE_FILE")
  state=$(echo "$state" | jq --argjson val "$is_test_only" '.test_only_loops = (.test_only_loops + [$val])[-5:]')
  state=$(echo "$state" | jq --argjson val "$is_stuck" '.stuck_signals = (.stuck_signals + [$val])[-5:]')

  # Exit recommendation
  local exit_recommended=false
  local exit_reason="null"

  [[ $total_confidence -ge $COMPLETION_CONFIDENCE_THRESHOLD ]] && { exit_recommended=true; exit_reason="\"confidence_threshold_reached\""; }

  local test_only_count=$(echo "$state" | jq '[.test_only_loops[] | select(. == true)] | length')
  [[ $test_only_count -ge $MAX_TEST_ONLY_LOOPS ]] && { exit_recommended=true; exit_reason="\"test_only_loop_limit\""; }

  local stuck_count=$(echo "$state" | jq '[.stuck_signals[] | select(. == true)] | length')
  [[ $stuck_count -ge $MAX_STUCK_LOOPS ]] && { exit_recommended=true; exit_reason="\"stuck_state_detected\""; }

  echo "$state" | jq \
    --argjson total "$total_iterations" \
    --argjson confidence "$total_confidence" \
    --argjson output_len "$current_output_length" \
    --arg trend "$output_trend" \
    --argjson exit "$exit_recommended" \
    --argjson reason "$exit_reason" \
    '.total_iterations = $total | .last_confidence = $confidence | .last_output_length = $output_len |
     .output_trend = $trend | .exit_recommended = $exit | .exit_reason = $reason |
     .confidence_scores = (.confidence_scores + [$confidence])[-10:] |
     .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))' > "${ANALYSIS_STATE_FILE}.tmp"

  mv "${ANALYSIS_STATE_FILE}.tmp" "$ANALYSIS_STATE_FILE"

  jq -n --argjson confidence "$total_confidence" --argjson exit_recommended "$exit_recommended" \
    --argjson exit_reason "$exit_reason" --arg trend "$output_trend" \
    --argjson is_test_only "$is_test_only" --argjson is_stuck "$is_stuck" \
    '{confidence: $confidence, exit_recommended: $exit_recommended, exit_reason: $exit_reason,
      output_trend: $trend, is_test_only: $is_test_only, is_stuck: $is_stuck}'
}

should_exit() {
  init_response_analyzer
  jq -r '.exit_recommended' "$ANALYSIS_STATE_FILE"
}

get_exit_reason() {
  init_response_analyzer
  local reason=$(jq -r '.exit_reason // "none"' "$ANALYSIS_STATE_FILE")
  case "$reason" in
    confidence_threshold_reached) echo "High completion confidence detected" ;;
    test_only_loop_limit) echo "Multiple test-only iterations" ;;
    stuck_state_detected) echo "Stuck state detected" ;;
    *) echo "No exit recommendation" ;;
  esac
}

show_analysis_status() {
  init_response_analyzer
  local confidence=$(jq -r '.last_confidence' "$ANALYSIS_STATE_FILE")
  local trend=$(jq -r '.output_trend' "$ANALYSIS_STATE_FILE")
  local iterations=$(jq -r '.total_iterations' "$ANALYSIS_STATE_FILE")
  local exit_rec=$(jq -r '.exit_recommended' "$ANALYSIS_STATE_FILE")

  echo "Response Analysis:"
  echo "  Iterations: $iterations"
  echo "  Confidence: $confidence/$COMPLETION_CONFIDENCE_THRESHOLD"
  echo "  Trend: $trend"
  echo "  Exit: $exit_rec"
  [[ "$exit_rec" == "true" ]] && echo "  Reason: $(get_exit_reason)"
}

reset_response_analyzer() {
  rm -f "$ANALYSIS_STATE_FILE"
  init_response_analyzer
  echo "Response analyzer reset"
}

cleanup_response_analyzer() {
  rm -f "$ANALYSIS_STATE_FILE"
}

export -f init_response_analyzer detect_completion_signals detect_test_only_loop detect_stuck_state
export -f analyze_response should_exit get_exit_reason show_analysis_status
export -f reset_response_analyzer cleanup_response_analyzer
