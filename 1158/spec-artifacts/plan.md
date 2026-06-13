---
number: 1158
title: "[PLAN] Forbid pre-existing failure rationalization — critical-rules-069"
status: open
labels: [PLAN, SPEC-FIX]
created: 2026-06-13T00:00:00Z
plan_number: 1158
plan_of: 1158
plan_type: implementation
---

## Implementation Plan: Forbid "Pre-Existing Failure" Rationalization

### Scope

Modifies:
- `.opencode/guidelines/000-critical-rules.md` — add critical-rules-069 under accountability-ownership §8
- `.opencode/skills/verification-before-completion/tasks/verify.md` — add Pre-Existing Failure Gate step
- `.opencode/tests/behaviors/` — new behavioral enforcement test (SC-4)

**Not in scope:** `using-git-worktrees/tasks/reference.md:35` — upgrade to cross-reference (SC-3 is soft — cross-reference verification only)

### Checkpoint Tag Convention

```
opencode-config/checkpoint/1158/phase-<N>-opencode
```

Where N is the phase number below.

### Pipeline Steps

| Step | Phase | Label | Dispatches To | SC Coverage |
|------|-------|-------|---------------|-------------|
| 1 | 1 | `sc-coherence-gate` | `adversarial-audit --task coherence-extraction` | SC-1..SC-4 coherence |
| 2 | 1 | `pre-red-baseline` | bash: `solve state init`, tag SHA | Setup |
| 3 | 2 | `red-phase` | `test-driven-development --task red` | SC-4 behavioral test RED |
| 4 | 2 | `red-doublecheck` | `verification-before-completion --task verify` | SC-4 RED evidence |
| 5 | 3 | `green-phase-prose` | `test-driven-development --task green` | SC-1, SC-2, SC-3 prose changes |
| 6 | 3 | `checkpoint-commit` | `git-workflow --task commit-prep` | Phase 3 commit + tag |
| 7 | 4 | `green-doublecheck` | `verification-before-completion --task verify` | SC-1, SC-2, SC-3 grep verification |
| 8 | 4 | `green-phase-test` | `test-driven-development --task green` | SC-4 behavioral test GREEN pass |
| 9 | 4 | `green-vbc` | `verification-before-completion --task completion` | VbC artifact |
| 10 | 5 | `adversarial-audit` | `adversarial-audit --task verification-audit` | All 4 SCs |
| 11 | 5 | `cross-validate` | `adversarial-audit --task cross-validate` | Cross-family consensus |
| 12 | 5 | `regression-check` | `test-driven-development --task patterns` | Full test suite |
| 13 | 6 | `review-prep` | `git-workflow --task review-prep` | PR readiness |
| 14 | 6 | `exec-summary` | `completion-core --task completion` | Push + comment |

### Phase Breakdown

#### Phase 1: Coherence + Baseline (Steps 1-2)
- **Step 1 (sc-coherence-gate):** Validate spec SCs against codebase reality. Verify all 4 SCs are coherent with current guidelines. Tag: `opencode-config/checkpoint/1158/phase-1-opencode`
- **Step 2 (pre-red-baseline):** `solve state init ./tmp/1158/state/` with `current_step: pre-red-baseline`. Tag parent repo and submodule at current SHAs.

#### Phase 2: RED Tests (Steps 3-4)
- **Step 3 (red-phase):** Write behavioral enforcement test `tests/behaviors/1158-sc4-pre-existing-failure-blocked.sh`. The test sends an agent a scenario where tests fail on both dev and feature branch, and verifies the agent does NOT ship. The test must FAIL against current code (agent ships with pre-existing failures).
- **Step 4 (red-doublecheck):** Verify RED tests FAIL. Tag: `opencode-config/checkpoint/1158/phase-2-opencode`

#### Phase 3: GREEN Prose Changes (Steps 5-6)
- **Step 5 (green-phase-prose):** Make prose changes:
  1. Insert critical-rules-069 prose in `000-critical-rules.md` after principle 7 in accountability-ownership section. New principle 8: **"Pre-existing failure is not a valid justification"** — test infrastructure is part of the ship condition. If dev has failing tests, the agent does NOT ship until failures are resolved or the developer explicitly authorizes proceeding. Update "7 principles" to "8 principles".
  2. Insert yaml+symbolic rule `critical-rules-069` after `critical-rules-066`. Tier 2. Title: "Pre-existing failure rationalization — test infrastructure is part of the ship condition."
  3. Insert verification step in `verification-before-completion/tasks/verify.md` after the "When Behavioral/Functional Tests Cannot Execute" section. New subsection: `### Pre-Existing Failure Gate` — "pre-existing failure" is not a valid justification. If tests fail on both dev and the feature branch, this is NOT justification to ship. The agent must remediate test infrastructure or obtain explicit developer authorization.
  4. Update `using-git-worktrees/tasks/reference.md:35` to cross-reference critical-rules-069.
- **Step 6 (checkpoint-commit):** Commit changes, tag: `opencode-config/checkpoint/1158/phase-3-opencode`

#### Phase 4: GREEN Test + Verification (Steps 7-9)
- **Step 7 (green-doublecheck):** Verify SC-1, SC-2, SC-3 PASS via grep
- **Step 8 (green-phase-test):** Re-run behavioral test — must PASS now (agent refuses to ship)
- **Step 9 (green-vbc):** Full VbC artifact. Tag: `opencode-config/checkpoint/1158/phase-4-opencode`

#### Phase 5: Adversarial Audit (Steps 10-12)
- **Step 10 (adversarial-audit):** Dual cross-family auditor verification of all 4 SCs
- **Step 11 (cross-validate):** Cross-family consensus
- **Step 12 (regression-check):** Full test suite pass. Tag: `opencode-config/checkpoint/1158/phase-5-opencode`

#### Phase 6: Review Prep (Steps 13-14)
- **Step 13 (review-prep):** `git-workflow --task review-prep` — squash to single commit, open PR
- **Step 14 (exec-summary):** Push, post PR URL as issue comment

### Z3 SAT Verification

Each pipeline transition validated via `solve check` against `pipeline-state-machine.yaml`:

```bash
solve state init ./tmp/1158/state/
  → current_step: pre-red-baseline, pipeline_state: init
solve state update ./tmp/1158/state/ --var-name current_step --var-value red-phase
solve check --state-path ./tmp/1158/state/ --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
  → PASS: transition pre-red-baseline → red-phase valid
```

Repeat for every step transition.

### Rollback Tags

```
opencode-config/checkpoint/1158/phase-1-opencode   (after coherence gate)
opencode-config/checkpoint/1158/phase-2-opencode   (after RED tests)
opencode-config/checkpoint/1158/phase-3-opencode   (after GREEN prose commit)
opencode-config/checkpoint/1158/phase-4-opencode   (after VbC)
opencode-config/checkpoint/1158/phase-5-opencode   (after regression check)
```

### Remediation Routing

| Step FAIL | Revert To | Re-run From |
|-----------|-----------|-------------|
| sc-coherence-gate | phase-1 | sc-coherence-gate |
| red-phase | phase-1 | pre-red-baseline |
| green-phase-prose | phase-2 | red-phase |
| green-doublecheck | phase-3 | green-phase-prose |
| green-phase-test | phase-3 | green-phase-prose |
| adversarial-audit | phase-4 | green-vbc |
| regression-check | phase-4 | green-doublecheck |

### Z3 Contract Validation

State file at `.issues/1158/spec-artifacts/state/state.yaml` initialized at `plan_creation`. Transitions validated by `solve check` against pipeline contract.