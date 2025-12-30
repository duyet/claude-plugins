---
name: quality-gates
description: Systematic quality verification procedures for code review and delivery. Use when validating completed work, conducting code reviews, or ensuring production readiness.
---

This skill provides structured quality gate procedures for verifying code quality, security, performance, and production readiness before delivery.

## When to Invoke This Skill

Automatically activate for:
- Code review and validation
- Pre-merge quality checks
- Pre-deployment verification
- Release readiness assessment
- Post-implementation quality audit

## Quality Gate Levels

### Standard (Default)

For routine changes, bug fixes, small features:

```
┌─────────────────────────────────────────────────────────┐
│                    STANDARD GATES                        │
├─────────────────────────────────────────────────────────┤
│ ✓ All tests pass                                        │
│ ✓ Linting clean (no errors)                             │
│ ✓ TypeScript compiles (no type errors)                  │
│ ✓ Code follows project patterns                         │
│ ✓ No obvious security issues                            │
│ ✓ Changes match requirements                            │
└─────────────────────────────────────────────────────────┘
```

### Strict

For significant features, refactors, public APIs:

```
┌─────────────────────────────────────────────────────────┐
│                     STRICT GATES                         │
├─────────────────────────────────────────────────────────┤
│ All Standard gates PLUS:                                │
│ ✓ Test coverage ≥ 90% for new code                      │
│ ✓ Security scan passes (no high/critical)               │
│ ✓ Performance benchmarks met                            │
│ ✓ API documentation updated                             │
│ ✓ Breaking changes documented                           │
│ ✓ Peer review completed                                 │
└─────────────────────────────────────────────────────────┘
```

### Critical

For security-sensitive, production-critical, high-risk changes:

```
┌─────────────────────────────────────────────────────────┐
│                    CRITICAL GATES                        │
├─────────────────────────────────────────────────────────┤
│ All Strict gates PLUS:                                  │
│ ✓ Security audit by security-focused review             │
│ ✓ Load testing completed                                │
│ ✓ Rollback procedure documented and tested              │
│ ✓ Monitoring and alerting configured                    │
│ ✓ Stakeholder sign-off obtained                         │
│ ✓ Incident response plan updated                        │
└─────────────────────────────────────────────────────────┘
```

## Quality Gate Procedures

### 1. Code Quality Gate

```bash
# Run these checks in sequence
npm run lint          # or: bun run lint
npm run type-check    # or: bun run type-check
npm run test          # or: bun run test
npm run build         # Verify build succeeds
```

**Verification checklist:**
- [ ] Zero linting errors
- [ ] Zero TypeScript errors
- [ ] All tests pass
- [ ] Build completes successfully
- [ ] No console.log statements in production code
- [ ] No TODO comments blocking release

### 2. Test Coverage Gate

```bash
npm run test:coverage
```

**Coverage requirements by level:**

| Level | Line Coverage | Branch Coverage | Function Coverage |
|-------|--------------|-----------------|-------------------|
| Standard | ≥ 70% | ≥ 60% | ≥ 70% |
| Strict | ≥ 90% | ≥ 80% | ≥ 90% |
| Critical | ≥ 95% | ≥ 90% | ≥ 95% |

**What to test:**
- [ ] Happy path scenarios
- [ ] Error handling paths
- [ ] Edge cases (null, empty, boundary values)
- [ ] Integration points
- [ ] User-facing behavior

### 3. Security Gate

**Automated checks:**
```bash
npm audit              # Dependency vulnerabilities
npm run lint:security  # Security-focused lint rules (if configured)
```

**Manual review checklist:**
- [ ] No hardcoded secrets or credentials
- [ ] Input validation on all user inputs
- [ ] Output encoding to prevent XSS
- [ ] SQL/NoSQL injection prevention
- [ ] Authentication checks on protected routes
- [ ] Authorization verified for sensitive operations
- [ ] HTTPS enforced for sensitive data
- [ ] Sensitive data not logged
- [ ] CORS configured correctly

**For Strict/Critical:**
- [ ] OWASP Top 10 review completed
- [ ] Security-focused code review by second engineer
- [ ] Penetration testing (Critical only)

### 4. Performance Gate

**Metrics to verify:**

| Metric | Standard | Strict | Critical |
|--------|----------|--------|----------|
| Page Load | < 3s | < 2s | < 1s |
| API Response | < 500ms | < 200ms | < 100ms |
| Bundle Size | < 500KB | < 300KB | < 200KB |
| Memory Leak | None | None | None |

**Verification steps:**
- [ ] No N+1 queries introduced
- [ ] Database queries use indexes
- [ ] Large lists are paginated
- [ ] Images are optimized
- [ ] Caching implemented where appropriate
- [ ] No blocking operations on main thread

### 5. Documentation Gate

**Required documentation:**

| Level | README | API Docs | Changelog | Architecture |
|-------|--------|----------|-----------|--------------|
| Standard | ✓ | - | ✓ | - |
| Strict | ✓ | ✓ | ✓ | - |
| Critical | ✓ | ✓ | ✓ | ✓ |

**Checklist:**
- [ ] README updated with new features/changes
- [ ] API endpoints documented (Strict+)
- [ ] Breaking changes clearly noted
- [ ] Migration guide provided (if applicable)
- [ ] Architecture decisions recorded (Critical)

### 6. Integration Gate

**Verification steps:**
- [ ] Feature works end-to-end
- [ ] No regression in existing functionality
- [ ] Cross-browser testing (if frontend)
- [ ] Mobile responsiveness verified (if applicable)
- [ ] Third-party integrations tested

**For Strict/Critical:**
- [ ] E2E test suite passes
- [ ] Staging environment validation
- [ ] User acceptance testing completed

## Quality Gate Report Template

```markdown
## Quality Gate Report

**Feature**: [Feature Name]
**Level**: [Standard | Strict | Critical]
**Date**: [YYYY-MM-DD]
**Reviewer**: [Name]

### Summary
| Gate | Status | Notes |
|------|--------|-------|
| Code Quality | ✅ PASS | All checks clean |
| Test Coverage | ✅ PASS | 92% coverage |
| Security | ✅ PASS | No vulnerabilities |
| Performance | ⚠️ WARN | API slightly slow |
| Documentation | ✅ PASS | Updated |
| Integration | ✅ PASS | E2E passing |

### Detailed Results

#### Code Quality
- Lint: 0 errors, 0 warnings
- TypeScript: 0 errors
- Tests: 47 passed, 0 failed
- Build: Success

#### Test Coverage
- Lines: 92% (target: 90%)
- Branches: 85% (target: 80%)
- Functions: 94% (target: 90%)

#### Security
- npm audit: 0 vulnerabilities
- Manual review: Completed, no issues
- [x] Input validation verified
- [x] Auth checks verified

#### Performance
- Page load: 1.8s (target: < 2s)
- API response: 180ms (target: < 200ms)
- Bundle size: 287KB (target: < 300KB)

#### Issues Found
1. [WARN] API endpoint `/api/users` responds in 450ms under load
   - Recommendation: Add caching layer
   - Severity: Low
   - Blocking: No

### Verdict

**✅ APPROVED FOR MERGE**

All critical gates pass. Performance warning noted for future optimization.
```

## Gate Failure Handling

When a gate fails:

### 1. Identify Severity

| Severity | Description | Action |
|----------|-------------|--------|
| Blocker | Prevents deployment | Must fix before merge |
| Critical | Security/data risk | Must fix before merge |
| Major | Significant issue | Should fix, can defer with approval |
| Minor | Quality concern | Can defer to follow-up |

### 2. Document the Issue

```markdown
### Gate Failure: [Gate Name]

**Severity**: [Blocker | Critical | Major | Minor]
**Description**: [What failed and why]
**Impact**: [What happens if not fixed]
**Remediation**: [How to fix]
**Timeline**: [When it will be fixed]
**Approved By**: [If deferring, who approved]
```

### 3. Resolution Path

```
Blocker/Critical → Fix immediately → Re-run gates
Major → Fix or get approval → Document decision
Minor → Create follow-up ticket → Proceed with caution
```

## Quick Reference Commands

```bash
# Standard gate check
npm run lint && npm run type-check && npm run test && npm run build

# Coverage check
npm run test:coverage

# Security audit
npm audit

# Full strict gate
npm run lint && npm run type-check && npm run test:coverage && npm run build && npm audit
```

## Checklist Summary

### Pre-Review (Author)
- [ ] Self-reviewed code changes
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No debugging code left
- [ ] Commit messages are clear

### Code Review (Reviewer)
- [ ] Logic is correct
- [ ] Code is readable
- [ ] Follows project patterns
- [ ] No security concerns
- [ ] Tests are meaningful
- [ ] Error handling is appropriate

### Pre-Merge
- [ ] All CI checks pass
- [ ] Required approvals obtained
- [ ] Conflicts resolved
- [ ] Branch is up to date

### Pre-Deploy (Critical)
- [ ] Rollback plan documented
- [ ] Monitoring configured
- [ ] Stakeholders notified
- [ ] Deployment window confirmed
