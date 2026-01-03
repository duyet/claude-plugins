---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git push:*)
description: Create a git commit with semantic commit message format and push to remote
---

# Commit and Push Commands

## Context

- Current Git status: !`git status`
- Current Git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Based on the above changes, create a single Git commit and push it to the remote repository.

You have the capability to call multiple tools in a single response. Stage, create the commit, and push using a single message. Do not use any other tools or do not send any other text or messages besides these tool calls.

Commit should follow semantic commit format: `type(scope): description`

Types: feat, fix, docs, style, refactor, test, chore
