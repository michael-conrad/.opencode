# [SPEC-FIX] Cleanup leaves parent repo on stale branch, hardcoded dev references in cleanup.md

**STATUS:** DRAFT
**CREATED:** 2026-07-11 (revised 2026-07-14)
**Issue:** [michael-conrad/.opencode#1877](https://github.com/michael-conrad/.opencode/issues/1877)

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| Problem Statement | After submodule PR merge, the cleanup task leaves the parent repo on a stale feature branch. The `cleanup.md` task file contains 7 hardcoded `dev` branch references that conflict with trunk-based development using `main`. The `branch-cleanup.md` file was already fixed in a prior commit (0f901a3e) and has 0 hardcoded `dev` references. |
| Root Cause / Motivation | Root Cause 1: The cleanup task's post-merge verification uses hardcoded `dev` in prose and step descriptions in `cleanup.md`, which conflicts with repos using `main` as trunk. Root Cause 2: The parent repo was not being parked on trunk after submodule PR merge (the `branch-cleanup.md` Step 1.7 parent repo parking logic was not dispatching correctly). |
| Approach Chosen | Replace all 7 hardcoded `dev` references in `cleanup.md` with `$DEFAULT_BRANCH` or trunk-equivalent prose. The `branch-cleanup.md` file is already correct (0 hardcoded `dev` references). The `git branch --show-current` check and parent repo inclusion in repos-to-clean list are already implemented in the current codebase. |
| Alternatives Considered & Why Discarded | (1) Hardcode `main` instead of `dev` — rejected because it creates the same problem for repos using different trunk names. (2) Only fix the parent repo parking — rejected because the hardcoded `dev` references in `cleanup.md` are the root cause of confusion about which branch is the trunk. |
| Key Design Decisions | DEC-1: Use `$DEFAULT_BRANCH` (dynamically resolved via `git remote show origin`) instead of any hardcoded branch name. DEC-2: Parent repo trunk parking is mandatory — the parent repo MUST be on trunk after cleanup. |

## Objective

Fix the cleanup workflow by replacing all 7 hardcoded `dev` references in `cleanup.md` with the dynamically resolved `$DEFAULT_BRANCH` variable. The `branch-cleanup.md` file was already fixed in commit 0f901a3e and requires no changes. The `git branch --show-current` check and parent repo inclusion in repos-to-clean list are already implemented in the current codebase.

## Problem

### Root Cause 1: Hardcoded `dev` references in `cleanup.md`

The file `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` has 7 occurrences of `dev` as a hardcoded branch name reference:

| Line | Content | Type |
|------|---------|------|
| 31 | "Submodule dev restored via sub-agent task()" | Exit criteria prose |
| 118 | "Switches to dev, syncs with remote..." | Step 3 purpose prose |
| 148 | "Get local dev HEAD" | Step 4.3.a prose |
| 153 | "Get remote dev HEAD" | Step 4.3.b prose |
| 173 | "If hashes match → repo is at dev tip" | Step 4.3.e prose |
| 187 | "All repos at dev tip" | Step 4.5 outcome prose |
| 216 | "Verify dev sync" | Step 1.5 prose |

The repo uses trunk-based development with `main` as the single trunk (per AGENTS.md: "Main is the single trunk. Dev branch has been removed."). The `$DEFAULT_BRANCH` variable is already used in code blocks throughout both files, but the surrounding prose still says `dev`.

### Root Cause 2: Parent repo not cleaned after PR merge (already fixed)

After PR #1876 merged into `.opencode` main, the cleanup sub-agent only operated on the `.opencode` submodule. The parent repo (`opencode-config`) was left on `feature/492-stale-branch-detection`.

**Current state:** The `cleanup.md` Step 4 already builds a `repos_to_check` list that includes the parent repo at index 0 (lines 130-144). The `branch-cleanup.md` Step 1.7 already has parent repo trunk parking logic. The `git branch --show-current` check already exists in both files (cleanup.md line 165, branch-cleanup.md lines 310/379/438). These fixes were implemented in prior commits but the spec was not updated to reflect the current state.

### Related Issues

- [#270](https://github.com/michael-conrad/.opencode/issues/270) — SPEC-FIX: Cleanup Fails to Park Parent Repo (closed, added parent parking to branch-cleanup.md Step 1.7)
- [#696](https://github.com/michael-conrad/.opencode/issues/696) — SPEC: missing dev-parking precondition gate (still open, added Step 0 precondition gate)
- [#1873](https://github.com/michael-conrad/.opencode/issues/1873) — SPEC-FIX: Cleanup Post-Verification Missing `git branch --show-current` Check (closed, implemented)

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` | Replace 7 hardcoded `dev` references with `$DEFAULT_BRANCH` or trunk-equivalent prose |

## Scope

**In scope:**
- Replace all 7 hardcoded `dev` references in `cleanup.md` with `$DEFAULT_BRANCH` or trunk-equivalent prose

**Out of scope:**
- Changes to `branch-cleanup.md` (already correct — 0 hardcoded `dev` references)
- Changes to other cleanup sub-task files (`verify-merge.md`, `issue-closure.md`, `issue-closure-sweep.md`)
- Adding `git branch --show-current` (already exists in both files)
- Adding parent repo to repos-to-clean list (already exists in cleanup.md Step 4.2)

## Fix Approach

### Phase 1: Replace hardcoded `dev` in cleanup.md

Scan `cleanup.md` for all 7 occurrences of `dev` used as a branch name reference and replace with `$DEFAULT_BRANCH` or trunk-equivalent prose. The file already uses `$DEFAULT_BRANCH` in code blocks but the surrounding prose still says `dev`.

Specific locations to fix (stable anchors — section headers, not line numbers):

1. **Exit Criteria** — "Submodule dev restored" → "Submodule trunk restored"
2. **Step 3 Purpose** — "Switches to dev" → "Switches to trunk"
3. **Step 4.3.a** — "Get local dev HEAD" → "Get local trunk HEAD"
4. **Step 4.3.b** — "Get remote dev HEAD" → "Get remote trunk HEAD"
5. **Step 4.3.e** — "repo is at dev tip" → "repo is at trunk tip"
6. **Step 4.5** — "All repos at dev tip" → "All repos at trunk tip"
7. **Step 1.5** — "Verify dev sync" → "Verify trunk sync"

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Phase Binding |
|----|-----------|---------------|---------------------|--------------|
| SC-1 | All 7 hardcoded `dev` branch references in `cleanup.md` replaced with `$DEFAULT_BRANCH` or trunk-equivalent prose | `string` | `grep -n '\bdev\b' .opencode/skills/git-workflow-cleanup/tasks/cleanup.md` returns 0 for branch-name usage (false positives: `/dev/null`, `2>/dev/null`, `DEFAULT_BRANCH` variable name, `cd -`, `--delete`) | Phase 1 |
| SC-2 | Behavioral enforcement tests verify the agent uses `$DEFAULT_BRANCH` instead of hardcoded `dev` in cleanup context | `behavioral` | `bash .opencode/tests-v2/behaviors/<scenario>.sh` returns zero after changes | Phase 1 |

## Edge Cases

- **Repo with `main` as trunk**: `$DEFAULT_BRANCH` resolves to `main` — all operations use `main` correctly
- **Repo with `dev` as trunk**: `$DEFAULT_BRANCH` resolves to `dev` — backward compatible
- **Repo with no remote**: `$DEFAULT_BRANCH` resolution falls back to `main` per existing fallback in `cleanup.md` line 11
- **`branch-cleanup.md` already correct**: No changes needed — commit 0f901a3e already replaced all hardcoded `dev` references

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source read | `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` | Verify hardcoded `dev` references (7 found) |
| Direct source read | `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` | Verify no hardcoded `dev` references remain (0 found) |
| Local docs | `AGENTS.md` | Confirm trunk-based development with `main` |
| Git log | `git log --oneline` | Verify commit 0f901a3e already fixed branch-cleanup.md |

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1877/plan.md` before implementation begins.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
