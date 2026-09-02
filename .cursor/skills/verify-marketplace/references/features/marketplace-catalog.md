# Marketplace catalog

The pack is three marketplace JSON files plus one directory per plugin. A user
cannot install a plugin that is missing from the catalog they use, or whose
`source` path does not exist.

## Sub-features

- `catalog-parse` loads `marketplace.json`, `.claude-plugin/marketplace.json`,
  and `.agents/plugins/marketplace.json` as JSON.
- `catalog-list` lists plugin directories that ship a Claude or Codex manifest.
- `catalog-claude-sources` resolves every Claude marketplace `source` to a
  directory.
- `catalog-root-ids` checks root marketplace `id` values are
  `<name>@<marketplace.name>`.
- `catalog-codex-names` checks Codex marketplace names match plugin
  directories.

## How to get to it (user POV)

- Open `marketplace.json` at the repo root (skills.sh / catalog metadata).
- Open `.claude-plugin/marketplace.json` (Claude Code marketplace add).
- Open `.agents/plugins/marketplace.json` (Codex local marketplace).
- List first-level plugin folders that contain `.claude-plugin/plugin.json`.

## Driving it with control-marketplace

Preconditions:

- `control-marketplace doctor` reports `ok`.
- This git checkout is `duyet/codex-claude-plugins` (or a fork with the same
  layout).

- **Parse catalogs.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs info --json`.
  `ok` is true, `marketplaceName` is `duyet-claude-plugins`, and
  `counts.pluginDirs` equals `counts.rootMarketplace` and
  `counts.claudeMarketplace`.
- **List plugins.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs list --json`.
  `plugins` is a non-empty array; each item has `name` and `claude: true`.
- **Claude sources.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs check-install --surface claude --json`.
  Every `claude-source-*` check passes.
- **Codex names.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs check-install --surface codex --json`.
  `codex-marketplace-names` passes only when Codex names equal plugin
  directories. A listed `missingFromCodex` value is a real catalog bug, not a
  harness bug.
- **Proof.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs prove --feature marketplace-catalog --json`.
  `proof/drive.json` has `ok: true` and step ids `doctor`, `info`, `list`,
  `check-install-claude`.

## Gotchas

- Root `marketplace.json` and `.claude-plugin/marketplace.json` are different
  schemas. Do not assert `source` on the root file.
- `info` can be `ok` while Codex still lags plugin directories. Use
  `gaps.missingFromCodex`.
- Doctor does not fail on Codex drift. `validate` does.
- There is no web catalog to click. GitHub's repo page is not this feature.
