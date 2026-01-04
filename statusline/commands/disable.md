# /statusline:disable

Disable real-time session monitoring and status updates.

## Usage

```
/statusline:disable
```

## What It Does

Stops background session monitoring while keeping the plugin active. This prevents periodic status updates from appearing in your session.

- Stops real-time monitoring
- Plugin remains installed and available
- Status info can still be viewed on-demand with `/statusline:status`
- Monitoring can be re-enabled anytime with `/statusline:enable`

## Notes

- Disabling only pauses automatic updates, not the plugin itself
- You can still manually check session status with `/statusline:status`
- Plugin data and history are preserved when disabled
- No changes to your workflow or active tasks

## Related Commands

- `/statusline:enable` — Resume real-time monitoring
- `/statusline:status` — View metrics without continuous monitoring
