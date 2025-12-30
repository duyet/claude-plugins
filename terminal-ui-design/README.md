# Terminal UI Design Plugin

Create distinctive, production-grade terminal user interfaces with high design quality.

## Installation

```bash
/plugin install terminal-ui-design@duyet-claude-plugins
```

## What It Does

Claude automatically uses this skill for terminal UI work. Creates polished CLI and TUI interfaces with:

- Bold aesthetic choices (cyberpunk, retro, minimalist, etc.)
- Custom box drawing and borders
- Cohesive color palettes (ANSI 16, 256-color, true color)
- Typography and text styling
- Layout composition patterns
- Motion and animation (spinners, progress bars, typing effects)

## Aesthetic Directions

Choose a bold direction:

| Style | Description |
|-------|-------------|
| Hacker/Cyberpunk | Neon accents, matrix rain, glitch effects |
| Retro Computing | 80s/90s terminals, amber/green phosphor |
| Minimalist Zen | Single focus, generous whitespace |
| Maximalist Dashboard | Dense information, many panels |
| Synthwave Neon | Pink/purple/cyan gradients |
| Brutalist | Monochrome, raw, industrial |
| Military/Tactical | Status displays, green-on-black |

## Supported Libraries

| Language | Libraries |
|----------|-----------|
| Python | Rich, Textual |
| Go | Bubbletea, Lipgloss |
| Rust | Ratatui |
| Node.js | Ink, Blessed |

## Usage

```
"Create a dashboard for monitoring Docker containers"
"Build a file manager TUI with vim keybindings"
"Design a CLI progress indicator with retro aesthetics"
"Create a terminal music player interface"
```

Claude will choose a distinctive aesthetic direction and implement production-ready code.

## Architecture

```
terminal-ui-design/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── skills/
│   └── terminal-ui-design/
│       └── SKILL.md             # Skill definition with guidelines
└── README.md                    # This file
```
