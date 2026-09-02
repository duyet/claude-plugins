# Validation harness

`scripts/validate-plugins.sh` is the production check for manifests, Claude /
Codex / Antigravity / Grok Bot / Grok Build parity, and marketplace files.
GitHub Actions runs the same script. Agents must use this script (via
`control-marketplace validate`), not a private reimplementation, as the source
of pass/fail.

## Sub-features

- `harness-script` `scripts/validate-plugins.sh` exists and is executable
  enough to run under `bash`.
- `harness-claude-manifests` validates every `.claude-plugin/plugin.json`.
- `harness-codex-manifests` validates every `.codex-plugin/plugin.json`.
- `harness-antigravity-manifests` validates every
  `.antigravity-plugin/plugin.json`.
- `harness-grok-manifests` validates every `.grok-plugin/plugin.json`.
- `harness-grok-build-manifests` validates every
  `.grok-build-plugin/plugin.json`.
- `harness-parity` shared fields match across hosts.
- `harness-marketplaces` marketplace files match plugin directories and
  source paths, including Grok logos under each plugin source.
- `harness-ci` `.github/workflows/validate-plugins.yml` invokes the script.

## How to get to it (user POV)

- Run `bash scripts/validate-plugins.sh` before opening a PR (CONTRIBUTING).
- Open a PR that touches manifests or marketplace JSON; workflow
  `Validate Plugins` runs.
- Read `CLAUDE.md` "When changing plugin metadata... run
  `bash scripts/validate-plugins.sh`".

## Driving it with control-marketplace

Preconditions:

- `control-marketplace doctor` reports `ok` (includes `validate-script` and
  `python3`).

- **Run the harness.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs validate --json`.
  `exitCode` is 0 on a clean pack. `passed` / `failed` are the script's
  `✅` / `❌` labels. `output` is the full transcript.
- **CI wiring.** Read `.github/workflows/validate-plugins.yml` and confirm it
  contains `bash scripts/validate-plugins.sh`. (File read is the user path for
  CI; do not invent a `gh workflow` run as the only proof.)
- **Failing catalog.** If `failed` includes `Marketplace files`, inspect
  `output` for the script's stderr lines (for example Codex names not matching
  directories). That is product drift, not a broken lever.
- **Proof.** Save the `validate --json` payload. A green doctor alone is not
  this feature.

## Gotchas

- The workflow path filter omits unrelated PRs. Local `validate` is the always
  available proof.
- `validate-plugins.sh` uses `find`, so it can see nested manifests `list`
  does not. If labels mention a nested path, record it.
- Do not "fix" a failing harness in a verification-only change unless the
  failure is in this skill. Catalog drift belongs in its own PR.
