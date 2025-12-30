#!/bin/bash

# Task Manager for Ralph Wiggum
# Hierarchical task tracking with progress monitoring

set -eo pipefail

TASK_STATE_FILE="${RALPH_STATE_DIR:-.claude}/ralph-tasks.json"
TASK_PLAN_FILE="${RALPH_STATE_DIR:-.claude}/ralph-plan.md"

init_task_manager() {
  [[ -f "$TASK_STATE_FILE" ]] && return
  cat > "$TASK_STATE_FILE" <<EOF
{
  "project_name": "",
  "total_phases": 0,
  "current_phase": 0,
  "phases": [],
  "progress_percentage": 0,
  "started_at": null,
  "last_activity": null,
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
}

create_task_plan() {
  local project_name="$1"
  shift
  local phases=("$@")

  init_task_manager
  local now=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  local phases_json="[]"
  local phase_num=1
  for phase in "${phases[@]}"; do
    phases_json=$(echo "$phases_json" | jq --arg name "$phase" --argjson num "$phase_num" \
      '. + [{phase_number: $num, name: $name, status: "pending", tasks: [], started_at: null, completed_at: null}]')
    ((phase_num++)) || true
  done

  jq -n --arg name "$project_name" --argjson total "${#phases[@]}" \
    --argjson phases "$phases_json" --arg now "$now" \
    '{project_name: $name, total_phases: $total, current_phase: 1, phases: $phases,
      progress_percentage: 0, started_at: $now, last_activity: $now, created_at: $now, updated_at: $now}' \
    > "$TASK_STATE_FILE"

  generate_plan_markdown
  echo "Task plan created with ${#phases[@]} phases"
}

add_task() {
  local phase_num="$1"
  local task_name="$2"
  local priority="${3:-medium}"

  init_task_manager
  local now=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  jq --argjson phase "$phase_num" --arg name "$task_name" --arg priority "$priority" --arg now "$now" \
    '(.phases[$phase - 1].tasks) += [{name: $name, status: "pending", priority: $priority, created_at: $now, completed_at: null}] |
     .last_activity = $now | .updated_at = $now' "$TASK_STATE_FILE" > "${TASK_STATE_FILE}.tmp"

  mv "${TASK_STATE_FILE}.tmp" "$TASK_STATE_FILE"
  generate_plan_markdown
}

complete_task() {
  local phase_num="$1"
  local task_index="$2"

  init_task_manager
  local now=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  jq --argjson phase "$phase_num" --argjson task "$task_index" --arg now "$now" \
    '(.phases[$phase - 1].tasks[$task]) |= (.status = "completed" | .completed_at = $now) |
     .last_activity = $now | .updated_at = $now' "$TASK_STATE_FILE" > "${TASK_STATE_FILE}.tmp"

  mv "${TASK_STATE_FILE}.tmp" "$TASK_STATE_FILE"
  update_progress
  generate_plan_markdown
}

complete_phase() {
  local phase_num="$1"

  init_task_manager
  local now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  local total_phases=$(jq -r '.total_phases' "$TASK_STATE_FILE")
  local next_phase=$((phase_num + 1))
  [[ $next_phase -gt $total_phases ]] && next_phase=$total_phases

  jq --argjson phase "$phase_num" --argjson next "$next_phase" --arg now "$now" \
    '(.phases[$phase - 1]) |= (.status = "completed" | .completed_at = $now) |
     .current_phase = $next | .last_activity = $now | .updated_at = $now' \
    "$TASK_STATE_FILE" > "${TASK_STATE_FILE}.tmp"

  mv "${TASK_STATE_FILE}.tmp" "$TASK_STATE_FILE"

  if [[ $next_phase -le $total_phases ]] && [[ $next_phase -ne $phase_num ]]; then
    jq --argjson next "$next_phase" --arg now "$now" \
      '(.phases[$next - 1]) |= (.status = "in_progress" | .started_at = $now)' \
      "$TASK_STATE_FILE" > "${TASK_STATE_FILE}.tmp"
    mv "${TASK_STATE_FILE}.tmp" "$TASK_STATE_FILE"
  fi

  update_progress
  generate_plan_markdown
}

start_phase() {
  local phase_num="$1"

  init_task_manager
  local now=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  jq --argjson phase "$phase_num" --arg now "$now" \
    '(.phases[$phase - 1]) |= (.status = "in_progress" | .started_at = $now) |
     .current_phase = $phase | .last_activity = $now | .updated_at = $now' \
    "$TASK_STATE_FILE" > "${TASK_STATE_FILE}.tmp"

  mv "${TASK_STATE_FILE}.tmp" "$TASK_STATE_FILE"
  generate_plan_markdown
}

update_progress() {
  init_task_manager

  local total_tasks=0
  local completed_tasks=0

  while IFS= read -r line; do
    ((total_tasks++)) || true
    echo "$line" | grep -q '"completed"' && ((completed_tasks++)) || true
  done < <(jq -c '.phases[].tasks[]' "$TASK_STATE_FILE" 2>/dev/null || echo "")

  local total_phases=$(jq -r '.total_phases' "$TASK_STATE_FILE")
  local completed_phases=$(jq '[.phases[] | select(.status == "completed")] | length' "$TASK_STATE_FILE")

  local progress=0
  if [[ $total_tasks -gt 0 ]]; then
    progress=$((completed_tasks * 100 / total_tasks))
  elif [[ $total_phases -gt 0 ]]; then
    progress=$((completed_phases * 100 / total_phases))
  fi

  jq --argjson progress "$progress" \
    '.progress_percentage = $progress | .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))' \
    "$TASK_STATE_FILE" > "${TASK_STATE_FILE}.tmp"

  mv "${TASK_STATE_FILE}.tmp" "$TASK_STATE_FILE"
}

all_tasks_complete() {
  init_task_manager
  local progress=$(jq -r '.progress_percentage' "$TASK_STATE_FILE")
  [[ "$progress" == "100" ]] && echo "true" || echo "false"
}

detect_task_completion() {
  local output="$1"
  echo "$output" | grep -cE '\[x\]|\[X\]|✓|✅|DONE:' || echo "0"
}

generate_plan_markdown() {
  init_task_manager

  local project_name=$(jq -r '.project_name' "$TASK_STATE_FILE")
  local progress=$(jq -r '.progress_percentage' "$TASK_STATE_FILE")

  {
    echo "# Task Plan: $project_name"
    echo ""
    echo "**Progress:** ${progress}%"
    echo ""
    echo "---"
    echo ""

    jq -r '.phases[] | "## Phase \(.phase_number): \(.name)\n**Status:** \(.status)\n"' "$TASK_STATE_FILE"

    local phase_num=1
    while IFS= read -r phase; do
      local phase_name=$(echo "$phase" | jq -r '.name')
      echo "### Tasks for Phase $phase_num: $phase_name"
      echo ""
      echo "$phase" | jq -r '.tasks[] | "- [\(if .status == "completed" then "x" else " " end)] \(.name) (\(.priority))"'
      echo ""
      ((phase_num++)) || true
    done < <(jq -c '.phases[]' "$TASK_STATE_FILE" 2>/dev/null)

    echo "---"
    echo "*Auto-generated by Ralph Wiggum*"
  } > "$TASK_PLAN_FILE"
}

show_task_status() {
  init_task_manager

  local project_name=$(jq -r '.project_name' "$TASK_STATE_FILE")
  local progress=$(jq -r '.progress_percentage' "$TASK_STATE_FILE")
  local current_phase=$(jq -r '.current_phase' "$TASK_STATE_FILE")
  local total_phases=$(jq -r '.total_phases' "$TASK_STATE_FILE")

  echo "Task Manager:"
  echo "  Project: $project_name"
  echo "  Progress: ${progress}%"
  echo "  Phase: $current_phase of $total_phases"

  if [[ $current_phase -gt 0 ]]; then
    local phase_name=$(jq -r ".phases[$((current_phase - 1))].name" "$TASK_STATE_FILE")
    local phase_status=$(jq -r ".phases[$((current_phase - 1))].status" "$TASK_STATE_FILE")
    local phase_tasks=$(jq ".phases[$((current_phase - 1))].tasks | length" "$TASK_STATE_FILE")
    local completed_tasks=$(jq "[.phases[$((current_phase - 1))].tasks[] | select(.status == \"completed\")] | length" "$TASK_STATE_FILE")

    echo "  Current: $phase_name ($phase_status)"
    echo "  Tasks: $completed_tasks/$phase_tasks"
  fi
}

get_task_progress() {
  init_task_manager
  jq -r '.progress_percentage' "$TASK_STATE_FILE"
}

reset_task_manager() {
  rm -f "$TASK_STATE_FILE" "$TASK_PLAN_FILE"
  init_task_manager
  echo "Task manager reset"
}

cleanup_task_manager() {
  rm -f "$TASK_STATE_FILE" "$TASK_PLAN_FILE"
}

export -f init_task_manager create_task_plan add_task complete_task complete_phase start_phase
export -f update_progress all_tasks_complete detect_task_completion generate_plan_markdown
export -f show_task_status get_task_progress reset_task_manager cleanup_task_manager
