# Team Agents Plugin

Coordinated agent team for parallel task execution with leader delegation and quality assurance.

## Installation

```bash
/plugin install team-agents@duyet-claude-plugins
```

## What It Does

Provides two specialized agents that work together to tackle complex development tasks:

- **Leader**: Technical lead that analyzes requirements, designs solutions, and delegates work
- **Senior Engineer**: Implementation specialist that executes delegated tasks with high quality

## How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                        Leader Agent                          │
│  - Analyzes complex requirements                             │
│  - Designs architecture and solution approach                │
│  - Breaks work into independent, parallelizable tasks        │
│  - Delegates to multiple senior engineers                    │
│  - Reviews completed work and ensures quality                │
└──────────────────────┬───────────────────────────────────────┘
                       │ delegates tasks
       ┌───────────────┼───────────────┐
       ▼               ▼               ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ Senior Eng 1 │ │ Senior Eng 2 │ │ Senior Eng 3 │
│  (Task A)    │ │  (Task B)    │ │  (Task C)    │
│  parallel    │ │  parallel    │ │  parallel    │
└──────────────┘ └──────────────┘ └──────────────┘
```

## Agents

### Leader (`leader`)

**Model**: Opus (for complex reasoning)
**Role**: Technical Lead & Engineering Manager

Responsibilities:
- Requirements analysis and clarification
- Solution design and architecture
- Task planning and parallel delegation
- Team coordination and support
- Code review and quality assurance
- Final validation before completion

### Senior Engineer (`senior-engineer`)

**Model**: Haiku (for fast execution)
**Role**: Implementation Specialist

Responsibilities:
- Execute delegated implementation tasks
- Write clean, maintainable, production-ready code
- Follow existing patterns and conventions
- Include comprehensive tests
- Document changes appropriately

## Use Cases

**Good for:**
- Complex features requiring multiple components
- Large refactoring spanning many files
- Tasks that benefit from parallel execution
- Projects needing both planning AND implementation

**Not for:**
- Simple, single-file changes
- Quick bug fixes
- Tasks requiring human design decisions

## Usage Example

```
We need to implement a user authentication system with OAuth2, JWT tokens,
and role-based access. Can you plan and coordinate the implementation?
```

The leader will:
1. Analyze requirements and design the architecture
2. Break work into parallel tasks (OAuth flow, JWT middleware, RBAC)
3. Delegate each task to senior engineers running in parallel
4. Review completed work and ensure quality gates pass

## Architecture

```
team-agents/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── agents/
│   ├── leader.md            # Leader agent definition
│   └── senior-engineer.md   # Senior engineer agent definition
└── README.md                # This file
```
