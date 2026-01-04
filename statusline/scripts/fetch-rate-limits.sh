#!/bin/bash
# Fetch rate limits from Anthropic OAuth API
# Outputs JSON: {"five_hour": N, "seven_day": N, "resets_at": "ISO", "error": "..."}

token=""

# macOS Keychain (primary on macOS)
if [ "$(uname)" = "Darwin" ]; then
    keychain_data=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
    if [ -n "$keychain_data" ]; then
        token=$(echo "$keychain_data" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
    fi
fi

# Fall back to file-based credentials
if [ -z "$token" ] || [ "$token" = "null" ]; then
    for cred_path in \
        ~/.claude/.credentials.json \
        ~/.config/claude/.credentials.json \
        ~/.config/claude-code/.credentials.json
    do
        if [ -f "$cred_path" ]; then
            token=$(jq -r '.claudeAiOauth.accessToken // empty' "$cred_path" 2>/dev/null)
            if [ -n "$token" ] && [ "$token" != "null" ]; then
                break
            fi
        fi
    done
fi

if [ -z "$token" ] || [ "$token" = "null" ]; then
    echo '{"error": "no_credentials"}'
    exit 0
fi

# Fetch from API
api_response=$(curl -s -m 3 \
    -H "Authorization: Bearer $token" \
    -H "anthropic-beta: oauth-2025-04-20" \
    "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)

if [ -z "$api_response" ]; then
    echo '{"error": "api_timeout"}'
    exit 0
fi

# Check for error
if echo "$api_response" | jq -e '.error' > /dev/null 2>&1; then
    error_msg=$(echo "$api_response" | jq -r '.error.message // "unknown"')
    if echo "$error_msg" | grep -qi "scope"; then
        echo '{"error": "scope_required"}'
    else
        echo '{"error": "api_error"}'
    fi
    exit 0
fi

# Parse and output
u5h=$(echo "$api_response" | jq -r '.five_hour.utilization // 0')
u7d=$(echo "$api_response" | jq -r '.seven_day.utilization // 0')
r5h=$(echo "$api_response" | jq -r '.five_hour.resets_at // empty')

printf '{"five_hour": %s, "seven_day": %s, "resets_at": "%s"}\n' \
    "${u5h:-0}" "${u7d:-0}" "${r5h:-}"
