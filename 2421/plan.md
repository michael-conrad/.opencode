---
plan_schema_version: 1
issue: 2421
title: "Mandatory live-registry verification of dependency versions before pinning"
dispatch: [test-driven-development, verification-before-completion, audit, finishing-a-development-branch, git-workflow-pr, completion-core]
---

# Plan — Mandatory live-registry verification of dependency versions before pinning

Issue: [.opencode#2421](https://github.com/michael-conrad/.opencode/issues/2421)

## Goal

Add a directive to 070-environment.md mandating live-registry verification of dependency version numbers before pinning (naming PyPI, npm, crates.io, with the justified-older-pin exception and the training-data recall prohibition), route agents to it via a Read-link cross-reference in 075-docs-verification.md, and enforce it with a behavioral test scenario plus clean-room evaluation, plus a standalone content-verification test.

## Architecture

The directive lives in EXACTLY one place — the §Version Pinning (MANDATORY) area of `.opencode/guidelines/070-environment.md` (R-5). 075-docs-verification.md carries only a Read [Text](path) link routing to the directive, never duplicated text (fragmentation prevention). The behavioral enforcement follows the two-SC pattern (SC-3 artifact-only generator + SC-4 clean-room evaluation of session.yaml — PRIMARY evidence source) per tests-v2/AGENTS.md §1, §2, §6a, §11, avoiding EVIDENCE_TYPE_MISMATCH. A standalone content-verification test (SC-5) asserts the directive text is present in 070-environment.md following the 2411/2419 precedent (not registered in test-enforcement.sh). The shared harness (helpers.sh, with-test-home) and test-enforcement.sh registration are NOT modified (R-14).

## Files

- `.opencode/guidelines/070-environment.md`
- `.opencode/guidelines/075-docs-verification.md`
- `.opencode/tests-v2/behaviors/` (new scenario script `2421-sc1-live-registry-verification.sh`)
- `.opencode/tests-v2/test-2421-sc1-directive-present.sh` (new standalone test)

## Dispatch

| Phase | Concern | Skill(s) |
|-------|---------|----------|
| 1 | 070-environment.md directive (SC-1) | test-driven-development, verification-before-completion |
| 2 | 075-docs-verification.md cross-reference (SC-2) | test-driven-development, verification-before-completion |
| 3 | Behavioral test generation + clean-room evaluation (SC-3, SC-4) | test-driven-development, verification-before-completion |
| 4 | Content-verification test (SC-5) | test-driven-development, verification-before-completion |
| Post | audit, structural, PR, completion | audit, finishing-a-development-branch, verification-before-completion, test-driven-development, git-workflow-pr, completion-core |

## Blast Radius

The change touches two guideline files, one new behavioral scenario script, and one new standalone content test. Impact zones: `.opencode/guidelines/070-environment.md` (§Version Pinning area only, existing `~=` mandates unchanged), `.opencode/guidelines/075-docs-verification.md` (§What Must Be Verified / §Related Guidelines area only), `.opencode/tests-v2/behaviors/` (new scenario script, harness NOT touched), and `.opencode/tests-v2/` (new standalone test). Explicitly excluded from scope: renaming/relocating dependency-addition workflows (REQ-N1), lockfile regeneration/update tooling (REQ-N2), transitive/indirect dependency versions (REQ-N3), any new registry-query tool or CLI (REQ-N4), harness modifications (helpers.sh, with-test-home) and test-enforcement.sh registration (REQ-C2, R-14), retroactive re-pinning of existing dependencies, and any edit to 065-verification-honesty.md (cross-referenced, not edited — R-5).

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Dispatch |
|-------|------|---------|-----|--------------|----------|
| 1 | 070 directive | live-registry verification directive in 070-environment.md | SC-1 | none | red/green/verify/commit |
| 2 | 075 cross-reference | Read-link in 075-docs-verification.md to the 070 directive | SC-2 | Phase 1 | red/green/verify/commit |
| 3 | Behavioral test + evaluation | scenario generation + clean-room evaluation | SC-3, SC-4 | Phase 1 | red/green/verify/commit |
| 4 | Content-verification test | standalone directive-present test | SC-5 | Phase 1 | red/green/verify/commit |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- [ ] C1. SC-1 verified: 070-environment.md contains a directive mandating live-registry verification of dependency version numbers before pinning, naming PyPI, npm, and crates.io, with the justified-older-pin exception and the training-data recall prohibition; existing `~=` pinning mandates unchanged.
- [ ] C2. SC-2 verified: 075-docs-verification.md contains a Read [Text](path) link to the 070 directive, without duplicating directive text.
- [ ] C3. SC-3 verified: the behavioral scenario script exists at `.opencode/tests-v2/behaviors/2421-sc1-live-registry-verification.sh` and runs, producing session.yaml/stdout.log/stderr.log/manifest.yaml/exit_code artifacts.
- [ ] C4. SC-4 verified: a clean-room sub-agent evaluates the session.yaml and produces a verdict on whether the agent queried the live registry before pinning.
- [ ] C5. SC-5 verified: the standalone content-verification test at `.opencode/tests-v2/test-2421-sc1-directive-present.sh` passes, asserting the directive text is present in 070-environment.md.
- [ ] C6. Audit and cross-validation produced no unaddressed findings.
- [ ] C7. Post-implementation gates (structural checks, regression, review-prep, PR) complete.

---

# Pre-Implementation (Tier 1 — once per plan)

- [ ] 1. **Coherence gate.**
    - Confirm the plan covers every SC from the spec: SC-1 in Phase 1, SC-2 in Phase 2, SC-3 and SC-4 in Phase 3, SC-5 in Phase 4.
    - Confirm the phase DAG is acyclic: Phase 2 depends on Phase 1, Phase 3 depends on Phase 1, Phase 4 depends on Phase 1; SC-4 depends on SC-3 within Phase 3.
    - Confirm no item covers more than one SC-ID.
    - Confirm all phase and post-phase dispatch skills are loaded and available.
- [ ] 2. **Baseline check.**
    - Read the §Version Pinning (MANDATORY) area of `.opencode/guidelines/070-environment.md` and confirm it lacks the live-registry verification directive.
    - Read the §What Must Be Verified and §Related Guidelines areas of `.opencode/guidelines/075-docs-verification.md` and confirm they lack a Read-link to a 070 directive.
    - Read `.opencode/guidelines/065-verification-honesty.md` and confirm it is present (to be referenced, not edited).
    - Confirm no behavioral scenario script exists yet at `.opencode/tests-v2/behaviors/2421-sc1-live-registry-verification.sh`.
    - Confirm no standalone content test exists yet at `.opencode/tests-v2/test-2421-sc1-directive-present.sh`.

---

# Phase 1 — 070 directive

## Phase Metadata

- **Concern:** Add the live-registry verification directive to the §Version Pinning area of 070-environment.md.
- **Files:** `.opencode/guidelines/070-environment.md`
- **SCs:** SC-1
- **Dependencies:** none (first phase)
- **Entry condition:** Phase 1 baseline shows the §Version Pinning area lacks the directive.
- **Exit condition:** The directive (registries named, exception path, prohibition) is committed in 070-environment.md; existing `~=` pinning mandates and the edit-pyproject-toml + uv sync workflow unchanged.

## Code Path Coverage

The directive is added to §Version Pinning (MANDATORY) in 070-environment.md where agents already read the `~=` pinning mandates. SC-1's read/grep verification confirms the registries named, the justified-older-pin exception present, and the training-data recall prohibition present.

## Cross-Cutting SCs

SC-1 is self-contained to the 070 directive concern; it does not span other concerns. It is the dependency root for Phases 2, 3, and 4 (each cross-phase edge originates here).

## Interface Boundaries

No function signature or interface contract changes. The directive is a text addition to the 070 guideline; 075 and 065 are unaffected at this phase (the Read-links are added in Phase 2 — R-5 fragmentation prevention, no directive duplication).

## State Transitions

No state machine exists. The transition is: 070-environment.md lacks the directive → 070-environment.md contains the directive (registries named, exception path, prohibition), with the commit as the transition trigger.

## Step-by-step

**Cost frame:** Verifying the directive exists in 070-environment.md costs one read/grep pass. Skipping means the version-source rule never lands in the pinning guideline — every future dependency pin can silently recall a stale training-data version and ship, a defect discovered only when a security fix or yanked release breaks a downstream consumer (1000× rework).

### Item 1 (SC-1): Directive text in 070-environment.md

- [ ] 3. **RED — write failing enforcement test.** `(**sub-agent**)`
    - Dispatch `execute red task from test-driven-development` with Phase 1 item-1 context.
    - The RED enforcement check asserts 070-environment.md lacks the live-registry verification directive (fails because the directive has not been added yet).
    - Confirm the RED test fails before proceeding.
    - Record pre-cleanup for the red step artifacts.
- [ ] 4. **GREEN — implement the change** `(**sub-agent**)`
    - Dispatch `execute green task from test-driven-development` with Phase 1 item-1 context.
    - Implement the minimum change: add a directive (new subsection or extension of the §Version Pinning section) to `.opencode/guidelines/070-environment.md` mandating live-registry verification of dependency version numbers before pinning, naming PyPI, npm, and crates.io, specifying the verification step (query the live registry API for the current stable version — via curl, the registry client, or the package manager's query command), the pin behavior (pin the verified version, or document a justified older pin — the justified-older-pin exception path), the crates.io User-Agent requirement (R-15), and the training-data recall prohibition (never recall dependency version numbers from training data). The directive SHALL be consistent with the existing `~=` pinning mandates (pinned with the compatible-release operator, not a bare version — R-7).
    - Scope guard: only the directive text in 070-environment.md; do not modify the `~=` pinning mandates, the edit-pyproject-toml + uv sync workflow (REQ-N1), or any other section (R-7).
    - Confirm the RED test now passes.
    - Run post-regression patterns (`execute phase-4 task from test-driven-development`).
- [ ] 5. **Verify** `(**sub-agent**)`
    - Dispatch `execute verify task from verification-before-completion` with Phase 1 item-1 context.
    - Read/grep the §Version Pinning area and assert the directive content is present (PyPI, npm, crates.io named; justified-older-pin exception path present; training-data recall prohibition present), and that existing `~=` pinning mandates remain unchanged.
    - Clean up verify-step artifacts before the run.
    - Record the SC-1 verdict in evidence.
- [ ] 6. **Commit** `(**inline**)`
    - Orchestrator runs `git add` on the 070-environment.md file.
    - Orchestrator commits the test and implementation together as one atomic slice.
    - No co-author trailers during this implementation commit.

## Phase Completion Block

- [ ] SC-1 verdict is PASS (clean).
- [ ] Evidence artifact written for SC-1.
- [ ] Commit includes the RED test and the GREEN directive edit; existing `~=` pinning mandates unchanged.

## Concern Transition

Phase 1 is complete. Phase 2 (075 Read-link), Phase 3 (behavioral test), and Phase 4 (content test) all depend on the Phase 1 directive — the Read-link must point to an existing directive, the behavioral test prompt requires the agent to follow an existing directive, and the content test asserts the directive text is present.

---

# Phase 2 — 075 cross-reference

## Phase Metadata

- **Concern:** Add a Read-link in 075-docs-verification.md routing agents to the 070 directive.
- **Files:** `.opencode/guidelines/075-docs-verification.md`
- **SCs:** SC-2
- **Dependencies:** Phase 1 (the Read-link points to the Phase 1 directive)
- **Entry condition:** Phase 1 committed; 070-environment.md contains the directive; 075-docs-verification.md lacks the Read-link.
- **Exit condition:** 075-docs-verification.md contains a Read [Text](path) link to the 070 directive (canonical Read-link pattern, not a "See file" citation), committed without duplicating directive text.

## Code Path Coverage

SC-2's verify greps the §What Must Be Verified and §Related Guidelines areas of 075-docs-verification.md and confirms the Read [Text](path) link exists and points to the 070 directive. Directive text appears only in 070-environment.md (R-5).

## Cross-Cutting SCs

SC-2 is self-contained to the 075 cross-reference concern. It depends on the SC-1 directive (Phase 1) as its link target but does not duplicate its text.

## Interface Boundaries

The interface contract between 070 and 075 is a one-way reference: 075 carries a Read [Text](path) link to the 070 directive; 070 does not reference 075. The directive text lives in exactly one place (070); 075 never duplicates it (R-5).

## State Transitions

No state machine exists. The transition is: 075-docs-verification.md lacks a Read-link → 075-docs-verification.md contains the Read [Text](path) link, with the commit as the transition trigger.

## Step-by-step

**Cost frame:** Verifying the Read-link cross-reference in 075-docs-verification.md costs one read/grep pass. Skipping means agents that load the live-verification guideline are never routed to the directive — the rule is documented but invisible where verification guidance is read, a routing defect caught only when a pinning defect ships.

### Item 2 (SC-2): Cross-reference from 075-docs-verification.md

- [ ] 7. **RED — write failing enforcement test.** `(**sub-agent**)`
    - Dispatch `execute red task from test-driven-development` with Phase 2 item-2 context.
    - The RED enforcement check asserts 075-docs-verification.md lacks a Read [Text](path) link to the 070 directive (fails because the link has not been added yet).
    - Confirm the RED test fails before proceeding.
    - Record pre-cleanup for the red step artifacts.
- [ ] 8. **GREEN — implement the change** `(**sub-agent**)`
    - Dispatch `execute green task from test-driven-development` with Phase 2 item-2 context.
    - Implement the minimum change: add a Read-link in `.opencode/guidelines/075-docs-verification.md` (in the §What Must Be Verified table area or the §Related Guidelines section) pointing to the 070 directive, using the Read [Text](path) pattern — not a "See file" citation. Optionally add a dependency-version row to the §What Must Be Verified table routing readers to the directive. Do NOT duplicate directive text (R-5).
    - Scope guard: only the Read-link cross-reference in 075-docs-verification.md; directive text must appear only in 070-environment.md (R-5).
    - Confirm the RED test now passes.
    - Run post-regression patterns (`execute phase-4 task from test-driven-development`).
- [ ] 9. **Verify** `(**sub-agent**)`
    - Dispatch `execute verify task from verification-before-completion` with Phase 2 item-2 context.
    - Read/grep the §What Must Be Verified and §Related Guidelines areas and assert the Read [Text](path) link exists and uses the canonical Read-link pattern (not a "See file" citation), and that the directive text appears only in 070-environment.md, not duplicated in 075.
    - Clean up verify-step artifacts before the run.
    - Record the SC-2 verdict in evidence.
- [ ] 10. **Commit** `(**inline**)`
    - Orchestrator runs `git add` on the 075-docs-verification.md file.
    - Orchestrator commits the test and implementation together as one atomic slice.
    - No co-author trailers during this implementation commit.

## Phase Completion Block

- [ ] SC-2 verdict is PASS (clean).
- [ ] Evidence artifact written for SC-2.
- [ ] Commit includes the RED test and the GREEN Read-link edit; directive text remains only in 070-environment.md.

## Concern Transition

Phase 2 is complete. Proceed to Phase 3 for the behavioral test generation and clean-room evaluation.

---

# Phase 3 — Behavioral test + evaluation

## Phase Metadata

- **Concern:** Generate the behavioral test scenario (SC-3) and evaluate its artifacts in a clean-room sub-agent (SC-4).
- **Files:** `.opencode/tests-v2/behaviors/2421-sc1-live-registry-verification.sh` (new)
- **SCs:** SC-3, SC-4
- **Dependencies:** Phase 1 (the behavioral test prompt requires the agent to follow the directive, which must exist first)
- **Entry condition:** Phase 1 committed; the 070 directive exists; no scenario script exists yet.
- **Exit condition:** The scenario script exists and runs via with-test-home, producing session.yaml/stdout.log/stderr.log/manifest.yaml/exit_code artifacts in tmp/behavioral-evidence-<scenario>-<phase>-<model>/; a clean-room sub-agent evaluates the session.yaml and produces a verdict on whether the agent queried the live registry before pinning.

## Code Path Coverage

The behavioral scenario script follows the artifact-only generator pattern (SCENARIO_NAME + SCENARIO_PROMPT + behavior_run + exit 0) per tests-v2/AGENTS.md §1 and §11, mirroring the 2411-sc4-false-numerical-target.sh reference example. The prompt is a real-domain add-dependency task telling the agent to add a dependency to the test project's pyproject.toml, so correct behavior requires querying the live registry for the current stable version before pinning. The shared harness (helpers.sh, with-test-home) is NOT modified (REQ-C2, R-14).

## Cross-Cutting SCs

SC-3 (artifact generation) and SC-4 (clean-room evaluation) are same-phase sequential: SC-4 evaluates the session.yaml artifact produced by the SC-3 scenario run and cannot produce a verdict before the SC-3 artifacts exist (two-SC pattern, R-12).

## Interface Boundaries

No runtime interface is affected. The scenario script is an artifact-only generator; the clean-room evaluation consumes only the artifact path and the SC-4 criterion (no orchestrator reasoning or expected outcomes — R-12). The script interacts with the real live registries (PyPI, npm, crates.io — no mocks); crates.io requires a User-Agent header, so the prompt MUST NOT assume header-less access (R-15). A registry version lookup is a read-only public metadata query, not a test against production data (R-13).

## State Transitions

No state machine exists. The scenario run produces session.yaml/stdout.log/stderr.log/manifest.yaml/exit_code artifacts in tmp/behavioral-evidence-<scenario>-<phase>-<model>/; the clean-room evaluation reads session.yaml (SQLite DB export — PRIMARY evidence source) and may use session-to-timeline as a permitted corroborating tool (distinct from the mandatory session.yaml inspection).

## Step-by-step

**Cost frame:** Running the behavioral generation test and the clean-room evaluation costs minutes of execution time (bash tool timeout >= 600s). Skipping means the enforcement claim is unverified — the agent may pin a training-data-recalled version without any registry query, a behavioral defect caught only when the stale pin breaks production.

### Item 3 (SC-3): Behavioral test artifact generator

- [ ] 11. **RED — write failing enforcement test.** `(**sub-agent**)`
    - Dispatch `execute red task from test-driven-development` with Phase 3 item-3 context.
    - The RED test runs the behavioral scenario script via with-test-home; it produces no artifacts because the script does not exist yet (fails because the scenario should be created).
    - Confirm the RED test fails before proceeding.
    - Record pre-cleanup for the red step artifacts.
- [ ] 12. **GREEN — implement the change** `(**sub-agent**)`
    - Dispatch `execute green task from test-driven-development` with Phase 3 item-3 context.
    - Implement the minimum change: create `.opencode/tests-v2/behaviors/2421-sc1-live-registry-verification.sh` following the artifact-only generator pattern (SCENARIO_NAME + SCENARIO_PROMPT + behavior_run + exit 0). The prompt is a real-domain task: add a dependency to the test project's pyproject.toml, where correct behavior requires querying the live registry for the current stable version before pinning. No assertion helpers, no evaluation in the script, no helpers.sh modification (R-10, REQ-C2). The prompt MUST NOT assume header-less access to crates.io (R-15).
    - Scope guard: only the scenario script (and a per-scenario fixture under fixtures/setup/ only if repo state is needed); do not modify helpers.sh, with-test-home, or register in test-enforcement.sh (R-14).
    - Confirm the RED test now passes.
    - Run post-regression patterns (`execute phase-4 task from test-driven-development`).
- [ ] 13. **Verify** `(**sub-agent**)`
    - Dispatch `execute verify task from verification-before-completion` with Phase 3 item-3 context.
    - Run the scenario script via with-test-home (opencode run, bash tool timeout >= 600s), producing session.yaml/stdout.log/stderr.log/manifest.yaml/exit_code artifacts in tmp/behavioral-evidence-<scenario>-<phase>-<model>/.
    - Clean up verify-step artifacts before the run.
    - Preserve the behavioral-evidence artifacts (exempt from mandatory cleanup until PR merge).
    - Record the SC-3 verdict in evidence using the produced artifacts.
- [ ] 14. **Commit** `(**inline**)`
    - Orchestrator runs `git add` on the scenario script (and any per-scenario fixture under fixtures/setup/ if created).
    - Orchestrator commits the test and implementation together as one atomic slice.
    - No co-author trailers during this implementation commit.

### Item 4 (SC-4): Clean-room evaluation of behavioral artifacts

- [ ] 15. **RED — write failing enforcement test.** `(**sub-agent**)`
    - Dispatch `execute red task from test-driven-development` with Phase 3 item-4 context.
    - The RED test is a clean-room evaluation of the item-3 artifacts; it cannot produce a verdict because the evaluation has not been performed (fails because the evaluation should be run).
    - Confirm the RED test fails before proceeding.
    - Record pre-cleanup for the red step artifacts.
- [ ] 16. **GREEN — implement the change** `(**sub-agent**)`
    - Dispatch `execute green task from test-driven-development` with Phase 3 item-4 context.
    - Implement the minimum change: a clean-room sub-agent reads the session.yaml (SQLite DB export — PRIMARY evidence source) from the item-3 artifact directory and evaluates whether the agent queried the live registry (PyPI/npm/crates.io API call) before pinning the dependency version, rather than recalling the version from training data. The sub-agent may use session-to-timeline as a permitted corroborating tool for a structured tool-call timeline.
    - Scope guard: the sub-agent receives only the artifact path and the SC-4 criterion — no orchestrator reasoning or expected outcomes (R-12). A contaminated evaluation is discarded and re-run.
    - Confirm the RED test now passes.
    - Run post-regression patterns (`execute phase-4 task from test-driven-development`).
- [ ] 17. **Verify** `(**sub-agent**)`
    - Dispatch `execute verify task from verification-before-completion` with Phase 3 item-4 context.
    - Verify the clean-room sub-agent inspection of session.yaml per tests-v2/AGENTS.md §2 and §6a produced a verdict on whether the agent queried the live registry before pinning.
    - Clean up verify-step artifacts before the run.
    - Record the SC-4 verdict in evidence.
- [ ] 18. **Commit** `(**inline**)`
    - No content change for this item; the evaluation produces a verdict slice, not source changes.
    - Orchestrator commits the evaluation verdict slice as the atomic unit for item 4.
    - No co-author trailers during this implementation commit.

## Phase Completion Block

- [ ] SC-3 verdict is PASS (clean).
- [ ] SC-4 verdict is PASS (clean).
- [ ] Evidence artifacts written for SC-3 and SC-4 (session.yaml/stdout.log/stderr.log/manifest.yaml preserved as behavioral evidence).
- [ ] Commits include the scenario script and the evaluation verdict slice.

---

# Phase 4 — Content-verification test

## Phase Metadata

- **Concern:** Add a standalone content-verification test asserting the directive text is present in 070-environment.md.
- **Files:** `.opencode/tests-v2/test-2421-sc1-directive-present.sh` (new)
- **SCs:** SC-5
- **Dependencies:** Phase 1 (the test asserts the Phase 1 directive text is present in 070-environment.md)
- **Entry condition:** Phase 1 committed; the 070 directive exists; no standalone content test exists yet.
- **Exit condition:** The standalone content test at `.opencode/tests-v2/test-2421-sc1-directive-present.sh` passes, asserting the directive text is present in 070-environment.md, committed (not registered in test-enforcement.sh).

## Code Path Coverage

SC-5's verify runs the standalone test script directly (bash `.opencode/tests-v2/test-2421-sc1-directive-present.sh`); PASS requires the directive text (live-registry verification mandate, justified-older-pin exception, training-data recall prohibition) to be present in 070-environment.md, following the 2411/2419 standalone precedent (PASSED/FAILED counter format, not registered in test-enforcement.sh).

## Cross-Cutting SCs

SC-5 is self-contained to the content-test concern; it asserts the SC-1 directive text is present in 070-environment.md and depends on the Phase 1 directive existing.

## Interface Boundaries

The standalone content test follows the precedent interfaces established by `test-2411-sc1-false-numerical-target-entry.sh` and `test-2419-sc1-echo-printf-removed.sh` (PASSED/FAILED counter format, exit 0/1). It asserts against the 070-environment.md directive text. It is NOT registered in test-enforcement.sh (R-14).

## State Transitions

No state machine exists. The transition is: standalone content test reports the directive absent → the test reports the directive present (PASS), verified by running the test script directly.

## Step-by-step

**Cost frame:** Verifying directive text presence costs one standalone test run. Skipping means the directive may be silently truncated or paraphrased out of 070-environment.md without any failing signal, and the content test that future changes must satisfy never exists.

### Item 5 (SC-5): Content-verification test

- [ ] 19. **RED — write failing enforcement test.** `(**sub-agent**)`
    - Dispatch `execute red task from test-driven-development` with Phase 4 item-5 context.
    - The RED test is the standalone content-verification test run; it reports the directive absent (fails because the directive should have been added in Phase 1 and the test should eventually pass).
    - Confirm the RED test fails before proceeding.
    - Record pre-cleanup for the red step artifacts.
- [ ] 20. **GREEN — implement the change** `(**sub-agent**)`
    - Dispatch `execute green task from test-driven-development` with Phase 4 item-5 context.
    - Implement the minimum change: create `.opencode/tests-v2/test-2421-sc1-directive-present.sh` asserting the directive text (live-registry verification mandate, justified-older-pin exception, training-data recall prohibition) exists in `.opencode/guidelines/070-environment.md`, following the 2411/2419 standalone precedent (PASSED/FAILED counter format; NOT registered in test-enforcement.sh).
    - Scope guard: only the standalone content test; do not register the test in test-enforcement.sh (R-14).
    - Confirm the RED test now passes.
    - Run post-regression patterns (`execute phase-4 task from test-driven-development`).
- [ ] 21. **Verify** `(**sub-agent**)`
    - Dispatch `execute verify task from verification-before-completion` with Phase 4 item-5 context.
    - Run the test script directly: `bash .opencode/tests-v2/test-2421-sc1-directive-present.sh`. PASS requires the directive text to be present in 070-environment.md.
    - Clean up verify-step artifacts before the run.
    - Record the SC-5 verdict in evidence.
- [ ] 22. **Commit** `(**inline**)`
    - Orchestrator runs `git add` on the standalone content test file.
    - Orchestrator commits the test and implementation together as one atomic slice.
    - No co-author trailers during this implementation commit.

## Phase Completion Block

- [ ] SC-5 verdict is PASS (clean).
- [ ] Evidence artifact written for SC-5.
- [ ] Commit includes the standalone content test; the test is not registered in test-enforcement.sh.

---

# Post-Implementation (Global Tier 1, once per plan)

- [ ] 1. **Audit** `(**sub-agent**)`
    - Dispatch the adversarial audit: `execute verification-audit DiMo investigator from audit. Read audit/tasks/verification-audit-investigator.md first`, followed by validator, evaluator, arbiter in sequence.
    - Confirm all SC verdicts are clean PASS; address any findings before proceeding.
    - Record audit artifacts.
- [ ] 2. **Z3 check** `(**inline**)`
    - Orchestrator runs `.opencode/tools/solve check --state-path ... --contract-path ...`.
    - Confirm phase-DAG constraints hold with no circular dependency.
- [ ] 3. **Structural checks** `(**sub-agent**)`
    - Dispatch `execute checklist task from finishing-a-development-branch`.
    - Run the finishing checklist: lint, typecheck, format checks on the modified guideline and behavioral/content test files, as applicable to their file types.
- [ ] 4. **Pre-PR gate** `(**sub-agent**)`
    - Dispatch `execute verify task from verification-before-completion` reading all SC verdicts.
    - Gate BLOCKs if any SC verdict is FAIL.
- [ ] 5. **Regression check** `(**sub-agent**)`
    - Dispatch `execute phase-4 task from test-driven-development`.
    - Run the final regression check before PR.
- [ ] 6. **Review prep** `(**sub-agent**)`
    - Dispatch `execute review-prep from git-workflow-pr. Read git-workflow-pr/tasks/review-prep.md first`.
    - Prepare the PR review context.
- [ ] 7. **Create PR** `(**sub-agent**)`
    - Dispatch `execute create task from git-workflow-pr`.
    - Create the pull request.
- [ ] 8. **Completion summary** `(**sub-agent**)`
    - Dispatch `execute completion task from completion-core`.
    - Generate the completion executive summary.

---

# Lifecycle Events

| Event | Timestamp (UTC) | Plan File | Phase Count |
|-------|-----------------|-----------|-------------|
| `plan_created` | 2026-08-31T18:45:00Z | `.opencode/.issues/2421/plan.md` | 4 |
