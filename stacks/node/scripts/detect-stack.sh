#!/bin/bash
set -e

# detect-stack.sh — Detect JS stack type from package.json
# Outputs a single word to stdout: nextjs, cra, or vite-react
# Exits 1 with a clear error if no supported stack is found.
#
# Usage: detect-stack.sh [repo-dir]
#   repo-dir defaults to /workspace

REPO_DIR="${1:-/workspace}"
PACKAGE_JSON="$REPO_DIR/package.json"

if [ ! -f "$PACKAGE_JSON" ]; then
  echo "ERROR: package.json not found at $PACKAGE_JSON" >&2
  exit 1
fi

# has_dep: checks both dependencies and devDependencies for a package name
has_dep() {
  local pkg="$1"
  jq -e --arg pkg "$pkg" '
    (.dependencies[$pkg] // .devDependencies[$pkg]) != null
  ' "$PACKAGE_JSON" > /dev/null 2>&1
}

# Priority 1: Next.js — check dep or next.config.* file
if has_dep "next" || ls "$REPO_DIR"/next.config.* 2>/dev/null | grep -q .; then
  echo "nextjs"
  exit 0
fi

# Priority 2: Create React App
if has_dep "react-scripts"; then
  echo "cra"
  exit 0
fi

# Priority 3: Vite + React
if has_dep "@vitejs/plugin-react" || has_dep "@vitejs/plugin-react-swc"; then
  echo "vite-react"
  exit 0
fi

# No match — report what was found and list supported stacks
echo "ERROR: Could not detect a supported JS stack from $PACKAGE_JSON" >&2
echo "  Found dependencies:" >&2
jq -r '(.dependencies // {}) + (.devDependencies // {}) | keys[]' "$PACKAGE_JSON" 2>/dev/null | head -20 | sed 's/^/    /' >&2
echo "  Supported stacks: nextjs (next), cra (react-scripts), vite-react (@vitejs/plugin-react or @vitejs/plugin-react-swc)" >&2
exit 1
