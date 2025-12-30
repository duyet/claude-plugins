---
name: task-decomposition
description: Break down complex tasks into parallel workstreams for efficient execution. Use when planning multi-component features, large refactors, or any work that benefits from parallelization.
---

This skill provides methodology for decomposing complex tasks into independent, parallelizable units that can be executed by multiple engineers simultaneously.

## When to Invoke This Skill

Automatically activate for:
- Complex features requiring multiple components
- Large refactoring spanning many files
- Multi-domain work (frontend + backend + database)
- Any task where "this could be parallelized" applies
- Planning sprints or implementation roadmaps

## Task Decomposition Principles

### 1. Independence First

Tasks must be independent to run in parallel:

```
GOOD: Each task can complete without waiting
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ Task A: Auth UI │  │ Task B: Auth API│  │ Task C: DB Schema│
│ (no deps)       │  │ (no deps)       │  │ (no deps)        │
└─────────────────┘  └─────────────────┘  └─────────────────┘

BAD: Sequential dependency chain
Task A → Task B → Task C (no parallelism possible)
```

### 2. Clear Boundaries

Each task must have:
- **Single responsibility**: One deliverable per task
- **Defined inputs**: What data/context is needed
- **Expected outputs**: What artifact is produced
- **Acceptance criteria**: How to verify completion

### 3. Right-Sized Tasks

| Size | Duration | Complexity | Assignment |
|------|----------|------------|------------|
| Small | < 30 min | Single file, routine | Junior engineer |
| Medium | 30-60 min | Multi-file, some decisions | Senior engineer |
| Large | 1-2 hours | Cross-cutting, architectural | Lead or split further |

**Rule**: If a task is "Large", decompose it further.

## Decomposition Framework

### Step 1: Identify Domains

Map the work to distinct domains:

```
Feature: User Authentication
├── Frontend Domain
│   ├── Login form component
│   ├── Registration flow
│   └── Password reset UI
├── Backend Domain
│   ├── Auth middleware
│   ├── JWT token service
│   └── User validation
├── Data Domain
│   ├── User schema
│   ├── Session storage
│   └── Migration scripts
└── Infrastructure Domain
    ├── OAuth provider setup
    └── Environment config
```

### Step 2: Map Dependencies

Create dependency graph:

```
[DB Schema] ──┬──> [Auth Middleware] ──> [Integration Tests]
              │
              ├──> [JWT Service]
              │
              └──> [User Validation]

[Login UI] ────────────────────────────> [E2E Tests]
[Registration UI] ─────────────────────> [E2E Tests]
```

### Step 3: Identify Parallel Lanes

Group independent tasks into lanes:

```
Lane 1 (Backend)     Lane 2 (Frontend)    Lane 3 (Infra)
─────────────────    ─────────────────    ─────────────────
[DB Schema]          [Login UI]           [OAuth Setup]
     │               [Registration UI]    [Env Config]
     ▼               [Reset UI]
[Auth Middleware]
[JWT Service]
[User Validation]
```

### Step 4: Define Integration Points

Where lanes must synchronize:

```
Sync Point 1: API Contract
- Backend exposes POST /auth/login
- Frontend implements against contract
- Both can develop in parallel with mock

Sync Point 2: Integration Testing
- All lanes complete
- Run integration test suite
- Fix cross-cutting issues
```

## Task Template

Use this template for each decomposed task:

```markdown
## Task: [Clear, action-oriented title]

**Lane**: [Backend | Frontend | Infra | Data]
**Size**: [Small | Medium]
**Dependencies**: [None | Task IDs that must complete first]

### Context
[1-2 sentences on why this task exists]

### Deliverables
- [ ] [Specific artifact 1]
- [ ] [Specific artifact 2]

### Acceptance Criteria
- [ ] [Measurable criterion 1]
- [ ] [Measurable criterion 2]
- [ ] Tests pass
- [ ] Linting clean

### Notes
[Any implementation hints or decisions already made]
```

## Parallelization Patterns

### Pattern 1: Component Parallel

Split by UI component when each is independent:

```
/leader --team-size=3 --mode=parallel

Task 1: Build LoginForm component
Task 2: Build RegistrationForm component
Task 3: Build PasswordResetForm component
```

### Pattern 2: Layer Parallel

Split by architectural layer:

```
/leader --team-size=3 --mode=parallel

Task 1: Implement API endpoints (backend)
Task 2: Implement UI components (frontend)
Task 3: Set up infrastructure (devops)
```

### Pattern 3: Hybrid

Critical path sequential, supporting work parallel:

```
/leader --team-size=3 --mode=hybrid

Sequential (Critical Path):
  Task 1: Design database schema
  Task 2: Implement core API

Parallel (After Task 1):
  Task 3: Build UI components
  Task 4: Write integration tests
  Task 5: Set up monitoring
```

## Anti-Patterns to Avoid

### Over-Decomposition
```
BAD: 20 tiny tasks that have coordination overhead
GOOD: 3-5 meaningful tasks per engineer
```

### Hidden Dependencies
```
BAD: "Task B assumes Task A's schema design"
GOOD: "Task B depends on Task A (schema must be finalized)"
```

### Unclear Ownership
```
BAD: "Someone should handle auth"
GOOD: "Engineer 2 owns auth middleware (Task B)"
```

### Missing Integration Plan
```
BAD: 5 parallel tasks with no sync point
GOOD: Parallel tasks + defined integration checkpoint
```

## Output Format

When decomposing tasks, produce:

```markdown
## Task Decomposition: [Feature Name]

### Overview
- Total tasks: N
- Parallel lanes: M
- Critical path: [sequence]
- Estimated parallelism: X%

### Dependency Graph
[ASCII diagram showing task relationships]

### Task Breakdown

#### Lane 1: [Domain]
| ID | Task | Size | Deps | Engineer |
|----|------|------|------|----------|
| T1 | ... | Medium | None | Senior 1 |
| T2 | ... | Small | T1 | Senior 1 |

#### Lane 2: [Domain]
| ID | Task | Size | Deps | Engineer |
|----|------|------|------|----------|
| T3 | ... | Medium | None | Senior 2 |

### Integration Points
1. After T1, T3: API contract validation
2. After all: Full integration test

### Execution Plan
Phase 1: T1, T3, T5 (parallel)
Phase 2: T2, T4 (parallel, after Phase 1)
Phase 3: Integration (sequential)
```

## Checklist

Before finalizing decomposition:

- [ ] Each task has single responsibility
- [ ] Dependencies are explicit (not assumed)
- [ ] No task exceeds "Medium" size
- [ ] Integration points defined
- [ ] Ownership is clear
- [ ] Acceptance criteria are testable
- [ ] Critical path identified
- [ ] Parallelism opportunities maximized
