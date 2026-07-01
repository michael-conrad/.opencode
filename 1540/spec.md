# Spec: Replace Mandatory Three-Branch Model with Trunk-Based Development (Issue #1540)

**Source:** Brainstorming session 2026-06-27  
**Created:** 2026-06-28  
**Updated:** 2026-06-30 — Added trunk-based development terminology anchor (SC-13, SC-14, Required Action 12)  
**Parent:** None (standalone)

## Problem

The current skill deck enforces a three-branch model (`feature → dev → main`) — a variant of Git Flow — where:

1. `dev` is mandatory — always auto-created at pre-work if it doesn't exist (~20 lines of conditional creation logic in `pre-work.md`)
2. PRs have two separate paths: feature→dev via `pr-creation-workflow`, release-promotion (dev→main) via `git-workflow --task release-promotion` — each with different rules and squash behavior
3. Dev has special treatment across 15+ files: protection gates, submodule lifecycle management (`submodule-dev-restore`), cleanup logic that switches to dev
4. Squash is conditional: single-issue squashes to one commit; multi-issue work branches keep multiple commits — creating inconsistent history depending on PR scope
5. Commit messages during development are unstructured (WIP, fixup) with no standardization at squash time

## Root Cause

The three-branch model (Git Flow variant) was designed when `dev` served as a mandatory staging buffer. The current workflow has evolved to where `dev` adds complexity without proportional value. The dual PR path creates maintenance burden and confusion about which path to use. Conditional squash produces unpredictable history.

## Terminology Anchor

This spec replaces the three-branch Git Flow variant with **trunk-based development (TBD)**. All AI-agent-facing text — skill descriptions, Persona sections, Overview sections, routing tables, enforcement gates, and task file headers — MUST use the term "trunk-based development" (not "single-path workflow", not "single-path branch workflow", not any other ad-hoc description) when referring to the branch model.

| Term | Status | Reason |
|------|--------|--------|
| `trunk-based development` | REQUIRED — use this | Industry-standard name for short-lived feature branches merging directly to main |
| `trunk-based development workflow` | ACCEPTABLE variant | Slightly longer, same semantic anchor |
| `single-path workflow` | FORBIDDEN — remove | Ad-hoc description, no industry recognition, ambiguous |
| `single-path branch workflow` | FORBIDDEN — remove | Same as above |
| `three-branch model` | FORBIDDEN — remove | Describes the old model being replaced |
| `three-branch workflow` | FORBIDDEN — remove | Same as above |
| `Git Flow` | ACCEPTABLE for historical contrast only | Use only when explaining what is being replaced |

**Rationale:** AI agents use semantic anchors to route to the correct mental model. "Trunk-based development" triggers the correct set of expectations: short-lived branches, direct-to-main PRs, no staging branch, squash commits, frequent rebase. "Single-path workflow" is a description, not a model — it does not anchor the agent to any known practice.

## Required Actions

### 1. Remove mandatory `dev` bootstrap
- **File:** `pre-work.md` (~lines 93-105)
- **Change:** Remove unconditional `dev` creation logic. Developer explicitly creates `dev` if they want a staging branch.
- **SC:** SC-1 (behavioral — verify pre-work doesn't create dev)

### 2. Unify PR creation path
- **File:** `pr-creation-workflow/SKILL.md`
- **Change:** Update Overview line 15 (remove "dev only"), remove pr-workflow-002 enforcement gate (base_branch must be dev), allow any branch as feature PR target
- **SC:** SC-2 (behavioral — verify PR creation accepts any target branch)

### 3. Remove "three-branch model" from git-workflow
- **File:** `git-workflow/SKILL.md`
- **Change:** Remove "three-branch model" definition (line 13), remove mandatory dev bootstrap rule, update PR routing table to support any target branch
- **SC:** SC-6 (semantic + string — verify no dev-specific rules remain)

### 4. Make squash mandatory for all branches at PR time
- **File:** `squash-push.md`
- **Change:** Collapse work-branch/squash-detection into one mandatory squash-at-PR rule for all branches. Remove conditional path at lines 41, 60.
- **SC:** SC-3 (behavioral — verify multi-issue PR produces one commit per issue)

### 5. Standardize commit message format at squash time
- **File:** `squash-push.md`
- **Change:** Agent generates fresh messages from combined diffs: `#<issue> <title> — <summary>` format. Not preserving WIP/fixup intermediate commits.
- **SC:** SC-4 (string + semantic — verify commit messages match `#\d+ .+ — .+` pattern)

### 5a. Fix Phase 4 RED test infrastructure
- **File:** `tests/behaviors/` (new files)
- **Change:** SC-3 RED test must be artifact-only generator per `.opencode/tests/AGENTS.md` (no inline evaluation, no `assert_*`, no `OVERALL_RESULT`). SC-4 RED test must use `#!/bin/bash` and include cross-reference header. Both tests must be placed in `.opencode/tests/behaviors/` (not `./tmp/`). SC-3 behavioral test must use `behavior_run` with proper timeout (600s) and model selection.
- **SC:** SC-9 (structural — verify RED tests follow artifact-only generator paradigm)

### 6. Update PR body template
- **File:** `create-pr.md`
- **Change:** PR body includes: intent, overview, VbC results table, adversarial auditor results, spec-card-mapped commits table, AI byline. No separate changelog generation needed.
- **SC:** SC-5 (structural — verify all 6 sections present)

### 7. Define rebase timing
- **File:** `pre-work.md` + `create-pr.md`
- **Change:** Rebase at three fixed points: before branch creation (sync with target), before PR creation (ensure mergable), after push (double-check remote for conflicts)
- **SC:** SC-8 (behavioral — verify rebase at all three points)

### 8. Unify release into single PR path (delete release-promotion.md)
- **File:** `release-promotion.md`
- **Change:** Delete `release-promotion.md`. Release IS a PR — same `create-pr` workflow, different target branch (`main` instead of `<target>`). `create-pr.md` absorbs the release-specific parts as optional post-merge steps gated by a `--release` flag. The submodule SHA locking (Steps 1-3 of current `release-promotion.md`) is already handled by the existing tag-based hash permanence system and is removed — it is not release-specific.
- **SC:** SC-7 (behavioral — verify agent routes release PR through `pr-creation-workflow`, not `release-promotion`)

### 9. Update routing table in git-workflow/SKILL.md
- **File:** `git-workflow/SKILL.md`
- **Change:** Update the Trigger Dispatch Table so "release" / "promote to main" triggers route to `pr-creation` with `{is_release: true}` context, not to `release-promotion`. The dual-path routing (Feature PR → `pr-creation-workflow`, Release PR → `release-promotion`) is replaced with a single path: all PRs route to `pr-creation-workflow`, with `is_release` flag determining target branch (`main` vs `<target>`).
- **SC:** SC-10 (behavioral — verify routing table dispatches release PR to pr-creation-workflow)

### 10. Update cross-references to release-promotion
- **File:** `provenance.md`, `promotion-provenance.md`
- **Change:** Update or remove cross-references to `release-promotion.md` that no longer exist. References to the release workflow concept remain but point to `create-pr.md` with `--release` flag documentation.
- **SC:** SC-11 (structural — verify no stale cross-references to release-promotion.md)

### 11. Update Non-Goals and Regression Invariants
- **File:** This spec
- **Change:** Add non-goal: "Does NOT change release workflow semantics — release remains a PR to main, just routed through the same path as feature PRs." Add regression invariant: "Release PRs continue to target main with post-merge steps (semver tagging, platform release creation, release notes synthesis) gated by --release flag."
- **SC:** SC-12 (structural — verify non-goals and invariants updated)

### 12. Standardize terminology to "trunk-based development" across all AI-agent-facing text
- **Files:** `git-workflow/SKILL.md`, `pr-creation-workflow/SKILL.md`, `approval-gate/tasks/verify-qa-mode.md`, `README.md`, `tests/behaviors/1540-sc6-no-dev-rules-red.sh`, `tests/behaviors/1540-sc1-prework-no-dev-red.sh`
- **Change:** Replace all occurrences of "single-path workflow", "single-path branch workflow", "three-branch model", and "three-branch workflow" with "trunk-based development" or "trunk-based development workflow" per the Terminology Anchor table above. The CHANGELOG.md historical entry is exempt.
- **SC:** SC-13 (string — verify all FORBIDDEN terms absent from skill/guideline/test files), SC-14 (behavioral — verify agent uses "trunk-based development" when describing the branch model)

## Success Criteria Summary

| SC | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Pre-work no longer auto-creates `dev` | behavioral |
| SC-2 | PR creation accepts any target branch | behavioral |
| SC-3 | Squash mandatory for all branches at PR time | behavioral |
| SC-4 | Commit messages follow `#<issue> <title> — <summary>` | string + semantic |
| SC-5 | PR body includes all 6 required sections | structural |
| SC-6 | No dev-specific rules remain in skill deck | semantic + string |
| SC-7 | Release routes through pr-creation-workflow, not release-promotion | behavioral |
| SC-8 | Rebase at three fixed points | behavioral |
| SC-10 | Routing table dispatches release PR to pr-creation-workflow | behavioral |
| SC-11 | No stale cross-references to release-promotion.md | structural |
| SC-12 | Non-goals and invariants updated for single-path release | structural |
| SC-13 | No FORBIDDEN terms ("single-path workflow", "single-path branch workflow", "three-branch model", "three-branch workflow") remain in skill/guideline/test files (CHANGELOG exempt) | string |
| SC-14 | Agent uses "trunk-based development" when describing the branch model in skill descriptions, Persona sections, and Overview sections | behavioral |

## Non-Goals

- Does NOT introduce new submodule synchronization strategies (existing tag-based system remains unchanged)
- Does NOT add parallel branch management complexity (dev is optional, not automatic)
- Does NOT change CI/CD gating logic (already handled by `pre-pr-checklist`)
- Does NOT create new naming conventions for branches beyond adapting existing ones
- Does NOT delete existing `dev` branches — dev becomes an ordinary branch
- Does NOT change `main` branch protection rules or merge requirements
- Does NOT change release workflow semantics — release remains a PR to main, just routed through the same path as feature PRs
- Does NOT change CHANGELOG.md historical entries — past references to "three-branch model" are preserved as historical record

## Regression Invariants

1. Existing feature branches continue to work without modification
2. Existing PRs are not affected — change applies to new PRs only
3. Submodule tag-based hash permanence system remains unchanged
4. All existing git hooks continue to function without modification
5. `main` remains the default PR target when no target is specified
6. Release PRs continue to target main with post-merge steps (semver tagging, platform release creation, release notes synthesis) gated by `--release` flag
