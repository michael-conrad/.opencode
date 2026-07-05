# [SPEC] Replace hardcoded dev branch references with $DEFAULT_BRANCH across skills tree

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| **Problem Statement** | ~180+ hardcoded `dev` branch references across 30+ skill files. Under trunk-based development, `dev` does not exist — the trunk is whatever the remote's HEAD branch points to. Every hardcoded `dev` reference is a latent defect. |
| **Root Cause / Motivation** | The skills tree was written when `dev` was the trunk branch. After migrating to trunk-based development (`main` as trunk), the skill files were not updated. The canonical `$DEFAULT_BRANCH` resolution pattern already exists in `pre-work.md` but is not applied consistently. |
| **Approach Chosen** | Mechanical find-and-replace: replace all hardcoded `dev` references with `$DEFAULT_BRANCH` using the canonical resolution pattern. Five categories (A-E) across 57 files. |
| **Alternatives Considered & Why Discarded** | Creating a shared utility script for branch resolution — over-engineered for a mechanical find-and-replace. The inline pattern is already established and proven. |
| **Key Design Decisions** | Use the exact same variable name (`$DEFAULT_BRANCH`) and resolution pattern as `pre-work.md` for consistency. No new abstractions. |

## Objective

Replace all hardcoded `dev` branch references in the `.opencode/skills/` tree with dynamic `$DEFAULT_BRANCH` resolution, using the canonical pattern from `pre-work.md`. This ensures all git operations target the correct trunk branch regardless of whether it is named `main`, `master`, or something else.

## Problem

The git-workflow skill and related skills contain ~180+ hardcoded `dev` branch references across 30+ files. Under trunk-based development, `dev` does not exist — the trunk is whatever the remote's HEAD branch points to. The canonical resolution pattern already exists in `pre-work.md`:

```bash
DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
if [ -z "$DEFAULT_BRANCH" ]; then DEFAULT_BRANCH="main"; fi
```

Every hardcoded `dev` reference is a latent defect: it will silently break or produce incorrect behavior on any repo whose trunk is not named `dev`.

## Affected Files

### Category A — Operational Git Commands (19 files)

| File | References |
|------|------------|
| `git-workflow/tasks/cleanup.md` | ~7 hardcoded `dev`/`origin/dev` |
| `git-workflow/tasks/rebase-pending.md` | ~12 hardcoded references |
| `git-workflow/tasks/check-pr.md` | ~4 hardcoded references |
| `git-workflow/tasks/pair-cleanup.md` | 2 hardcoded references |
| `git-workflow/tasks/pair-pr-creation.md` | 3 hardcoded references |
| `git-workflow/tasks/pair-mode-resume.md` | 1 hardcoded reference |
| `git-workflow/tasks/commit-prep.md` | 3 hardcoded references |
| `git-workflow/tasks/pr-creation.md` | 3 hardcoded references |
| `git-workflow/tasks/pr-creation/enforcement-gate.md` | 3 hardcoded references |
| `git-workflow/tasks/review-prep.md` | 2 hardcoded references |
| `git-workflow/tasks/review-prep/push-and-cleanup.md` | 4 hardcoded references |
| `git-workflow/tasks/cleanup/verify-merge.md` | 3 hardcoded references |
| `finishing-a-development-branch/tasks/prepare.md` | ~8 hardcoded references |
| `finishing-a-development-branch/tasks/checklist.md` | 2 hardcoded references |
| `pr-creation-workflow/tasks/pre-pr-checklist.md` | 4 hardcoded references |
| `approval-gate/tasks/post-implementation.md` | 2 hardcoded references |
| `approval-gate/tasks/pre-impl/write-work-state.md` | 5 hardcoded references |
| `approval-gate/tasks/verify-qa-mode.md` | 3 hardcoded references |
| `approval-gate/tasks/screen/screen-issue-gate2.md` | 1 hardcoded reference |

### Category B — Compare URLs (6 files)

| File | References |
|------|------------|
| `completion-core/completion-core.md` | 2 hardcoded `compare/dev...` |
| `completion-core/tasks/completion.md` | 2 hardcoded `compare/dev...` |
| `completion-core/SKILL.md` | 2 hardcoded `compare/dev...` |
| `finishing-a-development-branch/tasks/completion.md` | 3 hardcoded `compare/dev...` |
| `git-workflow/tasks/review-prep/report-url.md` | 3 hardcoded `compare/dev...` |
| `git-workflow/tasks/completion.md` | 1 hardcoded `compare/dev...` |

### Category C — Protected Branch Checks (5 files)

| File | References |
|------|------------|
| `git-workflow/tasks/pair-commit.md` | 1 hardcoded `dev` in branch check |
| `git-workflow/tasks/implementation.md` | 2 hardcoded `dev` in branch checks |
| `git-workflow/SKILL.md` | 4 hardcoded `dev` references |
| `issue-operations/platforms/local/SKILL.md` | 1 hardcoded `dev` reference |
| `issue-operations/platforms/gitbucket-api/tasks/repository-operations.md` | 1 hardcoded `dev` reference |

### Category D — SKILL.md DISPATCH_GATE Example Text (26 files)

All 26 SKILL.md files contain the identical example text: `"Step 1: sync dev. Step 2: delete branch."` in their DISPATCH_GATE tables. Replace with `"Step 1: sync $DEFAULT_BRANCH. Step 2: delete branch."`.

### Category E — pre-work.md Non-Submodule References (1 file, 6 lines)

Lines 22, 23, 268, 494, 516, 534 in `pre-work.md` contain hardcoded `dev` references that are NOT in the submodule sync section (covered by #1445).

## Success Criteria

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

| ID | Criterion | Evidence Type | Verification Method | Remediation |
|----|-----------|---------------|---------------------|-------------|
| SC-1 | Pre-phase setup: all 57 target files verified to exist before any modification | semantic | `ls` each file path; confirm non-empty | HALT if any file missing; report which file |
| SC-2 | Pre-phase coherence: no file is listed in more than one category (sets are disjoint) | string | `grep` for file path overlap between category lists | HALT if overlap detected; reclassify file to single category |
| SC-3 | Category A: all operational git commands use `$DEFAULT_BRANCH` instead of hardcoded `dev` | string | `grep -rn '\bdev\b'` on each Category A file; confirm zero matches in git command contexts | Remediate remaining references per file |
| SC-4 | Category B: all compare URLs use `$DEFAULT_BRANCH` instead of `dev` | string | `grep -rn 'compare/dev'` on each Category B file; confirm zero matches | Remediate remaining references per file |
| SC-5 | Category C: all protected branch checks use `$DEFAULT_BRANCH` instead of `dev` | string | `grep -rn '\"dev\"'` on each Category C file; confirm zero matches in branch check contexts | Remediate remaining references per file |
| SC-6 | Category D: all 26 SKILL.md files have updated DISPATCH_GATE example text | string | `grep -rn 'sync dev'` on all SKILL.md files; confirm zero matches | Remediate remaining files |
| SC-7 | Category E: pre-work.md non-submodule `dev` references replaced | string | `grep -n '\bdev\b' pre-work.md`; confirm only submodule sync section (Step 3.5) has `dev` references | Remediate remaining references |
| SC-8 | Post-phase: zero hardcoded `dev` references remain in any modified file (excluding known false positives) | string | `grep -rn '\bdev\b' .opencode/skills/`; review each match for false positive classification | Remediate each remaining reference |
| SC-9 | All modified files parse correctly (no syntax errors from variable substitution) | semantic | Read each modified file; confirm `$DEFAULT_BRANCH` is used in valid bash/Markdown context | Fix syntax errors per file |
| SC-10 | The `$DEFAULT_BRANCH` resolution pattern is present in every file that uses it | string | `grep -rn 'DEFAULT_BRANCH='` on each modified file; confirm pattern present before first use | Add resolution pattern to file |
| SC-11 | No behavioral regression: existing workflows that depend on `dev` behavior continue to work | behavioral | Run existing behavioral enforcement tests; confirm all PASS | Diagnose and fix regression |
| SC-12 | Before any implementation, write behavioral enforcement tests in `.opencode/tests/behaviors/` that verify the new rule; confirm RED state (test fails before change) | behavioral | Behavioral test exists and fails before implementation | Create behavioral test before any source changes |

## Non-Goals

- **Submodule sync task files** (`pre-work.md` Step 3.5, `branch-cleanup.md` Step 1.9, `submodule-sync.md`) — covered by #1445
- **Pre-push hook Gate 1** — covered by #1632
- **Renaming the trunk branch in actual remote repositories** — out of scope
- **Adding new git commands or workflows** — scope is strictly find-and-replace
- **Updating behavioral enforcement tests** — SC-12 mandates test creation, but the tests themselves are written during implementation

## Edge Cases

- **No remote available**: `git remote show origin` fails → fallback to `"main"`. This is safe.
- **Local-only repos**: Same fallback applies. No behavioral change.
- **`dev` in non-branch contexts**: The word "dev" appears in prose (e.g., "development", "dev-pair", "dev branch" as descriptive text). Each replacement MUST be verified against context to avoid over-replacement.
- **Line number drift in pre-work.md**: Category E references specific line numbers. If lines have shifted, use content-based matching instead.

## Dependencies

| Dependency | Impact |
|------------|--------|
| #1445 (submodule sync fix) | Must not conflict — Category E explicitly excludes submodule sync section |
| #1632 (pre-push Gate 1 redesign) | Must not conflict — pre-push hook is out of scope |

## Risk Analysis

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Over-replacement of `dev` in non-branch contexts (prose, descriptions) | Medium | Medium | Per-diff review during implementation; post-phase grep sweep | SC-8 |
| RISK-2 | Missing `$DEFAULT_BRANCH` resolution in a file that uses it | Low | High | SC-10 mandates resolution pattern presence check | SC-10 |
| RISK-3 | Conflict with #1445 on pre-work.md changes | Low | High | Category E explicitly excludes submodule sync section; verify with diff | SC-7 |
| RISK-4 | Syntax error from variable substitution in bash context | Low | Medium | SC-9 mandates parse check on all modified files | SC-9 |
| RISK-5 | Behavioral regression in existing workflows | Low | High | SC-11 mandates running existing behavioral tests | SC-11 |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Use `$DEFAULT_BRANCH` variable name (not a different name) | Must match canonical pattern from `pre-work.md` for consistency | MUST | SC-3 through SC-10 |
| DEC-2 | Include fallback to `"main"` when `git remote show origin` fails | Handles local-only repos and offline scenarios | MUST | SC-10 |
| DEC-3 | Category D example text uses `$DEFAULT_BRANCH` as prose (not runtime variable) | The DISPATCH_GATE example is documentation, not executable code | SHOULD | SC-6 |
| DEC-4 | No shared utility script for branch resolution | The inline pattern is already established and proven; a shared utility is over-engineering | MUST NOT | SC-10 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Decomposition Classification

**Multi-phase spec** — 7 phases (1 pre, 5 per-file, 1 post).

## Regression Invariants

1. Existing behavioral enforcement tests MUST continue to pass (SC-11)
2. No file outside the 57 target files MUST be modified
3. The `$DEFAULT_BRANCH` resolution pattern MUST be identical across all files — same variable name, same fallback

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep -rn '\bdev\b' .opencode/skills/` | Identify all hardcoded `dev` references |
| Direct source search | `grep -rn 'DEFAULT_BRANCH' .opencode/skills/` | Identify existing resolution pattern usage |
| MCP search | `srclight_search_symbols("DEFAULT_BRANCH")` | Verify canonical pattern location |
| Local docs | `pre-work.md` lines 86-93 | Extract canonical resolution pattern |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
