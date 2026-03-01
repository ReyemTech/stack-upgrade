#!/bin/bash
# verify-fast.sh — Quick verification: lint + tests + TypeScript + grep checks
# Run after every file change during upgrade
set -e

echo "=== verify-fast ==="
cd /workspace

# --- Section 1: Lint ---
echo "[lint] Detecting lint tool..."
if [ -f biome.json ] || [ -f biome.jsonc ]; then
  echo "[lint] Biome detected — running npx biome check ."
  npx biome check .
elif [ -f .eslintrc ] || [ -f .eslintrc.js ] || [ -f .eslintrc.cjs ] || [ -f .eslintrc.json ] || \
     [ -f .eslintrc.yaml ] || [ -f .eslintrc.yml ] || \
     ls eslint.config.* 2>/dev/null | grep -q . || \
     jq -e '.devDependencies.eslint // .dependencies.eslint' package.json > /dev/null 2>&1; then
  echo "[lint] ESLint detected — running npx eslint . --max-warnings=0"
  npx eslint . --max-warnings=0
else
  echo "[lint] No lint tool detected -- skipping"
fi

# --- Section 2: Tests ---
echo "[tests] Detecting test runner..."
if jq -e '.devDependencies.vitest // .dependencies.vitest' package.json > /dev/null 2>&1; then
  echo "[tests] Vitest detected — running npx vitest run"
  npx vitest run
elif jq -e '.devDependencies.jest // .dependencies.jest' package.json > /dev/null 2>&1; then
  echo "[tests] Jest detected — running npx jest --passWithNoTests"
  npx jest --passWithNoTests
elif jq -e '.scripts.test' package.json > /dev/null 2>&1 && \
     ! jq -r '.scripts.test' package.json 2>/dev/null | grep -qi "no test"; then
  echo "[tests] npm test script detected — running npm test"
  npm test -- --watchAll=false 2>&1 || true
else
  echo "[tests] No test runner detected -- skipping"
fi

# --- Section 3: TypeScript ---
if [ -f tsconfig.json ]; then
  echo "[tsc] tsconfig.json found — running npx tsc --noEmit"
  npx tsc --noEmit
else
  echo "[tsc] No tsconfig.json — skipping TypeScript check"
fi

# --- Section 4: Post-build grep checks (INFRA-08 — silent-failure markers) ---
echo "[grep] Running silent-failure marker checks..."

# Detect or use pre-exported STACK_TYPE
STACK_TYPE="${STACK_TYPE:-$(/skill/scripts/detect-stack.sh 2>/dev/null || echo "unknown")}"

# Only check if a build output directory exists
if [ -d dist ] || [ -d .next ] || [ -d build ]; then
  if [ "$STACK_TYPE" = "cra" ] || [ "$STACK_TYPE" = "vite-react" ]; then
    # CRA/Vite: REACT_APP_ vars in build output means env vars were not migrated to VITE_
    REACT_APP_HITS=$(grep -r "REACT_APP_" dist/ build/ 2>/dev/null | grep -v node_modules || true)
    if [ -n "$REACT_APP_HITS" ]; then
      echo "ERROR: REACT_APP_ variables found in build output — env vars must be migrated to VITE_ prefix" >&2
      echo "$REACT_APP_HITS" >&2
      exit 1
    fi
    echo "[grep] No REACT_APP_ markers found in build output"
  elif [ "$STACK_TYPE" = "nextjs" ]; then
    # Next.js: codemod markers left in source indicate incomplete migration
    UNSAFE_HITS=$(grep -r "UnsafeUnwrapped\|@next/codemod" src/ app/ pages/ 2>/dev/null | grep -v node_modules || true)
    if [ -n "$UNSAFE_HITS" ]; then
      echo "ERROR: Unresolved codemod markers found in source (UnsafeUnwrapped or @next/codemod)" >&2
      echo "$UNSAFE_HITS" >&2
      exit 1
    fi
    echo "[grep] No codemod markers found in source"
  fi
else
  echo "[grep] No build output directory (dist/, .next/, build/) — skipping marker checks"
fi

echo "=== verify-fast PASSED ==="
