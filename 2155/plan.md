---
plan_schema_version: "1.0"
issue: 2155
title: "Fix analytical-artifacts gate — remediation-first before halt"
dispatch:
  - phase: 1
    items:
      - item: 1
        sc_id: SC-1
        skill: implementation-pipeline
        task: step-dispatch
      - item: 2
        sc_id: SC-2
        skill: implementation-pipeline
        task: step-dispatch
  - phase: 2
    items:
      - item: 3
        sc_id: SC-3
        skill: implementation-pipeline
        task: step-dispatch
  - phase: 3
    items:
      - item: 4
        sc_id: SC-4
        skill: implementation-pipeline
        task: step-dispatch
      - item: 5
        sc_id: SC-7
        skill: implementation-pipeline
        task: step-dispatch
  - phase: 4
    items:
      - item: 6
        sc_id: SC-5
        skill: implementation-pipeline
        task: step-dispatch
  - phase: 5
    items:
      - item: 7
        sc_id: SC-6
        skill: implementation-pipeline
        task: step-dispatch
      - item: 8
        sc_id: SC-8
        skill: implementation-pipeline
        task: step-dispatch
---

# Implementation Plan: Fix analytical-artifacts gate

## Pre-Implementation

### Coherence gate

- [ ] Dispatch `skill({name: "audit"})` → `task(..., prompt: "execute coherence-extraction from audit. Read `audit/tasks/coherence-extraction.md` first")` (**sub-agent**)
  - Context: {issue_number: 2155}
- [ ] Verify spec/plan coherence — no contradictions between spec SCs and the planned approach (**inline**)
  - Context: {issue_number: 2155}
- [ ] If coherence check FAIL: remediate and re-dispatch the coherence gate (**inline**)

### Baseline check

- [ ] Dispatch `pre-red-baseline` → `task(..., prompt: "execute pre-red-baseline from implementation-pipeline. Read `implementation-pipeline/tasks/pre-red-baseline.md` first")` (**sub-agent**)
  - Context: {issue_number: 2155}
- [ ] Initialize solve state: `solve state init {project_root}/tmp/2155/state/` (**inline**)
  - Context: {issue_number: 2155, state_dir: tmp/2155/state/}
- [ ] Verify git state: clean working tree, on correct feature branch (**inline**)
  - Context: {issue_number: 2155}

---

## Phase 1 — TDT remediation routing: remove HALT rows, add catch-all

Concern: Remove the 7 hardcoded HALT rows from the audit SKILL.md TDT and replace with a single catch-all that routes to retroactive artifact generation via backfill.md.

Files affected: `.opencode/skills/audit/SKILL.md`
SC coverage: SC-1 (string), SC-2 (string)
Dependencies: None (Phase 1 is the root of the DAG)

### Item 1 — SC-1: Remove 7 HALT rows

- [ ] **RED phase** — Write a content-verification test (string evidence) that greps for the 7 HALT rows (lines 65-71 in audit SKILL.md TDT) and asserts they exist. This test MUST FAIL because RED means the HALT rows currently exist but the test expects to catch their removal. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute red from test-driven-development. Read `test-driven-development/tasks/red.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-1}
- [ ] **z3-check-red** — Run `solve check --state-path {project_root}/tmp/2155/state/ --contract-path {project_root}/.opencode/skills/implementation-pipeline/pipeline-state-machine.yaml` to validate RED-to-GREEN state transition. (**inline**)
  - Context: {issue_number: 2155, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}
- [ ] **RED doublecheck** — Dispatch verification of the RED test: confirm it correctly identifies the HALT rows. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute verify from verification-before-completion. Read `verification-before-completion/tasks/verify.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-1}
- [ ] **z3-check-red-doublecheck** — Run `solve check` again after doublecheck. (**inline**)
  - Context: same as z3-check-red
- [ ] **Post-RED enforcement** — Dispatch enforcement gate: verify RED test quality. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-red-enforcement.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-1}
- [ ] **z3-check-post-red** — Run `solve check` for post-RED state. (**inline**)
- [ ] **GREEN phase** — Edit `.opencode/skills/audit/SKILL.md` to remove the 7 HALT rows (lines 65-71: `"blast-radius artifact missing" | HALT` through `"testability-assessment artifact missing" | HALT`). Also remove the `"stale analytical artifacts" | HALT` row. Green means the grep test now passes (HALT rows absent). (**clean-room**)
  - Dispatch: `task(..., prompt: "execute green from test-driven-development. Read `test-driven-development/tasks/green.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-1, file: .opencode/skills/audit/SKILL.md}
- [ ] **z3-check-green** — Run `solve check` for GREEN state. (**inline**)
- [ ] **Post-GREEN enforcement** — Dispatch enforcement gate: verify GREEN implementation quality. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-green-enforcement.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-1}
- [ ] **z3-check-post-green** — Run `solve check` for post-GREEN state. (**inline**)
- [ ] **Checkpoint tag** — Create checkpoint tag: `<parent>/checkpoint/2155/phase-1-SC-1`. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read `implementation-pipeline/tasks/checkpoint-tag-create.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-1}
- [ ] **Checkpoint commit** — Commit the SC-1 changes (HALT row removal). (**clean-room**)
  - Dispatch: `task(..., prompt: "execute commit-prep from git-workflow. Read `git-workflow/tasks/commit-prep.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-1}
- [ ] **Structural checks** — Run lint/typecheck/formatters on affected file. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute checklist from finishing-a-development-branch. Read `finishing-a-development-branch/tasks/checklist.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-1, path: .opencode/skills/audit/SKILL.md}
- [ ] **GREEN doublecheck** — Re-verify: grep confirms HALT rows are absent. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute verify from verification-before-completion. Read `verification-before-completion/tasks/verify.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-1}
- [ ] **GREEN VbC** — Verification before completion: all SC-1 criteria met. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute completion from verification-before-completion. Read `verification-before-completion/tasks/completion.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-1}
- [ ] **SC count gate** — Verify SC-1 verdict exists and is PASS. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read `implementation-pipeline/tasks/sc-count-gate.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-1}

### Item 2 — SC-2: Add catch-all analytical-artifacts-missing TDT row

- [ ] **RED phase** — Write a content-verification test (string evidence) that greps for `analytical artifacts missing` or `generate_first` in the audit SKILL.md TDT and asserts it is ABSENT. This test MUST FAIL because the catch-all does not yet exist. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute red from test-driven-development. Read `test-driven-development/tasks/red.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-2}
- [ ] **z3-check-red** — Solve check for RED state. (**inline**)
- [ ] **RED doublecheck** — Verify RED test correctness. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute verify from verification-before-completion. Read `verification-before-completion/tasks/verify.md` first")`
- [ ] **z3-check-red-doublecheck** — Solve check. (**inline**)
- [ ] **Post-RED enforcement** — Verify RED test quality. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-red-enforcement.md` first")`
- [ ] **z3-check-post-red** — Solve check. (**inline**)
- [ ] **GREEN phase** — Edit `.opencode/skills/audit/SKILL.md` TDT: add a catch-all row before the completion row. The row format:
  `| "analytical artifacts missing" / "generate artifacts first" | spec-audit (with retroactive backfill dispatch) | sub-task (DiMo chain) | {issue_number, spec_local_dir, role_chain, backfill_mode: retroactive} |`
  The catch-all matches when the spec-audit dispatcher encounters missing artifacts (detected by the sub-agent at runtime, NOT by orchestrator file checks). The sub-agent returns `REMEDIATION_REQUIRED` with `remediation_action: backfill-artifacts`. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute green from test-driven-development. Read `test-driven-development/tasks/green.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-2, file: .opencode/skills/audit/SKILL.md}
- [ ] **z3-check-green** — Solve check. (**inline**)
- [ ] **Post-GREEN enforcement** — Verify GREEN quality. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-green-enforcement.md` first")`
- [ ] **z3-check-post-green** — Solve check. (**inline**)
- [ ] **Checkpoint tag** — Create checkpoint tag. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read `implementation-pipeline/tasks/checkpoint-tag-create.md` first")`
- [ ] **Checkpoint commit** — Commit SC-2 changes. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute commit-prep from git-workflow. Read `git-workflow/tasks/commit-prep.md` first")`
- [ ] **Structural checks** — Lint/typecheck. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute checklist from finishing-a-development-branch. Read `finishing-a-development-branch/tasks/checklist.md` first")`
- [ ] **GREEN doublecheck** — Re-verify: grep confirms `analytical artifacts missing` present. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute verify from verification-before-completion. Read `verification-before-completion/tasks/verify.md` first")`
- [ ] **GREEN VbC** — Verification before completion. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute completion from verification-before-completion. Read `verification-before-completion/tasks/completion.md` first")`
- [ ] **SC count gate** — Verify SC-2 verdict. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read `implementation-pipeline/tasks/sc-count-gate.md` first")`

---

## Phase 2 — REMEDIATION_REQUIRED contract schema

Concern: Document the REMEDIATION_REQUIRED status and its companion fields (remediation_action, remediation_context) in the audit SKILL.md sub-agent contract schema section.

Files affected: `.opencode/skills/audit/SKILL.md`
SC coverage: SC-3 (string)
Dependencies: Phase 1 complete (TDT uses the contract schema)

### Item 3 — SC-3: Add REMEDIATION_REQUIRED to contract schema

- [ ] **RED phase** — Write a content-verification test (string evidence) that greps for `REMEDIATION_REQUIRED` in audit SKILL.md and asserts it is ABSENT. Test MUST FAIL. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute red from test-driven-development. Read `test-driven-development/tasks/red.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-3}
- [ ] **z3-check-red** — Solve check. (**inline**)
- [ ] **RED doublecheck** — Verify RED test. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute verify from verification-before-completion. Read `verification-before-completion/tasks/verify.md` first")`
- [ ] **z3-check-red-doublecheck** — Solve check. (**inline**)
- [ ] **Post-RED enforcement** — Verify RED quality. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-red-enforcement.md` first")`
- [ ] **z3-check-post-red** — Solve check. (**inline**)
- [ ] **GREEN phase** — Edit `.opencode/skills/audit/SKILL.md`:
  - Add a `## Sub-Agent Contract Schema` section (or locate existing contract documentation) that defines valid result contract statuses.
  - Add `REMEDIATION_REQUIRED` as a valid status value alongside `DONE`, `BLOCKED`, `OVERFLOW`.
  - Add `remediation_action` and `remediation_context` fields: `remediation_action` is a string naming the action (e.g., `backfill-artifacts`, `regenerate-artifact`), `remediation_context` is a dict/struct containing parameters for the remediation action (e.g., `{issue_number, spec_local_dir}`).
  - Document that `REMEDIATION_REQUIRED` is returned by sub-agents that detect a fixable precondition failure (not a blocker that requires developer intervention). (**clean-room**)
  - Dispatch: `task(..., prompt: "execute green from test-driven-development. Read `test-driven-development/tasks/green.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-3, file: .opencode/skills/audit/SKILL.md}
- [ ] **z3-check-green** — Solve check. (**inline**)
- [ ] **Post-GREEN enforcement** — Verify GREEN quality. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-green-enforcement.md` first")`
- [ ] **z3-check-post-green** — Solve check. (**inline**)
- [ ] **Checkpoint tag** — Create checkpoint tag. (**clean-room**)
- [ ] **Checkpoint commit** — Commit SC-3 changes. (**clean-room**)
- [ ] **Structural checks** — Lint/typecheck. (**clean-room**)
- [ ] **GREEN doublecheck** — Re-verify: grep confirms `REMEDIATION_REQUIRED` present. (**clean-room**)
- [ ] **GREEN VbC** — Verification before completion. (**clean-room**)
- [ ] **SC count gate** — Verify SC-3 verdict. (**clean-room**)

---

## Phase 3 — Mandatory Task Discipline and backfill verification

Concern: Update Mandatory Task Discipline item 5 to distinguish 3 artifact-missing scenarios. Verify backfill.md supports standalone dispatch.

Files affected: `.opencode/skills/audit/SKILL.md`, `.opencode/skills/writing-plans/tasks/backfill.md`
SC coverage: SC-4 (string), SC-7 (structural)
Dependencies: Phase 1 complete (SC-4 references TDT routing behavior)

### Item 4 — SC-4: Update Mandatory Task Discipline item 5

- [ ] **RED phase** — Write a string-evidence test: grep audit SKILL.md for `remediation_action` and assert it is ABSENT in the Mandatory Task Discipline section. Test MUST FAIL. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute red from test-driven-development. Read `test-driven-development/tasks/red.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-4}
- [ ] **z3-check-red** — (**inline**)
- [ ] **RED doublecheck** — (**clean-room**)
- [ ] **z3-check-red-doublecheck** — (**inline**)
- [ ] **Post-RED enforcement** — (**clean-room**)
- [ ] **z3-check-post-red** — (**inline**)
- [ ] **GREEN phase** — Edit `.opencode/skills/audit/SKILL.md` §Mandatory Task Discipline item 5. Replace the current single-sentence requirement with three distinct scenarios:

  > 5. **Analytical artifact validation required before audit tasks.** Three artifact-missing scenarios:
  >    - **(a) Missing at orchestration level** — The orchestrator dispatches spec-audit with `backfill_mode: retroactive`. The spec-audit sub-agent checks for artifacts independently. If missing, it dispatches retroactive generation via `writing-plans/tasks/backfill.md` (mode: retroactive). After backfill completes, the audit proceeds with the generated artifacts.
  >    - **(b) Missing discovered by sub-agent** — During any audit sub-task, if a sub-agent detects that required artifacts are missing, it returns `status: REMEDIATION_REQUIRED` with `remediation_action: backfill-artifacts` and `remediation_context: {issue_number, spec_local_dir}`. The orchestrator routes to `writing-plans/tasks/backfill.md` with `mode: retroactive`, then re-dispatches the sub-agent.
  >    - **(c) Stale artifacts** — If artifacts exist but their timestamps predate the spec revision, the sub-agent returns `REMEDIATION_REQUIRED` with `remediation_action: regenerate-artifact`. The orchestrator routes to backfill with `mode: retroactive --force`, then re-dispatches. If regeneration fails, the sub-agent returns BLOCKED.

  Add `remediation_action` documentation as part of the scenario descriptions. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute green from test-driven-development. Read `test-driven-development/tasks/green.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-4, file: .opencode/skills/audit/SKILL.md}
- [ ] **z3-check-green** — (**inline**)
- [ ] **Post-GREEN enforcement** — (**clean-room**)
- [ ] **z3-check-post-green** — (**inline**)
- [ ] **Checkpoint tag** — (**clean-room**)
- [ ] **Checkpoint commit** — (**clean-room**)
- [ ] **Structural checks** — (**clean-room**)
- [ ] **GREEN doublecheck** — Confirm `remediation_action` present in Mandatory Task Discipline. (**clean-room**)
- [ ] **GREEN VbC** — (**clean-room**)
- [ ] **SC count gate** — (**clean-room**)

### Item 5 — SC-7: Verify backfill.md standalone dispatch support (structural)

- [ ] **Read** `.opencode/skills/writing-plans/tasks/backfill.md` and confirm:
  - The procedure supports `mode: retroactive` operation (Step 4 generates artifacts from spec body without upstream spec-creation artifacts).
  - The entry criteria accept `{issue_number, project_root, issues_prefix}` context (no pre-existing artifacts or prior pipeline state required).
  - The result contract includes `status: DONE | BLOCKED` with `artifact_path` pointing to the generated analysis-summary.yaml.
  - (**inline**)
  - Context: {issue_number: 2155, sc_id: SC-7, file: .opencode/skills/writing-plans/tasks/backfill.md}
- [ ] **Document finding** in the plan artifact: `{issue_number}/artifacts/backfill-verification.yaml`. Include the mode parameter evidence, entry criteria match, and status. (**inline**)
  - Context: {issue_number: 2155, sc_id: SC-7}
- [ ] **If backfill does NOT support standalone dispatch** → BLOCKED with `backfill-standalone-unsupported`. HALT and report upstream dependency failure. (**inline**)

---

## Phase 4 — Stale reference cleanup

Concern: Fix the 010-approval-gate.md reference that points to a nonexistent analytical-artifacts.md file.

Files affected: `.opencode/guidelines/010-approval-gate.md`
SC coverage: SC-5 (string)
Dependencies: None (independent cleanup)

### Item 6 — SC-5: Fix 010-approval-gate.md reference

- [ ] **RED phase** — Write a string-evidence test: grep `.opencode/guidelines/010-approval-gate.md` for `analytical-artifacts.md` and assert it returns at least one match. Test MUST PASS at RED (reference currently exists). (**clean-room**)
  - Dispatch: `task(..., prompt: "execute red from test-driven-development. Read `test-driven-development/tasks/red.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-5}
- [ ] **z3-check-red** — (**inline**)
- [ ] **RED doublecheck** — (**clean-room**)
- [ ] **z3-check-red-doublecheck** — (**inline**)
- [ ] **Post-RED enforcement** — (**clean-room**)
- [ ] **z3-check-post-red** — (**inline**)
- [ ] **GREEN phase** — Edit `.opencode/guidelines/010-approval-gate.md`: replace the line referencing `spec-creation/tasks/analytical-artifacts.md` with a reference to `writing-plans/tasks/backfill.md`. The exact replacement text: `writing-plans/tasks/backfill.md` (retroactive artifact generation mode). (**clean-room**)
  - Dispatch: `task(..., prompt: "execute green from test-driven-development. Read `test-driven-development/tasks/green.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-5, file: .opencode/guidelines/010-approval-gate.md}
- [ ] **z3-check-green** — (**inline**)
- [ ] **Post-GREEN enforcement** — (**clean-room**)
- [ ] **z3-check-post-green** — (**inline**)
- [ ] **Checkpoint tag** — (**clean-room**)
- [ ] **Checkpoint commit** — (**clean-room**)
- [ ] **Structural checks** — (**clean-room**)
- [ ] **GREEN doublecheck** — Re-verify: grep for `analytical-artifacts.md` returns empty. (**clean-room**)
- [ ] **GREEN VbC** — (**clean-room**)
- [ ] **SC count gate** — (**clean-room**)

---

## Phase 5 — Behavioral enforcement tests

Concern: Write behavioral enforcement tests that verify the new TDT routing for both missing-artifact and present-artifact scenarios.

Files affected: `.opencode/tests-v2/behaviors/analytical-artifacts-missing.sh`, `.opencode/tests-v2/behaviors/analytical-artifacts-present.sh`
SC coverage: SC-6 (behavioral), SC-8 (behavioral)
Dependencies: Phase 1 complete (TDT changes must be in place), Phase 2+3 complete (contract + discipline updates)

### Item 7 — SC-6: Behavioral test for missing-artifact routing

- [ ] **RED phase** — Write a behavioral enforcement test at `.opencode/tests-v2/behaviors/analytical-artifacts-missing.sh`. The test SHALL:
  - Set up a test home via `with-test-home`.
  - Configure a minimal spec repo with a `.opencode` submodule containing the audit SKILL.md (with the new TDT catch-all).
  - Seed a spec issue WITHOUT analytical artifacts.
  - Run `opencode run "spec audit #2155"`.
  - Assert stderr does NOT contain `HALT` (the agent does not halt on missing artifacts).
  - Assert stderr contains `backfill` or `retroactive` (the agent dispatches retroactive generation).
  - Assert the agent completes the audit with a PASS/FAIL verdict (does not get stuck in artifact-checking loop).
  - This test MUST FAIL at RED because the implementation does not yet exist. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute red from test-driven-development. Read `test-driven-development/tasks/red.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-6, file: .opencode/tests-v2/behaviors/analytical-artifacts-missing.sh}
- [ ] **z3-check-red** — (**inline**)
- [ ] **RED doublecheck** — Verify the behavioral test has correct structure (uses `assert_stderr_pattern_present`/`assert_stderr_pattern_absent` helpers, sets up test repo correctly). (**clean-room**)
  - Dispatch: `task(..., prompt: "execute verify from verification-before-completion. Read `verification-before-completion/tasks/verify.md` first")`
- [ ] **z3-check-red-doublecheck** — (**inline**)
- [ ] **Post-RED enforcement** — (**clean-room**)
- [ ] **z3-check-post-red** — (**inline**)
- [ ] **GREEN phase** — The GREEN phase for SC-6 is a **no-op** — the behavioral test passes when the Phase 1 TDT changes + Phase 2 contract + Phase 3 discipline updates are in place. The behavioral test verifies end-to-end behavior; no additional code changes are needed if Phase 1-3 changes already implement the required routing. However, verify by running the behavioral test: (**clean-room**)
  - Dispatch: `task(..., prompt: "execute green from test-driven-development. Read `test-driven-development/tasks/green.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-6, command: bash .opencode/tests-v2/behaviors/analytical-artifacts-missing.sh}
  - If the test FAILS at GREEN: the Phase 1-3 changes need adjustment. Diagnose root cause, remediate, re-run.
- [ ] **z3-check-green** — (**inline**)
- [ ] **Post-GREEN enforcement** — (**clean-room**)
- [ ] **z3-check-post-green** — (**inline**)
- [ ] **Checkpoint tag** — (**clean-room**)
- [ ] **Checkpoint commit** — Commit the behavioral test file. (**clean-room**)
- [ ] **Structural checks** — (**clean-room**)
- [ ] **GREEN doublecheck** — Verify the behavioral test passes consistently. (**clean-room**)
- [ ] **GREEN VbC** — (**clean-room**)
- [ ] **SC count gate** — (**clean-room**)

### Item 8 — SC-8: Behavioral test for existing-artifact flow

- [ ] **RED phase** — Write a behavioral enforcement test at `.opencode/tests-v2/behaviors/analytical-artifacts-present.sh`. The test SHALL:
  - Set up a test home via `with-test-home`.
  - Configure a spec repo with all 7 analytical artifacts pre-generated.
  - Run `opencode run "spec audit #2155"`.
  - Assert the audit completes the full DiMo chain (Investigator → Validator → Evaluator → Arbiter) and produces a PASS/FAIL verdict.
  - Assert stderr does NOT contain `backfill` or `retroactive` (artifacts exist, no backfill needed).
  - Assert stderr does NOT contain `HALT` (the agent does not halt on artifact checks).
  - This test MUST FAIL at RED because the TDT catch-all must NOT match when artifacts exist. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute red from test-driven-development. Read `test-driven-development/tasks/red.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-8, file: .opencode/tests-v2/behaviors/analytical-artifacts-present.sh}
- [ ] **z3-check-red** — (**inline**)
- [ ] **RED doublecheck** — Verify the behavioral test structure. (**clean-room**)
- [ ] **z3-check-red-doublecheck** — (**inline**)
- [ ] **Post-RED enforcement** — (**clean-room**)
- [ ] **z3-check-post-red** — (**inline**)
- [ ] **GREEN phase** — Same as SC-6: no-op GREEN. Run the behavioral test to confirm it passes with the Phase 1-3 changes. If FAIL, remediate Phase 1 TDT (the catch-all should match only on missing artifacts, not on all audit requests). (**clean-room**)
  - Dispatch: `task(..., prompt: "execute green from test-driven-development. Read `test-driven-development/tasks/green.md` first")`
  - Context: {issue_number: 2155, sc_id: SC-8, command: bash .opencode/tests-v2/behaviors/analytical-artifacts-present.sh}
- [ ] **z3-check-green** — (**inline**)
- [ ] **Post-GREEN enforcement** — (**clean-room**)
- [ ] **z3-check-post-green** — (**inline**)
- [ ] **Checkpoint tag** — (**clean-room**)
- [ ] **Checkpoint commit** — Commit the behavioral test file. (**clean-room**)
- [ ] **Structural checks** — (**clean-room**)
- [ ] **GREEN doublecheck** — Verify behavioral test passes consistently. (**clean-room**)
- [ ] **GREEN VbC** — (**clean-room**)
- [ ] **SC count gate** — (**clean-room**)

---

## Post-Implementation

- [ ] **Audit** — Dispatch a full spec-audit to verify all 8 SCs are satisfied. (**sub-agent**)
  - Dispatch: `task(..., prompt: "execute spec-audit from audit. Read `audit/tasks/spec-audit.md` first")`
  - Context: {issue_number: 2155, spec_local_dir: .opencode/.issues/2155/spec.md}
- [ ] If audit returns FAIL: remediate root cause, then restart audit. DONE_WITH_CONCERNS coerced to FAIL. (**inline**)
- [ ] **Cross-validate** — Dispatch cross-validate with audit findings. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute cross-validate from audit. Read `audit/tasks/cross-validate.md` first")`
  - Context: {issue_number: 2155, spec_local_dir: .opencode/.issues/2155/spec.md, artifact_evidence_dir: .opencode/.issues/2155/artifacts/}
- [ ] **Review-prep** — Prepare the branch for review. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute review-prep from git-workflow. Read `git-workflow/tasks/review-prep.md` first")`
  - Context: {issue_number: 2155}
- [ ] **Create PR** — Create the pull request. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute create from pr-creation-workflow. Read `pr-creation-workflow/tasks/create.md` first")`
  - Context: {issue_number: 2155, authorization_scope: for_pr, halt_at: pr_created}
- [ ] **Exec-summary / completion** — Append lifecycle event and report execution summary. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute completion from completion-core. Read `completion-core/tasks/completion.md` first")`
  - Context: {issue_number: 2155}

---

## Lifecycle Events

- event: plan_created
  timestamp: 2026-07-26T23:31:00Z
  issuer: OpenCode (opencode/deepseek-v4-free)
  phase_count: 5
  item_count: 8
