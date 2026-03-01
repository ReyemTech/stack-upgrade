#!/bin/bash
# verify-full.sh — Full verification: verify-fast + build + npm audit
# Run at phase completion during upgrade
set -e

echo "=== verify-full ==="
cd /workspace

# Run verify-fast first
/skill/scripts/verify-fast.sh

# Build
PKG_MANAGER="${PKG_MANAGER:-npm}"
echo "[build] Running build with $PKG_MANAGER..."
case "$PKG_MANAGER" in
  pnpm) pnpm run build ;;
  yarn) yarn build ;;
  npm)  npm run build ;;
esac

# npm audit (high/critical only per CONTEXT decision)
# Uses || true because audit exits non-zero when vulnerabilities are found — informational, not a build failure
echo "[audit] Running security audit (high/critical only)..."
case "$PKG_MANAGER" in
  pnpm) pnpm audit --prod 2>/dev/null || true ;;
  yarn) yarn audit --level high 2>/dev/null || true ;;
  npm)  npm audit --audit-level=high 2>/dev/null || true ;;
esac

echo "=== verify-full PASSED ==="
