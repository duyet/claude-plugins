# Commit Commands Plugin

Create Git commits with semantic commit message format using intelligent change analysis.

## Installation

```bash
/plugin install commit@duyet-claude-plugins
```

## What It Does

The `commit` plugin provides commands for creating Git commits with semantic commit message format.

## Commands

### `/commit:commit`

Create a semantic commit without pushing.

```bash
/commit:commit
```

Claude will:
1. Check `git status` to see all changes
2. Review `git diff HEAD` to understand what changed
3. Look at recent commits for context and style
4. Create an appropriate semantic commit message
5. Stage changes and commit

### `/commit:commit-and-push`

Create a semantic commit and push to remote.

```bash
/commit:commit-and-push
```

Same as `/commit:commit`, but also pushes the commit to the remote repository.

## Commit Format

Follows the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
type(scope): description
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation changes |
| `style` | Code style (formatting, semicolons, etc.) |
| `refactor` | Code refactoring |
| `test` | Adding or updating tests |
| `chore` | Build process, dependencies, etc. |

### Examples

```
feat(auth): add OAuth2 login support
fix(api): handle null response from external service
docs(readme): update installation instructions
refactor(utils): simplify date formatting logic
test(user): add unit tests for profile validation
```

## Architecture

```
commit/
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest
├── commands/
│   ├── commit.md             # Commit command definition
│   └── commit-and-push.md    # Commit and push command definition
└── README.md                 # This file
```

## Tips

- Make focused, atomic commits (one logical change per commit)
- The scope should match the main area of change
- Keep the description under 72 characters
- Use imperative mood ("add" not "added")

## Changelog

### [1.1.0] - 2025-01-03

- **Added**: `/commit:commit-and-push` command for committing and pushing in one operation
- **Changed**: Plugin renamed from `commit-commands` to `commit` for shorter invocation

### [1.0.0] - Initial Release

Semantic commit command using Conventional Commits specification with intelligent change analysis.
