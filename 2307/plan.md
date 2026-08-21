---
plan_schema_version: 1
issue: 2307
title: "Fix hardcoded 'dev' base branch in construct_compare_url()"
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

Replace the static `local base="dev"` default with dynamic remote HEAD branch resolution. Base resolution order: explicit `--base` override → dynamic remote HEAD branch (`git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p'`) → `main` fallback. The change is confined to the base defaulting logic in `construct_compare_url()`. A single implementation phase covers all four SCs — each SC is one item with its own RED/GREEN/verify/commit cycle. The phase DAG has no edges (single leaf phase).

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
| 1 | Dynamic base branch resolution | Replace hardcoded `dev` with `$DEFAULT_BRANCH` | SC-1, SC-2, SC-3, SC-4 | none | test-driven-development, verification-before-completion |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- [ ] C1. SC-1: `construct_compare_url` resolves the base from the remote HEAD branch (e.g. `master`), not `dev`.
- [ ] C2. SC-2: an explicit `--base` argument overrides the dynamically resolved default branch.
- [ ] C3. SC-3: when the remote HEAD branch cannot be determined, the base falls back to `main`.
- [ ] C4. SC-4: `set -euo pipefail`, owner/repo character-match verification, and error returns remain intact.
- [ ] C5. All four items committed as atomic slices.
- [ ] C6. Audit, structural checks, regression check, review-prep, and PR creation complete.

---

## Pre-Implementation

- [ ] 1. **Coherence gate.** Verify the spec is coherent and all four SCs are traceable to requirements. Confirm the phase DAG has no circular dependencies (contract edges: `[]`). (**inline**)
  - Confirm SC-1, SC-2, SC-3, SC-4 each map to exactly one item in Phase 1.
  - Confirm no item covers multiple SCs.
- [ ] 2. **Baseline check.** Verify the working tree is clean and the branch is at the remote trunk tip before any file modification. (**inline**)
  - Run `git status` and confirm zero pending changes.
  - Confirm the branch is at `origin/$DEFAULT_BRANCH` tip.

---

## Phase 1 — Dynamic base branch resolution (SC-1, SC-2, SC-3, SC-4)

**Concern:** Replace the hardcoded `local base="dev"` default in `construct_compare_url()` with dynamic remote HEAD branch resolution (`$DEFAULT_BRANCH`), preserving the explicit `--base` override, the `main` fallback, and the existing verification/error paths.

**Files:** `.opencode/skills/git-workflow/enforcement/url_validation.sh`, behavioral test artifact(s)

**SCs:** SC-1, SC-2, SC-3, SC-4

**Dependencies:** none

**Entry condition:** Coherence gate and baseline check passed.

**Exit condition:** All four SCs verified PASS; `construct_compare_url` resolves the base per resolution order and preserves verification/error handling.

**Code Path Coverage:** `construct_compare_url()` in `url_validation.sh` — base defaulting (`local base="dev"` line 18), `--base` case assignment, URL template construction, owner/repo character-match verification, missing-arg error return.

**Cross-Cutting SCs:** SC-1, SC-2, SC-3, SC-4 all concern the same function; they are handled as separate items within this single phase. SC-4 is the regression guard over the whole function.

**Interface Boundaries:** `construct_compare_url --owner --repo --branch [--base]` sourceable shared module interface (IF-1). The base resolution order (override → dynamic → `main`) is the target state. No caller signature change.

**State Transitions:** ST-1 — base from hardcoded `dev` → base from dynamic `$DEFAULT_BRANCH` with `--base` override and `main` fallback.

**Cost frame:** Running the behavioral shell test for each item costs minutes of execution time. Skipping SC-1 means every PR compare URL targets the non-existent `dev` branch until discovered downstream; skipping the regression guard SC-4 means the verification/error handling silently regresses while the URLs pass structural checks.

### Item 1 (SC-1)

- [ ] 1. **RED — write the failing behavioral assertion.** Write a behavioral shell test asserting `construct_compare_url` resolves the base from the remote HEAD branch instead of `dev`. (**sub-agent**)
  - Set up a controlled git remote whose HEAD branch is `master`.
  - Invoke `construct_compare_url --owner o --repo r --branch b`.
  - The test must FAIL because the base is currently hardcoded to `dev`.
- [ ] 2. **GREEN — resolve the base dynamically.** Replace `local base="dev"` with dynamic remote HEAD branch resolution. (**sub-agent**)
  - Resolve via `DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')`.
  - Use the resolved `$DEFAULT_BRANCH` as the base when no `--base` override was supplied.
- [ ] 3. **Post-regression.** Run regression test patterns after the GREEN change. (**sub-agent**)
- [ ] 4. **Verify.** Verify the implementation against SC-1. (**sub-agent**)
  - Run the behavioral shell test with a remote whose HEAD branch is `master`.
  - Assert the produced URL uses `master` as the base.
- [ ] 5. **Commit.** Stage and commit the base resolution change together with the behavioral test as one atomic slice. (**inline**)
  - `git add <files> && git commit -m "<message>"`.

**Phase completion:** SC-1 verified PASS. `construct_compare_url` resolves the base from the remote HEAD branch, not `dev`.

### Item 2 (SC-2)

- [ ] 1. **RED — write the failing behavioral assertion.** Write a behavioral shell test asserting an explicit `--base` argument overrides the resolved default branch. (**sub-agent**)
  - Invoke `construct_compare_url --owner o --repo r --branch b --base dev`.
  - The test must FAIL if the override is removed by the dynamic resolution change.
- [ ] 2. **GREEN — preserve the `--base` override.** Ensure the `--base) base="$2"` assignment takes precedence over dynamic resolution. (**sub-agent**)
  - The explicit `--base` override must win over the resolved `$DEFAULT_BRANCH`.
- [ ] 3. **Post-regression.** Run regression test patterns after the GREEN change. (**sub-agent**)
- [ ] 4. **Verify.** Verify the implementation against SC-2. (**sub-agent**)
  - Run the behavioral shell test with `--base dev`.
  - Assert the produced URL uses `dev` as the base.
- [ ] 5. **Commit.** Stage and commit the override-preservation change together with the behavioral test as one atomic slice. (**inline**)
  - `git add <files> && git commit -m "<message>"`.

**Phase completion:** SC-2 verified PASS. An explicit `--base` override takes precedence.

### Item 3 (SC-3)

- [ ] 1. **RED — write the failing behavioral assertion.** Write a behavioral shell test asserting the base falls back to `main` when the remote HEAD branch cannot be determined. (**sub-agent**)
  - Invoke `construct_compare_url` with no remote configured.
  - The test must FAIL if there is no `main` fallback.
- [ ] 2. **GREEN — add the `main` fallback.** Add the fallback when remote HEAD branch resolution is empty. (**sub-agent**)
  - Add `if [ -z "$DEFAULT_BRANCH" ]; then DEFAULT_BRANCH="main"; fi`.
- [ ] 3. **Post-regression.** Run regression test patterns after the GREEN change. (**sub-agent**)
- [ ] 4. **Verify.** Verify the implementation against SC-3. (**sub-agent**)
  - Run the behavioral shell test with no remote configured.
  - Assert the produced URL uses `main` as the base.
- [ ] 5. **Commit.** Stage and commit the fallback change together with the behavioral test as one atomic slice. (**inline**)
  - `git add <files> && git commit -m "<message>"`.

**Phase completion:** SC-3 verified PASS. Base falls back to `main` when the remote HEAD branch is undeterminable.

### Item 4 (SC-4)

- [ ] 1. **RED — write the failing behavioral regression assertion.** Write a behavioral regression test asserting `set -euo pipefail`, owner/repo character-match checks, and error returns still work. (**sub-agent**)
  - The test must FAIL if the base resolution change regresses verification/error handling.
- [ ] 2. **GREEN — preserve verification and error handling.** Ensure the base resolution change does not alter the verification/error paths. (**sub-agent**)
  - Retain `set -euo pipefail`.
  - Retain the owner/repo character-match checks and the ERROR + exit 1 returns on missing args and on mismatch.
- [ ] 3. **Post-regression.** Run regression test patterns after the GREEN change. (**sub-agent**)
- [ ] 4. **Verify.** Verify the implementation against SC-4. (**sub-agent**)
  - Run the behavioral regression test with missing args and with owner/repo not in URL.
  - Assert ERROR + exit 1 on both, and assert `set -euo pipefail` is retained.
- [ ] 5. **Commit.** Stage and commit the regression-guard test together with any verification-preserving change as one atomic slice. (**inline**)
  - `git add <files> && git commit -m "<message>"`.

**Phase completion:** SC-4 verified PASS. Verification/error handling intact after the base resolution change.

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
