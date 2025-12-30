#!/usr/bin/env bats

# Unit tests for ralph-wiggum bash scripts

setup() {
  export RALPH_STATE_DIR="$BATS_TMPDIR/ralph-test-$$"
  mkdir -p "$RALPH_STATE_DIR"

  # Source the lib scripts
  source "$BATS_TEST_DIRNAME/../ralph-wiggum/lib/response_analyzer.sh"
  source "$BATS_TEST_DIRNAME/../ralph-wiggum/lib/circuit_breaker.sh"
}

teardown() {
  rm -rf "$RALPH_STATE_DIR"
}

# Response Analyzer Tests

@test "response_analyzer: init creates state file" {
  init_response_analyzer
  [[ -f "$RALPH_STATE_DIR/ralph-analysis.json" ]]
}

@test "response_analyzer: detect completion signals returns confidence" {
  result=$(detect_completion_signals "Task complete, all tests pass")
  confidence=$(echo "$result" | jq -r '.confidence')
  [[ $confidence -gt 0 ]]
}

@test "response_analyzer: detect completion signals with no keywords returns 0" {
  result=$(detect_completion_signals "Hello world")
  confidence=$(echo "$result" | jq -r '.confidence')
  [[ $confidence -eq 0 ]]
}

@test "response_analyzer: detect test only loop identifies test commands" {
  result=$(detect_test_only_loop "Running npm test...")
  [[ "$result" == "true" ]]
}

@test "response_analyzer: detect test only loop with implementation returns false" {
  result=$(detect_test_only_loop "Creating new function and running npm test")
  [[ "$result" == "false" ]]
}

@test "response_analyzer: detect stuck state identifies stuck keywords" {
  result=$(detect_stuck_state "I am stuck and blocked on this issue")
  [[ "$result" == "true" ]]
}

@test "response_analyzer: detect stuck state with normal output returns false" {
  result=$(detect_stuck_state "Making progress on the implementation")
  [[ "$result" == "false" ]]
}

# Circuit Breaker Tests

@test "circuit_breaker: init creates state file" {
  init_circuit_breaker
  [[ -f "$RALPH_STATE_DIR/ralph-circuit.json" ]]
}

@test "circuit_breaker: initial state is CLOSED" {
  init_circuit_breaker
  state=$(get_circuit_state)
  [[ "$state" == "CLOSED" ]]
}

@test "circuit_breaker: can_execute returns true when CLOSED" {
  init_circuit_breaker
  run can_execute
  [[ "$status" -eq 0 ]]
}

@test "circuit_breaker: reset_circuit_breaker resets state" {
  init_circuit_breaker
  reset_circuit_breaker
  state=$(get_circuit_state)
  [[ "$state" == "CLOSED" ]]
}
