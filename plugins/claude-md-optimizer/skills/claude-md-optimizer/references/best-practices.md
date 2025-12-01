# CLAUDE.md Best Practices

Comprehensive best practices compiled from Anthropic, HumanLayer, and community experts.

## 1. Understanding Context Limits

**Critical Insight**: Frontier thinking LLMs can reliably follow ~150-200 instructions.

### Key Facts
- Claude Code's system prompt already contains ~50 individual instructions
- Your CLAUDE.md should add minimal additional instructions
- As instruction count increases, instruction-following quality decreases uniformly
- Target: **100-200 lines maximum**

### Implication
Every instruction in your CLAUDE.md competes for attention with Claude Code's built-in behaviors. Be extremely selective about what you include.

## 2. Core Principles

### 2.1 Conciseness is Non-Negotiable
- **Maximum length**: 100-200 lines (hard limit)
- **Every word costs context**: Cut ruthlessly
- **Long CLAUDE.md files are a code smell**: They indicate poor information architecture
- **Include only essential information**: For that level of the application

### 2.2 Progressive Disclosure
- **Don't tell Claude everything**: Tell it how to find information
- **Point to files**: Instead of copying content
- **Use nested CLAUDE.md files**: In subdirectories for context-specific guidance
- **Reference patterns**: `See src/utils/example.ts` beats copying code

### 2.3 Writing Style - Write for Claude, Not Humans
- **DO**: Use short, declarative bullet points
- **DON'T**: Write long, narrative paragraphs
- **DO**: Use simple language
- **DON'T**: Write conversational explanations
- **Remember**: "You're writing for Claude, not onboarding a junior dev"

### 2.4 Universal Applicability
- **Only include**: Instructions that apply to every task
- **Move task-specific guidance**: To slash commands or separate files
- **No edge cases**: Save those for specific command files

## 3. Essential Sections

### 3.1 Project Overview (2-3 sentences MAX)
```markdown
## Project Overview
This is a [type] application built with [framework]. It [primary purpose].
```

### 3.2 Directory Structure (Compact tree)
```markdown
## Structure
src/
  components/  # React components
  hooks/       # Custom hooks
  utils/       # Shared utilities
```

### 3.3 Development Commands (Bulleted list)
```markdown
## Commands
- `npm run dev` - Start development server
- `npm test` - Run tests
- `npm run lint` - Check linting
```

### 3.4 Key Conventions (Only non-obvious ones)
```markdown
## Conventions
- Components use PascalCase
- Hooks prefixed with `use`
- Tests co-located with source files
```

### 3.5 Pointers to Resources (Reference, don't embed)
```markdown
## References
- See `docs/architecture.md` for system design
- See `src/components/Button/` for component patterns
- See `.github/CONTRIBUTING.md` for PR guidelines
```

## 4. Nested CLAUDE.md Strategy

### Hierarchy Example
```
project/
  CLAUDE.md           # Project overview (50-100 lines)
  frontend/
    CLAUDE.md         # Frontend conventions (30-50 lines)
  backend/
    CLAUDE.md         # Backend conventions (30-50 lines)
    api/
      CLAUDE.md       # API-specific patterns (20-30 lines)
```

### Guidelines
- **Root level**: High-level overview, universal commands
- **Feature directories**: Feature-specific conventions
- **Each level**: Should be self-contained for its scope

## 5. Emphasis for Critical Rules

Use these patterns sparingly for must-follow rules:
- **IMPORTANT:** prefix for critical instructions
- **NEVER:** for absolute prohibitions
- **ALWAYS:** for essential patterns

Anthropic uses these in their own CLAUDE.md files.

## 6. Tools Over Instructions

### Don't Make Claude a Linter
- Use actual linters (ESLint, Prettier, Black, rustfmt)
- Configure hooks for pre-commit automation
- Move enforcement out of CLAUDE.md into tooling

### Leverage Existing Tools
- Git hooks for formatting
- CI/CD for validation
- IDE settings for conventions

## 7. The # Key Pattern

In Claude Code:
- Press `#` to add remembered instructions
- Instructions accumulate from actual usage
- Better than pre-writing everything
- Documents what you actually need

## 8. Living Documentation

- **Treat as living docs**: Update frequently
- **When Claude makes mistakes**: Update CLAUDE.md accordingly
- **Include in code reviews**: Like any documentation
- **Team collaboration**: Share via git commits

## 9. What to Include vs Exclude

### INCLUDE
- Project type and primary tech stack
- Directory structure (compact)
- Build/test/lint commands
- Non-obvious conventions
- Pointers to example files
- Critical warnings or gotchas
- Environment setup steps

### EXCLUDE
- Obvious coding practices
- Full code examples (point instead)
- Linter rules (use actual linters)
- Task-specific instructions (use commands)
- Generic AI prompting tips
- Long explanations
- Secrets or credentials
- Outdated information

## Sources

- [HumanLayer: Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- [Anthropic: Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Official Claude.md Documentation](https://www.claude.com/blog/using-claude-md-files)
- [Arize: CLAUDE.md Best Practices](https://arize.com/blog/claude-md-best-practices-learned-from-optimizing-claude-code-with-prompt-learning/)
