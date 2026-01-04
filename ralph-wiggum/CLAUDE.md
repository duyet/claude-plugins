# Ralph Wiggum Plugin

Self-referential development loop for Claude Code with session isolation.

## Commands

- `/ralph-loop` - Start iterative loop with a prompt
- `/status` - Show current loop status
- `/cancel-ralph` - Cancel active loop
- `/help` - Usage documentation

## Hooks

Two hooks in `hooks/hooks.json`:

| Hook | File | Purpose |
|------|------|---------|
| SessionStart | `session-start-hook.sh` | Initialize session ID for state isolation |
| Stop | `stop-hook.sh` | Intercept exit, feed prompt back for next iteration |

## Key Files

```
lib/
├── utils.sh              # Session isolation utilities (get_session_id, get_state_file_path)
├── circuit_breaker.sh    # Safety circuit breaker for error detection
├── response_analyzer.sh  # Smart exit detection based on response patterns
├── api_limit_handler.sh  # Rate limit detection and handling
└── task_manager.sh       # Task tracking across iterations
```

## State Files

State stored in `.claude/ralph-session.local/` with session ID suffix:
- `ralph-loop.{session_id}.md` - Loop state (iteration, prompt, settings)
- `ralph-circuit.{session_id}.json` - Circuit breaker state
- `ralph-analysis.{session_id}.json` - Response analysis data

## Testing Hooks

Test stop hook manually:
```bash
cd ralph-wiggum
echo '{"session_id": "test", "transcript_path": "/tmp/test.json"}' | ./hooks/stop-hook.sh
```

Test with set -euo pipefail (catches exit code issues):
```bash
bash -euo pipefail -c 'source lib/utils.sh && get_session_id'
```

## Common Issues

1. **Hook exits with code 1**: Check that all functions in `lib/utils.sh` return 0 explicitly
2. **Session state persists**: State files use session ID suffix for isolation
3. **Circuit breaker trips**: Check `.claude/ralph-session.local/ralph-circuit.*.json`
