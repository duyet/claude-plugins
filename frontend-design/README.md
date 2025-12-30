# Frontend Design Plugin

Create distinctive, production-grade frontend interfaces that avoid generic AI aesthetics.

## Installation

```bash
/plugin install frontend-design@duyet-claude-plugins
```

## What It Does

Claude automatically uses this skill for frontend work. Creates production-ready code with:

- Bold aesthetic choices that avoid "AI slop"
- shadcn/ui components with custom theming
- Recharts for beautiful data visualizations
- Distinctive typography and color palettes
- High-impact animations using Framer Motion
- Context-aware implementation

## Anti-Slop Guidelines

This plugin specifically teaches Claude to avoid:

- Generic fonts (Inter, Roboto, Arial)
- Purple gradients on white backgrounds
- Symmetric layouts with no hierarchy
- Glassmorphism everywhere
- Cookie-cutter card grids

Instead, it guides toward:

- Distinctive font pairings (Clash Display, Satoshi, Fraunces)
- Intentional color with one dominant accent
- Asymmetric compositions with clear hierarchy
- Components with character and micro-interactions
- Layouts that break the grid

## Tech Stack Preferences

| Category | First Choice | Alternatives |
|----------|--------------|--------------|
| Components | shadcn/ui | Radix UI, Headless UI |
| Charts | Recharts | Tremor, Victory |
| Styling | Tailwind CSS | CSS Variables |
| Animation | Framer Motion | CSS animations, GSAP |

## Usage

```
"Create a dashboard for a music streaming app"
"Build a landing page for an AI security startup"
"Design a settings panel with dark mode"
"Create a data visualization for sales metrics"
```

Claude will choose a clear aesthetic direction and implement production code with meticulous attention to detail.

## Learn More

See the [Frontend Aesthetics Cookbook](https://github.com/anthropics/claude-cookbooks/blob/main/coding/prompting_for_frontend_aesthetics.ipynb) for detailed guidance.

## Architecture

```
frontend-design/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── skills/
│   └── frontend-design/
│       └── SKILL.md         # Skill definition with guidelines
└── README.md                # This file
```

## Credits

Enhanced from Anthropic's original frontend-design plugin by Prithvi Rajasekaran and Alexander Bricken.
