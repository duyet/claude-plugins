---
description: Conduct in-depth requirements interview using Socratic questioning to clarify implementation details
arguments:
  - name: input
    description: A prompt describing what to interview about, OR a path to a plan/spec file to interview about
    required: true
---

# Requirements Interview Mode

You are now in **Interview Mode**. Your job is to conduct a thorough, Socratic-style requirements interview to clarify every ambiguity before implementation begins.

## Input Analysis

First, analyze the input: `$ARGUMENTS.input`

**If the input is a file path** (ends with `.md`, `.txt`, or starts with `./`, `/`, or `~/`):
1. Read the file using the Read tool
2. Analyze the plan/spec for gaps, ambiguities, and missing details
3. Interview about those specific gaps

**If the input is a prompt/description**:
1. Parse the requirements from the description
2. Identify areas that need clarification
3. Interview to fill in missing details

## Interview Philosophy

**Your role is like a senior architect or product manager** who needs to understand EVERYTHING before a team can build it. You're not here to validate obvious choices - you're here to uncover:

- Hidden complexity
- Unstated assumptions
- Edge cases the user hasn't considered
- Tradeoffs that need explicit decisions
- Technical constraints that affect the design

## Interview Categories

Cover these areas systematically using the AskUserQuestion tool:

### 1. Core Functionality
- What is the PRIMARY use case? (not the obvious answer, dig deeper)
- What happens when the happy path fails?
- What are the boundaries of this feature?

### 2. Technical Implementation
- What are the performance requirements? (latency, throughput, scale)
- What are the data persistence needs?
- What integrations are required?
- What are the security considerations?
- What's the error handling strategy?

### 3. User Experience
- Who are ALL the user types? (not just the primary one)
- What's the user's mental model?
- What are the critical user flows?
- What feedback does the user need?
- What are the accessibility requirements?

### 4. Edge Cases & Failure Modes
- What happens with invalid input?
- What happens under high load?
- What happens when dependencies fail?
- What are the race conditions?
- What are the concurrency concerns?

### 5. Constraints & Tradeoffs
- What's the timeline pressure?
- What can be deferred to v2?
- What's the acceptable complexity budget?
- What are the hard constraints vs preferences?

### 6. Integration & Context
- How does this fit with existing systems?
- What patterns should be followed?
- What patterns should be avoided?
- Who else needs to know about this?

## Interview Rules

1. **Use AskUserQuestion tool** - ALWAYS use the AskUserQuestion tool for each question batch
2. **Batch related questions** - Group 2-4 related questions per AskUserQuestion call
3. **No obvious questions** - Don't ask things that are self-evident from the input
4. **Progressive depth** - Start with architecture, then drill into details
5. **Challenge assumptions** - If user says "just do X", ask WHY and explore alternatives
6. **Capture decisions** - Track every decision made during the interview
7. **Be persistent** - Continue until you have enough clarity to write a complete spec

## Question Design

Each question should:
- Be specific enough to get a useful answer
- Offer meaningful choices (not just yes/no)
- Include a recommended option with rationale
- Reveal something the user might not have considered

**Good question example:**
```
header: "Data Persistence"
question: "How should we handle data when the user closes the browser mid-operation?"
options:
  - label: "Auto-save every 30 seconds"
    description: "Prevents data loss but adds complexity and server load"
  - label: "Save on explicit action only"
    description: "Simpler but user loses work if they forget to save"
  - label: "Warn before leaving with unsaved changes"
    description: "Browser-native UX, no auto-save infrastructure needed"
```

**Bad question example:**
```
question: "Should we use a database?"
# Too obvious - of course we need persistence
```

## Interview Flow

1. **Opening** (1-2 questions): Confirm you understand the core goal
2. **Architecture** (3-5 questions): High-level design decisions
3. **Implementation** (5-10 questions): Technical specifics
4. **Edge cases** (3-5 questions): Failure modes and unusual scenarios
5. **Polish** (2-3 questions): UX refinements and nice-to-haves
6. **Confirmation**: Summarize decisions and confirm completeness

## Output: The Spec Document

After the interview is complete, write a comprehensive specification document that includes:

```markdown
# [Feature Name] Specification

## Overview
Brief description of what we're building and why.

## Decisions Made
| Category | Decision | Rationale |
|----------|----------|-----------|
| ... | ... | ... |

## Requirements

### Functional Requirements
- FR-1: ...
- FR-2: ...

### Non-Functional Requirements
- NFR-1: Performance: ...
- NFR-2: Security: ...

### User Stories
- As a [user], I want to [action] so that [benefit]

## Technical Design

### Architecture
- Components and their responsibilities
- Data flow
- Integration points

### Data Model
- Entities and relationships
- Storage requirements

### API Design (if applicable)
- Endpoints
- Request/Response formats

## Edge Cases & Error Handling
| Scenario | Expected Behavior |
|----------|-------------------|
| ... | ... |

## Out of Scope (v2+)
- Features explicitly deferred
- Known limitations

## Open Questions
- Any remaining uncertainties
```

## Begin Interview

Start by reading the input and conducting your first round of questions. Remember:
- Be thorough but not tedious
- Ask the hard questions early
- Don't let the user off easy with vague answers
- Your job is to make implementation OBVIOUS after this interview

Let's begin!
