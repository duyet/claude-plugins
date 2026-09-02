# Grok Build and Grok Bot

A Grok user adds this GitHub repo as a marketplace, then installs plugins with
`grok plugin install <name> --trust`. Grok Bot and Grok Build share
`.grok-plugin/marketplace.json`. Each plugin ships `.grok-plugin/plugin.json`
and `.grok-build-plugin/plugin.json`, and listings render `assets/logo.svg`.

## Sub-features

- `grok-marketplace-parse` loads `.grok-plugin/marketplace.json` as JSON.
- `grok-marketplace-names` Grok marketplace names equal plugin directories.
- `grok-sources` every plugin `source.path` exists and `source.type` is
  `local`.
- `grok-logos` every marketplace `logo` exists under the plugin source
  (usually `assets/logo.svg`).
- `grok-bot-manifests` every plugin directory has `.grok-plugin/plugin.json`.
- `grok-build-manifests` every plugin directory has
  `.grok-build-plugin/plugin.json`.
- `grok-docs` README and CONTRIBUTING document
  `grok plugin marketplace add duyet/codex-claude-plugins` and
  `.grok-plugin/marketplace.json`.
- `grok-check` `check-install --surface grok` returns `ok: true` with no
  `severity: skip`. Skip is a failed drive.

## How to get to it (user POV)

- Run `grok plugin marketplace add duyet/codex-claude-plugins`, then
  `grok plugin install team-agents --trust` (or another name).
- In the Grok TUI, open `/marketplace` or `/plugin` and press `i` to install.
- In the Grok Bot app, open **Plugins** and add `duyet/codex-claude-plugins`
  as a marketplace source if the CLI is not available.
- Open `<plugin>/.grok-plugin/plugin.json` and
  `<plugin>/.grok-build-plugin/plugin.json`.
- Open `<plugin>/assets/logo.svg`.

## Driving it with control-marketplace

Preconditions:

- `control-marketplace doctor` reports `ok`.
- Grok CLI may be absent. Do not fail the drive for a missing `grok` binary;
  prove the files the commands would resolve.

- **Surfaces.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs info --json`.
  `surfaces.grokBuild` and `surfaces.grokBot` are `true`.
  `counts.grokMarketplace` equals `counts.pluginDirs`.
- **Inventory.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs list --json`.
  Every plugin has `grok` and `grokBuild` true. `list --missing-grok --json`
  returns `count: 0`.
- **Install resolvability.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs check-install --surface grok --json`.
  `grok-marketplace-parses`, `grok-bot`, `grok-build`, and
  `grok-marketplace-names` pass. Every `grok-source-*` and `grok-logo-*`
  check passes. `readme-grok-marketplace-add` and
  `readme-grok-marketplace-file` pass. No check has `severity: skip`.
- **Inspect one plugin.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs inspect anyrouter --json`.
  `manifests.grok` and `manifests.grokBuild` are relative paths that exist.
  `marketplaceRows.grok.source.path` is `./anyrouter` and `logo` is
  `assets/logo.svg`.
- **Proof.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs prove --feature grok-build-and-bot --json`.
  `proof/drive.json` has `ok: true`, no `skipFailure`, and step ids `doctor`,
  `info`, `list`, `check-install-grok`. A screenshot of grok.x.ai is not this
  feature.

## Gotchas

- Prompt-engineering docs mention Grok the model. That is not Grok Build /
  Grok Bot install infrastructure.
- Grok Bot and Grok Build share one marketplace file. Do not look for a
  second catalog at `.grok-build-plugin/marketplace.json`.
- Marketplace `logo` is relative to the plugin source directory, not the repo
  root. Root `assets/logo.svg` is not a substitute for
  `<plugin>/assets/logo.svg`.
- `info` can be `ok` while Grok still lags plugin directories. Use
  `gaps.missingFromGrok`.
- Do not treat a passing Claude or Codex catalog as Grok coverage.
