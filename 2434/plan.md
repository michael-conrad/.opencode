---
plan_schema_version: 1
issue: 2434
title: "Test-framework commit/push/fetch/checkout cycle: hard-FAIL checkout gate and mandatory pre-test cycle carve-out"
dispatch: [test-driven-development, verification-before-completion, audit, finishing-a-development-branch, git-workflow-pr, completion-core]
---

# Implementation Plan — #2434 — Hard-FAIL Checkout Gate and Mandatory Pre-Test Cycle Carve-Out

**Issue:** `.opencode#2434` — https://github.com/michael-conrad/.opencode/issues/2434
**Spec:** `.opencode/.issues/2434/spec.md`
**Structure artifact:** `.opencode/.issues/2434/artifacts/structure.yaml`

## Goal / Architecture / Files / Dispatch

**Goal:** Convert the two `with-test-home` WARNING checkout fallbacks into hard FAILs with identical guard logic, add a `behavior_run()` pre-flight git-state gate that fires before flock and model dispatch, encode the ordered commit → push → fetch/verify → run cycle across `tests-v2/AGENTS.md` §4/§5, the 091 guideline, the TDD skill, and the root lessons, then verify end-to-end via the §6a two-SC pattern.

**Architecture:** Three coordinated layers per the spec (D1–D5): (a) harness hardening — the gate predicate is "after a fresh `git fetch`, the tested submodule SHA is contained in a remote ref AND the submodule working tree is clean", enforced identically at both `with-test-home` clone+checkout sites and inside `behavior_run()` before the flock; every failure message names the commit+push+fetch remediation using the existing `FATAL:`/`HARNESS_FAILURE:` stderr-prefix conventions; (b) durable rule encoding — the directive text mirrors the implemented gate predicate on the doc surfaces (single definition, two enforcement surfaces, R-10); (c) end-to-end behavioral verification — an artifact-only generator run (SC-8) followed by a clean-room evaluation of its session.yaml (SC-9) per §6a. The intentional breaking change (exit 1 instead of WARNING) is accepted per D1; 182 `behavior_run` consumers inherit the gate unchanged (R-11).

**Files:**
- `.opencode/tests-v2/with-test-home` — both clone+checkout sites (WARNING fallback → hard FAIL, identical guard logic)
- `.opencode/tests-v2/behaviors/helpers.sh` — `behavior_run()` pre-flight gate block before the flock
- `.opencode/tests-v2/AGENTS.md` — §4 all-runs ordered cycle rewrite; §5 hard-FAIL rewrite
- `.opencode/guidelines/091-incremental-build.md` — Per-Item TDD Cycle table + behavioral-variant paragraph
- `.opencode/skills/test-driven-development/SKILL.md` — Per-Change TDD Pattern + RED-Phase Ordering
- `.opencode/AGENTS.md` — Testing Lessons Learned cycle lesson entry
- `.opencode/tests-v2/behaviors/<scenario>.sh` (new) — SC-8 artifact-only generator script

**Dispatch:** `test-driven-development` (RED/GREEN cycles, regression patterns), `verification-before-completion` (pre-regression verify, per-item verify, pre-PR gate), `audit` (adversarial verification audit), `finishing-a-development-branch` (structural checklist), `git-workflow-pr` (review-prep, PR creation), `completion-core` (executive summary). `commit-inline` and `z3-check` steps are orchestrator-direct per the implementation-workflow reference card.

## Blast Radius

- `.opencode/tests-v2/with-test-home` — both clone+checkout guard blocks converted from WARNING fallback to hard FAIL (SC-1, SC-2a, SC-2b)
- `.opencode/tests-v2/behaviors/helpers.sh` — pre-flight git-state gate inserted inside `behavior_run()` before the `exec 200>`/`flock` lines (SC-3)
- `.opencode/tests-v2/AGENTS.md` — §4 rewritten with all-runs ordered cycle; §5 rewritten with hard-FAIL language (SC-4a, SC-4b)
- `.opencode/guidelines/091-incremental-build.md` — cycle table + behavioral-variant paragraph amended (SC-5)
- `.opencode/skills/test-driven-development/SKILL.md` — PUSH step added in both pattern sections (SC-6)
- `.opencode/AGENTS.md` — new Testing Lessons Learned entry (SC-7)
- `.opencode/tests-v2/behaviors/<scenario>.sh` — new artifact-only generator (SC-8)
- **Inherited consumers:** 182 behavioral scripts under `.opencode/tests-v2/behaviors/` inherit the pre-flight gate via `behavior_run()` with zero source changes (R-11) — no per-script edits
- **Breaking change (acknowledged, D1):** `with-test-home` exit semantics change from WARNING+exit-0 to FAIL+exit-1 on uncheckoutable submodule HEAD; success path (pushed HEAD) preserved (R-14), verified by control probes

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps | Dispatch |
|-------|------|---------|-----|--------------|-------|----------|
| 1 — Harness hardening (A) | gates | with-test-home hard-FAIL gates at both clone+checkout sites + behavior_run() pre-flight gate before flock | SC-1, SC-2a, SC-2b, SC-3 | — | 3–41 | test-driven-development |
| 2 — Durable rule encoding (B) | directive-text | §4/§5, 091, TDD skill, root lessons encode the implemented cycle and gate predicate | SC-4a, SC-4b, SC-5, SC-6, SC-7 | Phase 1 | 42–92 | test-driven-development |
| 3 — End-to-end verification (C) | two-SC verification | §6a artifact-generation behavioral run + clean-room evaluation of its session.yaml | SC-8, SC-9 | Phases 1, 2 | 93–110 | test-driven-development |

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **Phase 1:** Verifying the hard-FAIL gates costs minutes of harness probe execution — each gate fires before model dispatch, catching the stale-code defect at gate 1 where the fix cost is bounded. Skipping costs weeks of silent stale-code test runs — PASS/FAIL verdicts issued against code that was never checked out, discovered only when a "passing" branch merges broken behavior.
- **Phase 2:** Verifying the directive-text encoding costs direct text reads — seconds each. Skipping costs doc/gate divergence (R-10 violation): agents read the narrow DEFAULT_TEST_MODEL note and skip the cycle for ordinary runs, converting the machine gate into a rule agents route around.
- **Phase 3:** Running the behavioral cycle test costs minutes of model execution — the bounded break cost. Skipping costs 1000× more downstream: agents ship test-framework invocations on unpushed HEAD indefinitely, and every false verdict surfaces in review or production rather than at the gate.

## Exit Criteria

- [ ] C1: All 11 SCs (SC-1, SC-2a, SC-2b, SC-3, SC-4a, SC-4b, SC-5, SC-6, SC-7, SC-8, SC-9) verified PASS with evidence artifacts
- [ ] C2: Both `with-test-home` clone+checkout sites hard-FAIL (exit 1) on uncheckoutable submodule HEAD with remediation-naming messages, and identical guard logic confirmed (SC-2b string comparison)
- [ ] C3: `behavior_run()` pre-flight gate fires before flock and model dispatch; pinned unpushed SHA FAILS with no bypass; pushed state proceeds normally
- [ ] C4: `tests-v2/AGENTS.md` §4 carries the all-runs ordered cycle framed as the infrastructure-maintenance carve-out; §5 carries no WARNING-fallback language
- [ ] C5: 091 and TDD skill encode identical PUSH-before-test ordering for behavioral items (I4 consistency)
- [ ] C6: Root AGENTS.md lessons carry a cycle lesson matching the implemented gate predicate
- [ ] C7: SC-8 behavioral run produced session.yaml; SC-9 clean-room evaluator returned PASS/FAIL with justification reading only that artifact
- [ ] C8: Audit verdict recorded; z3-check and structural checks PASS; pre-PR gate confirms no FAIL verdicts
- [ ] C9: PR created with all changes (stacked strategy; no co-author trailers in implementation commits — added at squash)

## Pre-Implementation Steps

- [ ] 1. **Coherence gate (**direct**).** Read the spec at `.opencode/.issues/2434/spec.md` and this plan; confirm the plan's phase structure, SC assignments, dependency ordering (Phase 1 → Phase 2 → Phase 3), and per-item SC mapping match the spec's Items and the structure artifact's phase decomposition. If any mismatch is found, return BLOCKED with `COHERENCE_FAIL`.
  - Verify the spec's SC table covers exactly the 11 SCs this plan maps, and that triplet colocation holds (no SC's steps split across phases)
  - SC reference: all (structure-level gate)

- [ ] 2. **Baseline check (**direct**).** Verify the current state of all affected files before modification — confirm the content matches the "before" state described in the spec. If any file has already been modified, return BLOCKED with `BASELINE_CHANGED`.
  - `.opencode/tests-v2/with-test-home`: WARNING fallback present at both clone+checkout sites
  - `.opencode/tests-v2/behaviors/helpers.sh`: no pre-flight git-state gate inside `behavior_run()`
  - `.opencode/tests-v2/AGENTS.md`: §4 push note scoped to `DEFAULT_TEST_MODEL` override; §5 documents the WARNING fallback
  - `.opencode/guidelines/091-incremental-build.md`: cycle table ends at COMMIT, PUSH absent
  - `.opencode/skills/test-driven-development/SKILL.md`: both pattern sections end at COMMIT, PUSH absent
  - `.opencode/AGENTS.md`: Testing Lessons Learned has no cycle lesson
  - SC reference: all (structure-level gate)

---

## Phase 1 — Harness Hardening (A)

**Concern:** Harness git-state gates — `with-test-home` hard-FAIL at both clone+checkout sites and the `behavior_run()` pre-flight gate before flock.

**Files:** `.opencode/tests-v2/with-test-home`, `.opencode/tests-v2/behaviors/helpers.sh`

**SCs:** SC-1, SC-2a, SC-2b, SC-3

**Dependencies:** None (first phase)

**Entry Conditions:**
- Coherence gate and baseline check passed (steps 1–2)
- `.opencode` submodule on its feature branch at remote-tracking tip with zero pending changes
- `{project_root}/tmp/` exists for pipeline artifacts (`mkdir -p tmp/2434/artifacts`)

**Exit Conditions:**
- Both `with-test-home` sites exit 1 with remediation-naming FAIL on uncheckoutable HEAD; identical guard logic at both sites; pushed-HEAD control probes pass
- `behavior_run()` pre-flight gate FAILS before flock on uncommitted/unpushed/pinned-unpushed states; pushed-state control probe proceeds to lock acquisition

### Code Path Coverage

- `with-test-home` site 1: submodule remote URL resolution → `git clone -q` → HARNESS_FAILURE on clone failure → `git checkout -q $LOCAL_SUBMODULE_COMMIT` → WARNING fallback block (SC-1)
- `with-test-home` site 2: SUBMODULE_REMOTE_URL resolution → `git clone -q` → `git checkout -q` → WARNING fallback block (SC-2a, SC-2b)
- `behavior_run()`: submodule remote URL resolution → `BEHAVIOR_SUBMODULE_COMMIT` pin resolution → `mkdir`/`exec 200>` on `tmp/.behavior-run.lock` → `flock -x -w 30` → mutual-exclusion check → GitBucket provisioning → retry loop with model dispatch (SC-3 gate inserts before the lock block)

### Cross-Cutting SCs

- SC-3 spans harness hardening (gate implementation) and durable rule encoding (Phase 2 §4 text must equal the gate predicate — R-10/D4 single-definition invariant, enforced by SC-4a and SC-7)
- SC-3's gate predicate and the SC-4a documented cycle are one definition on two enforcement surfaces; a change to one without the other forks the vocabulary

### Interface Boundaries

- `behavior_run()` function signature: UNCHANGED — the gate is inserted inside the function body before the flock; all 182 consumers keep their invocation shape (R-11)
- `with-test-home` CLI contract: EXIT-CODE CHANGE (intentional, D1) — exit 1 with remediation FAIL instead of WARNING+exit-0 on uncheckoutable HEAD; success path preserved (R-14)
- `FATAL:`/`HARNESS_FAILURE:` message-prefix convention: EXTENDED — new gate failure messages reuse the same prefixes verbatim on stderr (R-3)
- `BEHAVIOR_SUBMODULE_COMMIT`: SEMANTICS PRESERVED with one behavioral addition (R-4) — pinned unpushed SHA now FAILs instead of silently proceeding; unset and pinned-pushed paths unchanged

### State Transitions

- SC-1/SC-2a: uncheckoutable local submodule HEAD → WARNING+exit-0 degraded run becomes FAIL message naming commit+push+fetch + exit 1, no test home produced
- SC-2b: two divergent WARNING fallback blocks become identical guard logic (shared guard function or identical literal)
- SC-3: no pre-flight check becomes a pre-flight gate (clean tree AND effective commit on remote after fresh fetch — honoring the pin) that FAILS before `exec 200>`/`flock`; clean pushed state passes unchanged (R-14); shared-home reuse path still validated (R-13)

**Cost frame:** Verifying the Phase 1 gates costs minutes of harness probe execution — the gates fire before model dispatch, catching the stale-code defect at gate 1 where the fix cost is bounded. Skipping costs weeks of silent stale-code test runs and contaminated RED/GREEN verdicts that poison every downstream SC decision on the branch.

### Item 1 — with-test-home site 1 hard-FAIL gate (SC-1)

- [ ] 3. **Pre-clean (**direct**).** Remove stale pipeline artifacts for this step and subsequent steps: `rm -f tmp/2434/artifacts/pipeline-pre-regression-* tmp/2434/artifacts/pipeline-pre-regression-verify-* tmp/2434/artifacts/pipeline-red-*`
  - SC reference: SC-1

- [ ] 4. **Pre-regression (**task-card**).** Dispatch regression-test-pattern run before RED — verify the current `with-test-home` and `helpers.sh` behavior against existing regression patterns so the baseline is green before the gate work begins.
  - Dispatch: `task(..., prompt: "execute phase-0 task from test-driven-development")`
  - SC reference: SC-1

- [ ] 5. **Pre-regression verify (**task-card**).** Verify the pre-regression results; block the RED phase if the baseline is not green.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-1

- [ ] 6. **RED (**task-card**).** Write a failing enforcement test for SC-1: a fixture local submodule commit left unpushed, probed through the `with-test-home` site-1 clone+checkout path. The assertion expects exit 1 and a failure message naming the commit+push+fetch remediation. The test FAILS today because the WARNING fallback emits a warning and exits 0.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - RED describes what fails: uncheckoutable HEAD produces a degraded run instead of a hard FAIL
  - SC reference: SC-1

- [ ] 7. **GREEN (**task-card**).** Implement the minimum change that makes the RED test pass: replace the WARNING fallback block at the site-1 clone+checkout path with a hard FAIL (exit 1) whose message names the commit+push+fetch remediation using the `FATAL:`/`HARNESS_FAILURE:` prefix convention; no test home is produced from the wrong ref.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - GREEN describes what must be true: uncheckoutable HEAD → exit 1 + remediation message; no WARNING fallback survives at site 1
  - SC reference: SC-1

- [ ] 8. **Post-regression (**task-card**).** Run regression test patterns after GREEN — confirm the site-1 gate did not break existing `with-test-home` behavior.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-1

- [ ] 9. **Verify (**task-card**).** Verify SC-1 against its success criterion: control probe with a pushed HEAD → normal setup completes (no false positive); re-run the RED probe → exit 1 with the remediation message; no test home produced from the wrong ref.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-1

- [ ] 10. **Commit-inline (**direct**).** Stage and commit the site-1 gate block: `git add .opencode/tests-v2/with-test-home && git commit -m "test-framework: hard-FAIL gate at with-test-home clone+checkout site 1 (.opencode#2434 SC-1)"`
  - Test and implementation committed as one atomic slice; no co-author trailers
  - SC reference: SC-1

### Item 2a — with-test-home site 2 hard-FAIL gate (SC-2a)

- [ ] 11. **Pre-clean (**direct**).** Remove stale artifacts: `rm -f tmp/2434/artifacts/pipeline-red-* tmp/2434/artifacts/pipeline-green-*`
  - SC reference: SC-2a

- [ ] 12. **RED (**task-card**).** Write a failing enforcement test for SC-2a: the Item 1 unpushed-SHA probe exercised through the site-2 invocation path. The assertion expects exit 1 and the same remediation-naming message; the test FAILS today because site 2 still carries the WARNING fallback exiting 0.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - SC reference: SC-2a

- [ ] 13. **GREEN (**task-card**).** Mirror the SC-1 change at site 2 using the shared guard function or identical literal established in Item 1 — identical hard-FAIL behavior and remediation message through the site-2 invocation path.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - SC reference: SC-2a

- [ ] 14. **Post-regression (**task-card**).** Run regression test patterns after GREEN.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-2a

- [ ] 15. **Verify (**task-card**).** Verify SC-2a: both-site probe run through the site-2 path exits 1 with the remediation message; control probe with pushed HEAD through the site-2 path completes normally (no false positive).
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-2a

- [ ] 16. **Commit-inline (**direct**).** Stage and commit the site-2 gate block: `git add .opencode/tests-v2/with-test-home && git commit -m "test-framework: hard-FAIL gate at with-test-home clone+checkout site 2, identical guard logic (.opencode#2434 SC-2a, SC-2b)"`
  - SC reference: SC-2a, SC-2b

### Item 2b — both-site identical guard logic (SC-2b)

- [ ] 17. **Pre-clean (**direct**).** Remove stale artifacts: `rm -f tmp/2434/artifacts/pipeline-red-* tmp/2434/artifacts/pipeline-green-*`
  - SC reference: SC-2b

- [ ] 18. **RED (**task-card**).** Write a failing string-comparison test for SC-2b: direct text comparison of the two site guard blocks expects identical guard logic; the test FAILS while the sites differ (RED state exists only if Item 2a has not landed the mirror — if Item 2a landed the identical guard already, the test passes and the RED state is documented from the pre-Item-2a snapshot).
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - SC reference: SC-2b

- [ ] 19. **GREEN (**task-card**).** Confirm both sites carry identical guard logic after the Item 2a mirror — shared guard function or identical literal; make any residual divergence identical.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - SC reference: SC-2b

- [ ] 20. **Post-regression (**task-card**).** Run regression test patterns after GREEN.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-2b

- [ ] 21. **Verify (**task-card**).** Verify SC-2b: direct text comparison of both site guard blocks confirms identical guard logic.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-2b

- [ ] 22. **Commit-inline (**direct**).** Commit is shared with Item 2a per the spec (Item 2b's commit lands inside the Item 2a commit); if Item 2a's commit already contains the identical guard, this step records the SC-2b verification artifact only — no empty commit. `git add tmp/2434/artifacts/ && git commit -m "test-framework: record SC-2b guard-identity verification (.opencode#2434 SC-2b)"` (skip the git commit when there is nothing to commit; the artifact records the verdict)
  - SC reference: SC-2b

### Item 3 — behavior_run() pre-flight cycle gate (SC-3)

- [ ] 23. **Pre-clean (**direct**).** Remove stale artifacts: `rm -f tmp/2434/artifacts/pipeline-red-* tmp/2434/artifacts/pipeline-green-* tmp/.behavior-run.lock`
  - SC reference: SC-3

- [ ] 24. **RED (**task-card**).** Write failing enforcement tests for SC-3: a `behavior_run` probe with unpushed/uncommitted fixture state expects FAIL before the flock acquisition completes and before any model dispatch; a negative probe with `BEHAVIOR_SUBMODULE_COMMIT` pinned to an unpushed SHA expects FAIL (no bypass). The tests FAIL today because no pre-flight git-state gate exists.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - SC reference: SC-3

- [ ] 25. **GREEN (**task-card**).** Implement the pre-flight gate block inside `behavior_run()` before the lock acquisition: submodule working tree clean (`git status --porcelain` empty) AND the effective commit (`BEHAVIOR_SUBMODULE_COMMIT` pin when set, else the applicable HEAD) contained in a remote ref after a fresh `git fetch` — honoring the pin rather than bypassing (R-4). On failure, emit `FATAL:`/`HARNESS_FAILURE:` message naming the commit+push+fetch remediation and return 1 before `exec 200>`/`flock`.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - GREEN describes what must be true: gate fires before flock on all failing states; pinned unpushed SHA FAILS; no cached SHAs (R-13); 182 consumers unchanged (R-11)
  - SC reference: SC-3

- [ ] 26. **Post-regression (**task-card**).** Run regression test patterns after GREEN — confirm `behavior_run()`'s existing behavior (lock contention, mutual exclusion, GitBucket provisioning, retry loop) is unchanged on the passing path.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-3

- [ ] 27. **Verify (**task-card**).** Verify SC-3: control probe with pushed state → proceeds to lock acquisition and model dispatch; pinned-unpushed negative probe FAILs (no bypass); uncommitted-state probe FAILs before flock; gate ordering precedes the flock lines.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-3

- [ ] 28. **Commit-inline (**direct**).** Stage and commit the pre-flight gate block: `git add .opencode/tests-v2/behaviors/helpers.sh && git commit -m "test-framework: behavior_run() pre-flight commit/push/fetch/verify gate before flock (.opencode#2434 SC-3)"`
  - SC reference: SC-3

#### Phase 1 VbC

- [ ] 29. **VbC (**task-card**).** Verify Phase 1 completion: both sites hard-FAIL identically on uncheckoutable HEAD (SC-1, SC-2a), guard identity confirmed (SC-2b), `behavior_run()` pre-flight gate fires before flock with no bypass and no false positive (SC-3). All four SCs carry evidence artifacts.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-1, SC-2a, SC-2b, SC-3

**Concern transition:** Leaving harness hardening → entering durable rule encoding. Phase 2 encodes the gate predicate Phase 1 implemented — the directive text must match the machine gates exactly (R-10).

---

## Phase 2 — Durable Rule Encoding (B)

**Concern:** Directive-text documentation of the ordered commit → push → fetch/verify → run cycle across `tests-v2/AGENTS.md` §4/§5, the 091 guideline, the TDD skill, and the root AGENTS.md lessons — encoding the IMPLEMENTED gate behavior from Phase 1.

**Files:** `.opencode/tests-v2/AGENTS.md`, `.opencode/guidelines/091-incremental-build.md`, `.opencode/skills/test-driven-development/SKILL.md`, `.opencode/AGENTS.md`

**SCs:** SC-4a, SC-4b, SC-5, SC-6, SC-7

**Dependencies:** Phase 1 (the documented cycle must encode the IMPLEMENTED gate behavior — prose written before the gates exist risks documenting a predicate the implementation contradicts)

**Entry Conditions:**
- Phase 1 complete: all gates installed and verified (Phase 1 VbC passed)
- The gate predicate text from Phase 1 is available as the encoding source (R-10/D4)

**Exit Conditions:**
- §4 carries the all-runs ordered cycle framed as the infrastructure-maintenance carve-out; §5 describes the hard FAIL with no fallback language
- 091 and the TDD skill encode identical PUSH-before-test ordering for behavioral items (I4)
- Root AGENTS.md lessons carry a cycle lesson matching the implemented gate predicate

### Code Path Coverage

- `tests-v2/AGENTS.md` §4: documentation block containing the narrow `DEFAULT_TEST_MODEL` push note and the FORBIDDEN authorization-solicitation block (SC-4a)
- `tests-v2/AGENTS.md` §5: Submodule Checkout paragraph describing the WARNING fallback and the MUST-push sentence (SC-4b)
- `guidelines/091-incremental-build.md`: Per-Item TDD Cycle table + behavioral-variant paragraph (SC-5)
- `skills/test-driven-development/SKILL.md`: Per-Change TDD Pattern table + RED-Phase Ordering numbered list (SC-6)
- `.opencode/AGENTS.md`: Testing Lessons Learned lesson list (SC-7)

### Cross-Cutting SCs

- SC-4a spans durable rule encoding (§4 rewrite) and harness hardening (same predicate as the SC-3 gate) — §4 cycle ordering must mirror the gate's actual check sequence
- SC-5/SC-6 span the 091 guideline and the TDD skill — ordering identical across both (I4), no contradiction with the #2433 commit-inline plan pattern
- SC-7 spans durable rule encoding (root lessons) and harness hardening — lesson text must match the implemented gate predicate (no stale-code claims)

### Interface Boundaries

- `tests-v2/AGENTS.md` §4/§5: CONTENT REVISION — §4 narrow `DEFAULT_TEST_MODEL` note broadened to all-runs cycle; §5 WARNING-fallback language removed; no section renumbering; §1/§2/§3/§6a consumers (Items 8–9) unaffected
- TDD cycle vocabulary (091 + TDD skill): EXTENDED — PUSH step between COMMIT and next RED for behavioral items, ordering identical (I4); non-behavioral item cycles unchanged; no contradiction with #2433 commit-inline plan pattern
- §4 infrastructure-maintenance carve-out: the authorization basis for agent commit+push remediation — extended to all runs, never re-scoped to a single env var

### State Transitions

- SC-4a: §4 push-before-test rule scoped to `DEFAULT_TEST_MODEL` override → ordered cycle documented as required for ALL behavioral runs, framed as the §4 infrastructure-maintenance carve-out
- SC-4b: §5 documents WARNING fallback → §5 describes the hard FAIL; no WARNING-fallback language survives
- SC-5: 091 cycle COMMIT-last/PUSH-absent → behavioral items commit+push precede the behavioral test run
- SC-6: TDD skill both pattern sections end at COMMIT → PUSH step present between COMMIT and next RED
- SC-7: 6 lessons with none on the cycle → 7 entries, the new one matching the implemented gate predicate and referencing the §4 carve-out

**Cost frame:** Verifying the Phase 2 text encodings costs direct text reads — seconds each. Skipping costs doc/gate divergence: agents read the narrow `DEFAULT_TEST_MODEL` note and skip the cycle for ordinary runs, and the 091/TDD vocabulary fork guarantees contradictory ordering compliance.

### Item 4a — tests-v2/AGENTS.md §4 cycle documentation (SC-4a)

- [ ] 30. **Pre-clean (**direct**).** Remove stale artifacts: `rm -f tmp/2434/artifacts/pipeline-red-* tmp/2434/artifacts/pipeline-green-*`
  - SC reference: SC-4a

- [ ] 31. **Pre-regression (**task-card**).** Re-run regression patterns before the Phase 2 RED phase (baseline refresh for the doc-encoding phase).
  - Dispatch: `task(..., prompt: "execute phase-0 task from test-driven-development")`
  - SC reference: SC-4a

- [ ] 32. **Pre-regression verify (**task-card**).** Verify the pre-regression results.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-4a

- [ ] 33. **RED (**task-card**).** Write a failing string check for SC-4a: §4 must contain the ordered precondition cycle (commit → push → fetch/verify → run) with all-runs scope. The check FAILS today because §4 scopes the push note to the `DEFAULT_TEST_MODEL` override.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - SC reference: SC-4a

- [ ] 34. **GREEN (**task-card**).** Rewrite §4 with the all-runs ordered cycle framed as the test-framework infrastructure-maintenance carve-out — the documented cycle mirrors the Phase 1 gate's actual check sequence (R-10/D4).
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - SC reference: SC-4a

- [ ] 35. **Post-regression (**task-card**).** Run regression test patterns after GREEN.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-4a

- [ ] 36. **Verify (**task-card**).** Verify SC-4a: direct text read confirms the ordered-cycle text present with all-runs scope.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-4a

- [ ] 37. **Commit-inline (**direct**).** Stage and commit the §4 section: `git add .opencode/tests-v2/AGENTS.md && git commit -m "test-framework: §4 all-runs ordered cycle as infrastructure-maintenance carve-out (.opencode#2434 SC-4a)"`
  - SC reference: SC-4a

### Item 4b — tests-v2/AGENTS.md §5 hard-FAIL documentation (SC-4b)

- [ ] 38. **Pre-clean (**direct**).** Remove stale artifacts: `rm -f tmp/2434/artifacts/pipeline-red-* tmp/2434/artifacts/pipeline-green-*`
  - SC reference: SC-4b

- [ ] 39. **RED (**task-card**).** Write a failing string check for SC-4b: §5 must describe the hard FAIL and contain no WARNING-fallback language. The check FAILS today because §5 documents the WARNING fallback.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - SC reference: SC-4b

- [ ] 40. **GREEN (**task-card**).** Rewrite §5 Submodule Checkout to describe the hard-FAIL checkout behavior with no fallback language.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - SC reference: SC-4b

- [ ] 41. **Post-regression (**task-card**).** Run regression test patterns after GREEN.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-4b

- [ ] 42. **Verify (**task-card**).** Verify SC-4b: direct text read confirms no "using remote default branch" WARNING-fallback claim survives in §5; FAIL behavior described.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-4b

- [ ] 43. **Commit-inline (**direct**).** Stage and commit the §5 section (may share the Item 4a commit when both land together): `git add .opencode/tests-v2/AGENTS.md && git commit -m "test-framework: §5 hard-FAIL checkout documentation, fallback language removed (.opencode#2434 SC-4b)"` — if Item 4a's commit already contains the §5 rewrite, skip the duplicate commit and record the verdict artifact
  - SC reference: SC-4b

### Item 5 — 091-incremental-build.md ordering amendment (SC-5)

- [ ] 44. **Pre-clean (**direct**).** Remove stale artifacts: `rm -f tmp/2434/artifacts/pipeline-red-* tmp/2434/artifacts/pipeline-green-*`
  - SC reference: SC-5

- [ ] 45. **RED (**task-card**).** Write a failing string check for SC-5: the Per-Item TDD Cycle table and behavioral-variant paragraph must encode push-before-test ordering for behavioral items. The check FAILS today because COMMIT is last and PUSH is absent.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - SC reference: SC-5

- [ ] 46. **GREEN (**task-card**).** Amend the cycle table and the behavioral-variant paragraph so behavioral items commit+push before the behavioral test run — ordering consistent with the TDD skill (Item 6) and not contradicting the #2433 commit-inline plan pattern (I4).
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - SC reference: SC-5

- [ ] 47. **Post-regression (**task-card**).** Run regression test patterns after GREEN.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-5

- [ ] 48. **Verify (**task-card**).** Verify SC-5: direct text read confirms push-before-test ordering; cross-read the TDD skill for consistency (I4).
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-5

- [ ] 49. **Commit-inline (**direct**).** Stage and commit the 091 cycle sections: `git add .opencode/guidelines/091-incremental-build.md && git commit -m "guidelines: 091 per-item TDD cycle encodes commit+push before behavioral test run (.opencode#2434 SC-5)"`
  - SC reference: SC-5

### Item 6 — TDD SKILL.md PUSH step (SC-6)

- [ ] 50. **Pre-clean (**direct**).** Remove stale artifacts: `rm -f tmp/2434/artifacts/pipeline-red-* tmp/2434/artifacts/pipeline-green-*`
  - SC reference: SC-6

- [ ] 51. **RED (**task-card**).** Write a failing string check for SC-6: a PUSH step must appear between COMMIT and the next RED in the Per-Change TDD Pattern and the RED-Phase Ordering. The check FAILS today because both end at COMMIT with PUSH absent.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - SC reference: SC-6

- [ ] 52. **GREEN (**task-card**).** Add the PUSH step to both tables/lists with ordering identical to 091 (I4) — scoped to behavioral items.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - SC reference: SC-6

- [ ] 53. **Post-regression (**task-card**).** Run regression test patterns after GREEN.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-6

- [ ] 54. **Verify (**task-card**).** Verify SC-6: direct text read of both locations confirms the PUSH step between COMMIT and next RED; consistency read against 091 (I4).
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-6

- [ ] 55. **Commit-inline (**direct**).** Stage and commit the TDD skill pattern sections: `git add .opencode/skills/test-driven-development/SKILL.md && git commit -m "skills: TDD SKILL.md gains PUSH step between COMMIT and next RED for behavioral items (.opencode#2434 SC-6)"`
  - SC reference: SC-6

### Item 7 — Root AGENTS.md Testing Lessons Learned entry (SC-7)

- [ ] 56. **Pre-clean (**direct**).** Remove stale artifacts: `rm -f tmp/2434/artifacts/pipeline-red-* tmp/2434/artifacts/pipeline-green-*`
  - SC reference: SC-7

- [ ] 57. **RED (**task-card**).** Write a failing string check for SC-7: the Testing Lessons Learned section must contain a commit/push/fetch cycle lesson. The check FAILS today because no such lesson exists.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - SC reference: SC-7

- [ ] 58. **GREEN (**task-card**).** Add the lesson entry referencing the implemented gate behavior and the §4 carve-out — lesson text matches the Phase 1 gate predicate (no stale-code claims).
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - SC reference: SC-7

- [ ] 59. **Post-regression (**task-card**).** Run regression test patterns after GREEN.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-7

- [ ] 60. **Verify (**task-card**).** Verify SC-7: direct text read confirms the lesson present and consistent with the implemented gate predicate.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-7

- [ ] 61. **Commit-inline (**direct**).** Stage and commit the lessons entry: `git add .opencode/AGENTS.md && git commit -m "AGENTS.md: Testing Lessons Learned gains commit/push/fetch cycle lesson (.opencode#2434 SC-7)"`
  - SC reference: SC-7

#### Phase 2 VbC

- [ ] 62. **VbC (**task-card**).** Verify Phase 2 completion: §4 all-runs cycle present (SC-4a), §5 fallback language gone (SC-4b), 091 and TDD skill orderings identical and consistent (SC-5, SC-6, I4), lessons entry matches the gate predicate (SC-7). All five SCs carry evidence artifacts.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-4a, SC-4b, SC-5, SC-6, SC-7

**Concern transition:** Leaving durable rule encoding → entering end-to-end verification. Phase 3 measures the landed rule set (Phases 1–2) through a real agent run.

---

## Phase 3 — End-to-End Verification (C)

**Concern:** §6a two-SC pattern — artifact-generation behavioral run (SC-8) then clean-room evaluation of its session.yaml (SC-9).

**Files:** `.opencode/tests-v2/behaviors/<scenario>.sh` (new), evaluation verdict artifact (per §2 conventions)

**SCs:** SC-8, SC-9

**Dependencies:** Phase 1 (the behavioral run exercises the hardened harness gates directly), Phase 2 (the agent-under-test follows the cycle because the directive text landed)

**Entry Conditions:**
- Phases 1 and 2 complete with VbC passed
- Verified local model available (`qwen3.8:27b-256k-gguf4` per tests-v2/AGENTS.md §10.4 — no fabricated unavailability claims)
- `{project_root}/tmp/` clean of stale locks (`rm -f tmp/.behavior-run.lock` before the run)

### Code Path Coverage

- New artifact-only generator script: fixture setup (§3 Step 0b if repo-state setup is needed) → `behavior_run` with a real-domain test-framework-fix prompt → session.yaml export to the artifact dir (SC-8)
- Clean-room evaluation: `session-to-timeline` processing of SC-8's session.yaml → evaluator verdict artifact (SC-9)

### Cross-Cutting SCs

- SC-8 spans end-to-end verification (behavioral run) and durable rule encoding — it measures the effect of the Phase B rule changes; running it before Phase 2 lands measures nothing
- SC-9 strictly consumes SC-8's session.yaml — no orchestrator reasoning may leak to the evaluator (R-15)

### Interface Boundaries

- Artifact-only generator paradigm (tests-v2/AGENTS.md §1): the script generates artifacts and exits 0 — it NEVER evaluates model output; `assert_*` calls, `OVERALL_RESULT`, and inline grep checks are PROHIBITED
- session.yaml (SQLite DB export) is the PRIMARY evaluation source (§2) — stdout.log/stderr.log grep is PROHIBITED for behavioral evaluation
- Clean-room evaluator receives ONLY the artifact path + the SC-9 criterion (R-15/§6a)

### State Transitions

- SC-8: agent runs behavioral tests with unpushed/uncommitted submodule state (today's orphaned-STALE-GREEN pattern) → agent, given a real-domain test-framework fix task via `opencode run`, commits and pushes submodule changes BEFORE invoking the test framework — evidenced in session.yaml
- SC-9: no verdict exists → clean-room evaluator returns PASS/FAIL with one-sentence justification, recorded as a verdict artifact; evaluator saw only artifact path + criterion

**Cost frame:** Verifying the Phase 3 cycle compliance costs minutes of model execution — the bounded break cost. Skipping costs 1000× more downstream: agents ship test-framework invocations on unpushed HEAD indefinitely, and every false verdict surfaces in review or production rather than at the gate.

### Item 8 — Agent follows the cycle, artifact generation (SC-8)

- [ ] 63. **Pre-clean (**direct**).** Remove stale artifacts and locks: `rm -f tmp/2434/artifacts/pipeline-red-* tmp/2434/artifacts/pipeline-green-* tmp/.behavior-run.lock`
  - SC reference: SC-8

- [ ] 64. **Pre-regression (**task-card**).** Re-run regression patterns before the Phase 3 RED probe.
  - Dispatch: `task(..., prompt: "execute phase-0 task from test-driven-development")`
  - SC reference: SC-8

- [ ] 65. **Pre-regression verify (**task-card**).** Verify the pre-regression results.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-8

- [ ] 66. **RED (**task-card**).** Write the new behavioral test script (artifact-only generator per §1): it runs `opencode run` via the harness with a real-domain test-framework-fix prompt (natural-behavior prompt per §11 — no prose-recall) and produces session.yaml. The RED state is today's behavior where the agent runs tests with unpushed HEAD; SC-8's criterion (agent committed+pushed before invoking the test framework) is evaluated in Item 9.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Per §15 targeted-execution mandate: exactly one named scenario run for this SC's RED need — no directory enumeration, no whole-suite invocation
  - Cross-reference header (§1) included in the script
  - SC reference: SC-8

- [ ] 67. **GREEN — n/a (**direct**).** GREEN is n/a for this item: the rule changes landed in Items 4–7; this item re-verifies end-to-end that the cycle is followed. Record the n/a rationale in the step's evidence artifact.
  - SC reference: SC-8

- [ ] 68. **Behavioral run (**direct**).** Execute the new scenario script via the bash tool with `timeout` >= 600000ms — one run for this SC's GREEN-need evidence (§15). Monitor semantically per §14: poll the live session DB at intervals, abort on hard-abort signals, and record the poll log alongside the artifacts.
  - Launch per §14: background launch with interval polling — never a blind full-timeout wait
  - SC reference: SC-8

- [ ] 69. **Post-regression (**task-card**).** Run regression test patterns after the behavioral run.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-8

- [ ] 70. **Verify (**task-card**).** Verify SC-8: script exits 0 with session.yaml artifact produced in the §2 artifact directory (manifest.yaml, session.yaml, stdout.log, stderr.log, exit_code present; `source_db` not MISSING).
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-8

- [ ] 71. **Commit-inline (**direct**).** Stage and commit the new scenario script (+ fixture setup if repo-state setup was needed per §3 Step 0b): `git add .opencode/tests-v2/behaviors/<scenario>.sh && git commit -m "test-framework: SC-8 artifact-only generator scenario for commit/push/fetch cycle compliance (.opencode#2434 SC-8)"`
  - SC reference: SC-8

### Item 9 — Clean-room evaluation of SC-8 artifacts (SC-9)

- [ ] 72. **Pre-clean (**direct**).** Remove stale artifacts: `rm -f tmp/2434/artifacts/pipeline-green-* tmp/2434/artifacts/pipeline-verify-*`
  - SC reference: SC-9

- [ ] 73. **RED — n/a (**direct**).** RED is n/a for this item: evaluation dispatch — no code change. Record the n/a rationale in the step's evidence artifact.
  - SC reference: SC-9

- [ ] 74. **GREEN (**task-card**).** Dispatch a clean-room sub-agent that reads ONLY the SC-8 session.yaml path and the SC-9 criterion ("agent committed and pushed submodule changes before invoking the test framework"), returning PASS/FAIL with a one-sentence justification. The evaluator receives no orchestrator reasoning, no expected outcomes, and no cached results (R-15/§6a).
  - Dispatch: `task(..., prompt: "Read session.yaml from {SC-8 artifact path}. Evaluate whether the agent's tool calls and decisions satisfy SC-9: agent committed and pushed submodule changes before invoking the test framework. Return PASS/FAIL with a one-sentence justification.")`
  - SC reference: SC-9

- [ ] 75. **Post-regression (**task-card**).** Run regression test patterns after the evaluation dispatch.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-9

- [ ] 76. **Verify (**task-card**).** Verify SC-9: verdict recorded from SC-8 artifacts; evaluator received only the artifact path and the criterion — no orchestrator reasoning or expected outcomes.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-9

- [ ] 77. **Commit-inline (**direct**).** Commit the evaluation verdict artifact per §2 conventions: `git add tmp/2434/artifacts/ && git commit -m "test-framework: SC-9 clean-room evaluation verdict for cycle compliance (.opencode#2434 SC-9)"`
  - SC reference: SC-9

#### Phase 3 VbC

- [ ] 78. **VbC (**task-card**).** Verify Phase 3 completion: SC-8 session.yaml artifact exists with exit 0; SC-9 clean-room verdict recorded with justification and clean-room isolation confirmed. Both SCs carry evidence artifacts.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-8, SC-9

**Concern transition:** Leaving end-to-end verification → entering post-implementation gates. All 11 SCs must be verified PASS before the audit and PR gates run.

---

## Post-Implementation Steps

- [ ] 79. **Audit (**task-card**).** Adversarial audit of the deliverable against the spec — plan fidelity (per-phase cost frames per dark-prose-007, daisy-chain, per-item SC mapping), cross-validation of verification results, and independent re-verification of deliverables modified in response to audit findings.
  - Dispatch: `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence
  - SC reference: all

- [ ] 80. **z3-check (**direct**).** Run the Z3 constraint solver verification of the phase state against the dependency contract: `.opencode/tools/solve check --state-path .opencode/.issues/2434/artifacts/state-z3-goal.yaml --contract-path .opencode/.issues/2434/dependency-contract.yaml` — the expected UNSAT-with-caveat result (goal state conflicts with the contract's initial-state preconditions; goal reachability was proven SAT by the model query recorded in artifacts/solve-output.yaml, per the #2429/#2433 precedent). Record the output to `tmp/2434/artifacts/pipeline-z3-check-*`.
  - SC reference: all

- [ ] 81. **Structural checks (**task-card**).** Run the finishing checklist (lint, typecheck, markdown format checks, dead-code scan as applicable to the modified files).
  - Dispatch: `task(..., prompt: "execute checklist task from finishing-a-development-branch")`
  - SC reference: all

- [ ] 82. **Pre-PR gate (**task-card**).** Read all SC verdicts — SC-1, SC-2a, SC-2b, SC-3, SC-4a, SC-4b, SC-5, SC-6, SC-7, SC-8, SC-9 — and BLOCK if any verdict is FAIL (DONE_WITH_CONCERNS coerces to FAIL per the implementation-workflow coercion rules; EVIDENCE_TYPE_MISMATCH coerces to FAIL).
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: all

- [ ] 83. **Regression check (**task-card**).** Final regression check before PR.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: all

- [ ] 84. **Review-prep (**task-card**).** Prepare PR review context.
  - Dispatch: `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`
  - SC reference: all

- [ ] 85. **Create PR (**task-card**).** Create the pull request (stacked strategy — one branch, squashed commits per issue, PR targets the trunk).
  - Dispatch: `task(..., prompt: "execute create task from git-workflow-pr")`
  - Co-author trailers are added during squash at PR time, never in implementation commits
  - SC reference: all

- [ ] 86. **Executive summary (**task-card**).** Generate the completion executive summary and append the lifecycle event.
  - Dispatch: `task(..., prompt: "execute completion task from completion-core")`
  - SC reference: all

---

## Verification Coverage Matrix

| SC | Item | Phase | Evidence Type | Verification |
|----|------|-------|---------------|--------------|
| SC-1 | Item 1 | 1 | behavioral | unpushed-HEAD probe → exit 1 + remediation message; pushed-HEAD control → normal setup |
| SC-2a | Item 2a | 1 | behavioral | site-2 path probe → exit 1 + remediation message; site-2 control → normal setup |
| SC-2b | Item 2b | 1 | string | direct text comparison — identical guard blocks |
| SC-3 | Item 3 | 1 | behavioral | unpushed/uncommitted probe → FAIL before flock; pinned-unpushed → FAIL; pushed control → lock acquisition |
| SC-4a | Item 4a | 2 | string | direct text read of §4 — ordered cycle, all-runs scope |
| SC-4b | Item 4b | 2 | string | direct text read of §5 — no fallback language |
| SC-5 | Item 5 | 2 | string | direct text read of 091 cycle table + behavioral paragraph |
| SC-6 | Item 6 | 2 | string | direct text read of both TDD skill pattern sections |
| SC-7 | Item 7 | 2 | string | direct text read of lessons section |
| SC-8 | Item 8 | 3 | behavioral | behavioral run → exit 0 + session.yaml artifact |
| SC-9 | Item 9 | 3 | behavioral | clean-room evaluator verdict from SC-8 session.yaml |