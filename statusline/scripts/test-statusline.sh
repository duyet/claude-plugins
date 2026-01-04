#!/bin/bash
# Statusline compatibility and regression tests
# Run: bash statusline/scripts/test-statusline.sh

STATUSLINE_SCRIPT="$HOME/.claude/statusline-command.sh"
CONFIG_FILE="$HOME/.claude/statusline.config.json"
BACKUP_CONFIG="$HOME/.claude/statusline.config.json.bak"

# Skip API usage limit fetching during tests for speed
export SKIP_RATE_LIMITS=1

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

PASSED=0
FAILED=0

# Backup config
[ -f "$CONFIG_FILE" ] && cp "$CONFIG_FILE" "$BACKUP_CONFIG"
trap '[ -f "$BACKUP_CONFIG" ] && mv "$BACKUP_CONFIG" "$CONFIG_FILE" || rm -f "$CONFIG_FILE"' EXIT

pass() { echo -e "${GREEN}✓${NC} $1"; PASSED=$((PASSED + 1)); }
fail() { echo -e "${RED}✗${NC} $1"; FAILED=$((FAILED + 1)); }

run() {
    echo "$2" | "$STATUSLINE_SCRIPT" 2>&1
}

# ============================================
echo "╔════════════════════════════════════════╗"
echo "║  Statusline Test Suite                 ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Dependencies
echo "=== Dependencies ==="
command -v jq &>/dev/null && pass "jq installed" || fail "jq missing"
[ -f "$STATUSLINE_SCRIPT" ] && pass "Script exists" || { fail "Script missing"; exit 1; }
echo ""

# Context tests
echo "=== Context ==="
echo '{"line_format":"3"}' > "$CONFIG_FILE"

out=$(run "ctx from current_usage" '{"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":42000}}}')
echo "$out" | grep -q "21%" && pass "Context from current_usage" || fail "Context from current_usage"

out=$(run "ctx fallback" '{"context_window":{"total_input_tokens":43000,"context_window_size":200000,"current_usage":null}}')
echo "$out" | grep -q "21%" && pass "Fallback to total_input_tokens" || fail "Fallback to total_input_tokens"

out=$(run "ctx hidden" '{"context_window":{"total_input_tokens":0,"context_window_size":200000}}')
echo "$out" | grep -q "Context.*0%" && fail "Should hide 0% context" || pass "Hides 0% context"
echo ""

# Line format tests
echo "=== Line Formats ==="

echo '{"line_format":"1"}' > "$CONFIG_FILE"
lines=$(run "1-line" '{"context_window":{"total_input_tokens":43000,"context_window_size":200000}}' | wc -l | tr -d ' ')
[ "$lines" -eq 1 ] && pass "1-line format (1 line)" || fail "1-line format ($lines lines)"

echo '{"line_format":"2"}' > "$CONFIG_FILE"
lines=$(run "2-line" '{"context_window":{"total_input_tokens":43000,"context_window_size":200000}}' | wc -l | tr -d ' ')
[ "$lines" -eq 2 ] && pass "2-line format (2 lines)" || fail "2-line format ($lines lines)"

echo '{"line_format":"3"}' > "$CONFIG_FILE"
lines=$(run "3-line" '{"context_window":{"total_input_tokens":43000,"context_window_size":200000}}' | wc -l | tr -d ' ')
[ "$lines" -ge 2 ] && pass "3-line format ($lines lines)" || fail "3-line format ($lines lines)"
echo ""

# Empty value hiding
echo "=== Empty Value Hiding ==="
echo '{"line_format":"3"}' > "$CONFIG_FILE"
out=$(run "empty" '{"context_window":{"total_input_tokens":43000,"context_window_size":200000}}')
echo "$out" | grep -q "Tools: None" && fail "Should hide 'Tools: None'" || pass "Hides 'Tools: None'"
echo "$out" | grep -q "Agents: None" && fail "Should hide 'Agents: None'" || pass "Hides 'Agents: None'"
echo "$out" | grep -q "Tasks: No tasks" && fail "Should hide 'Tasks: No tasks'" || pass "Hides 'Tasks: No tasks'"
echo ""

# Error handling
echo "=== Error Handling ==="
out=$(echo '{}' | "$STATUSLINE_SCRIPT" 2>&1)
[ $? -eq 0 ] && pass "Handles empty JSON" || fail "Crashes on empty JSON"

out=$(echo 'not json' | "$STATUSLINE_SCRIPT" 2>&1)
[ $? -eq 0 ] && pass "Handles malformed JSON" || fail "Crashes on malformed JSON"
echo ""

# Model formatting
echo "=== Model Formatting ==="
echo '{"line_format":"1"}' > "$CONFIG_FILE"
out=$(run "model" '{"model":{"id":"claude-opus-4-5-20251101"},"context_window":{"total_input_tokens":0,"context_window_size":200000}}')
echo "$out" | grep -q "opus-4.5" && pass "Formats opus model (opus-4.5)" || fail "Model formatting: $out"

out=$(run "sonnet" '{"model":{"id":"claude-sonnet-4-20250514"},"context_window":{"total_input_tokens":0,"context_window_size":200000}}')
echo "$out" | grep -q "sonnet-4" && pass "Formats sonnet model (sonnet-4)" || fail "Sonnet formatting: $out"
echo ""

# Results
echo "═══════════════════════════════════════"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}"
echo "═══════════════════════════════════════"

[ "$FAILED" -eq 0 ]
