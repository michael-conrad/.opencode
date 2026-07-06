# Plan: Replace hardcoded dev branch references with $DEFAULT_BRANCH

> **Spec:** `.opencode/.issues/1676/spec.md`
> **Phases:** 7 (1 pre, 5 per-category, 1 post)
> **Total files:** 57
> **Strategy:** stacked (1 branch, 7 commits = 7 items)

## Dependency Order

```
Pre-phase (SC-1, SC-2, SC-12)
  ├── Category A — Operational git commands (SC-3)
  ├── Category B — Compare URLs (SC-4)
  ├── Category C — Protected branch checks (SC-5)
  ├── Category D — SKILL.md DISPATCH_GATE text (SC-6)
  └── Category E — pre-work.md (SC-7)
        └── Post-phase (SC-8, SC-9, SC-10, SC-11)
```

Categories A–E are independent and may be parallelized. Post-phase depends on all five.

---

## Item 1: Pre-phase — Setup + Behavioral Test (RED)

**SC:** SC-1, SC-2, SC-12

| Step | Action | Verification |
|------|--------|-------------|
| RED-1 | Verify all 57 target files exist via `ls` | SC-1: all files confirmed non-empty |
| RED-2 | Verify category sets are disjoint — grep for file path overlap between A/B/C/D/E lists | SC-2: zero overlap |
| RED-3 | Write behavioral enforcement test at `.opencode/tests/behaviors/default-branch-replacement.sh` that sends a prompt triggering a git command referencing `dev` and asserts the agent uses `$DEFAULT_BRANCH` instead | SC-12: test FAILS (RED) before any source change |
| RED-4 | Run behavioral test to confirm RED state | `bash .opencode/tests/behaviors/default-branch-replacement.sh` exits non-zero |

---

## Item 2: Category A — Operational Git Commands (19 files)

**SC:** SC-3, SC-10

**Files:** `git-workflow/tasks/cleanup.md`, `git-workflow/tasks/rebase-pending.md`, `git-workflow/tasks/check-pr.md`, `git-workflow/tasks/pair-cleanup.md`, `git-workflow/tasks/pair-pr-creation.md`, `git-workflow/tasks/pair-mode-resume.md`, `git-workflow/tasks/commit-prep.md`, `git-workflow/tasks/pr-creation.md`, `git-workflow/tasks/pr-creation/enforcement-gate.md`, `git-workflow/tasks/review-prep.md`, `git-workflow/tasks/review-prep/push-and-cleanup.md`, `git-workflow/tasks/cleanup/verify-merge.md`, `finishing-a-development-branch/tasks/prepare.md`, `finishing-a-development-branch/tasks/checklist.md`, `pr-creation-workflow/tasks/pre-pr-checklist.md`, `approval-gate/tasks/post-implementation.md`, `approval-gate/tasks/pre-impl/write-work-state.md`, `approval-gate/tasks/verify-qa-mode.md`, `approval-gate/tasks/screen/screen-issue-gate2.md`

| Step | Action | Verification |
|------|--------|-------------|
| GREEN-1 | For each file: add `$DEFAULT_BRANCH` resolution pattern before first use, replace hardcoded `dev`/`origin/dev` with `$DEFAULT_BRANCH`/`origin/$DEFAULT_BRANCH` in git command contexts | Per-file diff review; confirm no prose `dev` over-replaced |
| VERIFY-1 | `grep -rn '\bdev\b'` on each Category A file — zero matches in git command contexts | SC-3 PASS |
| VERIFY-2 | `grep -rn 'DEFAULT_BRANCH='` on each Category A file — pattern present before first use | SC-10 PASS |

---

## Item 3: Category B — Compare URLs (6 files)

**SC:** SC-4, SC-10

**Files:** `completion-core/completion-core.md`, `completion-core/tasks/completion.md`, `completion-core/SKILL.md`, `finishing-a-development-branch/tasks/completion.md`, `git-workflow/tasks/review-prep/report-url.md`, `git-workflow/tasks/completion.md`

| Step | Action | Verification |
|------|--------|-------------|
| GREEN-2 | Replace `compare/dev...` with `compare/$DEFAULT_BRANCH...` in each file | Per-file diff review |
| VERIFY-3 | `grep -rn 'compare/dev'` on each Category B file — zero matches | SC-4 PASS |
| VERIFY-4 | `grep -rn 'DEFAULT_BRANCH='` on each Category B file — pattern present before first use | SC-10 PASS |

---

## Item 4: Category C — Protected Branch Checks (5 files)

**SC:** SC-5, SC-10

**Files:** `git-workflow/tasks/pair-commit.md`, `git-workflow/tasks/implementation.md`, `git-workflow/SKILL.md`, `issue-operations/platforms/local/SKILL.md`, `issue-operations/platforms/gitbucket-api/tasks/repository-operations.md`

| Step | Action | Verification |
|------|--------|-------------|
| GREEN-3 | Replace `"dev"` branch checks with `"$DEFAULT_BRANCH"` in each file | Per-file diff review |
| VERIFY-5 | `grep -rn '"dev"'` on each Category C file — zero matches in branch check contexts | SC-5 PASS |
| VERIFY-6 | `grep -rn 'DEFAULT_BRANCH='` on each Category C file — pattern present before first use | SC-10 PASS |

---

## Item 5: Category D — SKILL.md DISPATCH_GATE Example Text (26 files)

**SC:** SC-6, SC-10

**Files:** All 26 SKILL.md files across `.opencode/skills/*/SKILL.md`

| Step | Action | Verification |
|------|--------|-------------|
| GREEN-4 | Replace `"Step 1: sync dev. Step 2: delete branch."` with `"Step 1: sync $DEFAULT_BRANCH. Step 2: delete branch."` in all 26 SKILL.md files | Per-file diff review |
| VERIFY-7 | `grep -rn 'sync dev'` on all SKILL.md files — zero matches | SC-6 PASS |
| VERIFY-8 | `grep -rn 'DEFAULT_BRANCH='` on each Category D file — pattern present before first use | SC-10 PASS |

---

## Item 6: Category E — pre-work.md Non-Submodule References (1 file)

**SC:** SC-7, SC-10

**File:** `git-workflow/tasks/pre-work.md` (lines 22, 23, 268, 494, 516, 534 — use content-based matching)

| Step | Action | Verification |
|------|--------|-------------|
| GREEN-5 | Replace hardcoded `dev` references on specified lines (content-based match, not line-number-based) with `$DEFAULT_BRANCH` | Per-diff review; confirm submodule sync section (Step 3.5) untouched |
| VERIFY-9 | `grep -n '\bdev\b' pre-work.md` — only submodule sync section has `dev` references | SC-7 PASS |
| VERIFY-10 | `grep -rn 'DEFAULT_BRANCH='` on pre-work.md — pattern present before first use | SC-10 PASS |

---

## Item 7: Post-phase — Verification + Behavioral Test Regression (GREEN)

**SC:** SC-8, SC-9, SC-11

| Step | Action | Verification |
|------|--------|-------------|
| VERIFY-11 | `grep -rn '\bdev\b' .opencode/skills/` — review each match; classify as false positive or remediate | SC-8: zero actionable `dev` references remain |
| VERIFY-12 | Read each modified file; confirm `$DEFAULT_BRANCH` is used in valid bash/Markdown context | SC-9: no syntax errors |
| VERIFY-13 | Run behavioral test from Item 1: `bash .opencode/tests/behaviors/default-branch-replacement.sh` | SC-11: test PASSES (GREEN) — agent now uses `$DEFAULT_BRANCH` |
| VERIFY-14 | Run existing behavioral enforcement test suite: `bash .opencode/tests/test-enforcement.sh --changed` | SC-11: all PASS — no regression |

---

## Commit Strategy

| Commit | Items | Message |
|--------|-------|---------|
| 1 | Item 1 (RED test) | `test: add behavioral enforcement test for $DEFAULT_BRANCH replacement (#1676)` |
| 2 | Item 2 (Category A) | `fix: replace hardcoded dev with $DEFAULT_BRANCH in operational git commands (#1676)` |
| 3 | Item 3 (Category B) | `fix: replace compare/dev... with compare/$DEFAULT_BRANCH... (#1676)` |
| 4 | Item 4 (Category C) | `fix: replace dev branch checks with $DEFAULT_BRANCH (#1676)` |
| 5 | Item 5 (Category D) | `fix: update SKILL.md DISPATCH_GATE example text to use $DEFAULT_BRANCH (#1676)` |
| 6 | Item 6 (Category E) | `fix: replace dev references in pre-work.md non-submodule sections (#1676)` |
| 7 | Item 7 (Post-phase) | `chore: verify zero remaining dev references, syntax check, regression tests (#1676)` |

---

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Over-replacement of `dev` in prose | Per-diff review on every file; SC-8 grep sweep catches false positives |
| Missing `$DEFAULT_BRANCH` resolution | SC-10 mandates resolution pattern check on every modified file |
| Conflict with #1445 on pre-work.md | Category E explicitly excludes submodule sync section; verify with diff |
| Syntax errors from variable substitution | SC-9 mandates parse check on all modified files |
| Behavioral regression | SC-11 mandates running existing behavioral tests; RED/GREEN test catches regressions |
