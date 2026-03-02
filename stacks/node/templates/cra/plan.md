# CRA to Vite Migration Plan

**Migration:** Create React App → Vite
**Date:** ${UPGRADE_DATE}
**Repo:** ${REPO_URL}

## Overview

Create React App (react-scripts) is officially deprecated. This plan migrates the project to Vite, which provides faster builds, native ESM, and an actively maintained toolchain.

**Critical constraint:** `REACT_APP_` env vars are NOT automatically rewritten by viject. Unrewritten vars will silently produce undefined values at runtime. Phase 2 addresses this before any build verification.

## Phases

### Phase 1: Viject Scaffold

**Goal:** Use viject to automate the bulk of the CRA→Vite scaffold.

**Link:** https://github.com/bhbs/viject

**Steps:**
1. Ensure git working tree is clean before running viject
2. Run `npx viject` — this creates vite.config, relocates index.html, renames JSX files if needed, updates package.json scripts
3. Commit the viject output as-is: `upgrade(phase-1): viject scaffold` — clean history showing exactly what the tool did
4. Run `npm install` (or `pnpm install` / `yarn install`) to install new vite dependencies

**Manual fallback if viject fails:**
- `npm install -D vite @vitejs/plugin-react`
- Create `vite.config.ts` with react plugin
- Move `public/index.html` to project root, add `<script type="module" src="/src/index.jsx">` (or `.tsx`)
- Update `package.json` scripts: `start` → `vite`, `build` → `vite build`, add `preview` → `vite preview`; leave `test` unchanged

**Do NOT** rewrite `REACT_APP_` env vars in this phase — that is Phase 2.

**Verify:** `npm install` succeeds, project structure looks correct (index.html at root, vite.config present)

---

### Phase 2: Env Var Rewrite

**Goal:** Replace all `REACT_APP_` references with `VITE_` prefix. This is the highest-risk step — unrewritten vars cause silent runtime failures.

**Link:** https://v6.vite.dev/guide/env-and-mode

**Steps:**
1. Find all occurrences in source files:
   ```bash
   grep -r "REACT_APP_" src/ --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx"
   ```
2. Find all occurrences in env files:
   ```bash
   grep -r "REACT_APP_" .env .env.local .env.development .env.production .env.test 2>/dev/null
   ```
3. Rewrite source files: `process.env.REACT_APP_X` → `import.meta.env.VITE_X`
4. Rewrite env files: `REACT_APP_X=value` → `VITE_X=value`
5. Also check for `process.env.NODE_ENV` — Vite uses `import.meta.env.MODE` for mode checks, but `process.env.NODE_ENV` still works via Vite's define config (usually no change needed)

**Verify:**
```bash
grep -r "REACT_APP_" src/ .env* 2>/dev/null
```
This must return no results. `.upgrade/scripts/verify-fast.sh` exits non-zero if `REACT_APP_` appears in dist/ — fix all source occurrences before running a build.

---

### Phase 3: Index HTML Relocation

**Goal:** Confirm index.html is correctly positioned and configured for Vite.

**Link:** https://github.com/bhbs/viject

**Steps:**
1. Verify `index.html` is in the **project root** (not `public/`) — viject usually handles this
2. Confirm `<script type="module" src="/src/index.jsx">` (or `.tsx` / `.js`) tag is present in index.html
3. Remove any `%PUBLIC_URL%` references — Vite does not use this CRA-specific placeholder
4. For other assets previously referenced as `%PUBLIC_URL%/...` in index.html, use `/` prefix instead

**Verify:** index.html at project root with module script tag, no `%PUBLIC_URL%` strings

---

### Phase 4: SVG Import Configuration

**Goal:** Ensure SVG imports work with Vite (CRA and Vite handle SVGs differently by default).

**Link:** https://github.com/pd4d10/vite-plugin-svgr

**Steps:**
1. Check if the project imports SVGs as React components:
   ```bash
   grep -r "ReactComponent" src/ --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx"
   grep -r "from '.*\.svg'" src/ --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx"
   ```
2. If SVG-as-React-component imports are used (`import { ReactComponent as Logo } from './logo.svg'`):
   - `npm install -D vite-plugin-svgr`
   - Add `svgr()` to the `plugins` array in `vite.config.ts`
3. If SVGs are only used as URLs (e.g., `<img src={logo} />`), no plugin is needed — Vite handles this natively
4. If no SVG imports at all, skip this phase and mark complete

**Verify:** `vite build` passes without SVG-related errors

---

### Phase 5: Proxy Config Translation

**Goal:** Translate CRA's `setupProxy.js` to Vite's built-in server proxy config.

**Link:** https://vite.dev/config/server-options

**Steps:**
1. Check if `src/setupProxy.js` (or `src/setupProxy.ts`) exists:
   ```bash
   ls src/setupProxy.* 2>/dev/null
   ```
2. If it does not exist, skip this phase and mark complete
3. If it exists and uses simple `createProxyMiddleware(path, { target })` patterns:
   - Translate to `server.proxy` in `vite.config.ts`:
     ```ts
     server: {
       proxy: {
         '/api': { target: 'http://localhost:8080', changeOrigin: true }
       }
     }
     ```
   - Remove `src/setupProxy.js` after successful translation
   - Remove `http-proxy-middleware` from package.json if no longer needed
4. If `setupProxy.js` uses Express-specific methods (`app.get`, `app.post`, custom middleware logic):
   - Attempt translation; if too complex after 3 attempts, log complexity in `.upgrade/run-log.md`
   - Mark the phase as `failed` with documentation — a human will handle it

**Verify:** Dev server proxy works (or phase marked failed with documentation in run-log.md)

---

### Phase 6: Build Verification

**Goal:** Confirm the full Vite build passes cleanly and react-scripts is fully removed.

**Link:** https://v6.vite.dev/guide/build

**Steps:**
1. Run `.upgrade/scripts/verify-full.sh` — full build + lint + tests + REACT_APP_ grep in dist/
2. Fix any remaining build errors (missing imports, incompatible syntax, etc.)
3. Ensure `react-scripts` is removed from `package.json` dependencies and devDependencies
4. Run `npm uninstall react-scripts` if still present
5. Confirm `vite build` completes without errors

**Verify:** `.upgrade/scripts/verify-full.sh` passes clean, `react-scripts` not in package.json

---

### Phase 7: CI/CD Env Var Flagging

**Goal:** Identify CI/CD files that still reference `REACT_APP_` variables and document them for manual update.

**Link:** https://v6.vite.dev/guide/env-and-mode

**Steps:**
1. Search all CI/CD configuration files:
   ```bash
   grep -r "REACT_APP_" .github/workflows/ Dockerfile docker-compose.yml \
     .gitlab-ci.yml Jenkinsfile Makefile .circleci/ .travis.yml 2>/dev/null
   ```
2. For each file and line found:
   - Add an entry to `.upgrade/run-log.md`: file path, line number, current value, required change
   - Add a note to `.upgrade/changelog.md` under "Manual Action Required"
3. Do NOT modify CI/CD files — they may contain deployment secrets or environment-specific context that requires human review

**Verify:** All `REACT_APP_` references in CI/CD files are documented in `.upgrade/run-log.md`

---

### Phase 8: Jest to Vitest Migration

**Goal:** Replace Jest with Vitest as the test runner. This is the final phase — Jest has been the safety net throughout.

**Link:** https://vitest.dev/guide/migration

**Steps:**
1. Install Vitest and testing library:
   ```bash
   npm install -D vitest @vitest/ui jsdom @testing-library/jest-dom
   ```
2. Add test configuration to `vite.config.ts`:
   ```ts
   test: {
     globals: true,
     environment: 'jsdom',
     setupFiles: './src/setupTests.ts'  // or .js — adjust to actual filename
   }
   ```
3. Replace Jest globals across all test files:
   - `jest.fn()` → `vi.fn()`
   - `jest.mock()` → `vi.mock()`
   - `jest.spyOn()` → `vi.spyOn()`
   - `jest.clearAllMocks()` → `vi.clearAllMocks()`
4. Update `package.json` test script: `"test": "vitest run"` (for CI; use `"vitest"` for watch mode)
5. Remove Jest and its type definitions:
   ```bash
   npm uninstall jest jest-environment-jsdom @types/jest babel-jest ts-jest react-scripts
   ```
6. Remove `jest.config.js` / `jest.config.ts` if present (Vitest config is in vite.config.ts)
7. If `jest.config.js` has complex transforms or custom moduleNameMapper entries, log them in `.upgrade/run-log.md` before removing

**Verify:** `npm test` runs vitest and all tests pass, `jest` is not in package.json

## Constraints

- Migrate everything to Vite — the goal is a fully working Vite build with no react-scripts remnants
- Never change application behaviour — the app must work identically after migration
- Keep Jest working throughout Phases 1–7 (it is the safety net)
- Commit after each phase
- If stuck after 3 attempts on the same error, log and move on
