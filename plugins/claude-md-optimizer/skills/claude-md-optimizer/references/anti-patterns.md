# CLAUDE.md Anti-Patterns

Patterns to detect and flag during analysis. Each anti-pattern wastes context, reduces instruction-following, or creates other issues.

## Anti-Pattern Reference Table

| # | Anti-Pattern | Why It's Bad | Fix |
|---|-------------|--------------|-----|
| 1 | Verbose explanations | Wastes context, reduces instruction following | Cut to bullet points |
| 2 | Embedded code examples | Stale, duplicated, wastes space | Point to actual files |
| 3 | Obvious instructions | "Write clean code" - Claude already knows | Remove entirely |
| 4 | Duplicate linter rules | Already enforced by tools | Use hooks/linters instead |
| 5 | Generic AI tips | "Think step by step" - built in | Remove entirely |
| 6 | Task-specific instructions | Not universally applicable | Move to slash commands |
| 7 | Long narratives | Hard for Claude to parse | Convert to bullets |
| 8 | API keys/secrets | Security risk | Never include |
| 9 | Outdated information | Misleads Claude | Update or remove |
| 10 | Auto-generated boilerplate | Generic, not project-specific | Customize heavily |
| 11 | Excessive line count | >200 lines wastes context | Trim ruthlessly |
| 12 | Embedded documentation | Copying docs into CLAUDE.md | Point to doc files |
| 13 | Repeated information | Same info in multiple places | Single source of truth |
| 14 | Unclear organization | No clear sections | Use standard sections |
| 15 | Missing structure | Wall of text | Add markdown headers |

## Detailed Anti-Pattern Descriptions

### 1. Verbose Explanations

**Detection**: Paragraphs with 3+ sentences, conversational tone

**Example (Bad)**:
```markdown
When you're working on this project, it's really important that you understand
how we handle authentication. We use JWT tokens for all API requests, and these
tokens are stored in localStorage. The reason we chose this approach is because
it provides a good balance between security and ease of implementation. You
should always make sure to include the token in the Authorization header.
```

**Example (Good)**:
```markdown
## Auth
- JWT tokens in localStorage
- Include in Authorization header
- See `src/auth/README.md` for details
```

### 2. Embedded Code Examples

**Detection**: Multi-line code blocks that could reference existing files

**Example (Bad)**:
```markdown
## Component Pattern
```jsx
function MyComponent({ data }) {
  const [state, setState] = useState(null);
  useEffect(() => {
    fetchData().then(setState);
  }, []);
  return <div>{state}</div>;
}
```
```

**Example (Good)**:
```markdown
## Component Pattern
- See `src/components/ExampleComponent.tsx` for the standard pattern
```

### 3. Obvious Instructions

**Detection**: Instructions that any competent developer or Claude would follow

**Examples to Remove**:
- "Write clean, readable code"
- "Follow best practices"
- "Use meaningful variable names"
- "Add comments where necessary"
- "Handle errors appropriately"

### 4. Duplicate Linter Rules

**Detection**: Style rules that linters/formatters handle

**Examples to Remove**:
- "Use 2-space indentation"
- "Use single quotes for strings"
- "Add trailing commas"
- "Maximum line length 80 characters"

**Fix**: Configure ESLint, Prettier, or equivalent

### 5. Generic AI Tips

**Detection**: Meta-instructions about how Claude should think

**Examples to Remove**:
- "Think step by step"
- "Consider edge cases"
- "Be thorough in your analysis"
- "Take a deep breath"

### 6. Task-Specific Instructions

**Detection**: Instructions that only apply to certain types of tasks

**Example (Bad in CLAUDE.md)**:
```markdown
## When Writing Tests
1. Use describe blocks for grouping
2. Use it blocks for individual tests
3. Mock external dependencies
4. Aim for 80% coverage
```

**Fix**: Move to a `/test` slash command

### 7. Long Narratives

**Detection**: Prose paragraphs without structure

**Fix**: Convert to:
- Bullet points
- Numbered lists
- Tables
- Clear sections

### 8. API Keys/Secrets

**Detection**: Patterns like `sk-`, `api_key=`, credentials, tokens

**Action**: Immediate removal, security warning

### 9. Outdated Information

**Detection**: References to deprecated features, old URLs, removed files

**Signs**:
- File paths that don't exist
- Deprecated library references
- Old version numbers
- Dead links

### 10. Auto-Generated Boilerplate

**Detection**: Generic `/init` output that wasn't customized

**Signs**:
- Very generic descriptions
- Placeholder text
- Obvious auto-generated structure
- No project-specific details

## Detection Checklist

When analyzing a CLAUDE.md, check for:

- [ ] Lines > 200 (line count anti-pattern)
- [ ] Code blocks > 10 lines (embedded code)
- [ ] Paragraphs > 3 sentences (verbose explanations)
- [ ] "Clean code", "best practices" phrases (obvious instructions)
- [ ] Indentation/quote/comma rules (linter rules)
- [ ] "Step by step", "thorough" phrases (AI tips)
- [ ] Task-specific sections (should be commands)
- [ ] Secrets patterns (sk-, api_key, password)
- [ ] Non-existent file references (outdated)
- [ ] Very generic content (boilerplate)

## Severity Levels

| Severity | Anti-Patterns | Action |
|----------|---------------|--------|
| Critical | API keys/secrets | Immediate removal |
| High | >300 lines, outdated info | Address first |
| Medium | Verbose, embedded code, obvious | Fix soon |
| Low | Minor formatting, organization | Nice to fix |
