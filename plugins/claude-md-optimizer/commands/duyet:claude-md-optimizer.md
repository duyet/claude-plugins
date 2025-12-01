Invoke the `claude-md-optimizer` skill to analyze and optimize CLAUDE.md files in this project.

## How It Works

The skill will:

1. **Load the knowledge base** from reference files:
   - `references/best-practices.md` - Comprehensive best practices
   - `references/anti-patterns.md` - 15+ anti-patterns to detect
   - `references/scoring-rubric.md` - Detailed scoring criteria
   - `references/output-format.md` - Report template

2. **Analyze the codebase**:
   - Detect project type and tech stack
   - Map directory structure
   - Find configuration files

3. **Assess CLAUDE.md files**:
   - Check line count (target: 100-200)
   - Identify sections present
   - Scan for anti-patterns
   - Check for nested files

4. **Generate comprehensive report**:
   - Effectiveness Score (1-10)
   - Score breakdown by category
   - Anti-patterns with line references
   - Priority recommendations
   - Quick wins (<5 min fixes)

## Key Best Practices Applied

| Principle | Target |
|-----------|--------|
| Conciseness | 100-200 lines max |
| Progressive Disclosure | Point to files, don't embed |
| Declarative Style | Bullet points, not paragraphs |
| Universal Applicability | Only instructions for every task |

## Sources

Best practices compiled from:
- Anthropic official documentation
- HumanLayer research
- Community experts

Start by reading the reference files in the skill, then explore the project.
