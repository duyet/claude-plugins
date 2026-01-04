# Statusline Plugin Development Notes

> **IMPORTANT**: Keep this file updated when modifying the statusline script or commands!

## Architecture

The statusline has two components:
1. **Plugin commands** (`commands/*.md`) - Claude Code plugin commands
2. **Shell script** (`~/.claude/statusline-command.sh`) - The actual renderer called by Claude Code

The shell script is configured in `~/.claude/settings.json`:
```json
{
  "statusLine": {
    "type": "command",
    "command": "/Users/duet/.claude/statusline-command.sh"
  }
}
```

## Data Sources

The script gets data from two sources:

1. **Stdin (real-time)** - Claude Code pipes JSON on every render:
   - `context_window.total_input_tokens` - cumulative tokens
   - `context_window.current_usage.*` - current context usage
   - `model.id` - model name (e.g., "claude-opus-4-5-20251101")
   - `workspace.current_dir` - working directory
   - `version` - Claude Code version

2. **API fetch (cached)** - Fetches from Anthropic OAuth API:
   - 5-hour usage percentage
   - 7-day usage percentage
   - Reset timer
   - **Cached for 60 seconds** (configurable via `USAGE_CACHE_TTL`)

## Configuration

Config file: `~/.claude/statusline.config.json`

```json
{
  "line_format": "1" | "2" | "3",
  "show_context": true,
  "show_rate_limits": true,
  "show_git_branch": true,
  "show_tools": true,
  "color_style": "colorful" | "minimal" | "plain"
}
```

## Testing

Run the test suite:
```bash
bash statusline/scripts/test-statusline.sh
```

### Manual Testing

```bash
# With full context data
DEBUG_STATUSLINE=1 echo '{"workspace":{"current_dir":"/test"},"model":{"id":"claude-opus-4-5-20251101"},"version":"2.0.76","context_window":{"total_input_tokens":43000,"context_window_size":200000}}' | ~/.claude/statusline-command.sh

# Test null current_usage (should fallback to total_input_tokens)
echo '{"context_window":{"total_input_tokens":43000,"context_window_size":200000,"current_usage":null}}' | ~/.claude/statusline-command.sh

# Test no context data (should hide context line)
echo '{"context_window":{"total_input_tokens":0,"context_window_size":200000}}' | ~/.claude/statusline-command.sh

# Test line formats
echo '{"line_format":"1"}' > ~/.claude/statusline.config.json
echo '{"context_window":{"total_input_tokens":43000,"context_window_size":200000}}' | ~/.claude/statusline-command.sh

echo '{"line_format":"2"}' > ~/.claude/statusline.config.json
echo '{"context_window":{"total_input_tokens":43000,"context_window_size":200000}}' | ~/.claude/statusline-command.sh

echo '{"line_format":"3"}' > ~/.claude/statusline.config.json
echo '{"context_window":{"total_input_tokens":43000,"context_window_size":200000}}' | ~/.claude/statusline-command.sh
```

## Environment Variables

- `DEBUG_STATUSLINE=1` - Show diagnostic output to stderr
- `SKIP_RATE_LIMITS=1` - Skip API fetch (for testing)
- `USAGE_CACHE_TTL=60` - Cache TTL in seconds (default: 60)

## Key Behaviors

1. **Context fallback**: If `current_usage` is null or all zeros, uses `total_input_tokens`
2. **Hide empty values**: Doesn't show "Context: 0%", "Tools: None", "Agents: None", "Tasks: No tasks"
3. **Line format**: Configurable 1/2/3 line display via config file
4. **API caching**: Usage data cached for 60s to avoid repeated API calls
5. **Model formatting**: "claude-opus-4-5-20251101" → "opus-4.5"

## Cache Files

- `~/.claude/statusline.config.json` - User configuration
- `~/.claude/statusline-usage-cache.json` - Cached API usage data (auto-generated)

## Commands

- `/statusline:setup` - Interactive setup wizard
- `/statusline:status` - Show current metrics
- `/statusline:config` - Quick format change
- `/statusline:disable` - Disable statusline

## Known Issues

- Rate limit API requires proper OAuth scope; may show "re-login needed" if token lacks permission
- `current_usage` may be null on first message of session (falls back to total_input_tokens)
- macOS uses `stat -f %m`, Linux uses `stat -c %Y` for cache age check
