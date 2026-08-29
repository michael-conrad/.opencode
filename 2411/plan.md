---
plan_schema_version: 1
issue: 2411
title: "Prohibit false numerical reduction targets in condensation specs"
dispatch: [test-driven-development, verification-before-completion, audit, finishing-a-development-branch, git-workflow-pr, completion-core]
---

# Plan — Prohibit false numerical reduction targets in condensation specs

Issue: [.opencode#2411](https://github.com/michael-conrad/.opencode/issues/2411)

## Goal

Add a rule to the Prohibited Content Patterns section of `.opencode/reference/spec-structure-standards.md` banning hard byte-count, token-count, percentage, or line-count reduction thresholds as PASS/FAIL criteria in specs, anchor the rule in the spec-audit pipeline via a new narrow criterion, and enforce it with a behavioral test scenario plus clean-room evaluation.

## Architecture

The rule lives only in the Prohibited Content Patterns section of the canonical reference (all consumers already Read-link that section, so no new cross-reference wiring is needed). The audit evaluator gains a parallel narrow criterion (SC-NUMERICAL-TARGET) mirroring SC-TRACKING-LANG / SC-PRESCRIPTIVE-CODE that Read-links the section. A behavioral test scenario (artifact-only generator) runs a real-domain spec-creation task containing a false numerical target; a clean-room sub-agent evaluates the session.yaml to determine whether the agent flagged/refused the target. The evidence type taxonomy and validate.md hardcoded determinism list are untouched.

## Files

- `.opencode/reference/spec-structure-standards.md`
- `.opencode/skills/audit/tasks/spec-audit-evaluator.md`
- `.opencode/tests-v2/behaviors/` (new scenario script, plus fixture issue if the prompt references issue content)

## Dispatch

| Phase | Concern | Skill(s) |
|-------|---------|----------|
| 1 | Reference rule entry (SC-1, SC-2) | test-driven-development, verification-before-completion |
| 2 | Audit narrow criterion (SC-3) | test-driven-development, verification-before-completion |
| 3 | Behavioral test generation + clean-room evaluation (SC-4, SC-5) | test-driven-development, verification-before-completion |
| Post | audit, structural, PR, completion | audit, finishing-a-development-branch, verification-before-completion, test-driven-development, git-workflow-pr, completion-core |

## Blast Radius

The change touches the canonical spec-structure reference, the audit evaluator task, and the behavioral test suite. Affected impact zones: `.opencode/reference/` (Prohibited Content Patterns section only), `.opencode/skills/audit/tasks/` (Step 5 narrow criteria), and `.opencode/tests-v2/behaviors/` (new scenario + optional fixture). Explicitly excluded from scope: the evidence type taxonomy, validate.md hardcoded determinism list (step 3.2), the preload mechanism and opencode.jsonc, and retroactive revision of existing condensation specs #2347–#2357.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Dispatch |
|-------|------|---------|-----|--------------|----------|
| 1 | Reference rule entry | Prohibited Content Patterns entry + example pair | SC-1, SC-2 | none | red/green/verify/commit |
| 2 | Audit narrow criterion | SC-NUMERICAL-TARGET in spec-audit-evaluator | SC-3 | none | red/green/verify/commit |
| 3 | Behavioral test + evaluation | scenario generation + clean-room evaluation | SC-4, SC-5 | Phase 1 | red/green/verify/commit |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- [ ] C1. SC-1 verified: the Prohibited Content Patterns section contains the false-numerical-target entry with the emergent-property wording.
- [ ] C2. SC-2 verified: the rule entry contains both an incorrect (numerical threshold) and a correct (content-based) example.
- [ ] C3. SC-3 verified: spec-audit-evaluator.md Step 5 contains the SC-NUMERICAL-TARGET narrow criterion Read-linking the section.
- [ ] C4. SC-4 verified: the behavioral scenario script exists and runs, producing session.yaml/stdout.log/stderr.log artifacts.
- [ ] C5. SC-5 verified: the clean-room evaluation of the session.yaml produces a verdict on whether the agent flagged/refused the target.
- [ ] C6. Audit and cross-validation produced no unaddressed findings.
- [ ] C7. Post-implementation gates (structural checks, regression, review-prep, PR) complete.

---

# Pre-Implementation (Tier 1 — once per plan)

- [ ] 1. **Coherence gate.**
    - Confirm the plan covers every SC from the spec: SC-1 and SC-2 in Phase 1, SC-3 in Phase 2, SC-4 and SC-5 in Phase 3.
    - Confirm the phase DAG is acyclic: Phase 3 depends on Phase 1; Phase 2 is independent of Phase 1; SC-5 depends on SC-4 within Phase 3.
    - Confirm no item covers more than one SC-ID.
    - Confirm all phase and post-phase dispatch skills are loaded and available.
- [ ] 2. **Baseline check.**
    - Read the Prohibited Content Patterns section of `.opencode/reference/spec-structure-standards.md` and confirm it lacks the false-numerical-target entry.
    - Read Step 5 of `.opencode/skills/audit/tasks/spec-audit-evaluator.md` and confirm it lacks the SC-NUMERICAL-TARGET narrow criterion.
    - Confirm no behavioral scenario script exists yet at `.opencode/tests-v2/behaviors/` targeting false numerical reduction targets.

---

# Phase 1 — Reference rule entry

## Phase Metadata

- **Concern:** Add the false-numerical-target prohibition and its example pair to the Prohibited Content Patterns section.
- **Files:** `.opencode/reference/spec-structure-standards.md`
- **SCs:** SC-1, SC-2
- **Dependencies:** none (first phase)
- **Entry condition:** Phase 1 baseline shows the section lacks the entry and the example pair.
- **Exit condition:** The section contains the entry with the emergent-property wording and the correct/incorrect example pair, committed.

## Code Path Coverage

The Prohibited Content Patterns section is Read-linked by spec-creation create.md (line 43), validate.md (step 1.2), and spec-audit-investigator.md (line 100). Adding the entry makes the rule automatically visible to those consumers; no new cross-reference wiring is needed.

## Cross-Cutting SCs

SC-1 (entry with emergent-property wording) and SC-2 (example pair) both modify the same rule entry in the same section. They are daisy-chained: item 1's commit is the precondition for item 2's RED.

## Interface Boundaries

No function signature or interface contract changes. Only the Prohibited Content Patterns section text is modified; the evidence type taxonomy and Format Requirements sections are untouched.

## State Transitions

No state machine exists. The change is a text edit to the reference section with the commit as the only transition.

## Step-by-step

**Cost frame:** Verifying the reference entry and example pair costs one read/grep pass. Skipping means the false-target rule never lands in the canonical reference, and every future condensation spec can carry a hard numerical threshold that fails in production — a 1000× downstream defect.

### Item 1 (SC-1): Reference rule entry added

- [ ] 1. **RED — write failing enforcement test.** `(**sub-agent**)`
    - Dispatch `execute red task from test-driven-development` with Phase 1 item-1 context.
    - The RED test reads the Prohibited Content Patterns section of the reference and asserts it lacks the false-numerical-target entry (fails because the entry should be added).
    - Confirm the RED test fails before proceeding.
    - Record pre-cleanup for the red step artifacts.
- [ ] 2. **GREEN — implement the change** `(**sub-agent**)`
    - Dispatch `execute green task from test-driven-development` with Phase 1 item-1 context.
    - Implement the minimum change: add a bullet to the Prohibited Content Patterns section stating that hard byte-count, token-count, percentage, or line-count reduction thresholds as PASS/FAIL criteria in specs are FAIL, and stating the emergent-property principle: SCs define WHAT to move/retain/remove; savings are an emergent property of correctly implementing content-based SCs; a hard numerical threshold is a FAIL.
    - Scope guard: only the Prohibited Content Patterns section; do not modify the evidence type taxonomy, Format Requirements, or any other section (R-4, R-12).
    - Confirm the RED test now passes.
    - Run post-regression patterns (`execute phase-4 task from test-driven-development`).
- [ ] 3. **Verify** `(**sub-agent**)`
    - Dispatch `execute verify task from verification-before-completion` with Phase 1 item-1 context.
    - Read the Prohibited Content Patterns section and assert the entry exists and contains the emergent-property wording.
    - Clean up verify-step artifacts before the run.
    - Record the SC-1 verdict in evidence.
- [ ] 4. **Commit** `(**inline**)`
    - Orchestrator runs `git add` on the reference file.
    - Orchestrator commits the test and implementation together as one atomic slice.
    - No co-author trailers during this implementation commit.

### Item 2 (SC-2): Correct/incorrect examples included

- [ ] 5. **RED — write failing enforcement test.** `(**sub-agent**)`
    - Dispatch `execute red task from test-driven-development` with Phase 1 item-2 context.
    - The RED test reads the rule entry and asserts it lacks a correct/incorrect example pair (fails because the examples should be added).
    - Confirm the RED test fails before proceeding.
    - Record pre-cleanup for the red step artifacts.
- [ ] 6. **GREEN — implement the change** `(**sub-agent**)`
    - Dispatch `execute green task from test-driven-development` with Phase 1 item-2 context.
    - Implement the minimum change: add a correct/incorrect example pair within the rule entry — an incorrect SC imposing a hard numerical reduction threshold (e.g., "post-condensation byte count < N bytes") and a compliant content-based SC (e.g., "the guideline retains the Zero Tolerance Rule verbatim; the relocated section is replaced with a Read-link").
    - Scope guard: only the example pair within the rule entry; the correct example carries no numerical threshold (R-10).
    - Confirm the RED test now passes.
    - Run post-regression patterns (`execute phase-4 task from test-driven-development`).
- [ ] 7. **Verify** `(**sub-agent**)`
    - Dispatch `execute verify task from verification-before-completion` with Phase 1 item-2 context.
    - Grep the rule entry and assert both an incorrect example (numerical threshold) and a correct example (content-based, no numerical threshold) are present.
    - Clean up verify-step artifacts before the run.
    - Record the SC-2 verdict in evidence.
- [ ] 8. **Commit** `(**inline**)`
    - Orchestrator runs `git add` on the reference file.
    - Orchestrator commits the test and implementation together as one atomic slice.
    - No co-author trailers during this implementation commit.

## Phase Completion Block

- [ ] SC-1 verdict is PASS (clean).
- [ ] SC-2 verdict is PASS (clean).
- [ ] Evidence artifacts written for SC-1 and SC-2.
- [ ] Commits include the RED tests and the GREEN reference edits.

## Concern Transition

Phase 1 is complete. Phase 3 depends on the Phase 1 rule entry (the agent under test reads the section and flags/refuses the target). Phase 2 is independent and may proceed in parallel.

---

# Phase 2 — Audit narrow criterion

## Phase Metadata

- **Concern:** Anchor the SC-NUMERICAL-TARGET narrow criterion in the audit evaluator.
- **Files:** `.opencode/skills/audit/tasks/spec-audit-evaluator.md`
- **SCs:** SC-3
- **Dependencies:** none (the criterion Read-links the already-existing Prohibited Content Patterns section)
- **Entry condition:** Phase 2 baseline shows Step 5 lacks the SC-NUMERICAL-TARGET criterion.
- **Exit condition:** Step 5 contains the new narrow criterion Read-linking §Prohibited Content Patterns, committed.

## Code Path Coverage

spec-audit-evaluator.md Step 5 hosts the narrow criteria (SC-TRACKING-LANG, SC-PRESCRIPTIVE-CODE). The new SC-NUMERICAL-TARGET criterion is a parallel entry mirroring those, Read-linking the reference section.

## Cross-Cutting SCs

SC-3 is self-contained to the audit evaluator Step 5. It does not gate on Phase 1 because the Read-link target section already exists (line 176).

## Interface Boundaries

No interface or function signature changes. Only a new narrow criterion step is added to the evaluator's Step 5.

## State Transitions

No state machine exists. The change is a text edit to the evaluator task with the commit as the only transition.

## Step-by-step

**Cost frame:** Verifying the audit narrow criterion is anchored costs one read/grep pass. Skipping means the rule is documented but not enforced — a false numerical target passes spec-audit and ships to production.

### Item 3 (SC-3): Audit evaluator narrow criterion anchored

- [ ] 9. **RED — write failing enforcement test.** `(**sub-agent**)`
    - Dispatch `execute red task from test-driven-development` with Phase 2 context.
    - The RED test reads Step 5 of spec-audit-evaluator.md and asserts it lacks the SC-NUMERICAL-TARGET narrow criterion (fails because the criterion should be added).
    - Confirm the RED test fails before proceeding.
    - Record pre-cleanup for the red step artifacts.
- [ ] 10. **GREEN — implement the change** `(**sub-agent**)`
    - Dispatch `execute green task from test-driven-development` with Phase 2 context.
    - Implement the minimum change: add a new narrow criterion (SC-NUMERICAL-TARGET) to Step 5 mirroring SC-TRACKING-LANG / SC-PRESCRIPTIVE-CODE: "Read [spec-structure-standards.md](reference/spec-structure-standards.md) §Prohibited Content Patterns and verify the spec contains no false numerical reduction targets (hard byte-count, token-count, percentage, or line-count reduction thresholds as PASS/FAIL criteria)."
    - Scope guard: only the new narrow criterion step; do not alter the evidence type taxonomy or the preload mechanism (R-11, R-12).
    - Confirm the RED test now passes.
    - Run post-regression patterns (`execute phase-4 task from test-driven-development`).
- [ ] 11. **Verify** `(**sub-agent**)`
    - Dispatch `execute verify task from verification-before-completion` with Phase 2 context.
    - Read Step 5 of spec-audit-evaluator.md and assert the SC-NUMERICAL-TARGET criterion exists and Read-links §Prohibited Content Patterns.
    - Clean up verify-step artifacts before the run.
    - Record the SC-3 verdict in evidence.
- [ ] 12. **Commit** `(**inline**)`
    - Orchestrator runs `git add` on the audit evaluator file.
    - Orchestrator commits the test and implementation together as one atomic slice.
    - No co-author trailers during this implementation commit.

## Phase Completion Block

- [ ] SC-3 verdict is PASS (clean).
- [ ] Evidence artifact written for SC-3.
- [ ] Commit includes the RED test and the GREEN evaluator edit.

## Concern Transition

Phase 2 is complete. Proceed to Phase 3 for the behavioral test generation and clean-room evaluation.

---

# Phase 3 — Behavioral test generation + clean-room evaluation

## Phase Metadata

- **Concern:** Generate the behavioral test scenario and evaluate its artifacts in a clean-room sub-agent.
- **Files:** `.opencode/tests-v2/behaviors/` (new scenario script, plus fixture issue if the prompt references issue content)
- **SCs:** SC-4, SC-5
- **Dependencies:** Phase 1 (the rule must exist before the behavior is observable and testable)
- **Entry condition:** Phase 1 committed; the reference rule entry exists; no scenario script exists yet.
- **Exit condition:** The scenario script runs via with-test-home producing session.yaml/stdout.log/stderr.log artifacts, and a clean-room sub-agent evaluates the session.yaml to a verdict.

## Code Path Coverage

The behavioral scenario script follows the artifact-only generator pattern (SCENARIO_NAME + SCENARIO_PROMPT + behavior_run + exit 0) per tests-v2/AGENTS.md §1 and §11. The prompt is a real-domain spec-creation task containing a false numerical reduction target. If the prompt references issue content, a fixture issue MUST exist at behaviors/fixtures/issues/{N}/ before the test runs.

## Cross-Cutting SCs

SC-4 (scenario generation) and SC-5 (clean-room evaluation) are same-phase sequential: SC-5 evaluates the session.yaml artifact produced by the SC-4 scenario run and cannot produce a verdict before the SC-4 artifacts exist.

## Interface Boundaries

No runtime interface is affected. The scenario script is a standalone behavioral test artifact; the clean-room evaluation consumes only the artifact path and the SC criterion (no orchestrator preload, per R-8).

## State Transitions

No state machine exists. The scenario run produces session.yaml/stdout.log/stderr.log artifacts in tmp/behavioral-evidence-<scenario>-<phase>-<model>/; the evaluation reads session.yaml as the primary evidence source.

## Step-by-step

**Cost frame:** Running the behavioral generation test and the clean-room evaluation costs minutes of execution time. Skipping means the enforcement claim is unverified — the agent may silently accept a false numerical target, a behavioral defect caught only when a trimmed spec breaks downstream consumers.

### Item 4 (SC-4): Behavioral test scenario artifact generation

- [ ] 13. **RED — write failing enforcement test.** `(**sub-agent**)`
    - Dispatch `execute red task from test-driven-development` with Phase 3 item-4 context.
    - The RED test is a behavioral run with a real-domain spec-creation prompt containing a false numerical target; it produces no artifacts because the scenario script does not exist yet (fails because the script should be created).
    - Confirm the RED test fails before proceeding.
    - Record pre-cleanup for the red step artifacts.
- [ ] 14. **GREEN — implement the change** `(**sub-agent**)`
    - Dispatch `execute green task from test-driven-development` with Phase 3 item-4 context.
    - Implement the minimum change: create a new behavioral test scenario script at `.opencode/tests-v2/behaviors/<scenario>.sh` following the artifact-only generator pattern (SCENARIO_NAME + SCENARIO_PROMPT + behavior_run + exit 0). The prompt is a real-domain spec-creation task where the agent is asked to create or validate a condensation spec containing a false numerical reduction target (or otherwise encounters one), so natural agent behavior either flags/refuses the target or accepts it. No assertion helpers in the script (R-8). If the prompt references issue content, create the fixture issue at behaviors/fixtures/issues/{N}/.
    - Scope guard: only the scenario script and any required fixture; the prompt MUST be a real-domain task, NOT a prose-recall interview (R-14).
    - Confirm the RED test now passes.
    - Run post-regression patterns (`execute phase-4 task from test-driven-development`).
- [ ] 15. **Verify** `(**sub-agent**)`
    - Dispatch `execute verify task from verification-before-completion` with Phase 3 item-4 context.
    - Run the script via with-test-home (opencode run, bash tool timeout >= 600s), producing session.yaml/stdout.log/stderr.log artifacts in tmp/behavioral-evidence-<scenario>-<phase>-<model>/.
    - Clean up verify-step artifacts before the run.
    - Record the SC-4 verdict in evidence.
- [ ] 16. **Commit** `(**inline**)`
    - Orchestrator runs `git add` on the scenario script (and fixture issue if created).
    - Orchestrator commits the test and implementation together as one atomic slice.
    - No co-author trailers during this implementation commit.

### Item 5 (SC-5): Clean-room evaluation of behavioral artifacts

- [ ] 17. **RED — write failing enforcement test.** `(**sub-agent**)`
    - Dispatch `execute red task from test-driven-development` with Phase 3 item-5 context.
    - The RED test is a clean-room evaluation of the item-4 artifacts; it cannot produce a verdict because the evaluation has not been performed (fails because the evaluation should be run).
    - Confirm the RED test fails before proceeding.
    - Record pre-cleanup for the red step artifacts.
- [ ] 18. **GREEN — implement the change** `(**sub-agent**)`
    - Dispatch `execute green task from test-driven-development` with Phase 3 item-5 context.
    - Implement the minimum change: a clean-room sub-agent reads the session.yaml (SQLite DB export — primary evidence source) from the item-4 artifact directory and evaluates whether the agent's tool calls, reasoning, and decisions flag/refuse the false numerical target (e.g., the agent reads the reference's Prohibited Content Patterns section and refuses to accept the hard threshold, or flags it as FAIL) rather than silently accepting it.
    - Scope guard: the sub-agent receives only the artifact path and the SC criterion — no orchestrator reasoning or expected outcomes (R-8).
    - Confirm the RED test now passes.
    - Run post-regression patterns (`execute phase-4 task from test-driven-development`).
- [ ] 19. **Verify** `(**sub-agent**)`
    - Dispatch `execute verify task from verification-before-completion` with Phase 3 item-5 context.
    - Verify the clean-room sub-agent inspection of session.yaml per tests-v2/AGENTS.md §2 and §6a produced a verdict on whether the agent flagged/refused the target.
    - Clean up verify-step artifacts before the run.
    - Record the SC-5 verdict in evidence.
- [ ] 20. **Commit** `(**inline**)`
    - No content change for this item; the evaluation produces a verdict slice, not source changes.
    - Orchestrator commits the evaluation verdict slice as the atomic unit for item 5.
    - No co-author trailers during this implementation commit.

## Phase Completion Block

- [ ] SC-4 verdict is PASS (clean).
- [ ] SC-5 verdict is PASS (clean).
- [ ] Evidence artifacts written for SC-4 and SC-5 (session.yaml/stdout.log/stderr.log preserved as behavioral evidence).
- [ ] Commits include the scenario script and the evaluation verdict slice.

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
    - Run the finishing checklist: lint, typecheck, format checks on the modified reference, audit evaluator, and behavioral test files.
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
| `plan_created` | 2026-08-29T16:09:00Z | `.opencode/.issues/2411/plan.md` | 3 |
| `plan_created` | 2026-08-29T16:16:35Z | `.opencode/.issues/2411/plan.md` | 3 |
