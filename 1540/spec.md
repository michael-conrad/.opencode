# Spec: Replace Mandatory Three-Branch Model with Single-Path Branch Workflow (Issue #1540)

**Source:** Brainstorming session 2026-06-27  
**Created:** 2026-06-28  
**Parent:** None (standalone)

## Problem

The current skill deck enforces a three-branch model (`feature → dev → main`) where:

1. `dev` is mandatory — always auto-created at pre-work if it doesn't exist (~20 lines of conditional creation logic in `pre-work.md`)
2. PRs have two separate paths: feature→dev via `pr-creation-workflow`, release-promotion (dev→main) via `git-workflow --task release-promotion` — each with different rules and squash behavior
3. Dev has special treatment across 15+ files: protection gates, submodule lifecycle management (`submodule-dev-restore`), cleanup logic that switches to dev
4. Squash is conditional: single-issue squashes to one commit; multi-issue work branches keep multiple commits — creating inconsistent history depending on PR scope
5. Commit messages during development are unstructured (WIP, fixup) with no standardization at squash time

## Root Cause

The three-branch model was designed when `dev` served as a mandatory staging buffer. The current workflow has evolved to where `dev` adds complexity without proportional value. The dual PR path creates maintenance burden and confusion about which path to use. Conditional squash produces unpredictable history.

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

### 6. Update PR body template
- **File:** `create-pr.md`
- **Change:** PR body includes: intent, overview, VbC results table, adversarial auditor results, spec-card-mapped commits table, AI byline. No separate changelog generation needed.
- **SC:** SC-5 (structural — verify all 6 sections present)

### 7. Define rebase timing
- **File:** `pre-work.md` + `create-pr.md`
- **Change:** Rebase at three fixed points: before branch creation (sync with target), before PR creation (ensure mergable), after push (double-check remote for conflicts)
- **SC:** SC-8 (behavioral — verify rebase at all three points)

### 8. Remove or unify release-promotion task
- **File:** `release-promotion.md`
- **Change:** Either remove or delegate to `create-pr`. The concept of a release workflow is preserved but the dual-path maintenance burden is eliminated.
- **SC:** SC-7 (structural — verify file removed or delegated)

## Success Criteria Summary

| SC | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Pre-work no longer auto-creates `dev` | behavioral |
| SC-2 | PR creation accepts any target branch | behavioral |
| SC-3 | Squash mandatory for all branches at PR time | behavioral |
| SC-4 | Commit messages follow `#<issue> <title> — <summary>` | string + semantic |
| SC-5 | PR body includes all 6 required sections | structural |
| SC-6 | No dev-specific rules remain in skill deck | semantic + string |
| SC-7 | Release-promotion removed or unified | structural |
| SC-8 | Rebase at three fixed points | behavioral |

## Non-Goals

- Does NOT introduce new submodule synchronization strategies (existing tag-based system remains unchanged)
- Does NOT add parallel branch management complexity (dev is optional, not automatic)
- Does NOT change CI/CD gating logic (already handled by `pre-pr-checklist`)
- Does NOT create new naming conventions for branches beyond adapting existing ones
- Does NOT delete existing `dev` branches — dev becomes an ordinary branch
- Does NOT change `main` branch protection rules or merge requirements

## Regression Invariants

1. Existing feature branches continue to work without modification
2. Existing PRs are not affected — change applies to new PRs only
3. Submodule tag-based hash permanence system remains unchanged
4. All existing git hooks continue to function without modification
5. `main` remains the default PR target when no target is specified
