# Plan: Remove silent provenance degradation escape hatch + Update SKILL.md description

**Issues:** #1556 (provenance fix), #1513 (SKILL.md description update)
**Authorization scope:** `for_pr`
**PR strategy:** `stacked` (one branch, one PR for both issues)
**Branch:** `feature/1556-1513-provenance-fix`

## Goal

1. Delete `promotion-provenance.md` (dead code under trunk-based development)
2. Rename `dev-push-provenance.md` → `trunk-push-provenance.md` with content updates
3. Remove "no HALT, no blocking" silent fallback policy
4. Update all cross-references across the codebase
5. Update git-workflow SKILL.md description to include `trunk-push-provenance` and `submodule-sync`, remove `promotion-provenance` and release PR promotion references

## Architecture

Simple file operations: delete, rename, edit. No new files. No behavioral changes to runtime logic — the provenance task files are documentation/instructions for sub-agents, not executable code.

## Files Affected

| File | Change |
|------|--------|
| `.opencode/skills/git-workflow/tasks/provenance/promotion-provenance.md` | DELETE |
| `.opencode/skills/git-workflow/tasks/provenance/dev-push-provenance.md` | RENAME → `trunk-push-provenance.md` + content edits |
| `.opencode/skills/git-workflow/tasks/provenance.md` | Update references, remove promotion section |
| `.opencode/skills/git-workflow/tasks/provenance/platform-detection.md` | Update references |
| `.opencode/skills/git-workflow/tasks/review-prep/push-and-cleanup.md` | Update mode reference |
| `.opencode/skills/git-workflow/SKILL.md` | Update description, dispatch table |
| `.opencode/tests/behaviors/provenance-task-decomposition.sh` | Update assertion pattern |

## Phase Table

| Phase | Description | Depends On |
|-------|-------------|------------|
| 1 | Delete `promotion-provenance.md` | — |
| 2 | Rename `dev-push-provenance.md` → `trunk-push-provenance.md` + content edits | Phase 1 |
| 3 | Update parent provenance task (`provenance.md`) | Phase 1, 2 |
| 4 | Update related task files (`platform-detection.md`, `push-and-cleanup.md`) | Phase 2 |
| 5 | Update `git-workflow/SKILL.md` description and dispatch table | Phase 1-4 |
| 6 | Update behavioral test assertion | Phase 2 |

## Exit Criteria

- `promotion-provenance.md` deleted
- `dev-push-provenance.md` renamed to `trunk-push-provenance.md` with all "dev" → "trunk" updates
- "no HALT, no blocking" policy removed from provenance files
- All cross-references updated (provenance.md, platform-detection.md, push-and-cleanup.md, SKILL.md)
- Behavioral test updated with correct task names
- All changes committed on `feature/1556-1513-provenance-fix` branch
- PR created targeting `main`

## Self-Review Evidence

- Research report from explore sub-agent confirms all 7 files need changes
- Dependency order verified: Phase 1 → 2 → 3 → 4 → 5 → 6
- No runtime behavioral changes — all changes are file renames, deletes, and reference updates
