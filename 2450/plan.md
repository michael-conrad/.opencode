---
plan_schema_version: "1.0"
issue: 2450
title: "local-issues validate-yaml scoped validation mode + R-13 gate scoping + governance mandates"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 4
dispatch:
  - "phase 1: test-driven-development (red, green, post-regression), verification-before-completion (verify), orchestrator (commit-inline)"
  - "phase 2: test-driven-development (red, green, post-regression, regression-check), verification-before-completion (verify, behavioral verify), orchestrator (commit-inline, push)"
  - "phase 3: test-driven-development (red, green, post-regression, regression-check), verification-before-completion (verify, behavioral verify), orchestrator (commit-inline, push)"
  - "phase 4: test-driven-development (red, green, post-regression, regression-check), verification-before-completion (verify, behavioral verify), orchestrator (commit-inline, push)"
  - "post-implementation: audit, verification-before-completion (pre-pr-gate), finishing-a-development-branch (structural-checks), test-driven-development (regression-check), git-workflow-pr (review-prep, create-pr), completion-core (exec-summary), orchestrator (z3-check)"
---

# Implementation Plan — #2450 — Scoped validate-yaml Mode, R-13 Gate Scoping, Governance Mandates

**Issue:** `.opencode/.issues/2450/spec.md`

**Goal:** Add a scoped validation mode to `local-issues validate-yaml` (`--number <repo>#N`), re-scope the spec-creation R-13 gates to the scoped form, and encode the issues-data hygiene and remote-first spec-number reservation mandates in the governing docs — so pipelines verify their own issue records independent of workspace drift.

**Architecture:** Phase 1 adds the scoped flag to the tool's `cmd_validate_yaml()` routing through the existing shared scan machinery (`_scan_issue_dir_errors`, exact-match directory lookup) so exit semantics and report-format parity are structural. Phase 2 updates the analyze.md and create.md R-13 gate sites to invoke the scoped form and to state the scoped-primary/workspace-secondary contract (workspace-wide scan MUST NOT gate progress on unrelated issues' records). Phase 3 encodes the issues-data hygiene mandate (`.opencode/.issues/AGENTS.md` Authorization section + `.opencode/AGENTS.md` worktree section). Phase 4 encodes the remote-first reservation mandate (`.opencode/.issues/AGENTS.md` Workflow section + create.md Step 3 + creation.md Step 2.1). Phases 3 and 4 are independent of Phases 1-2 and of each other (concern-map: issues-data-governance vs spec-number-reservation are separate concerns); Phase 2 depends on Phase 1 (the flag must exist before the gate cards instruct its use).

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
| 1 | Tool — scoped validation mode in local-issues | scoped `--number` flag with scoped exit codes and format parity | SC-1, SC-2 | — | 3-15 | task-card (3-4, 5-8, 10-13, 15) + direct (9, 14) |
| 2 | Gate text — analyze.md and create.md R-13 gate scoping | scoped gate invocation + scoped-primary contract | SC-3, SC-4, SC-5 | 1 | 16-38 | task-card (16-17, 18-20, 23-26, 29-32, 35-36, 38) + direct (21-22, 27-28, 33-34, 37) |
| 3 | Governance docs — issues-data hygiene mandate | hygiene mandate text at two sites | SC-6, SC-7 | — | 39-53 | task-card (39-43, 46-49, 52-53) + direct (44-45, 50-51) |
| 4 | Governance docs — remote-first reservation mandate | remote-first reservation mandate text at three sites | SC-8, SC-9, SC-10 | — | 54-76 | task-card (54-58, 61-64, 67-70, 73-74, 76) + direct (59-60, 65-66, 71-72, 75) |
| — | Post-implementation | audit, verification, review-prep, PR | all | 1, 2, 3, 4 | 77-84 | mixed — see steps |

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

**Concern:** Add the scoped `--number <repo>#N` validation mode with scoped exit-code semantics and report-format parity, delivered with pytest coverage in the existing suite.

**Files:** `.opencode/tools/local-issues`; `.opencode/tests/test_local_issues/`

**SCs:** SC-1, SC-2

**Dependencies:** None

**Entry Conditions:** Pre-implementation steps 1-2 complete; baseline suite green; feature branch active.

**Exit Conditions:** Scoped flag resolves qualified `repo#N`, exits on target-only semantics, fails fast on missing target, rejects bare numbers; format parity proven by shared-code-path tests; existing suite remains green.

**Code Path Coverage:** `cmd_validate_yaml()` gains the flag and scoped routing; `_find_issue_dir()` reused for exact-match target resolution (missing target → fail-fast, R-10); `_scan_issue_dir_errors()` reused as the shared per-directory scan collector so parity is structural; `_schema_problem()`/error-class constants/`YAML_FILES` untouched.

**Cross-Cutting SCs:** None — SC-1 and SC-2 are both confined to the tool + its test suite.

**Interface Boundaries:** CLI is purely additive; no-flag default byte-for-byte unchanged (R-5); qualified-form convention inherited (R-11); report format unchanged (R-4).

**State Transitions:** scoped × clean-target × unrelated-violations → exit 0; scoped × violating-target → exit 1 with target-only lines; scoped × absent-target → fail-fast error; scoped × bare-number → qualifier rejection.

**Cost frame:** Running the scoped pytest suites costs minutes of execution time — the behavioral tier, surfacing any exit-semantics or format defect at gate 1. Skipping costs the death-spiral tier: a flag that exits on workspace state or emits a second report dialect ships silently, every pipeline block recurs on the next drift, and the divergence surfaces days later as misrouted failure triage — the 100×–1000× discovery latency.

---

- [ ] 3. **Pre-regression (**task-card**).** Run the existing regression patterns for the tool suite before RED.
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-pre-regression-*`
  - Run `uv run pytest .opencode/tests/test_local_issues/` and record the green baseline. **→ SC-1, SC-2**
- [ ] 4. **Pre-regression verify (**task-card**).** Verify the pre-regression results — baseline suite fully green before any RED is written. **→ SC-1, SC-2**
- [ ] 5. **RED (**task-card**).** Write failing tests asserting `validate-yaml --number <repo>#N` exits 0 on a clean target amid a fixture workspace with violating neighbors, exits 1 on a violating target, fails fast on an absent target directory, and rejects bare unqualified numbers. **→ SC-1**
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-red-*`
  - RED condition: the flag does not exist — `validate-yaml --help` accepts zero flags — so the tests fail today.
- [ ] 6. **GREEN (**task-card**).** Implement the minimum change making the RED tests pass: add `--number` to the `validate-yaml` parser with qualified `repo#N` resolution, route to the target directory via the existing exact-match lookup, scan only that directory through the shared scan machinery, and apply scoped exit semantics with fail-fast on a missing directory. **→ SC-1**
  - GREEN condition: scoped exit code reflects only the target's own files; the no-flag default scan is unchanged.
- [ ] 7. **Post-regression (**task-card**).** Re-run the full existing suite — including `test_validate_yaml_exit_codes.py` — plus the new tests; confirm nothing regressed and the no-flag default is unchanged. **→ SC-1**
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-post-regression-*`
- [ ] 8. **Verify (**task-card**).** Verify the implementation against SC-1's success criteria with executed pytest evidence. **→ SC-1**
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-verify-*`
- [ ] 9. **Commit (**direct**).** Stage and commit the tool change plus its tests as one atomic slice.
  - `git add .opencode/tools/local-issues .opencode/tests/test_local_issues/ && git commit -m "feat(local-issues): scoped validate-yaml mode with scoped exit-code semantics"`
- [ ] 10. **RED (**task-card**).** Write failing tests asserting scoped-mode report lines match the `<path>: <error-class>` format and the same error classes the workspace scan emits for identical fixture files — scoped output equals the workspace output filtered to the target's paths. **→ SC-2**
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-red-*`
- [ ] 11. **GREEN (**task-card**).** Emit scoped findings through the same code path the workspace scan uses (the shared per-directory scan collector) so format parity is structural. **→ SC-2**
- [ ] 12. **Post-regression (**task-card**).** Re-run the full existing suite after the GREEN change; confirm nothing regressed. **→ SC-2**
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-post-regression-*`
- [ ] 13. **Verify (**task-card**).** Verify SC-2 with executed pytest evidence plus a manual cross-check comparing scoped output to the filtered workspace output. **→ SC-2**
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-verify-*`
- [ ] 14. **Commit (**direct**).** Stage and commit the tests plus any emitted-line adjustment as one atomic slice.
  - `git add .opencode/tests/test_local_issues/ .opencode/tools/local-issues && git commit -m "test(local-issues): scoped report format parity"`

#### Phase 1 Completion (VbC)

- [ ] 15. **VbC (**task-card**).** Verify SC-1 and SC-2 success criteria against executed test evidence: scoped exit semantics, fail-fast, bare-number rejection, format parity, unchanged default. **→ SC-1, SC-2**

**Concern transition:** Leaving tool semantics → entering gate-text scoping. Phase 2 depends on Phase 1's `--number` flag existing.

---

# Phase 2 — Gate text — analyze.md and create.md R-13 gate scoping

**Concern:** Re-scope the spec-creation R-13 gates to the scoped invocation and encode the scoped-primary/workspace-secondary contract at both task-card sites.

**Files:** `.opencode/skills/spec-creation/tasks/analyze.md`; `.opencode/skills/spec-creation/tasks/create.md`; `.opencode/tests-v2/behaviors/`

**SCs:** SC-3, SC-4, SC-5

**Dependencies:** Phase 1 (Items 3 and 5 depend on the `--number` flag; Item 5 additionally depends on Item 4's contract semantics, mirrored verbatim).

**Entry Conditions:** Phase 1 VbC passed; behavioral scenarios scaffolded per `tests-v2/AGENTS.md`; each item's commit pushed and fresh-fetched to a remote ref before its behavioral run.

**Exit Conditions:** analyze.md Step 5.3 and create.md Step 6.1 invoke `validate-yaml --number <repo>#<issue>` as the progress-gating check; both sites' bodies, exit criteria, and result contracts state scoped-primary gating with the MUST-NOT-gate-on-unrelated clause; behavioral runs show the scoped invocation and pipeline completion amid unrelated violations.

**Code Path Coverage:** analyze-step R-13 gate flow (agent decides → runs gate → proceeds/BLOCKED) switches the executed command to the scoped form; create-step gate flow likewise; BLOCKED-on-target-violations preserved at both sites.

**Cross-Cutting SCs:** SC-3/SC-4/SC-5 cut across pipeline-gate-enforcement, tool-cli-semantics, and test-infrastructure concerns.

**Interface Boundaries:** The gate contract change is intentional per the spec's problem statement; the workspace-wide scan remains available as a secondary maintenance check; existing mechanics (action-first wording, command+exit-code evidence) preserved.

**State Transitions:** unrelated-drift × analyze/create gate → proceeds (was BLOCKED); target-violations × gate → BLOCKED preserved; malformed/missing issue number at gate time → fail-fast on the qualifier, never a workspace-wide fallback.

**Cost frame:** Running each with-test-home real-model gate scenario costs minutes of model-inference execution time — the behavioral tier (1× multiplier, BREAK). Skipping — or settling for the supporting grep as the verdict — costs the string-tier trap: a content PASS over text the agent may not follow at runtime leaves the gate invoking the unscoped form, and the 2451-style block re-manifests on the very next unrelated drift, blocking every spec-creation pipeline — the exact failure this spec exists to prevent, discovered only after the block.

---

- [ ] 16. **Pre-regression (**task-card**).** Run the regression patterns for the gate-scenario fixtures before RED. **→ SC-3, SC-4**
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-pre-regression-*`
- [ ] 17. **Pre-regression verify (**task-card**).** Verify the pre-regression results before RED. **→ SC-3, SC-4**
- [ ] 18. **RED (**task-card**).** Behavioral run via `bash .opencode/tests-v2/with-test-home opencode run` — a gate-running agent at the analyze step against a fixture workspace with unrelated schema violations. **→ SC-3**
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-red-*`
  - RED condition (passes-as-defect today): session.yaml shows the agent executing the unscoped workspace-wide `validate-yaml` as the gate command.
- [ ] 19. **GREEN (**task-card**).** Update analyze.md Step 5.3 to invoke `validate-yaml --number <repo>#<issue-under-analysis>` as the progress-gating check, preserving the gate's action-first wording and the command+exit-code evidence requirement. **→ SC-3**
- [ ] 20. **REFACTOR (**task-card**).** Cross-check Step 5.3's surrounding text for stale unscoped references. **→ SC-3**
- [ ] 21. **Commit (**direct**).** Commit the task-card change.
  - `git add .opencode/skills/spec-creation/tasks/analyze.md && git commit -m "docs(spec-creation): analyze R-13 gate consumes scoped validate-yaml"`
- [ ] 22. **PUSH (**direct**).** Push the commit to its remote branch; fresh `git fetch` verifies the effective commit is contained in a remote ref — mandatory before the behavioral verify run. **→ SC-3**
- [ ] 23. **Verify (behavioral, verdict basis) (**task-card**).** Re-run the scenario; session.yaml (clean-room sub-agent inspection) shows the agent executing the scoped `--number` invocation as the gate action. Supporting (never the verdict): grep analyze.md for the scoped invocation and absence of the unscoped form as the gating command. **→ SC-3**
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-verify-*`
- [ ] 24. **RED (**task-card**).** Behavioral run — the analyze pipeline against a fixture workspace whose unrelated issues violate the schema while the issue under analysis is clean. **→ SC-4**
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-red-*`
  - RED condition (passes-as-defect today): the analyze step BLOCKS on unrelated drift — the contract mandates workspace-wide gating.
- [ ] 25. **GREEN (**task-card**).** Update the analyze.md R-13 gate contract site — Step 5.3 body beyond the invocation, exit criteria, and result-contract `gate_evidence`/`blocker_reason` wording: the scoped check gates pipeline progress; the workspace-wide scan is a secondary maintenance check that MUST NOT gate pipeline progress on unrelated issues' records. Keep BLOCKED-on-target-violations semantics. **→ SC-4**
- [ ] 26. **REFACTOR (**task-card**).** Ensure exit-criteria and result-contract sentences are mutually consistent — no residual workspace-wide-remediation requirement. **→ SC-4**
- [ ] 27. **Commit (**direct**).** Commit the task-card change.
  - `git add .opencode/skills/spec-creation/tasks/analyze.md && git commit -m "docs(spec-creation): analyze gate contract scoped-primary, workspace-secondary"`
- [ ] 28. **PUSH (**direct**).** Push; fresh-fetch verify containment in a remote ref. **→ SC-4**
- [ ] 29. **Verify (behavioral, verdict basis) (**task-card**).** Re-run the scenario; session.yaml shows the analyze step completing (not BLOCKED) amid unrelated violations, with the scoped gate recorded. Supporting: grep for the scoped-primary/secondary-maintenance language, the MUST-NOT-gate clause, and absence of workspace-wide-remediation contract sentences. **→ SC-4**
- [ ] 30. **RED (**task-card**).** Behavioral run — a gate-running agent at the create step against a fixture workspace with unrelated violations. **→ SC-5**
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-red-*`
  - RED condition (passes-as-defect today): session.yaml shows the unscoped workspace-wide invocation and the pipeline blocking on unrelated drift.
- [ ] 31. **GREEN (**task-card**).** Update the create.md R-13 gate site — Step 6.1 body including its gate invocation, exit criteria, and result-contract wording: the gate invokes the scoped form `--number <repo>#<issue-being-created>`, the scoped check gates progress, and the workspace-wide scan MUST NOT gate progress on unrelated issues' records. **→ SC-5**
- [ ] 32. **REFACTOR (**task-card**).** Align exit-criteria and result-contract `gate_evidence`/`blocker_reason` wording with the analyze.md site's contract — same semantics, verbatim mandate. **→ SC-5**
- [ ] 33. **Commit (**direct**).** Commit the task-card change.
  - `git add .opencode/skills/spec-creation/tasks/create.md && git commit -m "docs(spec-creation): create R-13 gate scoped invocation + scoped-primary contract"`
- [ ] 34. **PUSH (**direct**).** Push; fresh-fetch verify containment in a remote ref. **→ SC-5**
- [ ] 35. **Verify (behavioral, verdict basis) (**task-card**).** Re-run the scenario; session.yaml shows the scoped gate invocation and pipeline completion amid unrelated violations. Supporting: grep create.md Step 6.1 body, exit criteria, and result contract for the scoped invocation, the scoped-primary/secondary-maintenance language, and the MUST-NOT-gate clause. **→ SC-5**
- [ ] 36. **Post-regression (**task-card**).** Run regression patterns across the phase's deliverables after GREEN. **→ SC-3, SC-4, SC-5**
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-post-regression-*`
- [ ] 37. **Verify (**direct**).** Confirm all three SC verdicts are behavioral PASS with session.yaml evidence artifacts on disk; no structural substitute reported as PASS. **→ SC-3, SC-4, SC-5**

#### Phase 2 Completion (VbC)

- [ ] 38. **VbC (**task-card**).** Verify SC-3, SC-4, SC-5 against session.yaml evidence: scoped invocation executed, pipeline proceeds amid unrelated violations, BLOCKED-on-target preserved. **→ SC-3, SC-4, SC-5**

**Concern transition:** Leaving gate-text scoping → entering governance-doc mandates. Phase 3 is independent of Phases 1-2 but is sequenced here per the phase DAG.

---

# Phase 3 — Governance docs — issues-data hygiene mandate

**Concern:** Encode the issues-data hygiene mandate at its two governing sites (concern-map: issues-data-governance).

**Files:** `.opencode/.issues/AGENTS.md`; `.opencode/AGENTS.md`; `.opencode/tests-v2/behaviors/`

**SCs:** SC-6, SC-7

**Dependencies:** None — independent of Phases 1-2 and Phase 4 (different concern, disjoint behavioral scenarios).

**Entry Conditions:** Pre-implementation steps complete; behavioral fixtures per `fixtures/setup/` ready; each item's commit pushed to a remote ref before its behavioral run.

**Exit Conditions:** Both hygiene doc sites carry the mandate (responsibility + ALL-files scope + authorization-free/no-spec clause); behavioral runs show drift repair without spec requests.

**Code Path Coverage:** issues-data drift repair flow (agent encounters drift → repairs directly → continues; no spec dispatch, no authorization halt).

**Cross-Cutting SCs:** SC-6/SC-7 share one hygiene mandate's semantics verbatim across two sites — each independently verifiable by its own assertion set.

**Interface Boundaries:** All doc changes additive; existing Authorization-section content and worktree correct/forbidden table preserved.

**State Transitions:** drift-present × mandate-absent → agent requests spec or halts (current defect); drift-present × mandate-present → authorization-free repair.

**Cost frame:** Running each with-test-home real-model scenario costs minutes of model-inference execution time — the behavioral tier (1× multiplier, BREAK). Skipping leaves repair authority unstated, so the next drift sits unrepaired until it blocks a pipeline — discovered only after the damage, at the 100×–1000× tier.

---

- [ ] 39. **Pre-regression (**task-card**).** Run the regression patterns for the hygiene scenarios before RED. **→ SC-6, SC-7**
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-pre-regression-*`
- [ ] 40. **Pre-regression verify (**task-card**).** Verify the pre-regression results before RED. **→ SC-6, SC-7**
- [ ] 41. **RED (**task-card**).** Behavioral run — an agent facing injected issues-data drift (fixture per `fixtures/setup/`). **→ SC-6**
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-red-*`
  - RED condition (passes-as-defect today): the agent requests a spec or halts awaiting authorization instead of repairing.
- [ ] 42. **GREEN (**task-card**).** Update `.opencode/.issues/AGENTS.md` (Authorization section) to state the mandate: it is the agent's responsibility to repair, remediate, and revise as needed ALL files in the issues-data branches to prevent problems — issue-ticket data repairs are authorization-free agent hygiene and do NOT require a spec. Encode the rationale (374-file legacy drift blocked pipelines; developer directive 2026-09-17). **→ SC-6**
- [ ] 43. **REFACTOR (**task-card**).** Ensure the mandate reads as an extension of the existing Authorization section, not a contradiction of it. **→ SC-6**
- [ ] 44. **Commit (**direct**).** Commit the doc change.
  - `git add .opencode/.issues/AGENTS.md && git commit -m "docs(issues): issues-data hygiene mandate — authorization-free agent repairs"`
- [ ] 45. **PUSH (**direct**).** Push; fresh-fetch verify containment in a remote ref. **→ SC-6**
- [ ] 46. **Verify (behavioral, verdict basis) (**task-card**).** Re-run the scenario; session.yaml shows repair actions with NO spec-creation dispatch and NO authorization halt. Supporting: grep the doc for the responsibility mandate, the ALL-files scope, and the authorization-free/no-spec clause. **→ SC-6**
- [ ] 47. **RED (**task-card**).** Behavioral run — same repair archetype as Item 6, separate site. **→ SC-7**
- [ ] 48. **GREEN (**task-card**).** Update the `.opencode/AGENTS.md` `### .issues/ Is a Worktree — NOT a Regular Directory` section with the same mandate verbatim in semantics — the section governs repair rules for the worktrees. **→ SC-7**
- [ ] 49. **REFACTOR (**task-card**).** Keep the mandate consistent with the section's existing correct/forbidden table structure. **→ SC-7**
- [ ] 50. **Commit (**direct**).** Commit the doc change.
  - `git add .opencode/AGENTS.md && git commit -m "docs: hygiene mandate in .issues worktree guidance section"`
- [ ] 51. **PUSH (**direct**).** Push; fresh-fetch verify containment in a remote ref. **→ SC-7**
- [ ] 52. **Verify (behavioral, verdict basis) (**task-card**).** Re-run the scenario; session.yaml shows repair without spec request. Supporting: grep the section for the responsibility mandate, ALL-files scope, and authorization-free/no-spec clause. **→ SC-7**

#### Phase 3 Completion (VbC)

- [ ] 53. **VbC (**task-card**).** Verify SC-6 and SC-7 against session.yaml evidence: drift repaired without spec requests at both hygiene sites. **→ SC-6, SC-7**

**Concern transition:** Leaving issues-data hygiene → entering remote-first reservation mandates. Phase 4 is independent of Phases 1-3.

---

# Phase 4 — Governance docs — remote-first reservation mandate

**Concern:** Encode the remote-first spec-number reservation mandate at its three governing sites (concern-map: spec-number-reservation).

**Files:** `.opencode/.issues/AGENTS.md`; `.opencode/skills/spec-creation/tasks/create.md`; `.opencode/skills/issue-operations-core/tasks/creation.md`; `.opencode/tests-v2/behaviors/`

**SCs:** SC-8, SC-9, SC-10

**Dependencies:** None — independent of Phases 1-3 (different concern, disjoint files within this phase's scope, no tool dependency).

**Entry Conditions:** Pre-implementation steps complete; behavioral fixtures per `fixtures/setup/` ready; remote environment (`BEHAVIOR_NEEDS_REMOTE=1` / GitBucket container per tests-v2 §12-13) available for reservation scenarios; each item's commit pushed to a remote ref before its behavioral run.

**Exit Conditions:** All three reservation doc sites carry the mandate (MUST-be-filed-FIRST + clean-room-restartable context + BEFORE-local-setup ordering + local-first-is-a-violation clause); behavioral runs show remote-first filing with resumable context.

**Code Path Coverage:** remote-first spec filing flow (remote create FIRST → take N from create response → local setup after; local-only counter path conditionally inapplicable).

**Cross-Cutting SCs:** SC-8/SC-9/SC-10 share one reservation mandate's semantics verbatim across three sites — each independently verifiable by its own assertion set.

**Interface Boundaries:** All doc changes additive; existing Workflow init/sync table, create.md Step 3 mechanics (remote stub → local at N; renumber/migrate repair; `API_FAILURE_MID_FLOW`), and creation.md Step 2.1/2.2 mechanics preserved.

**State Transitions:** local-first reservation → split-brain collision → forced renumber (observed 2450→2451); remote-first reservation → remote create serializes numbering, local at exactly N.

**Cost frame:** Running each with-test-home real-model scenario costs minutes of model-inference execution time — the behavioral tier (1× multiplier, BREAK). Skipping leaves the local-first path unmarked as a violation, so the next agent repeats the 2450-style split-brain collision — remote number assigned elsewhere, local renumber, spec rewrite — discovered only after the damage, at the 100×–1000× tier.

---

- [ ] 54. **Pre-regression (**task-card**).** Run the regression patterns for the reservation scenarios before RED. **→ SC-8, SC-9, SC-10**
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-pre-regression-*`
- [ ] 55. **Pre-regression verify (**task-card**).** Verify the pre-regression results before RED. **→ SC-8, SC-9, SC-10**
- [ ] 56. **RED (**task-card**).** Behavioral run with remote environment enabled — an agent filing a spec. **→ SC-8**
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-red-*`
  - RED condition (passes-as-defect today): the Workflow section carries no reservation mandate, so nothing prevents local-first setup.
- [ ] 57. **GREEN (**task-card**).** Update the `.opencode/.issues/AGENTS.md` Workflow section with the mandate: when a remote spec system exists (platform is not local), file the remote spec FIRST — with clear intent and context sufficient for a clean-room restart — to reserve the spec number, BEFORE any local spec folder setup; local-first reservation is a violation. Record the observed 2450 split-brain collision as the motivating defect; cross-reference (not duplicate) the numbers-must-match mandate and the `.counter` drift defect. **→ SC-8**
- [ ] 58. **REFACTOR (**task-card**).** Integrate with the section's existing init/sync workflow table without disturbing it. **→ SC-8**
- [ ] 59. **Commit (**direct**).** Commit the doc change.
  - `git add .opencode/.issues/AGENTS.md && git commit -m "docs(issues): remote-first spec-number reservation mandate in Workflow"`
- [ ] 60. **PUSH (**direct**).** Push; fresh-fetch verify containment in a remote ref. **→ SC-8**
- [ ] 61. **Verify (behavioral, verdict basis) (**task-card**).** Re-run the scenario; session.yaml shows the remote create call preceding any local record creation, with clean-room-restartable context in the remote body. Supporting: grep for the MUST-be-filed-FIRST language, the clean-room-restart clause, the BEFORE-local-setup ordering, and the violation clause. **→ SC-8**
- [ ] 62. **RED (**task-card**).** Behavioral run with remote environment enabled, driven through the spec-creation create step. **→ SC-9**
- [ ] 63. **GREEN (**task-card**).** Update create.md Step 3 (remote-number-first) with the same mandate verbatim in semantics; preserve the existing mechanics (remote stub → read N → local at exactly N; renumber/migrate repair; `API_FAILURE_MID_FLOW` BLOCKED path). **→ SC-9**
- [ ] 64. **REFACTOR (**task-card**).** Ensure the added mandate composes with Step 3.1/3.2 label flows without contradiction. **→ SC-9**
- [ ] 65. **Commit (**direct**).** Commit the task-card change.
  - `git add .opencode/skills/spec-creation/tasks/create.md && git commit -m "docs(spec-creation): reservation mandate in create Step 3"`
- [ ] 66. **PUSH (**direct**).** Push; fresh-fetch verify containment in a remote ref. **→ SC-9**
- [ ] 67. **Verify (behavioral, verdict basis) (**task-card**).** Re-run the scenario; session.yaml shows remote-first filing with resumable context. Supporting: grep Step 3 for the MUST-be-filed-FIRST language, clean-room-restart clause, BEFORE-local-setup ordering, and violation clause. **→ SC-9**
- [ ] 68. **RED (**task-card**).** Behavioral run with remote environment enabled, driven through the issue-operations creation flow. **→ SC-10**
- [ ] 69. **GREEN (**task-card**).** Update creation.md Step 2.1 (Remote-First Flow) with the same mandate verbatim in semantics; preserve the existing Remote-First Flow mechanics (promote first, extract remote number, local at the remote number, counter advancement, best-effort remote label). **→ SC-10**
- [ ] 70. **REFACTOR (**task-card**).** Ensure the mandate composes with the local-only counter path (Step 2.2) without contradiction — the mandate is conditional on a remote spec system existing. **→ SC-10**
- [ ] 71. **Commit (**direct**).** Commit the task-card change.
  - `git add .opencode/skills/issue-operations-core/tasks/creation.md && git commit -m "docs(issue-operations): reservation mandate in creation Step 2.1"`
- [ ] 72. **PUSH (**direct**).** Push; fresh-fetch verify containment in a remote ref. **→ SC-10**
- [ ] 73. **Verify (behavioral, verdict basis) (**task-card**).** Re-run the scenario; session.yaml shows remote promotion preceding local `.issues/{N}/` creation with resumable context. Supporting: grep Step 2.1 for the MUST-be-filed-FIRST language, clean-room-restart clause, BEFORE-local-setup ordering, and violation clause. **→ SC-10**

- [ ] 74. **Post-regression (**task-card**).** Run regression patterns across the phase's deliverables after GREEN. **→ SC-8, SC-9, SC-10**
- [ ] 75. **Verify (**direct**).** Confirm all three SC verdicts are behavioral PASS with session.yaml evidence artifacts on disk; no structural substitute reported as PASS. **→ SC-8, SC-9, SC-10**

#### Phase 4 Completion (VbC)

- [ ] 76. **VbC (**task-card**).** Verify SC-8, SC-9, SC-10 against session.yaml evidence: remote-first filing with clean-room-restartable context at all three reservation sites. **→ SC-8, SC-9, SC-10**

**Concern transition:** Leaving governance-doc mandates → entering post-implementation verification and PR preparation.

---

# Post-implementation (global)

- [ ] 77. **Audit (**task-card**).** Adversarial audit of the deliverable — dispatch the verification-audit investigator, then validator, evaluator, and arbiter in sequence.
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-audit-*`
  - Coercion: DONE_WITH_CONCERNS coerces to FAIL for gate purposes; EVIDENCE_TYPE_MISMATCH is a hard FAIL.
- [ ] 78. **Z3 check (**direct**).** Run the constraint solver verification directly.
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-z3-check-*`
  - Command context: `.opencode/tools/solve check --state-path <state file> --contract-path .opencode/.issues/2450/dependency-contract.yaml`
- [ ] 79. **Structural checks (**task-card**).** Run the finishing checklist (lint, typecheck, format checks) per finishing-a-development-branch.
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-structural-checks-*`
- [ ] 80. **Pre-PR gate (**task-card**).** Verify all SC verdicts — reads all SC evidence artifacts and BLOCKs if any FAIL (including coerced DONE_WITH_CONCERNS and EVIDENCE_TYPE_MISMATCH verdicts).
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-pre-pr-gate-*`
- [ ] 81. **Regression check (**task-card**).** Final full regression run before PR — the complete pytest suite plus the no-flag `validate-yaml` default-scan sanity check on both repos.
  - Clean previous artifacts: `rm -f tmp/2450/artifacts/pipeline-regression-check-*`
- [ ] 82. **Review-prep (**task-card**).** Prepare PR review context per git-workflow-pr review-prep.
- [ ] 83. **Create PR (**task-card**).** Create the stacked PR per git-workflow-pr create — one branch, commits squashed to one commit per issue at PR creation; no co-author trailers in implementation commits (added during squash at PR time).
- [ ] 84. **Exec summary (**task-card**).** Generate the completion executive summary per completion-core.

**Cost frame:** Running the full audit + pre-PR-gate chain costs minutes of execution time — the behavioral tier. Skipping costs the death-spiral tier: a FAIL SC carried into review ships the unscoped gate or an unstated mandate, and the 2451-style block or split-brain collision is discovered in production use — the 1000×+ discovery latency the entire pipeline exists to prevent.

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.

## lifecycle_events

- 2026-09-17T23:29:21Z | plan_created | plan: .opencode/.issues/2450/plan.md | phases: 4 (+ post-implementation)
