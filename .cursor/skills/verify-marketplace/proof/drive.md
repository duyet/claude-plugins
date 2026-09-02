# Proven drive: marketplace-catalog

Result: **pass**

- Started: 2026-09-02T18:23:37.757Z
- Finished: 2026-09-02T18:23:37.859Z
- Repo: checkout root (paths in this file are repo-relative)
- Hosted UI: no

## What this proved

The checkout is a marketplace plugin pack. Marketplace JSON parses, plugin directories are listable, and every Claude marketplace `source` resolves to a real folder. There is no web app to click; Claude Code install needles in README match files that exist on disk. Inventory from `info`: 24 plugin directories, root/Claude catalogs 24/24, Codex 23 (missing command-code; not a Claude-catalog failure).

## Steps

- `doctor`: pass (exit 0) — `node .cursor/skills/verify-marketplace/control-marketplace.mjs doctor --json`
- `info`: pass (exit 0) — `node .cursor/skills/verify-marketplace/control-marketplace.mjs info --json`
- `list`: pass (exit 0) — `node .cursor/skills/verify-marketplace/control-marketplace.mjs list --json`
- `check-install-claude`: pass (exit 0) — `node .cursor/skills/verify-marketplace/control-marketplace.mjs check-install --surface claude --json`

## Artifacts

- `drive.json` — machine-readable summary
- `drive.md` — what the drive proved (committed). `drive.transcript.txt` is local-only.
