# Codex install

A Codex user clones this repo and imports the local marketplace at
`.agents/plugins/marketplace.json`. Each entry points at `./<plugin>` with
`source.source: local`. Codex then installs plugins from the display name
"Duyet Claude and Codex Plugins".

## Sub-features

- `codex-marketplace-file` documents and parses
  `.agents/plugins/marketplace.json`.
- `codex-interface` requires `interface.displayName`.
- `codex-sources` every plugin `source.path` exists and
  `source.source` is `local`.
- `codex-names` marketplace plugin names equal plugin directories.
- `codex-docs` README and CONTRIBUTING mention the Codex marketplace path.

## How to get to it (user POV)

- `git clone https://github.com/duyet/codex-claude-plugins.git`
- Import `.agents/plugins/marketplace.json` in Codex.
- Install plugins from **Duyet Claude and Codex Plugins**.
- Use Codex wrapper skills under each plugin's `skills/` folder when the
  plugin is command-heavy on the Claude side.

## Driving it with control-marketplace

Preconditions:

- `control-marketplace doctor` reports `ok`.
- Codex CLI may be absent. Prove the marketplace file, not a live Codex
  session.

- **Docs.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs check-docs --json`
  or `check-install --surface codex --json`.
  `readme-codex-marketplace` and `contributing-codex-marketplace` pass.
- **Name set.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs check-install --surface codex --json`.
  `codex-marketplace-names` must pass. If `missingFromCodex` is non-empty, a
  plugin directory is not Codex-installable.
- **Local paths.** The same command: every `codex-source-*` check passes.
- **Inspect a Codex row.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs inspect github --json`.
  `marketplaceRows.codex.source.source` is `local` and `source.path` is
  `./github`.

## Gotchas

- README clone snippet still says `cd claude-plugins` in places. Assert the
  marketplace path string, not the directory name in that snippet.
- `info --json` `gaps.missingFromCodex` is the structured form of the name
  check. `validate` fails the whole marketplace step when names differ.
- Do not treat a passing Claude catalog as Codex coverage.
