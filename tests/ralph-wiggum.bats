#!/usr/bin/env bats

# Unit tests for ralph-wiggum bash scripts

setup() {
  export RALPH_STATE_DIR="$BATS_TMPDIR/ralph-test-$$"
  mkdir -p "$RALPH_STATE_DIR"

  # Source the lib scripts
  source "$BATS_TEST_DIRNAME/../ralph-wiggum/lib/response_analyzer.sh"
  source "$BATS_TEST_DIRNAME/../ralph-wiggum/lib/circuit_breaker.sh"
  source "$BATS_TEST_DIRNAME/../ralph-wiggum/lib/api_limit_handler.sh"
}

teardown() {
  rm -rf "$RALPH_STATE_DIR"
}

# Cross-Platform Hash Function Tests

@test "hash: _hash function exists and is callable" {
  run bash -c 'echo "test" | _hash'
  [[ "$status" -eq 0 ]]
  [[ -n "$output" ]]
}

@test "hash: _hash produces consistent output" {
  hash1=$(echo "hello world" | _hash)
  hash2=$(echo "hello world" | _hash)
  [[ "$hash1" == "$hash2" ]]
}

@test "hash: _hash produces different output for different input" {
  hash1=$(echo "hello" | _hash)
  hash2=$(echo "world" | _hash)
  [[ "$hash1" != "$hash2" ]]
}

@test "hash: calculate_output_hash works" {
  result=$(calculate_output_hash "test string")
  [[ -n "$result" ]]
  [[ "$result" != "no_output" ]]
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

# API Limit Handler Tests

@test "api_limit_handler: init creates state file" {
  init_limit_handler
  [[ -f "$RALPH_STATE_DIR/ralph-limits.json" ]]
}

@test "api_limit_handler: detect rate limit identifies 429" {
  result=$(detect_rate_limit "Error: 429 Too Many Requests")
  [[ "$result" == "true" ]]
}

@test "api_limit_handler: detect rate limit identifies rate limit text" {
  result=$(detect_rate_limit "You have hit the rate limit")
  [[ "$result" == "true" ]]
}

@test "api_limit_handler: detect rate limit returns false for normal text" {
  result=$(detect_rate_limit "Everything is working fine")
  [[ "$result" == "false" ]]
}

@test "api_limit_handler: determine limit type identifies 5-hour limit" {
  result=$(determine_limit_type "You have exceeded your 5-hour usage limit")
  [[ "$result" == "5_hour_limit" ]]
}

@test "api_limit_handler: calculate wait time returns correct seconds" {
  result=$(calculate_wait_time "5_hour_limit")
  [[ "$result" == "3600" ]]

  result=$(calculate_wait_time "rate_limit")
  [[ "$result" == "60" ]]
}
