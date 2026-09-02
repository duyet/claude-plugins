# Plugin manifests

Each plugin ships a Claude manifest and a Codex manifest with shared
`name`, `version`, `description`, and `author.name`. Every plugin also ships
Grok Bot and Grok Build manifests. Some plugins also ship Antigravity. Users
and host tools read these files to load skills, commands, and agents.

## Sub-features

- `manifest-claude` requires `.claude-plugin/plugin.json` with name, version,
  description, author object.
- `manifest-codex` requires `.codex-plugin/plugin.json` plus `interface` and
  relative `./` paths that exist.
- `manifest-antigravity` requires `.antigravity-plugin/plugin.json` when that
  file is present (currently agent-loop).
- `manifest-grok` requires `.grok-plugin/plugin.json` with name, version,
  description, author object, and `logo`.
- `manifest-grok-build` requires `.grok-build-plugin/plugin.json` plus
  `interface` and a local `logo` / `interface.logo`.
- `manifest-parity` requires Claude/Codex/Grok/Antigravity shared fields to
  match.
- `manifest-inspect` shows one plugin's files and marketplace rows.

## How to get to it (user POV)

- Open `<plugin>/.claude-plugin/plugin.json`.
- Open `<plugin>/.codex-plugin/plugin.json`.
- Open `<plugin>/.grok-plugin/plugin.json`.
- Open `<plugin>/.grok-build-plugin/plugin.json`.
- Open `<plugin>/.antigravity-plugin/plugin.json` when the plugin supports
  Antigravity CLI.
- Open `<plugin>/assets/logo.svg`.
- Run `bash scripts/validate-plugins.sh` after editing either file.

## Driving it with control-marketplace

Preconditions:

- `control-marketplace doctor` reports `ok`.

- **Inventory manifests.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs list --json`.
  Every plugin has `claude`, `codex`, `grok`, and `grokBuild` true.
  `antigravity` is true only for plugins that ship that manifest.
  `list --missing-grok --json` is empty on a healthy pack.
- **Inspect one plugin.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs inspect commit --json`.
  `plugins[0].manifests.claude` and `manifests.codex` are relative paths that
  exist. `manifests.grok` and `manifests.grokBuild` exist.
  `marketplaceRows.claude` and `marketplaceRows.root` are non-null.
  `marketplaceRows.grok` is non-null.
- **Production parity.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs validate --json`.
  Labels include `Claude/Codex/Grok/Antigravity manifest parity`. If that
  label is in `failed`, manifests drifted.
- **Proof for a single plugin change.** Re-run `inspect <plugin>` after the
  edit and confirm `version` matches in both manifests.

## Gotchas

- Codex `skills` / `commands` values must be strings starting with `./`, not
  arrays (arrays live under `codex.skills` when used).
- `list --missing-codex` is empty on a healthy pack. A hit means a plugin is
  not installable in Codex.
- `list --missing-grok` is empty on a healthy pack. A hit means a plugin is
  missing `.grok-plugin/plugin.json` or `.grok-build-plugin/plugin.json`.
- Nested `plugin.json` under templates or `node_modules` is out of scope for
  `list` (first-level plugin dirs only). `validate-plugins.sh` uses `find` and
  may see more; treat a nested hit as a harness discrepancy and record it.
