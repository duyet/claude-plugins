# Grok Build and Grok Bot

Room for future Grok surfaces. This pack does not yet ship a Grok Build
marketplace or a Grok Bot plugin catalog. Verification must report an
**expected skip**, not invent manifests, install commands, or a browser flow.

## Sub-features

- `grok-build-absent` no Grok Build marketplace file in the repo root layout.
- `grok-bot-absent` no Grok Bot pack metadata in-tree.
- `grok-check` `check-install --surface grok` returns `available: false` with
  `severity: skip`.

## How to get to it (user POV)

- There is no user install path yet. Do not tell a user to run a Grok
  marketplace add command.
- When a Grok surface lands, it should get its own marketplace file, install
  docs in README, and new `control-marketplace` checks in the same shape as
  Claude and Codex.

## Driving it with control-marketplace

Preconditions:

- `control-marketplace doctor` reports `ok`.

- **Skip, do not fake.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs check-install --surface grok --json`.
  Checks `grok-build` and `grok-bot` have `ok: true`, `severity: skip`, and
  `available: false` (or a newly documented path if files appeared).
- **Surface flags.** Run
  `node .cursor/skills/verify-marketplace/control-marketplace.mjs info --json`.
  `surfaces.grokBuild` and `surfaces.grokBot` are `false` until a catalog
  exists.
- **Proof of absence.** The JSON above is the proof. Do not open Grok, X, or
  a bot dashboard as a substitute.

## Gotchas

- Prompt-engineering docs mention Grok the model. That is not Grok Build / Grok
  Bot install infrastructure.
- If someone adds `.grok-plugin/` or similar, this file is stale: extend
  `check-install` and replace the skip with real source-path checks.
- `/maintain-verification-skill` should keep this entry until those hosts are
  real.
