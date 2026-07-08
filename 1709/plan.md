# Plan: Release PR Workflow Fix (#1708-1709)

## Goal

Fix the agent's release PR workflow bypass by adding trigger phrases, wiring the Pre-Response Gate into task files, closing the escape hatch, creating version-manager and release-promoter skills, adding release branch naming, post-merge release detection, pre-release validation, and behavioral enforcement tests.

## Architecture

All changes are within the `.opencode` submodule. The plan modifies existing skill/guideline files and creates new skill files. Each phase is a self-contained set of file modifications that can be verified independently.

## Files to Modify

| File | Phase |
|------|-------|
| `skills/changelog-generator/SKILL.md` | 1 |
| `skills/git-workflow/SKILL.md` | 1, 7 |
| `skills/pr-creation-workflow/SKILL.md` | 1, 7 |
| `skills/git-workflow/tasks/pr-creation/squash-push.md` | 2 |
| `skills/git-workflow/tasks/pr-creation.md` | 2, 9 |
| `guidelines/010-approval-gate.md` | 3 |
| `skills/approval-gate/SKILL.md` | 3 |
| `AGENTS.md` | 4 |
| `skills/git-workflow/tasks/cleanup.md` | 8 |

## Files to Create

| File | Phase |
|------|-------|
| `skills/version-manager/SKILL.md` | 5 |
| `skills/version-manager/tasks/discover.md` | 5 |
| `skills/version-manager/tasks/bump.md` | 5 |
| `skills/release-promoter/SKILL.md` | 6 |
| `skills/release-promoter/tasks/tag.md` | 6 |
| `skills/release-promoter/tasks/create-release.md` | 6 |
| `tests/behaviors/release-pr-dispatch.sh` | 10 |
| `tests/behaviors/version-discovery.sh` | 10 |
| `tests/behaviors/release-tagging.sh` | 10 |

## Phase Table

| Phase | Description | Files | Chain |
|-------|-------------|-------|-------|
| 1 | Trigger phrase additions | 3 SKILL.md files | none |
| 2 | Pre-Response Gate in squash-push.md + pr-creation.md | 2 task files | phase_1 |
| 3 | Authorization-level gate | 010-approval-gate.md, approval-gate/SKILL.md | phase_2 |
| 4 | Close escape hatch in AGENTS.md | AGENTS.md | phase_3 |
| 5 | Create version-manager skill | 3 new files | phase_4 |
| 6 | Create release-promoter skill | 3 new files | phase_5 |
| 7 | Release branch naming + PR body template | git-workflow/SKILL.md, pr-creation-workflow/SKILL.md | phase_6 |
| 8 | Post-merge trigger wiring | cleanup.md | phase_7 |
| 9 | Pre-release validation gate | pr-creation.md | phase_8 |
| 10 | Behavioral enforcement tests | 3 new test files | phase_9 |

## Exit Criteria

- All 10 phases implemented and committed
- Feature branch pushed to remote
- PR created with summary of all changes
- All SCs from spec #1709 satisfied

## Implementation Steps

### Phase 1: Trigger Phrase Additions

**Files:** `skills/changelog-generator/SKILL.md`, `skills/git-workflow/SKILL.md`, `skills/pr-creation-workflow/SKILL.md`

**Changes:**
1. `changelog-generator/SKILL.md` — Add `release PR`, `release notes` to description trigger phrases. Add dispatch table row: `"release PR" / "release notes"` → `since-last-release`.
2. `git-workflow/SKILL.md` — Add `release PR` to description trigger phrases. Add dispatch table row: `"release PR" / "is_release"` → `pr-creation` with `{is_release: true}`. Add Operating Protocol rule 9 for release branch naming.
3. `pr-creation-workflow/SKILL.md` — Add `release PR`, `release` to description trigger phrases. Add dispatch table row: `"release PR" / "release"` → `pre-pr-checklist` with `{is_release: true}`.

**Verification:** grep for `release PR` in each modified SKILL.md.

### Phase 2: Pre-Response Gate in squash-push.md + pr-creation.md

**Files:** `skills/git-workflow/tasks/pr-creation/squash-push.md`, `skills/git-workflow/tasks/pr-creation.md`

**Changes:**
1. `squash-push.md` — Add new Step 1 (Pre-Response Gate) before current Step 2, renumbering subsequent steps. The gate requires skill deck evaluation per AGENTS.md, with a release PR constraint that "no skill applies directly" is NOT valid.
2. `pr-creation.md` — Add "Pre-Response Gate evaluation completed" to Entry Criteria.

**Verification:** grep for `Pre-Response Gate` in both files.

### Phase 3: Authorization-Level Gate

**Files:** `guidelines/010-approval-gate.md`, `skills/approval-gate/SKILL.md`

**Changes:**
1. `010-approval-gate.md` — Add `for_release_pr` scope to Key Scope Values table. Add release PR gate rule to Mandatory Requirements.
2. `approval-gate/SKILL.md` — Add `"release PR" / "release authorization"` row to Trigger Dispatch Table.

**Verification:** grep for `release PR` in both files.

### Phase 4: Close Escape Hatch in AGENTS.md

**File:** `AGENTS.md`

**Changes:** Add release PR constraint paragraph after Step 4 of Pre-Response Gate Procedure: when context is a release PR, "no skill applies directly" is NOT a valid justification.

**Verification:** grep for `Release PR constraint` in AGENTS.md.

### Phase 5: Create version-manager Skill

**Files:** `skills/version-manager/SKILL.md`, `skills/version-manager/tasks/discover.md`, `skills/version-manager/tasks/bump.md`

**Changes:** Create three new files with full skill card, discover task (dynamic regex-based version scanning), and bump task (semver bump from changelog categories).

**Verification:** File existence check.

### Phase 6: Create release-promoter Skill

**Files:** `skills/release-promoter/SKILL.md`, `skills/release-promoter/tasks/tag.md`, `skills/release-promoter/tasks/create-release.md`

**Changes:** Create three new files with full skill card, tag task (annotated tag with v prefix), and create-release task (GitHub Release from tag).

**Verification:** File existence check.

### Phase 7: Release Branch Naming + PR Body Template

**Files:** `skills/git-workflow/SKILL.md`, `skills/pr-creation-workflow/SKILL.md`

**Changes:**
1. `git-workflow/SKILL.md` — Add dispatch table row: `"release" / "release/v"` → `pre-work` with `{branch: release/v{semver}}`.
2. `pr-creation-workflow/SKILL.md` — Add Operating Protocol rule 10 for release PR body format.

**Verification:** grep for `release/v` in git-workflow/SKILL.md.

### Phase 8: Post-Merge Trigger Wiring

**File:** `skills/git-workflow/tasks/cleanup.md`

**Changes:** Add Step 1.5 (Post-Merge Release Detection) after Step 1. Checks if merged branch starts with `release/` or has release label, then dispatches release-promoter tasks.

**Verification:** grep for `release-promoter` in cleanup.md.

### Phase 9: Pre-Release Validation Gate

**File:** `skills/git-workflow/tasks/pr-creation.md`

**Changes:** Add Step -1 (Pre-Release Validation) before Step 0-1. Verifies clean working tree, no pending rebase, all changes committed, no uncommitted submodule changes.

**Verification:** grep for `Pre-Release Validation` in pr-creation.md.

### Phase 10: Behavioral Enforcement Tests

**Files:** `tests/behaviors/release-pr-dispatch.sh`, `tests/behaviors/version-discovery.sh`, `tests/behaviors/release-tagging.sh`

**Changes:** Create three behavioral test scripts that verify skill dispatch on release PR prompts. Make executable.

**Verification:** File existence + executable bit check.

## Self-Review

- All 10 phases are independent file modifications — no cross-phase conflicts
- Each phase produces verifiable artifacts (grep patterns, file existence)
- Phases 5-6 create new skills that are referenced in phases 7-8 (post-merge wiring)
- Phase 10 tests reference skills created in phases 1, 5, 6
- Sequential ordering: phases 1→2→3→4→5→6→7→8→9→10
