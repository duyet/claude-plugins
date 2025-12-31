#!/bin/bash

# API Limit Handler for Ralph Wiggum
# Handles Claude's 5-hour usage limits and rate limiting

set -eo pipefail

# Use get_state_file_path utility if available, otherwise use RALPH_STATE_DIR
if type get_state_file_path &>/dev/null; then
  LIMIT_STATE_FILE=$(get_state_file_path "ralph-limits" "json")
else
  LIMIT_STATE_FILE="${RALPH_STATE_DIR:-.claude}/ralph-limits.json"
fi
DEFAULT_WAIT_SECONDS=${RALPH_WAIT_SECONDS:-3600}

# Rate limit patterns as space-separated string (portable across bash versions)
RATE_LIMIT_PATTERNS="rate_limit too_many_requests 429 quota_exceeded usage_limit daily_limit hourly_limit 5-hour 5_hour exceeded_limit limit_exceeded overloaded capacity"

init_limit_handler() {
  [[ -f "$LIMIT_STATE_FILE" ]] && return
  cat > "$LIMIT_STATE_FILE" <<EOF
{
  "is_limited": false,
  "limit_type": null,
  "limited_at": null,
  "resume_at": null,
  "limit_events": [],
  "total_limits_hit": 0,
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
}

detect_rate_limit() {
  local output="$1"
  local output_lower=$(echo "$output" | tr '[:upper:]' '[:lower:]')

  for pattern in $RATE_LIMIT_PATTERNS; do
    # Convert underscores to spaces/regex for matching
    local search_term="${pattern//_/[_ ]}"
    echo "$output_lower" | grep -qiE "$search_term" && { echo "true"; return 0; }
  done
  echo "false"
}

determine_limit_type() {
  local output="$1"
  local output_lower=$(echo "$output" | tr '[:upper:]' '[:lower:]')

  echo "$output_lower" | grep -qiE "5.hour|5-hour|usage.limit" && { echo "5_hour_limit"; return; }
  echo "$output_lower" | grep -qiE "rate.limit|429|too.many" && { echo "rate_limit"; return; }
  echo "$output_lower" | grep -qiE "daily.limit|quota" && { echo "daily_limit"; return; }
  echo "$output_lower" | grep -qiE "overload|capacity" && { echo "capacity_limit"; return; }
  echo "unknown_limit"
}

calculate_wait_time() {
  local limit_type="$1"
  case "$limit_type" in
    5_hour_limit) echo 3600 ;;
    rate_limit) echo 60 ;;
    daily_limit) echo 3600 ;;
    capacity_limit) echo 300 ;;
    *) echo "$DEFAULT_WAIT_SECONDS" ;;
  esac
}

record_limit_event() {
  local limit_type="$1"
  local wait_seconds="$2"

  init_limit_handler

  local now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  local resume_at=$(date -u -v+"${wait_seconds}S" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || \
                    date -u -d "+${wait_seconds} seconds" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "$now")

  local total_limits=$(jq -r '.total_limits_hit' "$LIMIT_STATE_FILE")
  ((total_limits++)) || true

  local event=$(jq -n --arg type "$limit_type" --arg time "$now" --argjson wait "$wait_seconds" \
    '{type: $type, occurred_at: $time, wait_seconds: $wait}')

  jq --argjson event "$event" --arg type "$limit_type" --arg now "$now" \
     --arg resume "$resume_at" --argjson total "$total_limits" \
    '.is_limited = true | .limit_type = $type | .limited_at = $now | .resume_at = $resume |
     .total_limits_hit = $total | .limit_events = (.limit_events + [$event])[-20:] | .updated_at = $now' \
    "$LIMIT_STATE_FILE" > "${LIMIT_STATE_FILE}.tmp"

  mv "${LIMIT_STATE_FILE}.tmp" "$LIMIT_STATE_FILE"
}

is_rate_limited() {
  init_limit_handler
  local is_limited=$(jq -r '.is_limited' "$LIMIT_STATE_FILE")
  [[ "$is_limited" != "true" ]] && { echo "false"; return; }

  local resume_at=$(jq -r '.resume_at // ""' "$LIMIT_STATE_FILE")
  [[ -z "$resume_at" ]] || [[ "$resume_at" == "null" ]] && { echo "false"; return; }

  local now_ts=$(date -u +%s)
  local resume_ts=$(date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$resume_at" +%s 2>/dev/null || \
                    date -u -d "$resume_at" +%s 2>/dev/null || echo "0")

  [[ $now_ts -ge $resume_ts ]] && { clear_limit; echo "false"; } || echo "true"
}

clear_limit() {
  init_limit_handler
  jq '.is_limited = false | .limit_type = null | .limited_at = null | .resume_at = null |
      .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))' \
    "$LIMIT_STATE_FILE" > "${LIMIT_STATE_FILE}.tmp"
  mv "${LIMIT_STATE_FILE}.tmp" "$LIMIT_STATE_FILE"
}

get_remaining_wait() {
  init_limit_handler
  local resume_at=$(jq -r '.resume_at // ""' "$LIMIT_STATE_FILE")
  [[ -z "$resume_at" ]] || [[ "$resume_at" == "null" ]] && { echo "0"; return; }

  local now_ts=$(date -u +%s)
  local resume_ts=$(date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$resume_at" +%s 2>/dev/null || \
                    date -u -d "$resume_at" +%s 2>/dev/null || echo "0")

  local remaining=$((resume_ts - now_ts))
  [[ $remaining -lt 0 ]] && remaining=0
  echo "$remaining"
}

format_duration() {
  local seconds="$1"
  [[ $seconds -lt 60 ]] && { echo "${seconds}s"; return; }
  [[ $seconds -lt 3600 ]] && { echo "$((seconds / 60))m $((seconds % 60))s"; return; }
  echo "$((seconds / 3600))h $(((seconds % 3600) / 60))m"
}

handle_rate_limit() {
  local output="$1"
  local is_limit=$(detect_rate_limit "$output")
  [[ "$is_limit" != "true" ]] && return 1

  local limit_type=$(determine_limit_type "$output")
  local wait_seconds=$(calculate_wait_time "$limit_type")
  record_limit_event "$limit_type" "$wait_seconds"

  echo ""
  echo "API LIMIT: $limit_type"
  echo "Wait: $(format_duration "$wait_seconds")"
}

show_limit_status() {
  init_limit_handler
  local is_limited=$(jq -r '.is_limited' "$LIMIT_STATE_FILE")
  local total_limits=$(jq -r '.total_limits_hit' "$LIMIT_STATE_FILE")

  echo "API Limit Handler:"
  echo "  Limited: $is_limited"
  echo "  Total: $total_limits"

  if [[ "$is_limited" == "true" ]]; then
    local limit_type=$(jq -r '.limit_type' "$LIMIT_STATE_FILE")
    local remaining=$(get_remaining_wait)
    echo "  Type: $limit_type"
    echo "  Remaining: $(format_duration "$remaining")"
  fi
}

reset_limit_handler() {
  rm -f "$LIMIT_STATE_FILE"
  init_limit_handler
  echo "Limit handler reset"
}

cleanup_limit_handler() {
  rm -f "$LIMIT_STATE_FILE"
}

export -f init_limit_handler detect_rate_limit determine_limit_type calculate_wait_time
export -f record_limit_event is_rate_limited clear_limit get_remaining_wait format_duration
export -f handle_rate_limit show_limit_status reset_limit_handler cleanup_limit_handler
