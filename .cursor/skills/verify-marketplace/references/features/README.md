# Marketplace pack feature map

Behavior-level inventory of **duyet/codex-claude-plugins**. Agents use this map
to decide what to drive and what evidence counts. This checkout is a plugin
marketplace pack (Claude Code + Codex). It is not a hosted web app.

## Baseline preconditions

- Work in this git checkout only. Do not create git worktrees.
- `node .cursor/skills/verify-marketplace/control-marketplace.mjs doctor`
  reports `ok`.
- `python3` is on `PATH` (needed by `scripts/validate-plugins.sh`).
- Read-only commands are safe to run concurrently.
- Do not `install-antigravity --apply` against `$HOME` during verification.
- Grok Build / Grok Bot have no in-tree catalog. Drive
  [grok-build-and-bot.md](./grok-build-and-bot.md) as an expected skip, not a
  failure.

## Driving conventions

- Start from doctor unless a feature file says otherwise.
- Treat commands in feature files as literal.
- Use `--json` when asserting fields.
- `validate` wraps the production script; do not reimplement it ad hoc.
- Report unreachable paths (Claude Code / Codex CLIs not installed here) as
  skipped with the closest on-disk proof that remains.

## Proof and skip reporting

- Capture the command, exit code, and resulting catalog/docs state.
- A marketplace `source` that does not exist on disk is a failed install path,
  even if JSON parses.
- Missing plugin `README.md` is a docs warning unless `--strict`.
- Do not call a Codex gap verified via the Claude catalog.

## Full sweep

Walk this list top to bottom for a broad regression. Finish with
`grok-build-and-bot.md` (skip until a surface exists).

## Catalog & manifests

- [marketplace-catalog](./marketplace-catalog.md): root, Claude, and Codex
  marketplace JSON, plugin directory set, ids.
- [plugin-manifests](./plugin-manifests.md): per-plugin Claude / Codex /
  Antigravity `plugin.json` and parity.

## Install

- [claude-code-install](./claude-code-install.md): `/plugin marketplace add`,
  `/plugin install`, settings.json, Skills CLI.
- [codex-install](./codex-install.md): local Codex marketplace import from
  `.agents/plugins/marketplace.json`.

## Docs & harness

- [docs-and-readme](./docs-and-readme.md): README / CONTRIBUTING / CLAUDE.md
  install and structure docs; plugin READMEs.
- [validation-harness](./validation-harness.md): `scripts/validate-plugins.sh`
  and CI.

## Later surfaces

- [grok-build-and-bot](./grok-build-and-bot.md): placeholder for Grok Build /
  Grok Bot. No driver yet.

## Entry contract

Every feature file uses the same four H2s:

1. `Sub-features`
2. `How to get to it (user POV)`
3. `Driving it with control-marketplace`
4. `Gotchas`
