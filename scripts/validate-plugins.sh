#!/usr/bin/env bash
# Validate Claude, Codex, Antigravity, Grok, and Grok Build plugin
# manifests plus marketplace files. Exits 1 if any plugin or marketplace
# fails validation.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILED=0
CHECKED=0
TMP_ERR="${TMPDIR:-/tmp}/plugin-validate-err.$$"
trap 'rm -f "$TMP_ERR"' EXIT

validate_manifest() {
	local manifest="$1"
	local mode="$2"
	local plugin_dir
	plugin_dir="$(dirname "$(dirname "$manifest")")"

	python3 - "$manifest" "$plugin_dir" "$mode" <<'PYEOF'
import json
import os
import re
import sys

manifest_path, plugin_dir, mode = sys.argv[1:4]
errors = []

try:
    with open(manifest_path) as f:
        data = json.load(f)
except Exception as exc:
    print(f"  - invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)

for field in ("name", "version", "description"):
    if field not in data:
        errors.append(f"missing required field: '{field}'")
    elif not isinstance(data[field], str) or not data[field].strip():
        errors.append(f"'{field}' must be a non-empty string")

if isinstance(data.get("version"), str) and not re.fullmatch(r"\d+\.\d+\.\d+", data["version"]):
    errors.append(f"'version' must be semver (X.Y.Z), got: {data['version']!r}")

author = data.get("author")
if author is None:
    errors.append("missing required field: 'author'")
elif isinstance(author, str):
    errors.append(f"'author' must be an object with a 'name' key, got string: {author!r}")
elif not isinstance(author, dict):
    errors.append(f"'author' must be an object, got: {type(author).__name__}")
elif not isinstance(author.get("name"), str) or not author["name"].strip():
    errors.append("'author.name' must be a non-empty string")

skills = data.get("skills")
if isinstance(skills, list):
    for i, skill in enumerate(skills):
        if not isinstance(skill, dict):
            errors.append(f"skills[{i}]: must be an object")
            continue
        if not isinstance(skill.get("name"), str) or not skill["name"].strip():
            errors.append(f"skills[{i}]: missing 'name'")
        if not isinstance(skill.get("description"), str) or not skill["description"].strip():
            errors.append(f"skills[{i}]: missing 'description'")
        path_value = skill.get("path")
        if path_value is not None:
            if not isinstance(path_value, str):
                errors.append(f"skills[{i}]: 'path' must be a string")
            elif not os.path.isfile(os.path.join(plugin_dir, path_value)):
                errors.append(f"skills[{i}]: path '{path_value}' does not exist")

INTERFACE_MODES = ("codex", "antigravity", "grok-build")
PATH_MODES = ("codex", "antigravity", "grok", "grok-build")

def resolve_asset(plugin_dir, value):
    if not isinstance(value, str) or not value.strip():
        return None
    if value.startswith(("http://", "https://")):
        return value
    return os.path.normpath(os.path.join(plugin_dir, value))

def require_local_logo(label, value):
    if not isinstance(value, str) or not value.strip():
        errors.append(f"{label} must be a non-empty string")
        return
    if value.startswith(("http://", "https://")):
        errors.append(f"{label} must be a repo-local path so it renders after install, got URL")
        return
    target = resolve_asset(plugin_dir, value)
    if not os.path.isfile(target):
        errors.append(f"{label} path does not exist: {value}")

if mode in PATH_MODES:
    for field in ("skills", "hooks", "mcpServers", "apps", "commands", "agents"):
        value = data.get(field)
        if value is None:
            continue
        if not isinstance(value, str) or not value.startswith("./"):
            errors.append(f"'{field}' must be a relative string beginning with './'")
            continue
        target = os.path.normpath(os.path.join(plugin_dir, value))
        if not os.path.exists(target):
            errors.append(f"'{field}' path does not exist: {value}")

if mode in INTERFACE_MODES:
    interface = data.get("interface")
    if interface is None:
        errors.append("missing required field: 'interface'")
    elif not isinstance(interface, dict):
        errors.append("'interface' must be an object")
    else:
        for field in ("displayName", "shortDescription", "developerName", "category"):
            if not isinstance(interface.get(field), str) or not interface[field].strip():
                errors.append(f"'interface.{field}' must be a non-empty string")
        capabilities = interface.get("capabilities")
        if capabilities is not None:
            if not isinstance(capabilities, list) or not all(isinstance(item, str) and item.strip() for item in capabilities):
                errors.append("'interface.capabilities' must be an array of non-empty strings")
        require_local_logo("interface.logo", interface.get("logo"))
        require_local_logo("interface.composerIcon", interface.get("composerIcon"))

    mode_obj = data.get(mode)
    if mode_obj is not None:
        if not isinstance(mode_obj, dict):
            errors.append(f"'{mode}' must be an object")
        else:
            for field in ("skills", "commands"):
                val = mode_obj.get(field)
                if val is not None:
                    if not isinstance(val, list) or not all(isinstance(item, str) and item.strip() for item in val):
                        errors.append(f"'{mode}.{field}' must be an array of non-empty strings")

if mode in ("claude", "grok"):
    require_local_logo("logo", data.get("logo"))
elif mode == "grok-build":
    require_local_logo("logo", data.get("logo"))

if errors:
    for error in errors:
        print(f"  - {error}", file=sys.stderr)
    sys.exit(1)
PYEOF
}

check() {
	local label="$1"
	shift
	CHECKED=$((CHECKED + 1))
	if "$@" 2>"$TMP_ERR"; then
		echo "✅ $label"
	else
		echo "❌ $label"
		while IFS= read -r line; do
			echo "     $line"
		done <"$TMP_ERR"
		FAILED=$((FAILED + 1))
	fi
}

validate_cross_manifest() {
	python3 - "$REPO_ROOT" <<'PYEOF'
import json
import os
import sys

repo_root = sys.argv[1]
errors = []

plugin_dirs = sorted(
    name for name in os.listdir(repo_root)
    if (
        os.path.isfile(os.path.join(repo_root, name, ".claude-plugin", "plugin.json"))
        or os.path.isfile(os.path.join(repo_root, name, ".codex-plugin", "plugin.json"))
        or os.path.isfile(os.path.join(repo_root, name, ".grok-plugin", "plugin.json"))
        or os.path.isfile(os.path.join(repo_root, name, ".grok-build-plugin", "plugin.json"))
    )
)

def compare(label, other):
    for field in ("name", "version", "description"):
        if claude.get(field) != other.get(field):
            errors.append(f"{plugin}: {field} differs between Claude and {label} manifests")
    if claude.get("author", {}).get("name") != other.get("author", {}).get("name"):
        errors.append(f"{plugin}: author.name differs between Claude and {label} manifests")

for plugin in plugin_dirs:
    claude_path = os.path.join(repo_root, plugin, ".claude-plugin", "plugin.json")
    if not os.path.isfile(claude_path):
        errors.append(f"{plugin}: missing .claude-plugin/plugin.json")
        continue
    with open(claude_path) as f:
        claude = json.load(f)

    required_harnesses = (
        (".codex-plugin/plugin.json", "Codex"),
        (".grok-plugin/plugin.json", "Grok"),
        (".grok-build-plugin/plugin.json", "Grok Build"),
    )
    for relpath, label in required_harnesses:
        path = os.path.join(repo_root, plugin, relpath)
        if not os.path.isfile(path):
            errors.append(f"{plugin}: missing {relpath}")
            continue
        with open(path) as f:
            compare(label, json.load(f))

    antigravity_path = os.path.join(repo_root, plugin, ".antigravity-plugin", "plugin.json")
    if os.path.isfile(antigravity_path):
        with open(antigravity_path) as f:
            compare("Antigravity", json.load(f))

if errors:
    for error in errors:
        print(f"  - {error}", file=sys.stderr)
    sys.exit(1)
PYEOF
}

validate_marketplaces() {
	python3 - "$REPO_ROOT" <<'PYEOF'
import json
import os
import sys

repo_root = sys.argv[1]
errors = []

plugin_dirs = sorted(
    name for name in os.listdir(repo_root)
    if os.path.isfile(os.path.join(repo_root, name, ".claude-plugin", "plugin.json"))
)
plugin_set = set(plugin_dirs)

def load_json(relpath):
    try:
        with open(os.path.join(repo_root, relpath)) as f:
            return json.load(f)
    except (FileNotFoundError, OSError, json.JSONDecodeError) as exc:
        errors.append(f"{relpath}: {exc}")
    return None

def require(condition, message):
    if not condition:
        errors.append(message)

root_marketplace = load_json("marketplace.json")
if root_marketplace is None:
    root_marketplace = {"plugins": []}
root_names = [plugin.get("name") for plugin in root_marketplace.get("plugins", [])]
require(len(root_names) == len(set(root_names)), "marketplace.json contains duplicate plugin names")
require(set(root_names) == plugin_set, "marketplace.json plugin names must match plugin directories")
for plugin in root_marketplace.get("plugins", []):
    name = plugin.get("name")
    for field in ("name", "id", "description", "version", "type", "category"):
        value = plugin.get(field)
        require(isinstance(value, str) and value.strip(), f"marketplace.json {name}: missing {field}")
    require(plugin.get("id") == f"{name}@{root_marketplace.get('name')}", f"marketplace.json {name}: id does not match marketplace name")
    logo = plugin.get("logo")
    require(isinstance(logo, str) and logo.strip(), f"marketplace.json {name}: missing logo")
    if isinstance(logo, str) and not logo.startswith(("http://", "https://")):
        require(os.path.isfile(os.path.normpath(os.path.join(repo_root, logo))), f"marketplace.json {name}: logo path does not exist")

claude_marketplace = load_json(".claude-plugin/marketplace.json")
if claude_marketplace is None:
    claude_marketplace = {"plugins": []}
claude_names = [plugin.get("name") for plugin in claude_marketplace.get("plugins", [])]
require(set(claude_names).issubset(plugin_set), ".claude-plugin/marketplace.json references unknown plugin")
for plugin in claude_marketplace.get("plugins", []):
    name = plugin.get("name")
    source = plugin.get("source")
    require(isinstance(source, str) and source.startswith("./"), f".claude-plugin/marketplace.json {name}: source must be relative string")
    if isinstance(source, str):
        require(os.path.isdir(os.path.join(repo_root, source)), f".claude-plugin/marketplace.json {name}: source path does not exist")
    logo = plugin.get("logo")
    require(isinstance(logo, str) and logo.strip(), f".claude-plugin/marketplace.json {name}: missing logo")
    if isinstance(logo, str) and not logo.startswith(("http://", "https://")):
        require(os.path.isfile(os.path.normpath(os.path.join(repo_root, logo))), f".claude-plugin/marketplace.json {name}: logo path does not exist")

codex_marketplace = load_json(".agents/plugins/marketplace.json")
if codex_marketplace is None:
    codex_marketplace = {"plugins": []}
codex_names = [plugin.get("name") for plugin in codex_marketplace.get("plugins", [])]
require(len(codex_names) == len(set(codex_names)), ".agents/plugins/marketplace.json contains duplicate plugin names")
require(set(codex_names) == plugin_set, ".agents/plugins/marketplace.json plugin names must match plugin directories")
require(isinstance(codex_marketplace.get("interface", {}).get("displayName"), str), ".agents/plugins/marketplace.json missing interface.displayName")
for plugin in codex_marketplace.get("plugins", []):
    name = plugin.get("name")
    source = plugin.get("source")
    policy = plugin.get("policy")
    require(isinstance(source, dict), f".agents/plugins/marketplace.json {name}: source must be object")
    if isinstance(source, dict):
        require(source.get("source") == "local", f".agents/plugins/marketplace.json {name}: source.source must be local")
        path_value = source.get("path")
        require(isinstance(path_value, str) and path_value.startswith("./"), f".agents/plugins/marketplace.json {name}: source.path must be relative string")
        if isinstance(path_value, str):
            require(os.path.isdir(os.path.join(repo_root, path_value)), f".agents/plugins/marketplace.json {name}: source.path does not exist")
    require(isinstance(policy, dict), f".agents/plugins/marketplace.json {name}: policy must be object")
    if isinstance(policy, dict):
        require(policy.get("installation") in {"NOT_AVAILABLE", "AVAILABLE", "INSTALLED_BY_DEFAULT"}, f".agents/plugins/marketplace.json {name}: invalid policy.installation")
        require(policy.get("authentication") in {"ON_INSTALL", "ON_USE"}, f".agents/plugins/marketplace.json {name}: invalid policy.authentication")
    category = plugin.get("category")
    require(isinstance(category, str) and category.strip(), f".agents/plugins/marketplace.json {name}: missing category")
    iface = plugin.get("interface")
    require(isinstance(iface, dict), f".agents/plugins/marketplace.json {name}: missing interface")
    if isinstance(iface, dict):
        for field in ("logo", "composerIcon"):
            value = iface.get(field)
            require(isinstance(value, str) and value.strip(), f".agents/plugins/marketplace.json {name}: missing interface.{field}")
            if isinstance(value, str) and not value.startswith(("http://", "https://")):
                require(os.path.isfile(os.path.normpath(os.path.join(repo_root, value))), f".agents/plugins/marketplace.json {name}: interface.{field} path does not exist")

codex_iface = codex_marketplace.get("interface", {})
require(isinstance(codex_iface.get("logo"), str) and codex_iface["logo"].strip(), ".agents/plugins/marketplace.json missing interface.logo")
if isinstance(codex_iface.get("logo"), str) and not codex_iface["logo"].startswith(("http://", "https://")):
    require(os.path.isfile(os.path.normpath(os.path.join(repo_root, codex_iface["logo"]))), ".agents/plugins/marketplace.json interface.logo path does not exist")

grok_marketplace = load_json(".grok-plugin/marketplace.json")
if grok_marketplace is None:
    grok_marketplace = {"plugins": []}
grok_names = [plugin.get("name") for plugin in grok_marketplace.get("plugins", [])]
require(len(grok_names) == len(set(grok_names)), ".grok-plugin/marketplace.json contains duplicate plugin names")
require(set(grok_names) == plugin_set, ".grok-plugin/marketplace.json plugin names must match plugin directories")
require(isinstance(grok_marketplace.get("owner", {}).get("name"), str), ".grok-plugin/marketplace.json missing owner.name")
for plugin in grok_marketplace.get("plugins", []):
    name = plugin.get("name")
    source = plugin.get("source")
    require(isinstance(plugin.get("description"), str) and plugin["description"].strip(), f".grok-plugin/marketplace.json {name}: missing description")
    require(isinstance(plugin.get("category"), str) and plugin["category"].strip(), f".grok-plugin/marketplace.json {name}: missing category")
    require(isinstance(plugin.get("logo"), str) and plugin["logo"].strip(), f".grok-plugin/marketplace.json {name}: missing logo")
    path_value = None
    if isinstance(source, str) and source.startswith("./"):
        path_value = source
    elif isinstance(source, dict):
        path_value = source.get("path")
        require(
            source.get("type") == "local" or source.get("source") == "local",
            f".grok-plugin/marketplace.json {name}: source must be local",
        )
    require(isinstance(path_value, str) and path_value.startswith("./"), f".grok-plugin/marketplace.json {name}: source path must be relative string")
    if isinstance(path_value, str):
        plugin_root = os.path.join(repo_root, path_value)
        require(os.path.isdir(plugin_root), f".grok-plugin/marketplace.json {name}: source path does not exist")
        logo = plugin.get("logo")
        if isinstance(logo, str) and not logo.startswith(("http://", "https://")):
            require(os.path.isfile(os.path.normpath(os.path.join(plugin_root, logo))), f".grok-plugin/marketplace.json {name}: logo path does not exist")

if errors:
    for error in errors:
        print(f"  - {error}", file=sys.stderr)
    sys.exit(1)
PYEOF
}

echo "Validating plugin manifests..."
echo ""

while IFS= read -r -d '' manifest; do
	plugin_dir="$(dirname "$(dirname "$manifest")")"
	plugin_name="$(basename "$plugin_dir")"
	check "Claude manifest: $plugin_name" validate_manifest "$manifest" claude
done < <(find "$REPO_ROOT" -path "*/.claude-plugin/plugin.json" -not -path "*/node_modules/*" -print0 | sort -z)

while IFS= read -r -d '' manifest; do
	plugin_dir="$(dirname "$(dirname "$manifest")")"
	plugin_name="$(basename "$plugin_dir")"
	check "Codex manifest: $plugin_name" validate_manifest "$manifest" codex
done < <(find "$REPO_ROOT" -path "*/.codex-plugin/plugin.json" -not -path "*/node_modules/*" -print0 | sort -z)

while IFS= read -r -d '' manifest; do
	plugin_dir="$(dirname "$(dirname "$manifest")")"
	plugin_name="$(basename "$plugin_dir")"
	check "Antigravity manifest: $plugin_name" validate_manifest "$manifest" antigravity
done < <(find "$REPO_ROOT" -path "*/.antigravity-plugin/plugin.json" -not -path "*/node_modules/*" -print0 | sort -z)

while IFS= read -r -d '' manifest; do
	plugin_dir="$(dirname "$(dirname "$manifest")")"
	plugin_name="$(basename "$plugin_dir")"
	check "Grok manifest: $plugin_name" validate_manifest "$manifest" grok
done < <(find "$REPO_ROOT" -path "*/.grok-plugin/plugin.json" -not -path "*/node_modules/*" -print0 | sort -z)

while IFS= read -r -d '' manifest; do
	plugin_dir="$(dirname "$(dirname "$manifest")")"
	plugin_name="$(basename "$plugin_dir")"
	check "Grok Build manifest: $plugin_name" validate_manifest "$manifest" grok-build
done < <(find "$REPO_ROOT" -path "*/.grok-build-plugin/plugin.json" -not -path "*/node_modules/*" -print0 | sort -z)

check "Claude/Codex/Grok/Antigravity manifest parity" validate_cross_manifest
check "Marketplace files" validate_marketplaces

echo ""
echo "Checked $CHECKED item(s). $FAILED failed."

if [[ $FAILED -gt 0 ]]; then
	exit 1
fi
