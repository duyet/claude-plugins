# Claude Code install

A Claude Code user adds this GitHub repo as a marketplace, then installs
plugins by id `<name>@duyet-claude-plugins`. Manual `settings.json` and
`npx skills add` are documented alternatives. Antigravity local symlink install
is a related CLI path, not Claude Code itself.

## Sub-features

- `claude-marketplace-add` documents
  `/plugin marketplace add duyet/codex-claude-plugins`.
- `claude-plugin-install` documents `/plugin install <name>@duyet-claude-plugins`
  and root catalog ids of that shape.
- `claude-settings` documents `extraKnownMarketplaces` in `README.md`.
- `claude-skills-cli` documents `npx skills add duyet/codex-claude-plugins`.
- `claude-sources` every `.claude-plugin/marketplace.json` `source` directory
  exists.
- `antigravity-dry-run` plans Antigravity symlinks without writing.

## How to get to it (user POV)

- In Claude Code, run `/plugin marketplace add duyet/codex-claude-plugins`,
  then `/plugin install team-agents@duyet-claude-plugins` (or another id).
- Or edit `~/.claude/settings.json` as shown in README "Manual Installation".
- Or run `npx skills add duyet/codex-claude-plugins`.
- For Antigravity CLI:
  `./scripts/install-antigravity.sh <plugin-name>` (or `all`).

## Driving it with control-marketplace

Preconditions:

- `control-marketplace doctor` reports `ok`.
- Claude Code itself may be absent. Do not fail the drive for a missing
  `claude` binary; prove the files the commands would resolve.

- **Documented commands.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs check-install --surface claude --json`.
  `readme-marketplace-add`, `readme-plugin-install`, `readme-skills-cli`, and
  `readme-settings-json` pass.
- **Ids and sources.** The same command: every `root-id-*` and
  `claude-source-*` check passes.
- **Antigravity plan.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs install-antigravity --dry-run --json`.
  `dryRun` is true, `written` is `[]`. If `--target` is omitted, no files are
  created under `$HOME/.gemini/config/plugins` by this command.
- **Proof.** `check-install --surface claude` plus the dry-run JSON. A
  screenshot of claude.ai is not this feature.

## Gotchas

- Claude Code marketplace add talks to GitHub; this lever does not clone
  remotely. On-disk `source` paths are the proof that a local checkout can be
  imported.
- `install-antigravity` without `--apply` must not mkdir the default home
  target. Confirm by listing that directory before and after, or by using a
  missing `--target` and checking `written`.
- Skills CLI (`npx skills add`) is documented; it is not executed here (network
  + user agent dirs). Assert the README needle only.
