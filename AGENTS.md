# Claude Code Agent Plugins

A collection of specialized agent plugins for Claude Code marketplace. These agents expose proven engineering personas that can be installed and used by developers to enhance their workflow.

## Overview

Agent plugins provide reusable specialized roles that can be invoked for specific development tasks. Each agent encapsulates best practices, decision-making frameworks, and quality standards for their domain.

## Available Agents

### 1. Senior Engineer Agent

**Location:** `plugins/senior-engineer-agent.md`

An elite implementation engineer focused on translating specifications into high-performance, maintainable production code.

#### Specialization
- Feature implementation from requirements
- Frontend component development (React, Next.js, TypeScript)
- Backend system and API development
- Performance optimization and profiling
- Test-driven development and quality assurance

#### When to Invoke
- You have a detailed specification and need implementation
- Building components that require performance optimization
- Implementing features with strict quality requirements
- Refactoring code to follow SOLID principles
- Developing systems where clean architecture matters

#### Key Characteristics
- **Performance First**: Every decision prioritizes performance and scalability
- **Clean Code**: SOLID principles, DRY, self-documenting code
- **Test-Driven**: Comprehensive unit, integration, and E2E testing
- **Pattern Adherence**: Strictly follows existing project conventions
- **Proactive Improvement**: Identifies and suggests optimizations

#### Quality Standards Enforced
- Sub-3s load times
- <100ms API responses
- 90%+ test coverage
- Zero linting errors
- TypeScript strict compliance
- WCAG 2.1 AA accessibility compliance

---

### 2. Leader Agent

**Location:** `plugins/leader-agent.md`

A technical lead and engineering manager for coordinating complex development work, architectural planning, and ensuring quality standards.

#### Specialization
- Complex feature coordination and planning
- Multi-component bug investigation and fixing
- Large-scale refactoring and restructuring
- Architectural design and alignment
- Code review and quality assurance
- Team coordination and parallel execution

#### When to Invoke
- Multi-faceted features requiring architectural planning
- Critical bugs affecting multiple system components
- Large-scale refactoring or system redesign
- Need architectural guidance and planning
- Comprehensive code review and quality validation
- Breaking work into parallel workstreams

#### Key Characteristics
- **Comprehensive Analysis**: Deep understanding before planning
- **Architectural Thinking**: Solutions aligned with existing patterns
- **Parallel Execution**: Breaking work into independent tasks
- **Quality Gates**: Non-negotiable quality standards
- **Team Leadership**: Coordination and collaboration focus
- **Evidence-Based**: Decisions backed by data and testing

#### Quality Gates Enforced
- All tests passing (unit, integration, E2E)
- Zero linting errors
- ≥80% test coverage for critical paths
- Security vulnerabilities addressed
- Pattern and convention compliance
- Documentation accuracy

---

## Installation & Usage

### For Claude Code Users

1. **Add to your Claude Code configuration** by referencing the agent plugin files
2. **Invoke through natural language** requests:

```
// Senior Engineer Agent
I have a specification for [feature]. Can you implement this following our project patterns?

// Leader Agent
We need to implement [complex feature]. Can you analyze, design, plan, and coordinate the work?
```

3. **Customize** agent behavior through project-specific `.claude/` configuration files

### For Plugin Marketplace

These agents are ready for distribution through the Claude Code marketplace:

- **File Format**: Markdown with YAML frontmatter
- **Installation**: Copy `.md` file to plugins directory
- **Configuration**: Automatically discoverable by Claude Code

## Architecture & Design

### Plugin Structure

Each agent plugin consists of:
- **Metadata**: Name, description, category, tags
- **Philosophy**: Core principles and approach
- **Expertise**: Technical domains and competencies
- **Workflow**: Step-by-step execution patterns
- **Standards**: Quality requirements and metrics
- **Invocation**: How and when to use the agent

### Integration with Claude Code

- Agents are discovered and invoked by Claude Code through the Task tool
- Configuration available in project `.claude/agents/` directory
- Sub-agents can coordinate with each other for complex work
- All quality standards are enforced consistently

## Best Practices

### Using Senior Engineer Agent
- Provide detailed specifications or plans
- Include existing code patterns and conventions
- Specify performance requirements if critical
- Allow time for comprehensive testing
- Review and provide feedback on implementation

### Using Leader Agent
- Clearly articulate high-level requirements
- Allow time for deep analysis phase
- Be available for clarification questions
- Expect detailed planning and reporting
- Prepare for comprehensive code review

### Combining Agents
- Use **Leader Agent** to plan complex work
- Delegate implementation to **Senior Engineer Agent**
- Leader coordinates, Senior Engineer executes
- Iterative refinement and optimization

## Development & Contribution

### Creating New Agents

1. **Define the persona**: What role does this agent embody?
2. **Document expertise**: Technical domains and competencies
3. **Establish workflow**: Step-by-step execution process
4. **Set standards**: Quality requirements and metrics
5. **Create plugin file**: Markdown with YAML frontmatter
6. **Update documentation**: Add to AGENTS.md and README.md
7. **Test thoroughly**: Verify behavior and quality output

### Plugin Format

```markdown
---
name: agent-name
description: Clear description of what this agent does
category: agent
tags:
  - tag1
  - tag2
---

# Agent Name

[Detailed agent philosophy, expertise, and workflow]
```

## Frequently Asked Questions

### Can agents work together?
Yes! The Leader Agent can coordinate work and delegate to the Senior Engineer Agent, enabling complex multi-agent workflows.

### What if I need a custom agent?
Create a new agent plugin following the established format. Include clear philosophy, expertise documentation, and quality standards.

### How are quality standards enforced?
Each agent includes non-negotiable quality gates that must be passed before work is considered complete. Standards include testing, linting, security, and pattern compliance.

### Can agents be used in different projects?
Yes! Agents are designed to be project-agnostic but configurable. Project-specific behavior can be set through `.claude/` configuration files.

### What languages do agents support?
Agents have expertise in multiple languages and frameworks:
- **Frontend**: React, Next.js, Vue, TypeScript
- **Backend**: Node.js, Python, Go, Rust
- **Databases**: SQL, NoSQL, Redis
- **Platforms**: AWS, Docker, Kubernetes

---

## Related Resources

- **README.md**: Overview of all marketplace plugins
- **plugins/**: Individual plugin definitions
- **.claude/agents/**: Local agent configuration
- **Claude Code Documentation**: Official usage guide

## Support & Feedback

For issues, questions, or suggestions regarding these agents:
1. Check existing documentation
2. Create an issue in the repository
3. Provide detailed context and expected behavior
4. Include examples of how the agent was invoked
