# CLAUDE.md Scoring Rubric

Use this rubric to evaluate CLAUDE.md effectiveness on a 1-10 scale.

## Overall Score Guide

| Score | Rating | Line Count | Description |
|-------|--------|------------|-------------|
| 9-10 | Excellent | <100 | All essential sections, perfect progressive disclosure, zero anti-patterns |
| 7-8 | Good | 100-150 | Mostly essential content, good structure, minor anti-patterns |
| 5-6 | Needs Work | 150-250 | Some redundancy, several anti-patterns, missing key sections |
| 3-4 | Poor | 250-400 | Significant redundancy, many anti-patterns, poor structure |
| 1-2 | Critical | >400 or none | Major issues throughout, or no CLAUDE.md exists |

## Detailed Scoring Categories

### 1. Conciseness (25% weight)

| Score | Criteria |
|-------|----------|
| 10 | Under 80 lines, every line essential |
| 8-9 | 80-120 lines, minimal redundancy |
| 6-7 | 120-180 lines, some redundancy |
| 4-5 | 180-250 lines, noticeable bloat |
| 2-3 | 250-400 lines, significant bloat |
| 1 | Over 400 lines |

### 2. Structure (25% weight)

| Score | Criteria |
|-------|----------|
| 10 | All 5 essential sections, perfect organization |
| 8-9 | 4-5 sections, clear headers, logical flow |
| 6-7 | 3-4 sections, adequate organization |
| 4-5 | 2-3 sections, some organization issues |
| 2-3 | 1-2 sections, poor organization |
| 1 | No clear sections, wall of text |

**Essential Sections Checklist**:
- [ ] Project Overview
- [ ] Directory Structure
- [ ] Development Commands
- [ ] Coding Standards/Conventions
- [ ] Resource Pointers

### 3. Progressive Disclosure (25% weight)

| Score | Criteria |
|-------|----------|
| 10 | Excellent use of file references, nested CLAUDE.md files |
| 8-9 | Good file references, minimal embedded content |
| 6-7 | Some file references, moderate embedded content |
| 4-5 | Few references, lots of embedded content |
| 2-3 | No references, everything embedded |
| 1 | Massive embedded documentation |

**Indicators of Good Progressive Disclosure**:
- "See `path/to/file` for..." patterns
- Nested CLAUDE.md in subdirectories
- Commands instead of embedded instructions
- References to example implementations

### 4. Actionability (25% weight)

| Score | Criteria |
|-------|----------|
| 10 | All instructions are actionable, specific, and useful |
| 8-9 | Most instructions actionable, few vague items |
| 6-7 | Some actionable content, some generic |
| 4-5 | Mix of actionable and useless content |
| 2-3 | Mostly generic or obvious instructions |
| 1 | No actionable instructions |

**Actionable Content Examples**:
- ✅ `npm run test:unit` for unit tests
- ✅ Components in `src/components/` use PascalCase
- ❌ Write clean code
- ❌ Follow best practices

## Anti-Pattern Deductions

Apply these deductions to the base score:

| Anti-Pattern | Deduction |
|--------------|-----------|
| API keys/secrets present | -3 points (minimum) |
| >50% content is embedded code | -2 points |
| Generic AI tips present | -1 point |
| Obvious instructions present | -1 point |
| Outdated file references | -1 point |
| Task-specific (should be commands) | -1 point |
| No clear sections | -2 points |
| Auto-generated without customization | -2 points |

## Sample Scoring

### Example 1: Score 9/10 - Excellent

```markdown
# My Project

React + TypeScript web app for task management.

## Structure
src/
  components/  # React components
  hooks/       # Custom hooks
  api/         # API client

## Commands
- `npm run dev` - Development server
- `npm test` - Run tests
- `npm run build` - Production build

## Conventions
- Components: PascalCase
- Hooks: `use` prefix
- Tests: Co-located `.test.tsx`

## References
- Architecture: `docs/architecture.md`
- API: `docs/api.md`
```

**Score Breakdown**:
- Conciseness: 10/10 (under 30 lines)
- Structure: 10/10 (all sections present)
- Progressive Disclosure: 9/10 (good references)
- Actionability: 9/10 (all useful)
- **Total: 9/10**

### Example 2: Score 4/10 - Poor

```markdown
# My Project

This project is a web application built with React and TypeScript. It was
started in 2023 and has grown to include many features. The main purpose
is to help users manage their tasks and stay productive. We use modern
best practices and follow clean code principles...

[300+ lines of verbose content, embedded code examples, generic advice]
```

**Score Breakdown**:
- Conciseness: 2/10 (300+ lines)
- Structure: 5/10 (some sections)
- Progressive Disclosure: 3/10 (everything embedded)
- Actionability: 4/10 (lots of generic content)
- Deductions: -2 (generic AI tips)
- **Total: 4/10**

## Calculating Final Score

1. Score each category (1-10)
2. Weight by percentage (25% each)
3. Apply anti-pattern deductions
4. Round to nearest integer
5. Clamp to 1-10 range

**Formula**:
```
Final = max(1, min(10, round(
  (Conciseness × 0.25) +
  (Structure × 0.25) +
  (ProgressiveDisclosure × 0.25) +
  (Actionability × 0.25) -
  (AntiPatternDeductions)
)))
```

## Quick Assessment Guide

For rapid scoring:

1. **Check line count** → Sets maximum possible score
2. **Count sections** → Structure score
3. **Scan for "See..."** → Progressive disclosure
4. **Look for anti-patterns** → Apply deductions
5. **Read top 20 lines** → Actionability check
