# /statusline:setup

Interactive setup wizard that configures and generates your personalized statusline.

## Action Required

When this command is invoked, conduct an interview using AskUserQuestion, then generate the statusline script.

### Interview Questions

Use AskUserQuestion to ask these questions (can ask multiple in one call):

#### Q1: Line Format
**Header**: "Lines"
**Question**: "How many lines should the statusline display?"
**Options**:
1. **1 line (Compact)** — Everything on one line
2. **2 lines** — Location/model + metrics (Recommended)
3. **3 lines** — Full layout with separate sections

#### Q2: Information to Show
**Header**: "Show"
**Question**: "What information do you want to see?"
**multiSelect**: true
**Options**:
1. **Context usage** — Token count and percentage
2. **Rate limits** — 5-hour and 7-day API usage
3. **Git branch** — Current branch name
4. **Active tools** — Running MCP servers/tools

#### Q3: Color Style
**Header**: "Colors"
**Question**: "What color style do you prefer?"
**Options**:
1. **Colorful** — Full color with health indicators (Recommended)
2. **Minimal** — Muted colors, less visual noise
3. **Plain** — No colors (for simple terminals)

### Generate Statusline Script

Based on answers, generate `~/.claude/statusline-command.sh` with the user's preferences:

1. Read the current script at `~/.claude/statusline-command.sh`
2. Modify the configuration section based on answers:
   - Set `line_format` based on Q1
   - Enable/disable sections based on Q2
   - Set color intensity based on Q3
3. Save the updated script

Also save config to `~/.claude/statusline.config.json`:
```json
{
  "line_format": "2",
  "show_context": true,
  "show_rate_limits": true,
  "show_git_branch": true,
  "show_tools": true,
  "color_style": "colorful"
}
```

### Configure Claude Code Settings

Ensure `~/.claude/settings.json` has the statusLine configuration:
```json
{
  "statusLine": {
    "type": "command",
    "command": "/Users/duet/.claude/statusline-command.sh"
  }
}
```

### Show Preview

After setup, show a preview of the statusline output by running:
```bash
echo '{"workspace":{"current_dir":"'$(pwd)'"},"model":{"id":"claude-opus-4-5-20251101"},"version":"2.0.76","context_window":{"total_input_tokens":43000,"context_window_size":200000}}' | ~/.claude/statusline-command.sh
```

### Confirm Setup

Output:
```
✓ Statusline configured successfully!

Your settings:
  • Format: [N]-line layout
  • Showing: Context, Rate limits, Git branch, Tools
  • Colors: Colorful

Preview:
[show the actual statusline output]

The statusline will update automatically during your session.
Use /statusline:config to change settings anytime.
```

## Example Interview Flow

```
Q1: How many lines should the statusline display?
   → User selects: 2 lines

Q2: What information do you want to see?
   → User selects: Context usage, Rate limits, Git branch

Q3: What color style do you prefer?
   → User selects: Colorful

✓ Generating your statusline...
✓ Config saved to ~/.claude/statusline.config.json
✓ Script updated at ~/.claude/statusline-command.sh

Preview:
claude-plugins (master) │ Opus 4 5 │ v2.0.76
Context: 21% (43,000 tokens) │ 5h: 14% 7d: 46%
```

## Related Commands

- `/statusline:status` — View current metrics
- `/statusline:config` — Quick config change (just line format)
- `/statusline:disable` — Disable statusline
