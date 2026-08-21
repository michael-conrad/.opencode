---
plan_schema_version: 1
issue: 2307
title: "Fix hardcoded 'dev' base branch in construct_compare_url()"
phase_count: 2
dispatch:
  - test-driven-development
  - verification-before-completion
  - audit
  - finishing-a-development-branch
  - git-workflow-pr
  - completion-core
---

# Implementation Plan — Issue #2307

**Issue:** [\[BUG\] git-workflow/enforcement/url_validation.sh hardcodes base branch 'dev' instead of $DEFAULT_BRANCH](https://github.com/michael-conrad/.opencode/issues/2307)

## Goal

Fix `construct_compare_url()` in `.opencode/skills/git-workflow/enforcement/url_validation.sh` so it resolves the compare URL base from the remote HEAD branch (`$DEFAULT_BRANCH`) instead of the hardcoded `dev`, while preserving the explicit `--base` override, the `main` fallback convention, and the existing verification/error paths.

## Architecture

Replace the static `local base="dev"` default with dynamic remote HEAD branch resolution. Base resolution order: explicit `--base` override → dynamic remote HEAD branch (`git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p'`) → `main` fallback. The change is confined to the base defaulting logic in `construct_compare_url()`.

Two phases, one concern each:
- **Phase 1 (C1 — base-branch resolution):** SC-1, SC-2, SC-3 — implement dynamic resolution, preserve `--base` override, add `main` fallback. Three items, each with its own RED/GREEN/verify/commit cycle.
- **Phase 2 (C2 — URL construction and verification):** SC-4 — regression guard asserting `set -euo pipefail`, owner/repo character-match checks, and error returns remain intact after the Phase 1 change.

Phase 2 depends on Phase 1 (the regression guard runs against the post-change function). The phase DAG has one edge: Phase 1 → Phase 2.

## Files

- `.opencode/skills/git-workflow/enforcement/url_validation.sh` — SC-1, SC-2, SC-3, SC-4 source of the base resolution change
- Behavioral test artifact(s) exercising `construct_compare_url` — SC-1, SC-2, SC-3, SC-4

## Dispatch

- `test-driven-development` — RED, GREEN, post-regression, regression-check
- `verification-before-completion` — verify, pre-pr-gate
- `audit` — verification-audit DiMo chain
- `finishing-a-development-branch` — structural-checks
- `git-workflow-pr` — review-prep, create-pr
- `completion-core` — exec-summary

## Blast Radius

Confined to the base defaulting logic inside `construct_compare_url()` in `url_validation.sh`. No URL template change, no `validate_pr_body()` change, no caller interface change. The function's public interface `construct_compare_url --owner --repo --branch [--base]` is unchanged. The behavioral surface is the shell test asserting the resolved base under each of the four SC scenarios.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Dispatch |
|-------|------|---------|-----|--------------|----------|
| 1 | Dynamic base branch resolution | Replace hardcoded `dev` with `$DEFAULT_BRANCH` | SC-1, SC-2, SC-3 | none | test-driven-development, verification-before-completion |
| 2 | URL construction and verification regression guard | Preserve verification/error handling after base resolution change | SC-4 | 1 | test-driven-development, verification-before-completion |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Phase Details

### Phase 1 — Dynamic base branch resolution

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`, `green`, `post-regression`, `verify` |
| Target | `.opencode/skills/git-workflow/enforcement/url_validation.sh` base defaulting logic |
| SCs | SC-1, SC-2, SC-3 |
| Depends On | — |

**Concern (C1):** Base-branch resolution — dynamic `$DEFAULT_BRANCH` + `main` fallback + `--base` override, isolated from URL construction and character-match verification.

See [`plan-01-base-branch-resolution.md`](plan-01-base-branch-resolution.md).

### Phase 2 — URL construction and verification regression guard

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`, `green`, `post-regression`, `verify` |
| Target | `.opencode/skills/git-workflow/enforcement/url_validation.sh` verification/error paths |
| SCs | SC-4 |
| Depends On | 1 |

**Concern (C2):** URL construction and verification — preserve `set -euo pipefail`, owner/repo character-match checks, and error returns (unchanged, SC-4).

See [`plan-02-url-construction-verification.md`](plan-02-url-construction-verification.md).

## Exit Criteria

- [ ] C1. SC-1: `construct_compare_url` resolves the base from the remote HEAD branch (e.g. `master`), not `dev`.
- [ ] C2. SC-2: an explicit `--base` argument overrides the dynamically resolved default branch.
- [ ] C3. SC-3: when the remote HEAD branch cannot be determined, the base falls back to `main`.
- [ ] C4. SC-4: `set -euo pipefail`, owner/repo character-match verification, and error returns remain intact.
- [ ] C5. All four items committed as atomic slices.
- [ ] C6. Audit, structural checks, regression check, review-prep, and PR creation complete.

---

## Pre-Implementation

- [ ] 1. **Coherence gate.** Verify the spec is coherent and all four SCs are traceable to requirements. Confirm the phase DAG has no circular dependencies (contract edges: `phase_1 → phase_2`). (**inline**)
  - Confirm SC-1, SC-2, SC-3 map to exactly one item in Phase 1 and SC-4 maps to exactly one item in Phase 2.
  - Confirm no item covers multiple SCs.
- [ ] 2. **Baseline check.** Verify the working tree is clean and the branch is at the remote trunk tip before any file modification. (**inline**)
  - Run `git status` and confirm zero pending changes.
  - Confirm the branch is at `origin/$DEFAULT_BRANCH` tip.

---

## Post-Implementation

- [ ] 1. **Audit.** Run the adversarial verification-audit DiMo chain on the deliverable. (**sub-agent**)
  - Dispatch the verification-audit investigator, then validator, evaluator, arbiter in sequence.
- [ ] 2. **Z3 check.** Run the Z3 constraint solver verification. (**inline**)
  - Run `.opencode/tools/solve check --state-path ... --contract-path ...`.
- [ ] 3. **Structural checks.** Run the finishing checklist (lint, typecheck, etc.). (**sub-agent**)
  - Dispatch the checklist task from finishing-a-development-branch.
- [ ] 4. **Pre-PR gate.** Verify all SC verdicts before PR creation. (**sub-agent**)
  - Read all SC verdicts; BLOCK if any FAIL.
- [ ] 5. **Regression check.** Run the final regression check before PR. (**sub-agent**)
- [ ] 6. **Review-prep.** Prepare PR review context. (**sub-agent**)
- [ ] 7. **Create PR.** Create the pull request. (**sub-agent**)
- [ ] 8. **Exec summary.** Generate the completion executive summary. (**sub-agent**)

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Lifecycle Events

- `2026-08-21T01:17:00Z` — **plan_created** — plan at `.opencode/.issues/2307/plan.md`, 1 phase.
- `2026-08-21T01:28:00Z` — **plan_revised** — split single phase into Phase 1 (C1 base-branch resolution, SC-1..SC-3) and Phase 2 (C2 URL construction/verification, SC-4) to resolve concern-separation finding F1.
- `2026-08-21T05:35:46Z` — **plan_created** — final plan verified at `.opencode/.issues/2307/plan.md`, 2 phases (Phase 1: base-branch resolution; Phase 2: URL construction/verification regression guard).
