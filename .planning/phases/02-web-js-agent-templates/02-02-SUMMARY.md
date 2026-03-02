---
phase: 02-web-js-agent-templates
plan: "02"
subsystem: templates
tags: [cra, vite, react, viject, vitest, jest, migration, agent-templates]

# Dependency graph
requires: []
provides:
  - CRA-to-Vite migration agent template set (CLAUDE.md, plan.md, checklist.yaml)
  - 8-phase migration plan covering viject scaffold through Jest-to-Vitest migration
  - ralph-loop.sh-compatible checklist with measurable acceptance criteria per phase
affects:
  - 02-03-nextjs (same template structure pattern)
  - 02-04-vite-react (same template structure pattern)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - CLAUDE.md copied as-is (no envsubst); plan.md and checklist.yaml use envsubst with ${UPGRADE_DATE}, ${REPO_URL}
    - 8-section CLAUDE.md structure mirroring Laravel template (Startup Protocol, Execution Rules, Constraints, Reference Material, Verification Scripts, Useful Commands, CI/CD Awareness, Error Recovery)
    - Phase IDs in checklist.yaml match plan.md phase numbers for ralph-loop.sh compatibility
    - Codemod-first pattern: viject scaffold in Phase 1, committed as-is, then fix what it missed

key-files:
  created:
    - stacks/node/templates/cra/CLAUDE.md
    - stacks/node/templates/cra/plan.md
    - stacks/node/templates/cra/checklist.yaml
  modified: []

key-decisions:
  - "REACT_APP_ documented as BUILD BLOCKER in CLAUDE.md — viject does not rewrite these, agent must do it manually in Phase 2"
  - "Jest-to-Vitest is Phase 8 (last) — Jest kept as safety net throughout build migration phases 1-7"
  - "CI/CD REACT_APP_ references flagged but NOT modified by agent — documented for human maintainer review"
  - "viject manual fallback steps included in Phase 1 for when viject fails"
  - "Phase 5 (proxy translation) uses 3-attempt rule with graceful failure — complex Express middleware documented and left for human"

patterns-established:
  - "Plan-first: each phase has explicit link to official docs (viject, Vite env guide, Vitest migration guide)"
  - "Acceptance criteria are grep-verifiable: Phase 2 criterion is 'grep -r REACT_APP_ src/ returns no results'"
  - "Safety-net pattern: keep old test runner (Jest) working until the final migration phase"

requirements-completed: [CRA-01, CRA-02, CRA-03, CRA-04, CRA-05, CRA-06, CRA-07, CRA-08]

# Metrics
duration: 2min
completed: 2026-03-01
---

# Phase 2 Plan 02: CRA Agent Templates Summary

**8-phase CRA-to-Vite migration agent template set with viject scaffold, REACT_APP_ rewrite enforcement, and Jest-to-Vitest as the final safety-net migration**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-02T02:44:41Z
- **Completed:** 2026-03-02T02:46:54Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments
- CLAUDE.md with 8 sections mirroring Laravel structure, REACT_APP_ documented as build blocker, viject limitations explicitly listed
- plan.md with 8 sequential phases (CRA-01 through CRA-08), official doc links per phase, viject manual fallback, envsubst variables
- checklist.yaml with 8 phases, measurable acceptance criteria (grep-verifiable), all phases initialized as not_started

## Task Commits

Each task was committed atomically:

1. **Task 1: Write CRA CLAUDE.md** - `488b9e4` (feat)
2. **Task 2: Write CRA plan.md and checklist.yaml** - `fc1b1e9` (feat)

**Plan metadata:** (docs commit follows)

## Files Created/Modified
- `stacks/node/templates/cra/CLAUDE.md` - Agent instruction file: startup protocol, execution rules, REACT_APP_ constraints, viject limitation docs, CI/CD awareness section
- `stacks/node/templates/cra/plan.md` - 8-phase migration plan with envsubst vars, official doc links per phase, viject manual fallback in Phase 1
- `stacks/node/templates/cra/checklist.yaml` - ralph-loop.sh-compatible checklist with 8 phases, measurable acceptance criteria, all not_started

## Decisions Made
- REACT_APP_ documented as BUILD BLOCKER because viject doesn't handle it — silent runtime failures are the highest-risk CRA migration pitfall
- Jest kept working through Phases 1-7 as the safety net; Jest-to-Vitest migration is Phase 8 (last)
- CI/CD files flagged but not modified — they may contain deployment secrets requiring human context
- Phase 5 proxy translation uses graceful failure (3-attempt rule + mark failed) because complex Express middleware requires human judgment
- viject manual fallback steps documented in Phase 1 because viject is medium-confidence tool

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- CRA template set complete and production-ready
- Next.js template set (02-03) and Vite+React template set (02-04) follow same structural pattern
- All must-have truths verified: REACT_APP_ as build-blocker, viject limitations documented, Jest-to-Vitest last phase, 8 matching phases between plan.md and checklist.yaml

---
*Phase: 02-web-js-agent-templates*
*Completed: 2026-03-01*
