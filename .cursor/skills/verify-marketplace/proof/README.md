# Proof artifacts

This directory is the named evidence location for `control-marketplace prove`.
Cleanup must never delete these files.

Generate (or refresh) a drive with:

```bash
node .cursor/skills/verify-marketplace/control-marketplace.mjs prove --feature marketplace-catalog --json
node .cursor/skills/verify-marketplace/control-marketplace.mjs prove --feature grok-build-and-bot --json
node .cursor/skills/verify-marketplace/control-marketplace.mjs prove --feature codex-install --json
```

`prove` writes one drive at a time into this directory. Claude and Codex
recipes stay in `proveSteps`. The Grok drive is the required proof after the
Grok marketplace shipped. Skip from `check-install --surface grok` fails the
Grok drive.

Expected files after a successful drive:

- `drive.json` — machine-readable summary (`ok`, feature id, step exits)
- `drive.md` — what the drive proved
- `drive.transcript.txt` — local full stdout/stderr (gitignored; it echoes
  plugin docs and is regenerable via `prove`)
