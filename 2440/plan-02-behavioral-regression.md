# Phase 2 — Behavioral Regression Verification

**Concern:** Hazard-state blocking preserved + safe-state DONE-with-WARN proven — after all Phase 1 changes, a local-only submodule pointer commit still causes BLOCKED with `SUBMODULE_UNMERGED_COMMIT`, and the new safe-state scenario asserts DONE with WARNs.

**Files:**
- `.opencode/tests-v2/behaviors/` (new safe-state scenario script — finalized from Phase 1)
- `.opencode/tests-v2/behaviors/trunk-tip-enforcement.sh` (regression run target)
- `.opencode/tests-v2/behaviors/git-workflow/2313-sc1-prework-merged-commit.sh` (regression run target)

**SCs:** SC-5

**Dependencies:** Phase 1 (SC-1, SC-2, SC-4 outputs)

**Entry Conditions:**
- Phase 1 complete: Steps 2/7 WARN classification, Step 8 if/else fix, contract sync — all committed
- Phase 1 VbC passed (step 25)
- All Phase 1 commits pushed; fresh `git fetch` confirms effective commit contained in a remote ref

**Exit Conditions:**
- Combined behavioral suite green: `trunk-tip-enforcement.sh` + `2313-sc1-prework-merged-commit.sh` + new safe-state scenario
- Hazard-state blocking (SUBMODULE_UNMERGED_COMMIT) preserved; safe state DONE with WARNs
- Regression evidence artifacts committed with the final item

---

## Code Path Coverage

- Full gate suite run via `with-test-home` — all three scripts enumerated above
- Read-only: `pre-work.md` status consumption of DONE-with-WARN

## Cross-Cutting SCs

- Behavioral evidence mandate (guideline 080): SC-5 is behavioral — full `with-test-home opencode run` suite; grep/static substitution is EVIDENCE_TYPE_MISMATCH → FAIL.
- Test framework mandate: `>=600s` bash timeout; `rm -f tmp/.behavior-run.lock` before re-runs; never GNU `timeout`; standalone binary via `$TEST_HOME/bin/opencode`.

## Interface Boundaries

- No interface changes in this phase — verification only. The `SUBMODULE_UNMERGED_COMMIT` blocker reason and the DONE-with-WARN outcome are observed as-is.

## State Transitions

- Verified transitions: hazard state (local-only pointer commit) → BLOCKED (SUBMODULE_UNMERGED_COMMIT) — unchanged; safe state → DONE (with WARN) — new from Phase 1.
- Invariant under test: `SUBMODULE_UNMERGED_COMMIT` always BLOCKs (never downgraded).

---

- [ ] 26. **Item 5 RED — pre-change combined suite run (**task-card**).** Run the combined behavioral suite (existing gate tests + new safe-state scenario) in its pre-final state and record the failure — the safe-state scenario does not yet pass end-to-end against the fully assembled gate semantics. **→ SC-5**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`.
  - Pre-clean: `rm -f tmp/.behavior-run.lock`; `rm -f tmp/2440/artifacts/pipeline-red-*`.
  - Use `bash .opencode/tests-v2/with-test-home opencode run '<scenario>'` with `>=600s` timeout.
- [ ] 27. **Item 5 GREEN — combined suite passes (**task-card**).** Confirm/complete the scenario assertions in `tests-v2` behaviors: `2313-sc1-prework-merged-commit.sh` stays green (SUBMODULE_UNMERGED_COMMIT blocking preserved), `trunk-tip-enforcement.sh` green with synced assertions, new safe-state scenario asserts DONE with WARNs. **→ SC-5**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`.
- [ ] 28. **Item 5 post-regression (**task-card**).** Run regression test patterns after GREEN. **→ SC-5**
- [ ] 29. **Item 5 verify (**task-card**).** Verify SC-5: full `with-test-home` suite run with `>=600s` timeout; all three scripts green; assert BLOCKED-with-SUBMODULE_UNMERGED_COMMIT on the hazard fixture and DONE-with-WARNs on the safe fixture. Evidence to `tmp/2440/artifacts/pipeline-verify-*`. **→ SC-5**
- [ ] 30. **Item 5 commit-inline (**direct**).** Commit the regression evidence artifact plus any final scenario script adjustments as one atomic slice. Push the branch; fresh-fetch and verify the effective commit is contained in a remote ref. **→ SC-5**

#### Phase 2 Completion Block

- [ ] 31. **Phase 2 VbC (**task-card**).** Verify all phase-2 exit conditions: combined suite green, hazard blocking preserved, safe-state DONE-with-WARNs, evidence artifacts on disk. **→ SC-5**

---

## Post-Implementation Steps

- [ ] 32. **Audit (**task-card**).** Adversarial audit of the deliverable — dispatch the verification-audit investigator, then validator, evaluator, arbiter in sequence.
  - Dispatch: `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`.
  - Pre-clean: `rm -f tmp/2440/artifacts/pipeline-audit-*`.
- [ ] 33. **Z3 check (**direct**).** Run the Z3 constraint solver verification directly: `.opencode/tools/solve check --state-path ... --contract-path ...` against the phase dependency contract (phase-1 → phase-2 DAG, no cycles). Pre-clean: `rm -f tmp/2440/artifacts/pipeline-z3-check-*`.
- [ ] 34. **Structural checks (**task-card**).** Run the finishing checklist (lint, typecheck, etc.).
  - Dispatch: `task(..., prompt: "execute checklist task from finishing-a-development-branch")`.
  - Pre-clean: `rm -f tmp/2440/artifacts/pipeline-structural-checks-*`.
- [ ] 35. **Pre-PR gate (**task-card**).** Verify all SC verdicts before PR creation — reads all SC evidence verdicts; BLOCKs if any FAIL (DONE_WITH_CONCERNS coerces to FAIL; EVIDENCE_TYPE_MISMATCH coerces to FAIL).
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Pre-clean: `rm -f tmp/2440/artifacts/pipeline-pre-pr-gate-*`.
- [ ] 36. **Regression check (**task-card**).** Final regression check before PR (test-driven-development phase-4 task).
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Pre-clean: `rm -f tmp/.behavior-run.lock`; `rm -f tmp/2440/artifacts/pipeline-regression-check-*`.
- [ ] 37. **Review prep + create PR (**task-card**).** Prepare PR review context, then create the pull request (stacked — one branch, one PR targeting the trunk; `for_pr` scope authorizes PR creation; human-only merge — HALT after PR creation).
  - Dispatch review prep: `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`.
  - Dispatch PR creation: `task(..., prompt: "execute create task from git-workflow-pr")`.
- [ ] 38. **Executive summary (**task-card**).** Generate the completion executive summary.
  - Dispatch: `task(..., prompt: "execute completion task from completion-core")`.

**Cost frame:** Running the full behavioral regression suite (SC-5) costs minutes of execution time — the defect is caught before merge where the fix costs the same bounded delay. Skipping means a weakened `SUBMODULE_UNMERGED_COMMIT` check ships — the hazardous state (local-only pointer commit) passes pre-work silently, and the defect surfaces as a broken submodule pointer in a released build, costing 1000× more to diagnose and repair. Correctness is the only metric.

**Concern transition:** Plan complete — all phases executed. Post-implementation gates (audit through executive summary) close the pipeline.
