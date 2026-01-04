# /statusline:config

Configure the statusline display format.

## Action Required

When this command is invoked, you MUST use the AskUserQuestion tool to ask:

### Question: Line Format

Ask the user which display format they prefer:

**Header**: "Lines"
**Question**: "How many lines should the statusline display?"

**Options**:
1. **1 line (Compact)** — `dir (branch) │ Model │ Ctx% │ 5h/7d │ Tasks`
2. **2 lines** — Line 1: location/model, Line 2: all metrics
3. **3 lines (Default)** — Full layout with separate lines for location, metrics, and activity

### Save Configuration

After the user answers, save their choice to `~/.claude/statusline.config.json`:

```json
{
  "line_format": "1"
}
```

Use values: `"1"`, `"2"`, or `"3"`

### Confirm

Output:
```
✓ Statusline configured: [N]-line format
  Config saved to ~/.claude/statusline.config.json
```

## Example Outputs

**1-line format**:
```
claude-plugins (master) │ Opus 4 5 │ Ctx: 21% │ 5h: 14% 7d: 46%
```

**2-line format**:
```
claude-plugins (master) │ Opus 4 5 │ v2.0.76
Ctx: 21% │ 5h: 14% 7d: 46% │ Tasks: 2/5
```

**3-line format** (default):
```
claude-plugins (master) │ Opus 4 5 │ v2.0.76
Context: 21% (43,000 tokens) │ 5h: 14% 7d: 46%
Tools: Sequential │ Tasks: 2/5
```

**Note**: Empty values are automatically hidden (no "None", no "0%", no "No tasks").

## Related Commands

- `/statusline:status` — View current metrics
- `/statusline:enable` — Enable monitoring
- `/statusline:disable` — Disable monitoring
