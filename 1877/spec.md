# [SPEC-FIX] Cleanup leaves parent repo on stale branch, hardcoded dev references in branch-cleanup.md

**STATUS:** DRAFT
**CREATED:** 2026-07-11
**Issue:** [michael-conrad/.opencode#1877](https://github.com/michael-conrad/.opencode/issues/1877)

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| Problem Statement | After submodule PR merge, the cleanup task leaves the parent repo on a stale feature branch and `branch-cleanup.md` contains 40+ hardcoded `dev` references that conflict with trunk-based development using `main`. |
| Root Cause / Motivation | Root Cause 1: The cleanup task's post-merge verification only checks repos in the submodule list, not the parent repo itself. Root Cause 2: `branch-cleanup.md` was written before the repo switched to trunk-based development and was never updated. |
| Approach Chosen | Replace all hardcoded `dev` references in `branch-cleanup.md` with `$DEFAULT_BRANCH` (dynamically resolved), add `git branch --show-current` to `cleanup.md` Step 3 post-cleanup verification, and ensure the parent repo is included in the repos-to-clean list. |
| Alternatives Considered & Why Discarded | (1) Hardcode `main` instead of `dev` — rejected because it creates the same problem for repos using different trunk names. (2) Only fix the parent repo parking — rejected because the hardcoded `dev` references are the root cause of the parent repo not being parked correctly. |
| Key Design Decisions | DEC-1: Use `$DEFAULT_BRANCH` (dynamically resolved via `git remote show origin`) instead of any hardcoded branch name. DEC-2: Parent repo trunk parking is mandatory — the parent repo MUST be on trunk after cleanup. |

## Objective

Fix two defects in the cleanup workflow that cause the parent repo to be left on a stale feature branch after submodule PR merge, and replace all hardcoded `dev` references in `branch-cleanup.md` with the dynamically resolved `$DEFAULT_BRANCH` variable.

## Problem

### Root Cause 1: Parent repo not cleaned after PR merge

After PR #1876 merged into `.opencode` main, the cleanup sub-agent only operated on the `.opencode` submodule (deleted the feature branch, synced to main). The parent repo (`opencode-config`) was left on `feature/492-stale-branch-detection` — no cleanup was dispatched for it.

The cleanup task's post-merge verification (Step 4 in `cleanup.md`) builds a `repos_to_check` list that includes the parent repo at index 0 and each submodule. However, the `branch-cleanup.md` Step 1.7 parent repo trunk parking logic only activates when running from a submodule context (detected via `git rev-parse --show-superproject-working-tree`). When the cleanup sub-agent runs from the submodule, it correctly parks the submodule on trunk but the parent repo parking logic in Step 1.7 uses `git -C "$PARENT_REPO_PATH"` which resolves to the parent repo path — this SHOULD work but the cleanup sub-agent may not be dispatching Step 1.7 correctly, or the parent repo is not being included in the repos-to-clean list.

### Root Cause 2: Hardcoded `dev` references throughout `branch-cleanup.md`

The file `.opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md` has 40+ occurrences of `dev` as a hardcoded branch name — in the purpose statement, evidence artifacts, branch merge checks, persistence notes, and prose. The repo uses trunk-based development with `main` as the single trunk (per AGENTS.md: "Main is the single trunk. Dev branch has been removed.").

The `DEFAULT_BRANCH` variable is resolved dynamically in some spots (`git remote show origin | sed -n 's/.*HEAD branch: //p'`) but the surrounding prose still says `dev`. All hardcoded `dev` references must be replaced with `$DEFAULT_BRANCH` or `<trunk>`.

### Related Issues

- [#270](https://github.com/michael-conrad/.opencode/issues/270) — SPEC-FIX: Cleanup Fails to Park Parent Repo (closed, added parent parking to branch-cleanup.md Step 1.7)
- [#696](https://github.com/michael-conrad/.opencode/issues/696) — SPEC: missing dev-parking precondition gate (still open, added Step 0 precondition gate)
- [#1873](https://github.com/michael-conrad/.opencode/issues/1873) — SPEC-FIX: Cleanup Post-Verification Missing `git branch --show-current` Check (closed, but implementation was defective — the `git branch --show-current` check was NOT actually added to `cleanup.md` Step 3)

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md` | Replace all hardcoded `dev` with `$DEFAULT_BRANCH` |
| `.opencode/skills/git-workflow/tasks/cleanup.md` | Add `git branch --show-current` to Step 3 post-cleanup verification |
| `.opencode/skills/git-workflow/tasks/cleanup.md` | Ensure parent repo is included in the repos-to-clean list |

## Scope

**In scope:**
- Replace all hardcoded `dev` references in `branch-cleanup.md` with `$DEFAULT_BRANCH`
- Add `git branch --show-current` check to `cleanup.md` Step 3 post-cleanup verification
- Ensure parent repo is included in repos-to-clean list in `cleanup.md`

**Out of scope:**
- Changes to other cleanup sub-task files (`verify-merge.md`, `issue-closure.md`, `issue-closure-sweep.md`)
- Changes to the cleanup orchestrator dispatch logic
- Changes to `cleanup.md` Step 0 submodule detection

## Fix Approach

### Phase 1: Replace hardcoded `dev` in branch-cleanup.md

Scan `branch-cleanup.md` for all occurrences of `dev` used as a branch name reference and replace with `$DEFAULT_BRANCH`. The file already uses `$DEFAULT_BRANCH` in some code blocks (Steps 1, 1.5, 1.7, 1.9) but the surrounding prose, purpose statement, evidence artifacts, and some code blocks still use hardcoded `dev`.

Specific locations to fix:
- Line 5: Purpose statement — "sync dev" → "sync trunk"
- Lines 18, 118, 300, 305, 341, 343, 429, 441: Prose references to `dev`
- Lines 343, 429: Code blocks using hardcoded `dev` instead of `$DEFAULT_BRANCH`

### Phase 2: Add `git branch --show-current` to cleanup.md Step 3

`cleanup.md` Step 3 (Branch Cleanup and Sync) routes to `cleanup/branch-cleanup`. The post-cleanup verification in Step 4 checks local vs remote trunk hashes for each repo but does NOT verify the current branch. Add a `git branch --show-current` check to Step 3 or Step 4 to verify the repo is actually on the trunk branch after cleanup.

### Phase 3: Ensure parent repo in repos-to-clean list

`cleanup.md` Step 4 already builds a `repos_to_check` list that includes the parent repo at index 0. Verify this is working correctly and that the parent repo trunk parking in `branch-cleanup.md` Step 1.7 is being dispatched. If the parent repo is not being parked, fix the dispatch logic.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | All hardcoded `dev` references in `branch-cleanup.md` replaced with `$DEFAULT_BRANCH` | `string` | `grep -c '\bdev\b' .opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md` returns 0 for branch-name usage | Re-scan file, replace remaining occurrences | red-green | `.opencode/.issues/1877/` | RC1: hardcoded dev references | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-2 | `cleanup.md` Step 3 or Step 4 includes `git branch --show-current` verification | `string` | `grep 'git branch --show-current' .opencode/skills/git-workflow/tasks/cleanup.md` returns match | Add the check to the appropriate step | red-green | `.opencode/.issues/1877/` | RC2: missing show-current check | Phase 2 | pre-commit | standalone | — | — | — | Phase 2 |
| SC-3 | Parent repo is included in repos-to-clean list in `cleanup.md` Step 4 | `string` | `grep 'parent.*repo' .opencode/skills/git-workflow/tasks/cleanup.md` returns match in Step 4 context | Add parent repo to the list | red-green | `.opencode/.issues/1877/` | RC1: parent repo not cleaned | Phase 3 | pre-commit | standalone | — | — | — | Phase 3 |
| SC-4 | Before any implementation, write behavioral enforcement tests that verify the new cleanup behavior; confirm RED state | `behavioral` | `bash .opencode/tests/behaviors/<scenario>.sh` returns non-zero before changes, zero after | Re-create missing tests, re-run RED | red-green | `.opencode/.issues/1877/behavioral/` | TDD mandate | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |

## Edge Cases

- **Repo with no submodules**: Parent repo parking should still work — the parent repo is the only repo to clean
- **Repo with `main` as trunk**: `$DEFAULT_BRANCH` resolves to `main` — all operations use `main` correctly
- **Repo with `dev` as trunk**: `$DEFAULT_BRANCH` resolves to `dev` — backward compatible
- **Repo with no remote**: `$DEFAULT_BRANCH` resolution fails — fallback to `main` per existing fallback in `cleanup.md` line 11

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source read | `.opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md` | Verify hardcoded `dev` references |
| Direct source read | `.opencode/skills/git-workflow/tasks/cleanup.md` | Verify Step 3/4 structure and parent repo handling |
| Local docs | `AGENTS.md` | Confirm trunk-based development with `main` |

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1877/plan.md` before implementation begins.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

🤖 Co-authored with AI: OpenCode (deepseek-v4-pro)
