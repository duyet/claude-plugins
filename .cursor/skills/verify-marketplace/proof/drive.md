# Proven drive: grok-build-and-bot

Result: **pass**

- Started: 2026-09-02T18:52:29.522Z
- Finished: 2026-09-02T18:52:29.632Z
- Repo: checkout root (paths in this file are repo-relative)
- Hosted UI: no

## What this proved

The checkout ships Grok Bot and Grok Build. `.grok-plugin/marketplace.json` parses, every plugin directory has `.grok-plugin/plugin.json` and `.grok-build-plugin/plugin.json`, marketplace sources resolve, and each marketplace logo path exists on disk. `check-install --surface grok` does not report skip. Inventory from `info`: 24 plugin directories, root/Claude catalogs 24/24, Codex 24, Grok 24.

## Steps

- `doctor`: pass (exit 0) — `node .cursor/skills/verify-marketplace/control-marketplace.mjs doctor --json`
- `info`: pass (exit 0) — `node .cursor/skills/verify-marketplace/control-marketplace.mjs info --json`
- `list`: pass (exit 0) — `node .cursor/skills/verify-marketplace/control-marketplace.mjs list --json`
- `check-install-grok`: pass (exit 0) — `node .cursor/skills/verify-marketplace/control-marketplace.mjs check-install --surface grok --json`

## Artifacts

- `drive.json` — machine-readable summary
- `drive.md` — what the drive proved (committed). `drive.transcript.txt` is local-only.

