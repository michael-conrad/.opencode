---
plan_schema_version: 1
issue: 2376
title: "Update default test model to ollama/qwen3.8:27b-256k"
dispatch: [test-driven-development, verification-before-completion, audit, finishing-a-development-branch, git-workflow-pr, completion-core]
---

# Plan — Update default test model for the opencode run framework

Issue: [.opencode#2376](https://github.com/michael-conrad/.opencode/issues/2376)

## Goal

Replace the default test model literal `ollama/qwen3.6:35b-256k` with `ollama/qwen3.8:27b-256k` across the test harness and its documentation. The change is a pure string-value substitution across three concerns: the single source of truth variable in `default-model.sh`, two hardcoded fallback literals in `with-test-home` that do not consume the variable, and five documentation files.

## Architecture

The `DEFAULT_TEST_MODEL` fallback in `.opencode/tests-v2/default-model.sh` is the single source of truth; tests that source the script or read the env var propagate the new value automatically. The two hardcoded fallback literals in `.opencode/tests-v2/with-test-home` (`seed_model_config` fallback and `isolation-model` fallback) must be updated manually because they do not read the variable. The five documentation files must be updated to match the new runtime default.

## Files

- `.opencode/tests-v2/default-model.sh`
- `.opencode/tests-v2/with-test-home`
- `.opencode/AGENTS.md`
- `.opencode/docs/model-dependency.md`
- `.opencode/README.md`
- `.opencode/tests-v2/AGENTS.md`
- `AGENTS.md`

## Dispatch

| Phase | Concern | Skill(s) |
|-------|---------|----------|
| 1 | default-model.sh fallback literal | test-driven-development, verification-before-completion |
| 2 | with-test-home hardcoded fallbacks | test-driven-development, verification-before-completion |
| 3 | documentation model references | test-driven-development, verification-before-completion |
| Post | audit, structural, PR, completion | audit, finishing-a-development-branch, verification-before-completion, test-driven-development, git-workflow-pr, completion-core |

## Blast Radius

The change touches the test-harness model default and its documentation. Affected impact zones: `.opencode/tests-v2/` (harness scripts and AGENTS), `.opencode/docs/`, `.opencode/README.md`, and root `AGENTS.md`. Explicitly excluded from scope: `.opencode/opencode.jsonc` model list (`qwen3.6:35b`, no `-256k` suffix), `.opencode/docs/audit-sc6959-verification.md` (historical audit record), model availability/ollama-probe, and harness isolation logic.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Dispatch |
|-------|------|---------|-----|--------------|----------|
| 1 | default-model.sh fallback | DEFAULT_TEST_MODEL fallback literal | SC-1 | none | red/green/verify/commit |
| 2 | with-test-home fallbacks | two hardcoded fallback literals | SC-2 | Phase 1 | red/green/verify/commit |
| 3 | documentation references | model literal across five docs | SC-3 | Phase 1, Phase 2 | red/green/verify/commit |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- [ ] C1. SC-1 verified: the `DEFAULT_TEST_MODEL` fallback in `.opencode/tests-v2/default-model.sh` equals `ollama/qwen3.8:27b-256k`.
- [ ] C2. SC-2 verified: both hardcoded fallback literals in `.opencode/tests-v2/with-test-home` equal `ollama/qwen3.8:27b-256k`.
- [ ] C3. SC-3 verified: zero occurrences of `ollama/qwen3.6:35b-256k` across the five documentation files.
- [ ] C4. Audit and cross-validation produced no unaddressed findings.
- [ ] C5. Post-implementation gates (structural checks, regression, review-prep, PR) complete.

---

# Pre-Implementation (Tier 1 — once per plan)

- [ ] 1. **Coherence gate.**
    - Confirm the plan covers every SC from the spec: SC-1 in Phase 1, SC-2 in Phase 2, SC-3 in Phase 3.
    - Confirm the phase DAG is acyclic and linear (1 -> 2 -> 3).
    - Confirm no item covers more than one SC-ID.
    - Confirm all phase and post-phase dispatch skills are loaded and available.
- [ ] 2. **Baseline check.**
    - Read the current `DEFAULT_TEST_MODEL` fallback in `.opencode/tests-v2/default-model.sh` and confirm it equals `ollama/qwen3.6:35b-256k`.
    - Grep `.opencode/tests-v2/with-test-home` and confirm both hardcoded fallback literals equal `ollama/qwen3.6:35b-256k`.
    - Grep the five documentation files and confirm at least one `ollama/qwen3.6:35b-256k` default-model reference remains.

---

# Phase 1 — default-model.sh fallback

## Phase Metadata

- **Concern:** Update the `DEFAULT_TEST_MODEL` fallback literal to `ollama/qwen3.8:27b-256k`.
- **Files:** `.opencode/tests-v2/default-model.sh`
- **SCs:** SC-1
- **Dependencies:** none (first phase)
- **Entry condition:** Phase 1 baseline shows the stale fallback literal.
- **Exit condition:** The `DEFAULT_TEST_MODEL` fallback equals `ollama/qwen3.8:27b-256k` and is committed.

## Code Path Coverage

The `DEFAULT_TEST_MODEL` assignment in `default-model.sh` is read by tests that source the script or read the `$DEFAULT_TEST_MODEL` env var. Updating the fallback literal propagates automatically to those consumers.

## Cross-Cutting SCs

SC-1 is a self-contained structural substitution; it does not share a concern with SC-2 or SC-3 beyond the common model string value.

## Interface Boundaries

`default-model.sh` exports the `DEFAULT_TEST_MODEL` value. No function signature or interface contract changes; only the fallback literal value changes.

## State Transitions

No state machine exists for this substitution. The change is a single assignment edit with no dependent transitions.

## Step-by-step

**Cost frame:** Verifying the fallback literal costs one read of `default-model.sh`. Skipping means the single source of truth stays pinned to the stale model, and every test consuming the variable silently runs the old model.

- [ ] 1. **RED — write failing enforcement test.** `(**sub-agent**)`
    - Dispatch `execute red task from test-driven-development` with Phase 1 context.
    - The RED test reads the `DEFAULT_TEST_MODEL` assignment in the default-model script and asserts the fallback is NOT `ollama/qwen3.8:27b-256k` (fails because the change does not exist yet).
    - Confirm the RED test fails before proceeding.
    - Record pre-cleanup for the red step artifacts.
- [ ] 2. **GREEN — implement the change** (`(**sub-agent**)`)
    - Dispatch `execute green task from test-driven-development` with Phase 1 context.
    - Implement the minimum change: replace the `DEFAULT_TEST_MODEL` fallback literal in `default-model.sh` with `ollama/qwen3.8:27b-256k`.
    - Scope guard: only the fallback literal; no logic, routing, or harness-structure change.
    - Confirm the RED test now passes.
    - Run post-regression patterns (`execute phase-4 task from test-driven-development`).
- [ ] 3. **Verify** (`(**sub-agent**)`)
    - Dispatch `execute verify task from verification-before-completion` with Phase 1 context.
    - Read the `DEFAULT_TEST_MODEL` assignment in `default-model.sh` and assert the fallback equals `ollama/qwen3.8:27b-256k`.
    - Clean up verify-step artifacts before the run.
    - Record the SC-1 verdict in evidence.
- [ ] 4. **Commit** (`(**inline**)`)
    - Orchestrator runs `git add` on `default-model.sh`.
    - Orchestrator commits the test and implementation together as one atomic slice.
    - No co-author trailers during this implementation commit.

## Phase Completion Block

- [ ] SC-1 verdict is PASS (clean).
- [ ] Evidence artifact written for SC-1.
- [ ] Commit includes the RED test and the GREEN implementation.

## Concern Transition

Phase 1 is complete. Proceed to Phase 2 for the `with-test-home` hardcoded fallbacks.

---

# Phase 2 — with-test-home hardcoded fallbacks

## Phase Metadata

- **Concern:** Update the two hardcoded fallback literals in `with-test-home` to `ollama/qwen3.8:27b-256k`.
- **Files:** `.opencode/tests-v2/with-test-home`
- **SCs:** SC-2
- **Dependencies:** Phase 1 (source-of-truth value established)
- **Entry condition:** Phase 1 committed; both `with-test-home` fallbacks still stale.
- **Exit condition:** Both hardcoded fallback literals equal `ollama/qwen3.8:27b-256k` and committed.

## Code Path Coverage

The `seed_model_config` fallback and the `isolation-model` fallback in `with-test-home` are hardcoded literals that do not consume the `DEFAULT_TEST_MODEL` variable, so they must be updated manually to match.

## Cross-Cutting SCs

SC-2 is independent of SC-1 and SC-3; the two literals share only the common model string value with the rest of the change.

## Interface Boundaries

No interface or function signature changes. Only the two hardcoded fallback literal values in the harness script.

## State Transitions

No state machine exists. The change is two assignment edits with the commit as the only transition.

## Step-by-step

**Cost frame:** Verifying both `with-test-home` literals costs one grep. Skipping means the two hardcoded fallbacks silently keep selecting the old model even after the variable is updated.

- [ ] 1. **RED — write the enforcement test** (`(**sub-agent**)`)
    - Dispatch `execute red task from test-driven-development` with Phase 2 context.
    - The assertion: grep `with-test-home` and assert both fallback literals are NOT `ollama/qwen3.8:27b-256k` (fails because they are still stale).
    - Confirm the RED test fails before proceeding.
    - Record pre-step cleanup for the red step artifacts.
- [ ] 2. **GREEN — implement the change** (`(**sub-agent**)`)
    - Dispatch `execute green task from test-driven-development` with Phase 2 context.
    - Implement the minimum change: replace both hardcoded fallback literals in `with-test-home` with `ollama/qwen3.8:27b-256k`.
    - Scope guard: only the two literal values; no harness isolation-logic change.
    - Confirm the RED test now passes.
    - Record post-regression (`execute phase-4 task from test-driven-development`).
- [ ] 3. **Verify** (`(**sub-agent**)`)
    - Dispatch `execute verify task from verification-before-completion` with Phase 2 context.
    - Grep `with-test-home` and assert both fallback literals equal `ollama/qwen3.8:27b-256k`.
    - Clean up verify step artifacts before the run.
    - Record the SC-2 verdict in evidence.
- [ ] 4. **Commit** (`(**inline**)`)
    - Orchestrator runs `git add` on `with-test-home`.
    - Orchestrator commits the test and implementation together as one atomic slice.
    - No co-author trailers during this commit.

## Phase Completion Block

- [ ] SC-2 verdict is PASS (clean).
- [ ] Evidence confirmed for SC-2.
- [ ] Commit includes the RED test and the GREEN implementation.

## Concern Transition

Phase 2 is complete. Proceed to Phase 3 for the documentation references.

---

# Phase 3 — documentation model references

## Phase Metadata

- **Concern:** Update the model literal across the five documentation files to `ollama/qwen3.8:27b-256k`.
- **Files:** `.opencode/AGENTS.md`, `.opencode/docs/model-dependency.md`, `.opencode/README.md`, `.opencode/tests-v2/AGENTS.md`, `AGENTS.md`
- **SCs:** SC-3
- **Dependencies:** Phase 1, Phase 2 (runtime literals established before doc consistency validation)
- **Entry condition:** Phase 3 has the runtime literals updated; at least one stale doc reference remains.
- **Exit condition:** Zero occurrences of `ollama/qwen3.6:35b-256k` across the five documentation files.

## Code Path Coverage

The five documentation files reference the default test model literal. They are documentation-only; no code path reads them.

## Cross-Cutting SCs

SC-3 spans all five documentation files — the cross-cutting concern is documenting the runtime default model consistently.

## Interface Boundaries

No runtime interface is affected. Only documentation text changes.

## State Transitions

No state machine exists. The change is a set of text edits committed together.

## Step-by-step

**Cost frame:** Verifying the five documentation files costs a grep across them. Skipping means stale documentation ships and future readers are told the wrong default model, deferring discovery until the next model reference is audited.

- [ ] 1. **RED — write the enforcement test** (`(**sub-agent**)`)
    - Dispatch `execute red task from test-driven-development` with Phase 3 context.
    - The assertion: grep the five documentation files and assert at least one `ollama/qwen3.6:35b-256k` default-model reference remains (fails because a stale reference exists).
    - Confirm the RED test fails before proceeding.
    - Record pre-step cleanup for the red step artifacts.
- [ ] 2. **GREEN — implement the change** (`(**sub-agent**)`)
    - Dispatch `execute green task from test-driven-development` with Phase 3 context.
    - Implement the minimum change: update the model literal to `ollama/qwen3.8:27b-256k` in all five documentation files.
    - Scope guard: only the default-model literal; do not touch `opencode.jsonc` (`qwen3.6:35b`, no suffix) or the audit record.
    - Confirm the RED test now passes.
    - Record post-regression (`execute phase-4 task from test-driven-development`).
- [ ] 3. **Verify** (`(**sub-agent**)`)
    - Dispatch `execute verify task from verification-before-completion` with Phase 3 context.
    - Grep all five documentation files and assert zero occurrences of `ollama/qwen3.6:35b-256k`.
    - Clean up verify step artifacts before the run.
    - Record the SC-3 verdict in evidence.
- [ ] 4. **Commit** (`(**inline**)`)
    - Orchestrator runs `git add` on the five documentation files.
    - Orchestrator commits the test and implementation together as one atomic slice.
    - No co-author trailers during this commit.

## Phase Completion Block

- [ ] SC-3 verdict is PASS (clean).
- [ ] Evidence confirmed for SC-3 (zero old literal occurrences).
- [ ] Commit includes the RED test and the GREEN documentation edits.

---

# Post-Implementation (Global Tier 1, once per plan)

- [ ] 1. **Audit** (`(**sub-agent**)`)
    - Dispatch the adversarial audit: `execute verification-audit DiMo investigator from audit. Read audit/tasks/verification-audit-investigator.md first`, followed by validator, evaluator, arbiter in sequence.
    - Confirm all SC verdicts are clean PASS; address any findings before proceeding.
    - Record audit artifacts.
- [ ] 2. **Z3 check** (`(**inline**)`)
    - Orchestrator runs `.opencode/tools/solve check --state-path ... --contract-path ...`.
    - Confirm phase-DAG constraints hold with no circular dependency.
- [ ] 3. **Structural checks** (`(**sub-agent**)`)
    - Dispatch `execute checklist task from finishing-a-development-branch`.
    - Run the finishing checklist: lint, typecheck, format checks on the modified harness and markdown files.
- [ ] 4. **Pre-PR gate** (`(**sub-agent**)`)
    - Dispatch `execute verify task from verification-before-completion` reading all SC verdicts.
    - Gate BLOCKs if any SC verdict is FAIL.
- [ ] 5. **Regression check** (`(**sub-agent**)`)
    - Dispatch `execute phase-4 task from test-driven-development`.
    - Run the final regression check before PR.
- [ ] 6. **Review prep** (`(**sub-agent**)`)
    - Dispatch `execute review-prep from git-workflow-pr. Read `git-workflow-pr/tasks/review-prep.md` first`.
    - Prepare the PR review context.
- [ ] 7. **Create PR** (`(**sub-agent**)`)
    - Dispatch `execute create task from git-workflow-pr`.
    - Create the pull request.
- [ ] 8. **Completion summary** (`(**sub-agent**)`)
    - Dispatch `execute completion task from completion-core`.
    - Generate the completion executive summary.

---

# Lifecycle Events

| Event | Timestamp (UTC) | Plan File | Phase Count |
|-------|-----------------|-----------|-------------|
| `plan_created` | 2026-08-27T04:38:06Z | `.opencode/.issues/2376/plan.md` | 3 |
