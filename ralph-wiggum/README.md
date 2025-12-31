# Ralph Wiggum Plugin

A self-referential development loop for Claude Code. Run iterative tasks until completion with automatic progress detection and safety controls.

## Concept

The Ralph technique feeds the same prompt to Claude repeatedly in a `while true` loop. Each iteration, Claude sees its previous work in files and git history, enabling continuous refinement until the task completes.

```bash
while true; do
  cat PROMPT.md | claude --continue
done
```

This plugin implements the loop within Claude Code using a stop-hook that intercepts exit attempts and restarts with the same prompt.

## Usage

```bash
# Start a loop
/ralph-loop "Build a REST API with CRUD operations and tests"

# Set iteration limit
/ralph-loop "Refactor auth module" --max-iterations 15

# Define completion criteria
/ralph-loop "Add input validation" --completion-promise "DONE"

# Check status
/status

# Cancel
/cancel-ralph
```

## Completion

The loop stops when any condition is met:

| Condition | Trigger |
|-----------|---------|
| **Promise** | Output `<promise>TEXT</promise>` matching `--completion-promise` |
| **Iterations** | Reach `--max-iterations` limit |
| **Circuit Breaker** | No file changes for 3 iterations |
| **Smart Exit** | High confidence completion detected |
| **API Limit** | Rate limit or usage limit reached |

## Safety Features

### Circuit Breaker

Prevents runaway loops through stagnation detection:

- **No Progress**: Stops after 3 iterations without file changes
- **Errors**: Stops after 5 consecutive errors in output
- **Duplicates**: Stops after 3 identical outputs
- **States**: `CLOSED` → `HALF_OPEN` → `OPEN`

### Intelligent Exit

Analyzes responses for completion signals:

- Keyword detection: "done", "complete", "finished", "all tests pass"
- Test-only loop detection: running tests without new code
- Confidence scoring: exits at 40+ points

### API Limit Handler

Gracefully handles rate limits:

- 5-hour usage limit detection
- 429 rate limit detection
- Automatic pause with wait recommendations

## Options

| Flag | Description |
|------|-------------|
| `--max-iterations <n>` | Stop after N iterations |
| `--completion-promise <text>` | Promise phrase to signal completion |
| `--no-circuit-breaker` | Disable stagnation detection |
| `--no-smart-exit` | Disable completion analysis |
| `--no-rate-limit` | Disable rate limit handling |
| `--reset-circuit` | Reset circuit breaker state |

## Prompt Guidelines

Write prompts with clear, verifiable completion criteria:

### Structure

1. **Goal**: What you want to build/fix
2. **Requirements**: Specific, testable criteria
3. **Completion signal**: How to know when done

### Examples

**Bug fix with tests:**
```markdown
Fix the token refresh bug in auth.ts.

Requirements:
- Token refresh returns valid JWT
- Expired tokens trigger refresh flow
- All auth tests pass

Output <promise>FIXED</promise> when tests pass.
```

**Feature implementation:**
```markdown
Add rate limiting to the API.

Requirements:
- 100 requests per minute per IP
- Return 429 status when exceeded
- Include retry-after header
- Add rate limit tests

Output <promise>DONE</promise> when feature works.
```

**Refactoring task:**
```markdown
Refactor user service to use repository pattern.

Requirements:
- Extract database calls to UserRepository
- Service depends on repository interface
- Existing tests still pass
- No TypeScript errors

Output <promise>REFACTORED</promise> when complete.
```

### Tips

- Use measurable criteria ("tests pass", "no errors", "build succeeds")
- Include the `<promise>` tag in your prompt so Claude knows how to exit
- Keep requirements focused—fewer is better for iterative tasks

## Monitoring

Use the status command or inspect files directly:

```bash
# Quick status check (shows session ID)
/status

# List all session state files
ls -la .claude/ralph-session.local/

# View specific session state (session_id shown in /status)
cat .claude/ralph-session.local/ralph-loop.{session_id}.local.md
cat .claude/ralph-session.local/ralph-circuit.{session_id}.json
cat .claude/ralph-session.local/ralph-analysis.{session_id}.json
```

State files are stored in `.claude/ralph-session.local/` with session_id as filename suffix. Each Claude Code session has isolated state. The `.local` suffix ensures gitignore compatibility.

## Configuration

Environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `RALPH_MAX_NO_PROGRESS` | 3 | Iterations without progress before halt |
| `RALPH_MAX_ERRORS` | 5 | Consecutive errors before halt |
| `RALPH_MAX_IDENTICAL` | 3 | Identical outputs before halt |
| `RALPH_COMPLETION_THRESHOLD` | 40 | Confidence score for smart exit |

## Architecture

```
ralph-wiggum/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/
│   ├── ralph-loop.md        # Start loop command
│   ├── status.md            # Check loop status
│   ├── cancel-ralph.md      # Cancel active loop
│   └── help.md              # Plugin documentation
├── hooks/
│   ├── hooks.json           # Hook configuration
│   ├── session-start-hook.sh # Session ID capture
│   └── stop-hook.sh         # Main loop interceptor
├── lib/
│   ├── utils.sh             # Session isolation utilities
│   ├── circuit_breaker.sh   # Stagnation detection
│   ├── response_analyzer.sh # Completion analysis
│   ├── api_limit_handler.sh # Rate limit handling
│   └── task_manager.sh      # Task state management
└── scripts/
    ├── setup-ralph-loop.sh  # Loop initialization
    ├── status.sh            # Status display
    └── cancel-ralph.sh      # Cancellation handler

Project directory (.claude/):
├── ralph-session.local/
│   ├── ralph-loop.{session_id}.local.md
│   ├── ralph-circuit.{session_id}.json
│   ├── ralph-analysis.{session_id}.json
│   ├── ralph-limits.{session_id}.json
│   └── ralph-tasks.{session_id}.json
```

## When to Use

**Good for:**
- Tasks with clear success criteria (tests pass, build succeeds)
- Iterative refinement (debugging, optimization)
- Greenfield implementation with defined requirements

**Not for:**
- Tasks requiring human judgment or design decisions
- One-shot operations
- Production debugging

## Troubleshooting

### Loop won't start

1. Check if another loop is active: `/status`
2. Cancel any existing loop: `/cancel-ralph`
3. Try again with your prompt

### Loop exits too early

The smart exit feature may trigger on completion keywords. Options:
- Use `--no-smart-exit` to disable completion detection
- Add more specific requirements to your prompt
- Check `.claude/ralph-session.local/ralph-analysis.{session_id}.json` to see what triggered the exit

### Loop runs forever

Ensure your prompt includes:
- Clear, testable completion criteria
- A `<promise>` tag if using `--completion-promise`
- Measurable success conditions (tests pass, build succeeds)

### Circuit breaker keeps triggering

The circuit breaker stops loops that aren't making progress:
- Ensure each iteration changes files
- Check `.claude/ralph-session.local/ralph-circuit.{session_id}.json` for details
- Use `--reset-circuit` to reset state if needed

### Rate limits

If you hit Claude's API limits:
- The loop pauses automatically
- Wait for the recommended duration
- Resume with `/ralph-loop` using the same prompt

### Debugging

```bash
# Check all session state files
ls -la .claude/ralph-session.local/

# View loop configuration (use session_id from /status)
cat .claude/ralph-session.local/ralph-loop.{session_id}.local.md

# Check circuit breaker state
cat .claude/ralph-session.local/ralph-circuit.{session_id}.json

# Review completion analysis
cat .claude/ralph-session.local/ralph-analysis.{session_id}.json
```

## Changelog

### [1.1.0] - Session Isolation

**Added**
- Session isolation: State files now stored as `.claude/ralph-session.local/{name}.{session_id}.{ext}`
- SessionStart hook: Captures session_id at session start
- Session ID display: `/status` shows current session ID
- lib/utils.sh: New utility module for session isolation

**Fixed**
- Cross-session interference: Stop hook now only processes state belonging to its session, preventing multiple Claude Code sessions from hijacking each other's loops

**Changed**
- State file location moved from `.claude/ralph-*.local.*` to `.claude/ralph-session.local/{name}.{session_id}.{ext}`
- All library modules use dynamic path resolution
- `.local` suffix on directory ensures gitignore compatibility

### [1.0.1] - Initial Release

Self-referential development loop with circuit breaker, smart exit, and API limit handling.

## References

- [ghuntley.com/ralph](https://ghuntley.com/ralph/)
- [frankbria/ralph-claude-code](https://github.com/frankbria/ralph-claude-code)
