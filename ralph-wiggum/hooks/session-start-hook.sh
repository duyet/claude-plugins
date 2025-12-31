#!/bin/bash

# Ralph Wiggum Session Start Hook
# Captures session ID and persists it for use in commands and stop hook

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
LIB_DIR="$PLUGIN_ROOT/lib"

# Load utilities
[[ -f "$LIB_DIR/utils.sh" ]] && source "$LIB_DIR/utils.sh"

# Read hook input from stdin
HOOK_INPUT=$(cat)

# Extract and persist session ID
load_session_from_hook_input "$HOOK_INPUT"

# Session start hook must exit 0 and produce no output
exit 0
