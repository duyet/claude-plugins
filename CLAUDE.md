# Claude Plugins Project

## Install

```bash
/plugin marketplace add duyet/codex-claude-plugins
/plugin install <plugin-name>@duyet-claude-plugins
```

Alternative: `npx skills add duyet/codex-claude-plugins` ([skills.sh](https://skills.sh))

### Grok Build / Grok Bot

```bash
grok plugin marketplace add duyet/codex-claude-plugins
grok plugin install <plugin-name> --trust
```

### Antigravity Installation

For Antigravity CLI, install/symlink a plugin locally for development:

```bash
./scripts/install-antigravity.sh <plugin-name>  # Or 'all' to install all
```

## Plugin Metadata

Codex plugin metadata is maintained beside Claude metadata in each plugin:

- Claude manifest: `.claude-plugin/plugin.json`
- Codex manifest: `.codex-plugin/plugin.json`
- Grok Bot / Grok Build manifest: `.grok-plugin/plugin.json`
- Grok Build interface manifest: `.grok-build-plugin/plugin.json`
- Antigravity manifest: `.antigravity-plugin/plugin.json`
- Claude marketplace: `marketplace.json` and `.claude-plugin/marketplace.json`
- Codex marketplace: `.agents/plugins/marketplace.json`
- Grok marketplace: `.grok-plugin/marketplace.json`
- Plugin logo: `assets/logo.svg` (referenced from every harness manifest)

## Versioning

Follow semantic versioning (semver) for all plugins:

| Change Type               | Version Bump | Example       |
| ------------------------- | ------------ | ------------- |
| Bug fix, docs             | Patch        | 1.0.0 → 1.0.1 |
| New feature, minor change | Minor        | 1.0.0 → 1.1.0 |
| Breaking change           | Major        | 1.0.0 → 2.0.0 |

**When to bump:**

- Adding new commands, skills, or agents → **Minor**
- Modifying existing behavior → **Minor** (or Major if breaking)
- Updating documentation only → **Patch**
- Bug fixes → **Patch**

Always update `plugin.json` version when making changes.

## Plugin Structure

```text
plugin-name/
├── .claude-plugin/
│   └── plugin.json          # Manifest (name, version, description, logo)
├── .codex-plugin/
│   └── plugin.json          # Codex manifest and interface metadata
├── .grok-plugin/
│   └── plugin.json          # Grok Bot / Grok Build manifest
├── .grok-build-plugin/
│   └── plugin.json          # Grok Build interface metadata
├── assets/
│   └── logo.svg             # Rendered by every listed harness
├── agents/                  # Sub-agent definitions
├── commands/                # Slash commands
├── skills/                  # Reusable knowledge/procedures
├── hooks/                   # Hook configurations
└── README.md                # Documentation
```

When changing plugin metadata, keep Claude, Codex, and Grok manifests in sync and run `bash scripts/validate-plugins.sh`.

## No Personal / Environment-Specific Information

Plugins in this repo are **published and shared**. Never bake personal or
machine-specific information into any plugin file (manifests, hooks, scripts,
skills, commands, configs, docs, examples).

**Never hardcode:**

- Absolute home paths (`/Users/<you>/…`) — use `$HOME`, `~`, `${CLAUDE_PLUGIN_ROOT}`, or `$PWD`.
- Personal secret-file conventions (e.g. `~/.secret`) — read secrets from documented env vars; allow an optional, user-set key-file path.
- Real project, client, host, or repo names — use neutral placeholders (`demo-project`, `/path/to/project`).
- Account-bound resources (private/professional voice IDs, API keys, tokens, account ids, emails).

**Defaults must be generic.** Ship neutral, English-first defaults that work for
any user. Put personal preferences (language, voice, key location, custom
wording) in the user's own config under `~/.config/<plugin>/` — outside the repo,
never committed.

Author/owner metadata (`author`, marketplace `owner`) is allowed — that is
legitimate attribution, not environment-specific leakage. Shipping additional
**language presets** (e.g. a `vi` template set) is a feature, not personal info.

Before committing a plugin, scan for leaks:
`grep -rniE "/Users/|~/\.secret|<your-name>|<real-project-names>" <plugin>/`

## Commit Convention

Use semantic commits with plugin scope:

```text
feat(plugin-name): add new feature
fix(plugin-name): fix bug
docs(plugin-name): update documentation
```

Co-author: `Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>`
