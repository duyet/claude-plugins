# Contributing

Thanks for your interest in contributing to the Claude, Codex, and Grok Plugins Marketplace!

## Quick Start

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-new-plugin`
3. Make your changes
4. Push to your fork: `git push origin feature/my-new-plugin`
5. Open a Pull Request

## Plugin Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest (name, version, description, logo)
├── .codex-plugin/
│   └── plugin.json          # Codex manifest and interface metadata
├── .grok-plugin/
│   └── plugin.json          # Grok Bot / Grok Build manifest
├── .grok-build-plugin/
│   └── plugin.json          # Grok Build interface metadata
├── assets/
│   └── logo.svg             # Local logo rendered by every listed harness
├── README.md                # Plugin documentation
├── CLAUDE.md               # Claude-specific instructions (optional, for skills/agents)
├── agents/                  # Agent definitions (optional)
├── commands/                # Slash commands (optional)
├── skills/                  # Reusable knowledge (optional)
└── hooks/hooks.json          # Lifecycle hooks (optional)
```

## Creating a New Plugin

### 1. Plugin Manifest (.claude-plugin/plugin.json)

```json
{
  "name": "my-plugin",
  "description": "A brief description of what this plugin does",
  "version": "1.0.0",
  "author": {
    "name": "your-username"
  },
  "logo": "./assets/logo.svg"
}
```

### 2. Codex Manifest (.codex-plugin/plugin.json)

Every plugin also needs a Codex manifest with the same `name`, `version`, `description`, and `author.name` as the Claude manifest:

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "A brief description of what this plugin does",
  "author": {
    "name": "your-username"
  },
  "skills": "./skills/",
  "interface": {
    "displayName": "My Plugin",
    "shortDescription": "A brief description of what this plugin does",
    "developerName": "your-username",
    "category": "Productivity",
    "capabilities": ["Skill"],
    "logo": "./assets/logo.svg",
    "composerIcon": "./assets/logo.svg"
  }
}
```

Copy `assets/logo.svg` from another plugin (or the repo-root `assets/logo.svg`). Point every harness at that local file — remote URLs do not render reliably after install.

### 3. Grok Bot / Grok Build Manifests

`.grok-plugin/plugin.json` is the official Grok Bot + Grok Build manifest. `.grok-build-plugin/plugin.json` mirrors the Codex interface metadata for Grok Build. Keep `name`, `version`, `description`, and `author.name` identical across Claude, Codex, Grok, and Grok Build manifests:

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "A brief description of what this plugin does",
  "author": {
    "name": "your-username"
  },
  "logo": "assets/logo.svg",
  "skills": "./skills/"
}
```

### 4. Documentation (README.md)

Required sections:
- Description of what the plugin does
- Installation instructions
- Usage examples
- Configuration options (if any)
- Versioning guidelines (if applicable)

### 5. Claude Instructions (CLAUDE.md)

Required for skills and agents:
- How Claude should use the plugin
- When to invoke it
- Expected inputs and outputs

### 6. Update Marketplaces

Add your plugin to `marketplace.json`:

```json
{
  "name": "my-plugin",
  "id": "my-plugin@duyet-claude-plugins",
  "description": "...",
  "version": "1.0.0",
  "type": "skill|command|hook",
  "category": "your-category",
  "logo": "./my-plugin/assets/logo.svg"
}
```

Also add a Codex entry to `.agents/plugins/marketplace.json`:

```json
{
  "name": "my-plugin",
  "source": {
    "source": "local",
    "path": "./my-plugin"
  },
  "policy": {
    "installation": "AVAILABLE",
    "authentication": "ON_INSTALL"
  },
  "category": "Productivity"
}
```

Also add a Grok entry to `.grok-plugin/marketplace.json` (Grok Build + Grok Bot):

```json
{
  "name": "my-plugin",
  "description": "...",
  "category": "productivity",
  "source": {
    "type": "local",
    "path": "./my-plugin"
  },
  "logo": "assets/logo.svg"
}
```

Include `logo` on the Claude marketplace entry (`./my-plugin/assets/logo.svg`) and Codex marketplace `interface.logo` / `interface.composerIcon`.

### 7. Update Main README

Add your plugin to the main README.md table:

| Plugin | Type | Description |
|--------|------|-------------|
| [🔧 my-plugin](./my-plugin/) | Type | Description |

## Development Guidelines

### Code Quality

- Write clear, well-documented code
- Follow existing patterns in the codebase
- Keep changes focused and atomic

### Versioning

Follow [Semantic Versioning](https://semver.org/):
- **Patch** (1.0.0 → 1.0.1): Bug fixes, documentation
- **Minor** (1.0.0 → 1.1.0): New features, non-breaking changes
- **Major** (1.0.0 → 2.0.0): Breaking changes

Update plugin.json version on every change.
Keep `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `.grok-plugin/plugin.json`, and `.grok-build-plugin/plugin.json` in sync for shared metadata fields.

### Commits

Use conventional commits with plugin scope:

```bash
feat(my-plugin): add new feature
fix(my-plugin): fix bug
docs(my-plugin): update documentation
test(my-plugin): add tests
refactor(my-plugin): refactor code
```

### Testing

- Test your plugin thoroughly before submitting
- Include usage examples in README
- Consider edge cases and error handling
- Run `bash scripts/validate-plugins.sh` to validate Claude, Codex, Grok, Grok Build, and Antigravity manifests plus marketplace files

## Pull Request Process

1. **Title**: Use conventional commit format (e.g., `feat(my-plugin): add X`)
2. **Description**: Explain what and why
3. **Link issues**: `Fixes #123` if applicable
4. **Co-author**: Add if using duyetbot: `Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>`

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Getting Help

- Check [existing issues](https://github.com/duyet/codex-claude-plugins/issues)
- Use [feature request template](.github/ISSUE_TEMPLATE/feature_request.md) for new ideas
- Use [bug report template](.github/ISSUE_TEMPLATE/bug_report.md) for issues
