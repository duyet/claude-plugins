#!/bin/bash
# Statusline SessionStart hook
# Outputs initial status line and enables monitoring for the session

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

# Fetch rate limits
rate_limits=$("$PLUGIN_ROOT/scripts/fetch-rate-limits.sh" 2>/dev/null)

# Parse rate limit values
if [ -n "$rate_limits" ]; then
    u5h=$(echo "$rate_limits" | jq -r '.five_hour // 0' 2>/dev/null)
    u7d=$(echo "$rate_limits" | jq -r '.seven_day // 0' 2>/dev/null)
    error=$(echo "$rate_limits" | jq -r '.error // empty' 2>/dev/null)

    if [ "$error" = "scope_required" ]; then
        rate_str="5h: re-login | 7d: needed"
    elif [ -n "$error" ]; then
        rate_str=""
    else
        u5h_rounded=$(printf "%.0f" "$u5h" 2>/dev/null || echo "0")
        u7d_rounded=$(printf "%.0f" "$u7d" 2>/dev/null || echo "0")
        rate_str="5h: ${u5h_rounded}% | 7d: ${u7d_rounded}%"
    fi
fi

# Build status line
status_parts=()

# Add rate limits if available
if [ -n "$rate_str" ]; then
    status_parts+=("$rate_str")
fi

# Output the status
if [ ${#status_parts[@]} -gt 0 ]; then
    IFS='|'
    echo "📊 ${status_parts[*]}"
fi

exit 0
