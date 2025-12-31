# Interview Plugin

Conduct in-depth requirements interviews using Socratic questioning before implementation.

## Installation

```bash
/plugin install interview@duyet-claude-plugins
```

## What It Does

The `/interview` command puts Claude into an interview mode where it systematically asks clarifying questions about a feature or plan. It uses the `AskUserQuestion` tool to gather decisions on:

- Technical implementation details
- UI/UX decisions
- Edge cases and failure modes
- Tradeoffs and constraints
- Integration requirements

## Usage

### Interview about a prompt

```
/interview "build a user authentication system with OAuth"
```

### Interview about an existing plan file

```
/interview ./docs/feature-spec.md
```

## What Gets Asked

The interview covers:

1. **Core Functionality** - Primary use cases, failure scenarios, feature boundaries
2. **Technical Implementation** - Performance, persistence, security, error handling
3. **User Experience** - User types, mental models, accessibility
4. **Edge Cases** - Invalid input, high load, dependency failures
5. **Constraints** - Timeline, complexity budget, hard vs soft requirements
6. **Integration** - Existing systems, patterns to follow or avoid

## Output

After the interview completes, Claude writes a comprehensive specification document including:

- Decisions made (with rationale)
- Functional and non-functional requirements
- User stories
- Technical design (architecture, data model, APIs)
- Edge cases and error handling
- Out of scope items
- Open questions

## Philosophy

This plugin takes the approach that **asking the right questions is more valuable than assuming answers**. It's designed to:

- Uncover hidden complexity before coding begins
- Make unstated assumptions explicit
- Identify edge cases the user hasn't considered
- Force explicit decisions on tradeoffs
- Produce specs that make implementation obvious

## Example Session

```
> /interview "add a commenting system to our blog"

Claude: [Uses AskUserQuestion tool]
Header: "Comment Scope"
Question: "Should comments be available on all content types or just blog posts?"
Options:
- Blog posts only (Recommended) - Simpler scope, can extend later
- All content types - More complex, needs polymorphic design
- Configurable per content type - Maximum flexibility, most work

[User selects option]

Claude: [Continues with more questions...]
...

Claude: Here's the complete specification based on our interview:
[Writes spec document]
```

## Tips

- Don't give vague answers - Claude will push back
- Be honest about constraints (timeline, complexity budget)
- It's okay to say "I don't know" - that gets captured as an open question
- The more specific you are, the better the spec

## Architecture

```
interview/
├── .claude-plugin/
│   └── plugin.json      # Plugin manifest
├── commands/
│   └── interview.md     # Interview command definition
└── README.md            # This file
```

## Changelog

### [1.0.0] - Initial Release

Requirements interview plugin using Socratic questioning and AskUserQuestion tool for systematic requirements discovery before implementation.
