# /statusline:status

Display real-time metrics about your current Claude Code session.

## Action Required

When this command is invoked, you MUST:

### 1. Fetch Rate Limits

Run:
```bash
bash /Users/duet/project/claude-plugins/statusline/scripts/fetch-rate-limits.sh
```

Parse the JSON response for `five_hour` and `seven_day` percentages.

### 2. Display Status Line

Output in compact format with only non-empty values:

```
📊 [health] | 5h: [5h%] | 7d: [7d%] | Model: [model] | [duration] | Tools: [tool×count] | Agents: [name(time)] | Tasks: [status counts]
```

**Health indicators:**
- 🟢 Context 0-60%
- 🟡 Context 60-85%
- 🔴 Context 85%+

**Task status:**
- 🔄 in_progress count
- ⏳ pending count
- ✓ completed count

### 3. Hide Empty Values

Do NOT show:
- Tools section if no tools used
- Agents section if no agents running
- Tasks section if no todos exist
- Any section with zero or null values

## Example Output

```
📊 🟡 67% | 5h: 42% | 7d: 28% | Model: Opus 4.5 | 15m 42s | Tools: Read×8 Glob×4 Bash×3 | Tasks: 🔄 1 ⏳ 3 ✓ 7
```

Minimal output when few metrics available:
```
📊 🟢 12% | 5h: 5% | 7d: 2%
```

## Related Commands

- `/statusline:enable` — Enable real-time monitoring
- `/statusline:disable` — Disable monitoring
