# /statusline:enable

Enable real-time session monitoring with automatic status updates.

## Usage

```
/statusline:enable [interval]
```

### Parameters

- `interval` (optional) — Update interval in seconds. Default: 5 seconds. Min: 1, Max: 60

## What It Does

Enables continuous monitoring of your session with status updates displayed at regular intervals:

- Real-time context usage tracking
- Active tool monitoring
- Running agent visibility
- Task/todo progress updates

The monitor runs in the background and displays summary updates without interrupting your workflow.

## Examples

Enable with default 5-second updates:
```
/statusline:enable
```

Enable with custom 10-second interval:
```
/statusline:enable 10
```

## Notes

- Monitoring is active by default when the plugin is installed
- Updates respect your Claude Code terminal settings
- You can view the current status anytime with `/statusline:status`
- Use `/statusline:disable` to stop background updates

## Related Commands

- `/statusline:status` — View current metrics immediately
- `/statusline:disable` — Stop background monitoring
