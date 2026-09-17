---
plan_schema_version: "1.0"
issue: 2450
title: "local-issues validate-yaml scoped validation mode + R-13 gate scoping + governance mandates"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
dispatch:
  - "phase 1: test-driven-development (red, green, post-regression), verification-before-completion (verify), orchestrator (commit-inline)"
  - "phase 2: test-driven-development (red, green, post-regression, regression-check), verification-before-completion (verify, behavioral verify), orchestrator (commit-inline, push)"
  - "phase 3: test-driven-development (red, green, post-regression, regression-check), verification-before-completion (verify, behavioral verify), orchestrator (commit-inline, push)"
  - "post-implementation: audit, verification-before-completion (pre-pr-gate), finishing-a-development-branch (structural-checks), test-driven-development (regression-check), git-workflow-pr (review-prep, create-pr), completion-core (exec-summary), orchestrator (z3-check)"
---

# Implementation Plan — #2450 — Scoped validate-yaml Mode, R-13 Gate Scoping, Governance Mandates

**Issue:** `.opencode/.issues/2450/spec.md`

**Goal:** Add a scoped validation mode to `local-issues validate-yaml` (`--number <repo>#N`), re-scope the spec-creation R-13 gates to the scoped form, and encode the issues-data hygiene and remote-first spec-number reservation mandates in the governing docs — so pipelines verify their own issue records independent of workspace drift.

**Architecture:** Phase 1 adds the scoped flag to the tool's `cmd_validate_yaml()` routing through the existing shared scan machinery (`_scan_issue_dir_errors`, exact-match directory lookup) so exit semantics and report-format parity are structural. Phase 2 updates the analyze.md and create.md R-13 gate sites to invoke the scoped form and to state the scoped-primary/workspace-secondary contract (workspace-wide scan MUST NOT gate progress on unrelated issues' records). Phase 3 encodes the hygiene mandate (`.opencode/.issues/AGENTS.md` Authorization section + `.opencode/AGENTS.md` worktree section) and the remote-first reservation mandate (`.opencode/.issues/AGENTS.md` Workflow section + create.md Step 3 + creation.md Step 2.1). Phase 3 is independent of Phases 1-2; Phase 2 depends on Phase 1 (the flag must exist before the gate cards instruct its use).

**Files:**
- `.opencode/tools/local-issues` and `.opencode/tests/test_local_issues/` — scoped mode + pytest suite
- `.opencode/skills/spec-creation/tasks/analyze.md` — R-13 gate site (Step 5.3, exit criteria, result contract)
- `.opencode/skills/spec-creation/tasks/create.md` — R-13 gate site (Step 6.1) and Step 3 reservation mandate
- `.opencode/.issues/AGENTS.md` — hygiene mandate (Authorization) + reservation mandate (Workflow)
- `.opencode/AGENTS.md` — hygiene mandate (`.issues/` worktree section)
- `.opencode/skills/issue-operations-core/tasks/creation.md` — Step 2.1 reservation mandate
- `.opencode/tests-v2/behaviors/` — behavioral scenarios for SC-3..SC-10

## Blast Radius

- `cmd_validate_yaml()` gains the `--number` flag; `_find_issue_dir()` reused unchanged for exact-match target resolution; `_scan_issue_dir_errors()`, `_schema_problem()`, error-class constants, and `YAML_FILES` reused unchanged as the single shared taxonomy — format parity is structural, not asserted.
- No-flag default remains the byte-for-byte unchanged full workspace scan (maintenance guarantee preserved).
- New behavioral scenarios under `.opencode/tests-v2/behaviors/` cover SC-3..SC-10 (fixtures per `fixtures/setup/`; `BEHAVIOR_NEEDS_REMOTE` / GitBucket container for reservation scenarios).
- Untouched: record schema definitions, `creation.md` Step 2.2 local-only counter path, `tests-v2/AGENTS.md` harness spec, issue 2450's own records.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| 1 | Tool — scoped validation mode in local-issues | scoped `--number` flag with scoped exit codes and format parity | SC-1, SC-2 | — | 3-12 | direct (1-2) + task-card (3-11) + direct (12) |
| 2 | Gate text — analyze.md and create.md R-13 gate scoping | scoped gate invocation + scoped-primary contract | SC-3, SC-4, SC-5 | 1 | 13-33 | task-card (13-32) + direct (33) |
| 3 | Governance docs — hygiene and reservation mandates | hygiene + remote-first reservation mandate text at five sites | SC-6..SC-10 | — | 34-68 | task-card (34-67) + direct (68) |
| — | Post-implementation | audit, verification, review-prep, PR | all | 1, 2, 3 | 69-76 | mixed — see steps |

## Self-Remediation

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- [ ] C1. `validate-yaml --number <repo>#N` validates only the target issue's records with scoped exit-code semantics; no-flag default unchanged (SC-1)
- [ ] C2. Scoped-mode report lines use the same `<path>: <error-class>` format and error-class taxonomy as the workspace scan (SC-2)
- [ ] C3. analyze.md Step 5.3 invokes the scoped form as the progress-gating check (SC-3)
- [ ] C4. analyze.md gate contract states scoped-primary/workspace-secondary with the MUST-NOT-gate clause across Step 5.3 body, exit criteria, and result contract (SC-4)
- [ ] C5. create.md Step 6.1 invokes the scoped form and carries the same scoped-primary contract (SC-5)
- [ ] C6. `.opencode/.issues/AGENTS.md` states the issues-data hygiene mandate (authorization-free, no spec) (SC-6)
- [ ] C7. `.opencode/AGENTS.md` worktree section states the same hygiene mandate verbatim in semantics (SC-7)
- [ ] C8. `.opencode/.issues/AGENTS.md` Workflow section states the remote-first reservation mandate with clean-room-restartable context and the local-first-is-a-violation clause (SC-8)
- [ ] C9. create.md Step 3 states the same reservation mandate verbatim in semantics (SC-9)
- [ ] C10. creation.md Step 2.1 states the same reservation mandate verbatim in semantics (SC-10)
- [ ] C11. All behavioral verdicts are real-model with-test-home runs evaluated by session.yaml clean-room inspection; no structural substitute reported as PASS

## Pre-implementation (global)

- [ ] 1. **Coherence gate (**direct**).** Re-read the spec's SC table and this plan's phase/SC mapping; confirm every SC is covered by exactly one item, phase DAG has no cycles, and evidence types match the spec's declared types.
  - Context: spec at `.opencode/.issues/2450/spec.md` §3; structure artifact at `.opencode/.issues/2450/artifacts/structure.yaml`
- [ ] 2. **Baseline check (**direct**).** Verify clean working tree and trunk-tip state per git-workflow pre-work; run the existing pytest suite and the no-flag `validate-yaml` on both repos to record the pre-change baseline.
  - Command context: `uv run pytest .opencode/tests/test_local_issues/`; `./.opencode/tools/local-issues validate-yaml`

---

# Phase 1 — Tool — scoped validation mode in local-issues

- [ STUB — phase body pending ]

---

# Phase 2 — Gate text — analyze.md and create.md R-13 gate scoping

- [ STUB — phase body pending ]

---

# Phase 3 — Governance docs — hygiene and reservation mandates

- [ STUB — phase body pending ]

---

# Post-implementation (global)

- [ STUB — post-implementation body pending ]

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.
