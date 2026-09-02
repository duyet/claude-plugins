#!/bin/bash
# Main Documentation Generator
# Generates root README.md and plugin CLAUDE.md files
# shellcheck disable=SC2034,SC2155

set -euo pipefail

MARKETPLACE_ROOT="${1:-$(pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# Source library functions
source "$LIB_DIR/plugin-scanner.sh"
source "$LIB_DIR/type-detector.sh"
source "$LIB_DIR/feature-extractor.sh"
source "$LIB_DIR/emoji-mapper.sh"

# Main generation function
generate_all_docs() {
    echo "Scanning plugins from marketplace.json..." >&2

    # Get list of all plugins
    plugins=$(scan_plugins "$MARKETPLACE_ROOT")

    if [[ -z "$plugins" ]]; then
        echo "No plugins found in marketplace.json" >&2
        return 1
    fi

    echo "Found $(echo "$plugins" | wc -l) plugins" >&2

    # Generate root README.md
    generate_root_readme

    # Generate CLAUDE.md for each plugin
    for plugin in $plugins; do
        local plugin_dir="$MARKETPLACE_ROOT/$plugin"
        if [[ -d "$plugin_dir" ]]; then
            generate_plugin_claude_md "$plugin_dir"
        fi
    done

    echo "Documentation generation complete" >&2
}

# Generate root README.md
generate_root_readme() {
    local output="$MARKETPLACE_ROOT/README.md"
    local plugins=$(scan_plugins "$MARKETPLACE_ROOT")

    # Start building README
    cat > "$output" << 'EOF'
# Claude/Codex/Grok Plugins Marketplace

> Extend Claude Code, Codex, Grok Build, and Grok Bot with specialized agents, commands, and skills.

## Quick Install

### Claude Code

```bash
# Add marketplace
/plugin marketplace add duyet/codex-claude-plugins

# Install plugins
EOF

    # Add install commands for each plugin
    for plugin in $plugins; do
        echo "/plugin install ${plugin}@duyet-claude-plugins" >> "$output"
    done

    cat >> "$output" << 'EOF'
```

### Grok Build / Grok Bot

```bash
grok plugin marketplace add duyet/codex-claude-plugins
grok plugin install <plugin-name> --trust
```

Codex uses `.agents/plugins/marketplace.json`. Plugin logos live at `assets/logo.svg` in each plugin.

---

## Plugins at a Glance

| Plugin | Type | What it does |
|--------|------|--------------|
EOF

    # Generate table rows
    for plugin in $plugins; do
        local plugin_dir="$MARKETPLACE_ROOT/$plugin"
        local plugin_json="$plugin_dir/.claude-plugin/plugin.json"

        if [[ ! -f "$plugin_json" ]]; then
            continue
        fi

        local name=$(jq -r '.name // "'"$plugin"'"' "$plugin_json" 2>/dev/null || echo "$plugin")
        local description=$(jq -r '.description // ""' "$plugin_json" 2>/dev/null)
        local type=$(detect_plugin_type "$plugin_dir")
        local emoji=$(assign_emoji "$plugin")

        # Create short description from full description (first 40 chars)
        local short_desc=$(echo "$description" | cut -c1-40)
        if [[ ${#description} -gt 40 ]]; then
            short_desc="${short_desc}..."
        fi

        # Escape special markdown characters in link
        local anchor_link=$(echo "$name" | sed 's/ /-/g' | sed 's/\([_\*`\[\]()]\)/\\\1/g')
        echo "| [$emoji $name](#${emoji}-$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')) | $type | $short_desc |" >> "$output"
    done

    cat >> "$output" << 'EOF'


---

## Plugin Details

EOF

    # Generate plugin detail sections
    for plugin in $plugins; do
        local plugin_dir="$MARKETPLACE_ROOT/$plugin"
        local plugin_json="$plugin_dir/.claude-plugin/plugin.json"

        if [[ ! -f "$plugin_json" ]]; then
            continue
        fi

        local name=$(jq -r '.name // "'"$plugin"'"' "$plugin_json" 2>/dev/null || echo "$plugin")
        local description=$(jq -r '.description // ""' "$plugin_json" 2>/dev/null)
        local emoji=$(assign_emoji "$plugin")

        echo "### $emoji $name" >> "$output"
        echo "" >> "$output"
        echo "**$description**" >> "$output"
        echo "" >> "$output"

        # Show example commands
        local commands=$(extract_commands "$plugin_dir")
        if [[ -n "$commands" ]]; then
            echo '```bash' >> "$output"
            echo "$commands" | head -3 >> "$output"
            echo '```' >> "$output"
            echo "" >> "$output"
        fi

        # Show components
        local agents=$(extract_agents "$plugin_dir")
        local skills=$(extract_skills "$plugin_dir")

        if [[ -n "$agents" ]] || [[ -n "$skills" ]]; then
            echo "**Components:**" >> "$output"
            if [[ -n "$agents" ]]; then
                echo "" >> "$output"
                echo "Agents:" >> "$output"
                echo "$agents" >> "$output"
            fi
            if [[ -n "$skills" ]]; then
                echo "" >> "$output"
                echo "Skills:" >> "$output"
                echo "$skills" >> "$output"
            fi
            echo "" >> "$output"
        fi

        echo "---" >> "$output"
        echo "" >> "$output"
    done

    # Add footer sections
    cat >> "$output" << 'EOF'

## Manual Installation

Add to `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "duyet-claude-plugins": {
      "source": { "source": "github", "repo": "duyet/codex-claude-plugins" }
    }
  },
  "enabledPlugins": {
    "team-agents@duyet-claude-plugins": true
  }
}
```

---

## Contributing

```
your-plugin/
├── .claude-plugin/plugin.json      # name, version, description, logo
├── .codex-plugin/plugin.json       # Codex manifest and interface metadata
├── .grok-plugin/plugin.json        # Grok Bot / Grok Build manifest
├── .grok-build-plugin/plugin.json  # Grok Build interface metadata
├── assets/logo.svg                 # rendered by every listed harness
├── agents/                         # .md with YAML frontmatter
├── commands/                       # slash commands
├── skills/                         # reusable knowledge
└── hooks/hooks.json                # lifecycle hooks
```

Update `marketplace.json`, `.claude-plugin/marketplace.json`, `.agents/plugins/marketplace.json`, `.grok-plugin/marketplace.json`, and the harness manifests. Run `bash scripts/validate-plugins.sh`.

---

MIT License
EOF

    echo "Generated README.md" >&2
}

# Generate CLAUDE.md for a single plugin
generate_plugin_claude_md() {
    local plugin_dir="$1"
    local plugin_json="$plugin_dir/.claude-plugin/plugin.json"
    local output="$plugin_dir/CLAUDE.md"

    if [[ ! -f "$plugin_json" ]]; then
        return
    fi

    local name=$(jq -r '.name // "unknown"' "$plugin_json" 2>/dev/null)
    local version=$(jq -r '.version // "1.0.0"' "$plugin_json" 2>/dev/null)
    local description=$(jq -r '.description // ""' "$plugin_json" 2>/dev/null)

    # Capitalize first letter (portable method for bash 3+)
    local name_title="$(echo "$name" | sed 's/./\U&/')"

    cat > "$output" << EOF
# ${name_title} Plugin

$description

## Versioning

Follow semantic versioning (semver) for this plugin:

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Bug fix, docs | Patch | 1.0.0 → 1.0.1 |
| New feature, minor change | Minor | 1.0.0 → 1.1.0 |
| Breaking change | Major | 1.0.0 → 2.0.0 |

**When to bump:**
- Adding new commands, skills, or agents → **Minor**
- Modifying existing behavior → **Minor** (or Major if breaking)
- Updating documentation only → **Patch**
- Bug fixes → **Patch**

Always update \`plugin.json\` version when making changes.

## Plugin Structure

\`\`\`
${name}/
├── .claude-plugin/
│   └── plugin.json          # Manifest (version ${version})
├── agents/                      # Sub-agent definitions
├── commands/                    # Slash commands
├── skills/                      # Reusable knowledge
└── hooks/hooks.json             # Lifecycle hooks (optional)
\`\`\`

## Components

EOF

    # Add commands section
    local commands=$(extract_commands "$plugin_dir")
    if [[ -n "$commands" ]]; then
        echo "### Commands" >> "$output"
        echo "" >> "$output"
        echo "$commands" >> "$output"
        echo "" >> "$output"
    fi

    # Add agents section
    local agents=$(extract_agents "$plugin_dir")
    if [[ -n "$agents" ]]; then
        echo "### Agents" >> "$output"
        echo "" >> "$output"
        echo "$agents" >> "$output"
        echo "" >> "$output"
    fi

    # Add skills section
    local skills=$(extract_skills "$plugin_dir")
    if [[ -n "$skills" ]]; then
        echo "### Skills" >> "$output"
        echo "" >> "$output"
        echo "$skills" >> "$output"
        echo "" >> "$output"
    fi

    # Add commit convention
    cat >> "$output" << EOF

## Commit Convention

Use semantic commits with plugin scope:

\`\`\`
feat(${name}): add new feature
fix(${name}): fix bug
docs(${name}): update documentation
\`\`\`

Co-author: \`Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>\`

---

**Generated by docs-generator v1.0.0**
EOF

    echo "Generated CLAUDE.md for $name" >&2
}

# Run generation
generate_all_docs
