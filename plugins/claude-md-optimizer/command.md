---
allowed-tools: Read, Glob, Grep, Bash(ls:*), Bash(wc:*), Bash(head:*)
description: Analyze and optimize CLAUDE.md files based on codebase context and industry best practices. Provides actionable recommendations to improve Claude Code effectiveness.
---

## Context

This skill helps users create effective CLAUDE.md files that maximize Claude Code productivity. It analyzes the codebase structure, existing CLAUDE.md content, and provides specific optimization recommendations based on proven best practices.

## Best Practices Knowledge Base

### Core Principles

1. **Conciseness is Critical**: Keep CLAUDE.md to 100-200 lines maximum. Claude Code's system prompt already contains ~50 instructions. Long files waste precious context and reduce instruction-following reliability.

2. **Progressive Disclosure**: Don't embed all information—tell Claude how to find it. Point to files instead of copying content. Use nested CLAUDE.md files in subdirectories for context-specific guidance.

3. **Declarative Style**: Write for Claude, not for onboarding humans. Use short, declarative bullet points. Avoid narrative paragraphs.

4. **Universal Applicability**: Only include instructions that apply to every task. Move task-specific guidance to slash commands or separate files.

### Essential Sections

A well-structured CLAUDE.md should include:

1. **Project Overview** (2-3 sentences max)
   - What the project does
   - Primary technologies/frameworks
   - High-level architecture pattern

2. **Directory Map** (compact tree structure)
   - Key directories and their purposes
   - Where different component types live
   - Entry points

3. **Development Commands** (bulleted list)
   - Build, test, lint commands
   - Development server startup
   - Common workflows

4. **Coding Standards** (only non-obvious ones)
   - Style preferences not enforced by linters
   - Naming conventions
   - File organization patterns

5. **Testing Requirements** (if applicable)
   - Framework and location
   - Required coverage or patterns
   - Fixture conventions

6. **Pointers to Resources** (reference files, don't embed)
   - Point to example implementations
   - Reference documentation files
   - Link to configuration files

### Anti-Patterns to Avoid

- **Verbose explanations**: Cut ruthlessly. Every word costs context.
- **Embedded code examples**: Point to actual files instead.
- **Obvious instructions**: Don't tell Claude to "write clean code."
- **Duplicate linter rules**: Use actual linters via hooks.
- **Sensitive data**: Never include API keys, credentials, or secrets.
- **Generic AI prompting tips**: Claude already knows how to code.
- **Task-specific instructions**: Move these to slash commands.
- **Outdated information**: Stale docs are worse than no docs.

### Advanced Optimization

- **Use nested CLAUDE.md files**: Place context-specific files in subdirectories.
- **Leverage hooks**: Move linting/formatting to pre-commit hooks.
- **Create slash commands**: For repetitive task patterns.
- **Reference by path**: `See src/utils/example.ts for the pattern` is better than copying code.

## Analysis Process

When invoked, perform these steps:

### Step 1: Codebase Analysis
Examine the project structure to understand:
- Primary programming language(s)
- Framework(s) in use (check package.json, requirements.txt, Cargo.toml, etc.)
- Directory structure and organization
- Test framework and locations
- Configuration files present

### Step 2: CLAUDE.md Assessment
If CLAUDE.md exists:
- Count total lines
- Identify sections present
- Check for anti-patterns
- Measure verbosity
- Look for outdated or redundant content

If no CLAUDE.md exists:
- Note this and prepare to generate recommendations

### Step 3: Gap Analysis
Compare current state against best practices:
- Missing essential sections
- Overly verbose sections
- Anti-patterns detected
- Opportunities for progressive disclosure
- Missing pointers to important files

### Step 4: Generate Recommendations

Provide a structured report with:

1. **Score** (1-10): Overall effectiveness rating
2. **Strengths**: What's working well
3. **Issues**: Specific problems found with line references
4. **Recommendations**: Prioritized, actionable improvements
5. **Suggested Structure**: Optimized section outline
6. **Optional**: Draft optimized content if user requests

## Output Format

Structure your response as:

```
## CLAUDE.md Analysis Report

### Project Summary
[Brief description of detected project type and structure]

### Current State
- File exists: Yes/No
- Line count: X lines (target: 100-200)
- Sections detected: [list]

### Effectiveness Score: X/10

### Strengths
- [What's working well]

### Issues Found
1. [Issue] (line X-Y)
   - Impact: [why this matters]
   - Fix: [specific action]

### Priority Recommendations
1. [Most impactful change]
2. [Second priority]
3. [Third priority]

### Suggested Structure
[Optimized outline with section headers]

### Quick Wins
[Immediate improvements that take <5 minutes]
```

## Your Task

1. **Analyze the codebase** to understand the project structure, technologies, and patterns
2. **Read existing CLAUDE.md** (if present) and assess against best practices
3. **Identify gaps and anti-patterns** based on the knowledge base above
4. **Provide actionable recommendations** prioritized by impact
5. **Optionally generate optimized content** if requested by the user

Start by exploring the project structure and any existing CLAUDE.md file, then provide your analysis report.
