---
name: verify-marketplace
description: >-
  Drive the duyet/codex-claude-plugins marketplace pack via control-marketplace:
  marketplace JSON, Claude/Codex/Antigravity/Grok manifests, local plugin logos,
  and documented install paths. Use when verifying plugin catalog changes,
  install docs, or scripts/validate-plugins.sh. There is no hosted web UI.
---

# Verify marketplace

Drive this checkout as a **plugin marketplace pack**, not a web app. Users add a
marketplace and install plugins in Claude Code, Codex, Grok Build, or Grok Bot.
The lever is `control-marketplace.mjs`. `--help` is canonical.

```bash
node .cursor/skills/verify-marketplace/control-marketplace.mjs --help
```

## Surface (interview)

- **Primary:** catalogs and manifests on disk
  (`marketplace.json`, `.claude-plugin/marketplace.json`,
  `.agents/plugins/marketplace.json`, `.grok-plugin/marketplace.json`,
  per-plugin `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`,
  `.grok-plugin/plugin.json`, and `.grok-build-plugin/plugin.json`).
- **Install docs:** root `README.md`, `CLAUDE.md`, `CONTRIBUTING.md`.
- **Logos:** each plugin's `assets/logo.svg`, plus marketplace `logo` paths
  relative to the plugin source directory.
- **Existing harness:** `bash scripts/validate-plugins.sh` (same script CI
  runs).
- **Also present:** `scripts/install-antigravity.sh` for the one plugin that
  ships `.antigravity-plugin/plugin.json`.
- **Not present:** hosted UI. Do not open a browser against this repo. Drive
  Grok Build and Grok Bot with `check-install --surface grok`. Skip is a
  failure.

## Launch

There is no server. Launch means: this git checkout, `python3`, and Node.

```bash
node .cursor/skills/verify-marketplace/control-marketplace.mjs doctor --json
```

Ready when `ok` is true and `checks` all pass. Teardown is not required for
read-only commands. Two agents may run read-only commands in the same checkout.
Do not create git worktrees for verification.

## Doctor

Run first when anything looks off:

```bash
node .cursor/skills/verify-marketplace/control-marketplace.mjs doctor
node .cursor/skills/verify-marketplace/control-marketplace.mjs doctor --json
```

Doctor answers "is this instance worth driving?": marketplace JSON parses
(including `.grok-plugin/marketplace.json`), `scripts/validate-plugins.sh`
exists, plugin directories are visible, python3 works. Catalog drift (for
example a plugin missing from the Codex or Grok marketplace) is **not** a
doctor failure; `validate` and `check-install --surface codex|grok` report
that.

## Drive

Match the change to a file under
[`references/features/`](references/features/). Then run the commands that file
lists. Compose with `--json` and `jq`.

```bash
# identity and inventory
node .cursor/skills/verify-marketplace/control-marketplace.mjs info --json
node .cursor/skills/verify-marketplace/control-marketplace.mjs list --json
node .cursor/skills/verify-marketplace/control-marketplace.mjs inspect commit --json

# production validator (CI equivalent)
node .cursor/skills/verify-marketplace/control-marketplace.mjs validate --json

# docs + install resolvability
node .cursor/skills/verify-marketplace/control-marketplace.mjs check-docs --json
node .cursor/skills/verify-marketplace/control-marketplace.mjs check-install --surface claude --json
node .cursor/skills/verify-marketplace/control-marketplace.mjs check-install --surface codex --json
node .cursor/skills/verify-marketplace/control-marketplace.mjs check-install --surface grok --json

# Grok Bot + Grok Build proven drive (skip is a failure)
node .cursor/skills/verify-marketplace/control-marketplace.mjs prove --feature grok-build-and-bot --json

# destructive Antigravity symlink plan only
node .cursor/skills/verify-marketplace/control-marketplace.mjs install-antigravity --dry-run --json
```

Prefer these handles over reading source: marketplace `name` / `source` /
`source.path`, manifest `name`+`version`+`description`, README install
commands.

## Evidence

Proof lives under `.cursor/skills/verify-marketplace/proof/` unless `--out`
says otherwise. Cleanup must not delete it.

Standards:

- Exercise the real user path: documented install commands and the files those
  commands would resolve, plus `scripts/validate-plugins.sh`. Do not treat
  "the JSON looks fine" as proof that a `source` path exists.
- Capture the command and the resulting `ok` / failed check ids, not only a
  final summary.
- Side effects: for `install-antigravity --dry-run`, observe that the target
  directory is unchanged (no new symlinks). Do not trust the flag name alone.
- Mocks: none. This pack is files on disk.
- Hosted UI screenshots are not evidence here; there is nothing to screenshot.

Record a drive:

```bash
node .cursor/skills/verify-marketplace/control-marketplace.mjs prove --feature marketplace-catalog --json
node .cursor/skills/verify-marketplace/control-marketplace.mjs prove --feature grok-build-and-bot --json
```

## Cleanup

```bash
node .cursor/skills/verify-marketplace/control-marketplace.mjs cleanup --dry-run --json
node .cursor/skills/verify-marketplace/control-marketplace.mjs cleanup --json
```

Removes `/tmp/verify-marketplace-*` only. Never kill processes by name. Never
delete `proof/`. After cleanup, `proof/drive.json` must still exist.

## Helpers

The only helper is `control-marketplace.mjs` in this directory. It is
executable. `--help` and `<command> --help` document flags. Destructive
command: `install-antigravity` (writes symlinks) and `cleanup` (deletes tmp
scratch); both accept `--dry-run`. `install-antigravity` is dry-run unless
`--apply` is passed, and it refuses the default `$HOME/.gemini/config/plugins`
target without `--force`.

## Feature map

[`references/features/README.md`](references/features/README.md) is the
regression index. Each feature file uses `Sub-features`,
`How to get to it (user POV)`, `Driving it with control-marketplace`,
`Gotchas`.

Keep the map honest with `/maintain-verification-skill` as catalogs grow.
