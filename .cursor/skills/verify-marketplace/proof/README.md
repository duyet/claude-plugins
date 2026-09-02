# Proof artifacts

This directory is the named evidence location for `control-marketplace prove`.
Cleanup must never delete these files.

Generate (or refresh) a drive with:

```bash
node .cursor/skills/verify-marketplace/control-marketplace.mjs prove --feature marketplace-catalog --json
```

Expected files after a successful drive:

- `drive.json` — machine-readable summary (`ok`, feature id, step exits)
- `drive.md` — what the drive proved
- `drive.transcript.txt` — full stdout/stderr per step
