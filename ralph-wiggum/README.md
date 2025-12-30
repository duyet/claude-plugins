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

Write prompts with clear completion criteria:

```markdown
Build a user authentication system.

Requirements:
- JWT token generation and validation
- Password hashing with bcrypt
- Login and register endpoints
- Input validation
- Unit tests with >80% coverage

Output <promise>COMPLETE</promise> when all requirements pass.
```

## Monitoring

```bash
# Loop state
cat .claude/ralph-loop.local.md

# Circuit breaker
cat .claude/ralph-circuit.json

# Response analysis
cat .claude/ralph-analysis.json

# API limits
cat .claude/ralph-limits.json
```

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
│   └── plugin.json
├── commands/
│   ├── ralph-loop.md
│   ├── cancel-ralph.md
│   └── help.md
├── hooks/
│   ├── hooks.json
│   └── stop-hook.sh
├── lib/
│   ├── circuit_breaker.sh
│   ├── response_analyzer.sh
│   ├── api_limit_handler.sh
│   └── task_manager.sh
└── scripts/
    └── setup-ralph-loop.sh
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

## References

- [ghuntley.com/ralph](https://ghuntley.com/ralph/)
- [frankbria/ralph-claude-code](https://github.com/frankbria/ralph-claude-code)
