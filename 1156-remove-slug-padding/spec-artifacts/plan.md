---
number: 1156
title: "[PLAN] Remove slug padding from .issues/ directory naming"
status: open
labels: [PLAN, SPEC-FIX]
created: 2026-06-13T04:46:01+00:00
updated: 2026-06-13T00:00:00Z
plan_number: 1156
plan_of: 1156
plan_type: implementation
---

## Implementation Plan: Remove Slug Padding (`.opencode#1156`)

### Scope

Mirror of remote issue `.opencode#1156`. Modifies:
- `.opencode/tools/local-issues` — `_find_issue_dir()`, `_find_issue_dir_in_repo()`, `get_issue_path()`
- `.opencode/tests/test_local_issues.py` — padded number assertions
- `.opencode/skills/issue-operations/tasks/` — `NNN-slug` → `N-slug` references
- `.opencode/skills/issue-operations/platforms/local/SKILL.md` — architecture diagram

**Not in scope:** `__model_slug()` in `helpers.sh`, existing `.issues/NNN-slug/` dirs (backward compat via prefix matching)

### Checkpoint Tag Convention

```
opencode-config/checkpoint/1156/phase-<N>-opencode
```

Where N is the phase number below.

### Pipeline Steps

| Step | Phase | Label | Dispatches To | SC Coverage |
|------|-------|-------|---------------|-------------|
| 1 | 1 | `sc-coherence-gate` | `adversarial-audit --task coherence-extraction` | SC-1..SC-11 coherence |
| 2 | 1 | `pre-red-baseline` | bash: `solve state init`, tag SHA | Setup |
| 3 | 2 | `red-phase` | `test-driven-development --task red` | SC-3 unit test RED |
| 4 | 2 | `red-doublecheck` | `verification-before-completion --task verify` | SC-3 RED evidence |
| 5 | 3 | `green-phase` | `test-driven-development --task green` | SC-1, SC-2, SC-3, SC-9, SC-11 code changes |
| 6 | 3 | `checkpoint-commit` | `git-workflow --task commit-prep` | Phase 3 commit + tag |
| 7 | 4 | `structural-checks` | `finishing-a-development-branch --task checklist` | SC-4, SC-5, SC-6, SC-10 grep checks |
| 8 | 4 | `green-doublecheck` | `verification-before-completion --task verify` | SC-1, SC-2, SC-3, SC-9, SC-11 |
| 9 | 4 | `green-vbc` | `verification-before-completion --task completion` | VbC artifact |
| 10 | 5 | `adversarial-audit` | `adversarial-audit --task verification-audit` | All 11 SCs |
| 11 | 5 | `cross-validate` | `adversarial-audit --task cross-validate` | Cross-family consensus |
| 12 | 5 | `regression-check` | `test-driven-development --task patterns` | Full test suite |
| 13 | 6 | `review-prep` | `git-workflow --task review-prep` | PR readiness |
| 14 | 6 | `exec-summary` | `completion-core --task completion` | Push + comment |

### Phase Breakdown

#### Phase 1: Coherence + Baseline (Steps 1-2)
- **Step 1 (sc-coherence-gate):** Validate spec SCs against codebase reality. Verify all 11 SCs are coherent with current `local-issues` source. Tag: `opencode-config/checkpoint/1156/phase-1-opencode`
- **Step 2 (pre-red-baseline):** `solve state init ./tmp/1156/state/` with `current_step: pre-red-baseline`. Tag parent repo and submodule at current SHAs.

#### Phase 2: RED Tests (Steps 3-4)
- **Step 3 (red-phase):** Write/modify `test_local_issues.py` with:
  - `_parse_number()` unit test for bare `NNN` directory (SC-3)
  - Update existing padded-number assertions (lines 42, 175, 310, 316-317) to use bare `N` format
- **Step 4 (red-doublecheck):** Verify RED tests FAIL (change not made yet). Tag: `opencode-config/checkpoint/1156/phase-2-opencode`

#### Phase 3: GREEN Implementation (Steps 5-6)
- **Step 5 (green-phase):** Make code changes:
  1. `local-issues` `get_issue_path()` — remove `_slug()` call, return bare `name = f"{number}"`
  2. `local-issues` `_find_issue_dir()` — remove `padded_prefix = f"{number:03d}"` and padded startswith branches (lines 66, 80, 92)
  3. `local-issues` `_find_issue_dir_in_repo()` — same removal (lines 102, 114, 125)
  4. Update test fixtures to use bare `N` format
- **Step 6 (checkpoint-commit):** Commit changes, tag: `opencode-config/checkpoint/1156/phase-3-opencode`

#### Phase 4: Verification (Steps 7-9)
- **Step 7 (structural-checks):** grep for `NNN-slug` and `:03d` across `.opencode/skills/` and `.opencode/guidelines/`. Update remaining references to `N-slug` format.
- **Step 8 (green-doublecheck):** Verify all SC-1, SC-2, SC-3, SC-9, SC-11 PASS
- **Step 9 (green-vbc):** Full VbC artifact. Tag: `opencode-config/checkpoint/1156/phase-4-opencode`

#### Phase 5: Adversarial Audit (Steps 10-12)
- **Step 10 (adversarial-audit):** Dual cross-family auditor verification of all 11 SCs
- **Step 11 (cross-validate):** Cross-family consensus
- **Step 12 (regression-check):** Full test suite pass. Tag: `opencode-config/checkpoint/1156/phase-5-opencode`

#### Phase 6: Review Prep (Steps 13-14)
- **Step 13 (review-prep):** `git-workflow --task review-prep` — squash to single commit, open PR
- **Step 14 (exec-summary):** Push, post PR URL as issue comment

### Z3 SAT Verification

Each pipeline transition validated via `solve check` against `pipeline-state-machine.yaml`:

```
solve state init ./tmp/1156/state/
  → current_step: pre-red-baseline, pipeline_state: init
solve state update ./tmp/1156/state/ --var-name current_step --var-value red-phase
solve check --state-path ./tmp/1156/state/ --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
  → PASS: transition pre-red-baseline → red-phase valid
```

Repeat for every step transition. Full Z3 SAT evidence in `spec-artifacts/audit/`.

### Rollback Tags

```
opencode-config/checkpoint/1156/phase-1-opencode   (after coherence gate)
opencode-config/checkpoint/1156/phase-2-opencode   (after RED tests)
opencode-config/checkpoint/1156/phase-3-opencode   (after GREEN commit)
opencode-config/checkpoint/1156/phase-4-opencode   (after VbC)
opencode-config/checkpoint/1156/phase-5-opencode   (after regression check)
```

### Remediation Routing

| Step FAIL | Revert To | Re-run From |
|-----------|-----------|-------------|
| sc-coherence-gate | phase-1 | sc-coherence-gate |
| red-phase | phase-1 | pre-red-baseline |
| green-phase | phase-2 | red-phase |
| green-doublecheck | phase-3 | green-phase |
| adversarial-audit | phase-4 | green-vbc |
| regression-check | phase-4 | structural-checks |