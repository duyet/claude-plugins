#!/bin/bash

# Ralph Loop Setup Script
# Creates state file for in-session Ralph loop with safety controls

set -euo pipefail

# Parse arguments
PROMPT_PARTS=()
MAX_ITERATIONS=0
COMPLETION_PROMISE="null"
ENABLE_CIRCUIT_BREAKER="true"
ENABLE_SMART_EXIT="true"
ENABLE_RATE_LIMIT="true"
RESET_CIRCUIT=false
SHOW_STATUS=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      cat << 'EOF'
Ralph Loop - Self-referential development loop

USAGE:
  /ralph-loop [PROMPT] [OPTIONS]

OPTIONS:
  --max-iterations <n>          Stop after N iterations (default: unlimited)
  --completion-promise <text>   Promise phrase to signal completion
  --no-circuit-breaker          Disable stagnation detection
  --no-smart-exit               Disable completion analysis
  --no-rate-limit               Disable rate limit handling
  --reset-circuit               Reset circuit breaker state
  --status                      Show loop status
  -h, --help                    Show this help

EXAMPLES:
  /ralph-loop Build a todo API --completion-promise DONE --max-iterations 20
  /ralph-loop Fix the auth bug --max-iterations 10
  /ralph-loop --status

STOP CONDITIONS:
  - --max-iterations reached
  - <promise>TEXT</promise> matches --completion-promise
  - Circuit breaker opens (stagnation/errors)
  - Smart exit triggers (completion detected)
  - API rate limit reached

MONITORING:
  cat .claude/ralph-loop.local.md    # Loop state
  cat .claude/ralph-circuit.json     # Circuit breaker
  cat .claude/ralph-analysis.json    # Response analysis
EOF
      exit 0
      ;;
    --max-iterations)
      if [[ -z "${2:-}" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "Error: --max-iterations requires a number" >&2
        exit 1
      fi
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --completion-promise)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --completion-promise requires text" >&2
        exit 1
      fi
      COMPLETION_PROMISE="$2"
      shift 2
      ;;
    --no-circuit-breaker)
      ENABLE_CIRCUIT_BREAKER="false"
      shift
      ;;
    --no-smart-exit)
      ENABLE_SMART_EXIT="false"
      shift
      ;;
    --no-rate-limit)
      ENABLE_RATE_LIMIT="false"
      shift
      ;;
    --reset-circuit)
      RESET_CIRCUIT=true
      shift
      ;;
    --status)
      SHOW_STATUS=true
      shift
      ;;
    *)
      PROMPT_PARTS+=("$1")
      shift
      ;;
  esac
done

# Handle status display
if [[ "$SHOW_STATUS" == "true" ]]; then
  echo ""
  echo "Ralph Loop Status"
  echo "============================================="

  if [[ -f .claude/ralph-loop.local.md ]]; then
    ITERATION=$(grep '^iteration:' .claude/ralph-loop.local.md | sed 's/iteration: *//')
    MAX_ITER=$(grep '^max_iterations:' .claude/ralph-loop.local.md | sed 's/max_iterations: *//')
    echo "Active: YES"
    echo "Iteration: $ITERATION"
    echo "Max: $(if [[ $MAX_ITER -gt 0 ]]; then echo $MAX_ITER; else echo 'unlimited'; fi)"
  else
    echo "Active: NO"
  fi

  if [[ -f .claude/ralph-circuit.json ]]; then
    echo ""
    echo "Circuit Breaker:"
    jq -r '"  State: \(.state)\n  No Progress: \(.no_progress_count)\n  Errors: \(.error_count)"' .claude/ralph-circuit.json
  fi

  if [[ -f .claude/ralph-analysis.json ]]; then
    echo ""
    echo "Response Analysis:"
    jq -r '"  Confidence: \(.last_confidence)\n  Trend: \(.output_trend)\n  Exit: \(.exit_recommended)"' .claude/ralph-analysis.json
  fi

  echo "============================================="
  exit 0
fi

# Reset circuit breaker if requested
if [[ "$RESET_CIRCUIT" == "true" ]]; then
  rm -f .claude/ralph-circuit.json .claude/ralph-analysis.json
  echo "Circuit breaker reset"
fi

# Join prompt parts
PROMPT="${PROMPT_PARTS[*]}"

if [[ -z "$PROMPT" ]]; then
  echo "Error: No prompt provided" >&2
  echo "" >&2
  echo "Usage: /ralph-loop \"Your task\" [OPTIONS]" >&2
  echo "" >&2
  echo "Examples:" >&2
  echo "  /ralph-loop Build a REST API" >&2
  echo "  /ralph-loop Fix auth --max-iterations 10" >&2
  echo "" >&2
  echo "For options: /ralph-loop --help" >&2
  exit 1
fi

# Create state file
mkdir -p .claude

if [[ -n "$COMPLETION_PROMISE" ]] && [[ "$COMPLETION_PROMISE" != "null" ]]; then
  COMPLETION_PROMISE_YAML="\"$COMPLETION_PROMISE\""
else
  COMPLETION_PROMISE_YAML="null"
fi

cat > .claude/ralph-loop.local.md <<EOF
---
active: true
iteration: 1
max_iterations: $MAX_ITERATIONS
completion_promise: $COMPLETION_PROMISE_YAML
circuit_breaker: $ENABLE_CIRCUIT_BREAKER
smart_exit: $ENABLE_SMART_EXIT
rate_limit_handler: $ENABLE_RATE_LIMIT
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
---

$PROMPT
EOF

# Output
echo "Ralph loop activated"
echo ""
echo "Iteration: 1"
echo "Max iterations: $(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo $MAX_ITERATIONS; else echo 'unlimited'; fi)"
echo "Completion promise: $(if [[ "$COMPLETION_PROMISE" != "null" ]]; then echo "$COMPLETION_PROMISE"; else echo 'none'; fi)"
echo ""

if [[ "$ENABLE_CIRCUIT_BREAKER" == "true" ]]; then
  echo "Circuit breaker: ON (stops on stagnation)"
fi
if [[ "$ENABLE_SMART_EXIT" == "true" ]]; then
  echo "Smart exit: ON (detects completion)"
fi
if [[ "$ENABLE_RATE_LIMIT" == "true" ]]; then
  echo "Rate limit: ON (pauses on limits)"
fi

echo ""
echo "To monitor: /ralph-loop --status"

if [[ "$COMPLETION_PROMISE" != "null" ]]; then
  echo ""
  echo "To complete: output <promise>$COMPLETION_PROMISE</promise>"
fi

echo ""
echo "$PROMPT"
