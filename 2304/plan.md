---
plan_schema_version: 1
issue: 2304
title: "Standardize remote branch-tip terminology across skilldeck and guidelines"
dispatch:
  - test-driven-development
  - verification-before-completion
  - audit
  - finishing-a-development-branch
  - git-workflow-pr
  - completion-core
---

# Implementation Plan — Issue #2304

**Issue:** [Standardize remote branch-tip terminology across skilldeck and guidelines](https://github.com/michael-conrad/.opencode/issues/2304)

## Goal

Perform a holistic documentation-only terminology sweep across `.opencode/skills/`, `.opencode/guidelines/`, `.opencode/commands/`, and `AGENTS.md`. Every unqualified branch-tip reference (`trunk tip`, `dev tip`, `feature-branch tip`, hardcoded `dev`/`master`) is standardized to `remote trunk tip` / `remote $DEFAULT_BRANCH tip` / `origin/$DEFAULT_BRANCH` so the agent always reads that the remote `origin/` tip is authoritative. The verification enforcement logic in `trunk-tip-verification.md` Steps 3/6 remains byte-identical.

## Architecture

Documentation-only prose rewrite. No code, config, or workflow behavior change. Four independent leaf phases, one per SC, no inter-phase dependency.

## Files

- `.opencode/skills/` — SC-1, SC-2 scan + sweep targets
- `.opencode/guidelines/` — SC-1, SC-2 scan + sweep targets
- `.opencode/commands/` — SC-1, SC-2 scan + sweep targets
- `AGENTS.md` — SC-1, SC-2 scan + sweep target
- `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md` — SC-3 baseline (Steps 3/6 byte-identical)
- `.opencode/tests-v2/behaviors/2304-*.sh` — SC-4 behavioral regression scenario

## Dispatch

- `test-driven-development` — RED, GREEN, post-regression, regression-check
- `verification-before-completion` — verify, pre-pr-gate
- `audit` — verification-audit DiMo chain
- `finishing-a-development-branch` — structural-checks
- `git-workflow-pr` — review-prep, create-pr
- `completion-core` — exec-summary

## Blast Radius

Documentation-only sweep. Affected impact zones: skilldeck prose, guideline prose, command prose, and `AGENTS.md` prose. No runtime behavior change. The only behavioral surface is SC-4's new tests-v2 scenario, which asserts the agent consults `origin/$DEFAULT_BRANCH`. Enforcement logic in `trunk-tip-verification.md` Steps 3/6 is guarded byte-identical by SC-3.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Dispatch |
|-------|------|---------|-----|--------------|----------|
| 1 | Structural scan gate | Zero unqualified branch-tip references | SC-1 | none | test-driven-development, verification-before-completion |
| 2 | Remote-qualify trunk tip prose | All `trunk tip` prose remote-prefixed | SC-2 | none | test-driven-development, verification-before-completion |
| 3 | Steps 3/6 byte-identical guard | No git command altered | SC-3 | none | test-driven-development, verification-before-completion |
| 4 | Behavioral regression guard | Agent consults `origin/$DEFAULT_BRANCH` | SC-4 | none | test-driven-development, verification-before-completion |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- [ ] C1. SC-1: `rg` scan across the four directories returns zero unqualified branch-tip references.
- [ ] C2. SC-2: `rg -i 'trunk tip'` returns only remote-qualified sites.
- [ ] C3. SC-3: `trunk-tip-verification.md` Steps 3/6 byte-identical to pre-change state.
- [ ] C4. SC-4: behavioral tests-v2 scenario asserts agent consults `origin/$DEFAULT_BRANCH`.
- [ ] C5. All four phases committed as atomic slices.
- [ ] C6. Audit, structural checks, regression check, review-prep, and PR creation complete.

---

## Pre-Implementation

- [ ] 1. **Coherence gate.** Verify the spec is coherent and all four SCs are traceable to requirements. Confirm the phase DAG has no circular dependencies (contract edges: `[]`). (**inline**)
  - Confirm SC-1, SC-2, SC-3, SC-4 each map to exactly one phase.
  - Confirm no item covers multiple SCs.
- [ ] 2. **Baseline check.** Verify the working tree is clean and the branch is at the remote trunk tip before any file modification. (**inline**)
  - Run `git status` and confirm zero pending changes.
  - Confirm the branch is at `origin/$DEFAULT_BRANCH` tip.

---

## Phase 1 — Structural scan gate (SC-1)

**Concern:** Zero unqualified branch-tip references across `.opencode/skills/`, `.opencode/guidelines/`, `.opencode/commands/`, and `AGENTS.md`.

**Files:** `.opencode/skills/`, `.opencode/guidelines/`, `.opencode/commands/`, `AGENTS.md`

**SCs:** SC-1

**Dependencies:** none

**Entry condition:** Coherence gate and baseline check passed.

**Exit condition:** `rg` scan returns zero unqualified branch-tip references.

**Code Path Coverage:** Prose scan of the four directories for `trunk tip`, `dev tip`, `feature-branch tip`, and hardcoded `dev`/`master` branch-tip names.

**Cross-Cutting SCs:** none — SC-1 is a leaf.

**Interface Boundaries:** skilldeck + guidelines prose → agent reading context (IF-1). Documentation-only prose rewrite; no command, config, or workflow behavior change.

**State Transitions:** ST-1 — from unqualified references present to zero unqualified references remaining.

**Cost frame:** Running the rg scan costs seconds. Skipping means a missed unqualified site ships, the prose still says "trunk tip", and the agent starts from a stale local base — the exact defect the gate prevents.

### Item 1 (SC-1)

- [ ] 1. **RED — write the failing scan assertion.** Write an enforcement scan that asserts zero unqualified branch-tip references across the four directories. (**sub-agent**)
  - The scan must FAIL because unqualified `trunk tip`, `dev tip`, `feature-branch tip`, and hardcoded `dev`/`master` references are currently present.
  - Use `rg -i 'trunk tip|dev tip|feature-branch tip'` plus a hardcoded `dev`/`master` branch-tip assertion.
- [ ] 2. **GREEN — perform the sweep.** Standardize every unqualified branch-tip reference to the remote-qualified form. (**sub-agent**)
  - `trunk tip` → `remote trunk tip` / `remote $DEFAULT_BRANCH tip`.
  - `dev tip` and hardcoded `dev`/`master` → `remote $DEFAULT_BRANCH tip` / `$DEFAULT_BRANCH` / `origin/$DEFAULT_BRANCH`.
  - `feature-branch tip` → `remote feature branch tip` / `remote $DEFAULT_BRANCH tip`.
  - Align all sites with the model pattern in `create-pr.md` and `enforcement-gate.md`.
- [ ] 3. **Post-regression.** Run regression test patterns after the GREEN change. (**sub-agent**)
- [ ] 4. **Verify.** Verify the implementation against SC-1. (**sub-agent**)
  - Run the rg scan across the four directories.
  - Assert zero unqualified matches remain.
- [ ] 5. **Commit.** Stage and commit the scan assertion together with the sweep changes as one atomic slice. (**inline**)
  - `git add <files> && git commit -m "<message>"`.

**Phase completion:** SC-1 verified PASS. `rg` scan returns zero unqualified branch-tip references.

---

## Phase 2 — Remote-qualify trunk tip prose (SC-2)

**Concern:** All `trunk tip` prose standardized to `remote trunk tip` / `remote $DEFAULT_BRANCH tip`.

**Files:** `.opencode/skills/`, `.opencode/guidelines/`, `.opencode/commands/`, `AGENTS.md`

**SCs:** SC-2

**Dependencies:** none

**Entry condition:** Coherence gate and baseline check passed.

**Exit condition:** `rg -i 'trunk tip'` returns only remote-qualified sites.

**Code Path Coverage:** Prose scan of the four directories for `trunk tip` sites.

**Cross-Cutting SCs:** none — SC-2 is a leaf.

**Interface Boundaries:** skilldeck + guidelines prose → agent reading context (IF-1). Aligns with the existing model pattern in `create-pr.md` ("remote trunk tip SHA") and `enforcement-gate.md` ("remote trunk HEAD SHAs").

**State Transitions:** ST-2 — from `trunk tip` prose unqualified to all `trunk tip` prose remote-qualified.

**Cost frame:** Standardizing the prose costs one per-site edit plus a grep. Skipping leaves the 21 unqualified `trunk tip` sites that let agents treat the local tip as authoritative.

### Item 2 (SC-2)

- [ ] 1. **RED — write the failing scan assertion.** Write an enforcement scan that asserts all `trunk tip` prose is remote-qualified. (**sub-agent**)
  - The scan must FAIL because `rg 'trunk tip'` currently returns unqualified sites.
- [ ] 2. **GREEN — remote-prefix all `trunk tip` prose.** Standardize every `trunk tip` site to `remote trunk tip` / `remote $DEFAULT_BRANCH tip`. (**sub-agent**)
  - Align with the model pattern in `create-pr.md` and `enforcement-gate.md`.
- [ ] 3. **Post-regression.** Run regression test patterns after the GREEN change. (**sub-agent**)
- [ ] 4. **Verify.** Verify the implementation against SC-2. (**sub-agent**)
  - Run `rg -i 'trunk tip'`.
  - Assert only remote-qualified matches remain.
- [ ] 5. **Commit.** Stage and commit the `trunk tip` prose sweep changes as one atomic slice. (**inline**)
  - `git add <files> && git commit -m "<message>"`.

**Phase completion:** SC-2 verified PASS. `rg -i 'trunk tip'` returns only remote-qualified sites.

---

## Phase 3 — Steps 3/6 byte-identical guard (SC-3)

**Concern:** `trunk-tip-verification.md` Steps 3/6 remain byte-identical to pre-change state.

**Files:** `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md`

**SCs:** SC-3

**Dependencies:** none

**Entry condition:** Coherence gate and baseline check passed.

**Exit condition:** `git diff` scoped to `trunk-tip-verification.md` proves only prose lines changed; Steps 3/6 git commands unchanged.

**Code Path Coverage:** `trunk-tip-verification.md` Steps 3/6 fetch+compare against `origin/$DEFAULT_BRANCH`.

**Cross-Cutting SCs:** none — SC-3 is a leaf.

**Interface Boundaries:** trunk-tip-verification.md Steps 3/6 fetch+compare (IF-2). Target state unchanged (byte-identical); only prose lines change.

**State Transitions:** ST-3 — from Steps 3/6 baseline (pre-sweep) to Steps 3/6 byte-identical to pre-change state.

**Cost frame:** Verifying Steps 3/6 unchanged costs a scoped `git diff`. Skipping risks a prose edit silently altering a git command, turning a documentation sweep into a behavioral defect.

### Item 3 (SC-3)

- [ ] 1. **RED — write the failing guard assertion.** Write an assertion that detects any alteration to Steps 3/6 git commands. (**sub-agent**)
  - The assertion must FAIL if a Step 3/6 git command has been altered from the pre-change baseline.
- [ ] 2. **GREEN — confirm Steps 3/6 byte-identical.** Confirm the sweep left Steps 3/6 byte-identical to pre-change state. (**sub-agent**)
  - Only prose lines in `trunk-tip-verification.md` may change; no git command altered.
- [ ] 3. **Post-regression.** Run regression test patterns after the GREEN change. (**sub-agent**)
- [ ] 4. **Verify.** Verify the implementation against SC-3. (**sub-agent**)
  - Run a `git diff` scoped to `trunk-tip-verification.md`.
  - Assert Steps 3/6 git commands unchanged.
- [ ] 5. **Commit.** Stage and commit the guard assertion as one atomic slice. (**inline**)
  - `git add <files> && git commit -m "<message>"`.

**Phase completion:** SC-3 verified PASS. Steps 3/6 byte-identical to pre-change state.

---

## Phase 4 — Behavioral regression guard (SC-4)

**Concern:** Behavioral tests-v2 scenario asserts the agent consults `origin/$DEFAULT_BRANCH` rather than a stale local tip.

**Files:** `.opencode/tests-v2/behaviors/2304-*.sh`

**SCs:** SC-4

**Dependencies:** none

**Entry condition:** Coherence gate and baseline check passed.

**Exit condition:** `with-test-home opencode run` with stderr-based `assert_stderr_pattern_present` shows agent consulting `origin/$DEFAULT_BRANCH`.

**Code Path Coverage:** Behavioral test harness (`with-test-home`) executing a real-domain prompt.

**Cross-Cutting SCs:** none — SC-4 is a leaf.

**Interface Boundaries:** behavioral test harness (IF-3). Standard `with-test-home opencode run` harness; new scenario `2304-*.sh` uses the standard harness; no harness interface change.

**State Transitions:** ST-4 — from agent may fall back to stale local branch tip to agent consults `origin/$DEFAULT_BRANCH`.

**Cost frame:** Running the behavioral test costs minutes of execution time. Skipping means the behavioral defect (agent falls back to stale local tip) ships to production and costs 1000× more to fix.

### Item 4 (SC-4)

- [ ] 1. **RED — write the failing behavioral scenario.** Write a behavioral tests-v2 scenario asserting the agent consults `origin/$DEFAULT_BRANCH`. (**sub-agent**)
  - The scenario must FAIL because the agent currently falls back to a stale local tip.
  - Use `bash .opencode/tests-v2/with-test-home opencode run '<real-domain prompt>'`.
  - Assert stderr shows agent consulting `origin/$DEFAULT_BRANCH` via `assert_stderr_pattern_present`.
- [ ] 2. **GREEN — make the scenario pass.** Ensure the prose sweep enables the agent to consult `origin/$DEFAULT_BRANCH`. (**sub-agent**)
  - The agent stderr must show consultation of `origin/$DEFAULT_BRANCH`.
- [ ] 3. **Post-regression.** Run regression test patterns after the GREEN change. (**sub-agent**)
- [ ] 4. **Verify.** Verify the implementation against SC-4. (**sub-agent**)
  - Run `with-test-home opencode run` with the real-domain prompt.
  - Assert stderr shows `origin/$DEFAULT_BRANCH` consultation via `assert_stderr_pattern_present`.
- [ ] 5. **Commit.** Stage and commit the behavioral scenario together with the prose sweep that enables it as one atomic slice. (**inline**)
  - `git add <files> && git commit -m "<message>"`.

**Phase completion:** SC-4 verified PASS. Agent stderr shows consultation of `origin/$DEFAULT_BRANCH`.

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
