# /statusline:config

Configure the statusline plugin with your preferences through interactive questions.

## Usage

```
/statusline:config
```

## What It Does

This command walks you through a series of questions to configure how statusline displays information in your Claude Code session:

- **Display Frequency** — How often to update metrics (1-60 seconds)
- **Display Format** — Compact, standard, or detailed output
- **Metrics to Show** — Choose which metrics are important to you
- **Color Theme** — Terminal-aware theme selection
- **Auto-Start** — Enable monitoring automatically on session start

## Configuration Questions

The interactive setup includes:

1. **Update Interval** — How frequently should statusline refresh?
   - Fast (1-3 seconds) for active monitoring
   - Standard (5-10 seconds) for balanced view
   - Slow (15-60 seconds) for minimal updates

2. **Display Mode** — How should metrics be displayed?
   - **Compact** — Single line summary
   - **Standard** — Multi-line detailed view (default)
   - **Detailed** — Full breakdown with charts

3. **Show Metrics** — Which information matters most?
   - Context health
   - Active tools
   - Running agents
   - Task progress
   - Session duration

4. **Color Theme** — Terminal color preference?
   - Auto (detects terminal)
   - Dark background
   - Light background
   - No colors (plain text)

5. **Auto-Start** — Enable monitoring on session start?
   - Enabled (recommended)
   - Disabled

## Example Session

```
$ /statusline:config

⚙️  Statusline Configuration Wizard
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Q1: Update Interval?
  ▶ Standard (5-10 seconds)
  ○ Fast (1-3 seconds)
  ○ Slow (15-60 seconds)

Q2: Display Mode?
  ○ Compact (single line)
  ▶ Standard (multi-line)
  ○ Detailed (with charts)

Q3: Show metrics (select multiple)?
  ☑ Context health
  ☑ Active tools
  ☑ Running agents
  ☑ Task progress
  ☑ Duration

Q4: Color theme?
  ▶ Auto (auto-detect)
  ○ Dark
  ○ Light
  ○ None

Q5: Auto-start monitoring?
  ▶ Enabled
  ○ Disabled

✓ Configuration saved!
→ Statusline will update every 5 seconds in standard mode
→ Monitoring enabled on session start
→ Use /statusline:status to view metrics anytime
```

## Configuration File

Your settings are saved to `.statusline.config.json` in your project root. You can also manually edit this file if needed.

## Related Commands

- `/statusline:status` — View current metrics immediately
- `/statusline:enable [interval]` — Enable with custom interval
- `/statusline:disable` — Pause monitoring
