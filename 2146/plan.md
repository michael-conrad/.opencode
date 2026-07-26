---
plan_schema_version: "1.0"
issue: 2146
title: Add session timestamp to session-init output
dispatch:
  - phase: 1
    name: Session Timestamp
    skill: test-driven-development
    task: red, green
---

## Pre-Implementation

- [ ] **Coherence gate.** Dispatch `audit --task coherence-extraction` to verify spec/plan coherence before any RED routing. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **Baseline check.** Dispatch `pre-red-baseline` from implementation-pipeline. Verifies branch state, submodule state, and working tree cleanliness before any file modification. Context: `{issue_number: 2146}`. (**sub-agent**)

## Phase 1 — Session Timestamp

This phase covers 3 concerns, each documented as a sub-phase below. All 5 SCs are co-located in a single phase because they modify the same file (`tools/session-init`) and share the same RED/GREEN/COMMIT lifecycle — splitting across phases would create artificial dependencies on a single file.

### Sub-Phase 1a — Timestamp Content (C1)

Concern: The timestamp must be human-readable, natural English prose with local timezone abbreviation. Covers SC-1, SC-3, SC-5.

### Sub-Phase 1b — Timestamp Position (C2)

Concern: The timestamp must appear after the Git branch line and before the `## CLI Auth Status` section. Covers SC-2.

### Sub-Phase 1c — Runtime Generation (C3)

Concern: The timestamp must use `datetime.now()` at runtime — no hardcoded date strings. Covers SC-4.

### Item 1 — SC-1: Human-readable datetime (behavioral)

- [ ] **red-phase.** Dispatch `red` from test-driven-development. Write a behavioral enforcement test that runs session-init and asserts the output contains a human-readable datetime with date, day of week, time, and timezone. The test MUST FAIL at this point (change doesn't exist yet). Context: `{issue_number: 2146, sc_id: SC-1}`. (**sub-agent**)
- [ ] **z3-check-red.** Run `solve --task check` to validate RED phase state transition. Context: `{issue_number: 2146, contract_path: <path>}`. (**inline**)
- [ ] **red-doublecheck.** Dispatch `verify` from verification-before-completion. Verify the RED test exists, is executable, and fails as expected. Context: `{issue_number: 2146, sc_id: SC-1}`. (**sub-agent**)
- [ ] **z3-check-red-doublecheck.** Run `solve --task check` to validate red-doublecheck state transition. Context: `{issue_number: 2146, contract_path: <path>}`. (**inline**)
- [ ] **post-red-enforcement.** Dispatch `post-red-enforcement` from implementation-pipeline. Enforce that RED test exists and fails before GREEN proceeds. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **z3-check-post-red.** Run `solve --task check` to validate post-RED state transition. Context: `{issue_number: 2146, contract_path: <path>}`. (**inline**)
- [ ] **green-phase.** Dispatch `green` from test-driven-development. Add a `print()` line to `tools/session-init` that emits the current local datetime using `datetime.now()` with `datetime.now().astimezone().tzname()` for the timezone abbreviation. Format as natural English prose (e.g. "Session started: Friday, July 25, 2026 at 10:15 PM EDT"). Place the line after the Git branch output and before the `## CLI Auth Status` section. Context: `{issue_number: 2146, sc_id: SC-1, affected_file: tools/session-init}`. (**sub-agent**)
- [ ] **z3-check-green.** Run `solve --task check` to validate GREEN phase state transition. Context: `{issue_number: 2146, contract_path: <path>}`. (**inline**)
- [ ] **post-green-enforcement.** Dispatch `post-green-enforcement` from implementation-pipeline. Enforce that GREEN implementation exists and RED test now passes. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **z3-check-post-green.** Run `solve --task check` to validate post-GREEN state transition. Context: `{issue_number: 2146, contract_path: <path>}`. (**inline**)
- [ ] **checkpoint-tag-create.** Dispatch `checkpoint-tag-create` from implementation-pipeline. Create a checkpoint tag for this item's PASS state. Context: `{issue_number: 2146, item: 1}`. (**sub-agent**)
- [ ] **checkpoint-commit.** Dispatch `commit-prep` from git-workflow. Commit the RED test and GREEN implementation together as one working slice. Context: `{issue_number: 2146, item: 1}`. (**sub-agent**)
- [ ] **structural-checks.** Dispatch `checklist` from finishing-a-development-branch. Run lint, typecheck, and structural verification on the modified file. Context: `{issue_number: 2146, item: 1}`. (**sub-agent**)
- [ ] **green-doublecheck.** Dispatch `verify` from verification-before-completion. Verify the GREEN implementation satisfies SC-1: run session-init and confirm the output contains a human-readable datetime with date, day of week, time, and timezone. Context: `{issue_number: 2146, sc_id: SC-1}`. (**sub-agent**)
- [ ] **green-vbc.** Dispatch `completion` from verification-before-completion. Produce evidence artifact for SC-1 with PASS/FAIL verdict. Context: `{issue_number: 2146, sc_id: SC-1}`. (**sub-agent**)
- [ ] **sc-count-gate.** Dispatch `sc-count-gate` from implementation-pipeline. Read `sc-summary.yaml`, count verified SCs, BLOCK if `verified_count < total_count`. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **pre-pr-gate.** Dispatch `verify` from verification-before-completion. Read all SC verdicts, BLOCK if any FAIL. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **audit.** Dispatch the appropriate audit task from audit skill with `{spec_local_dir: .opencode/.issues/2146, artifact_evidence_dir: <path>}`. If non-clean-pass (FAIL or DONE_WITH_CONCERNS), remediate root cause and restart audit. On clean PASS, collect artifact path. Context: `{issue_number: 2146}`. (**orchestrator** — multi-step: dispatch audit task, remediate inline if needed, then cross-validate)
- [ ] **cross-validate.** Dispatch `cross-validate` from audit. Produce consensus findings from auditor artifacts. Context: `{issue_number: 2146, auditor_artifact_paths: <path>}`. (**sub-agent**)
- [ ] **regression-check.** Dispatch `patterns` from test-driven-development. Generate and run regression test patterns to verify no regressions. Context: `{issue_number: 2146, sc_id: SC-1}`. (**sub-agent**)

### Item 2 — SC-2: Timestamp position (string)

- [ ] **red-phase.** Dispatch `red` from test-driven-development. Write a string-matching enforcement test that greps session-init output and asserts the timestamp line appears after the Git branch line and before the `## CLI Auth Status` section. The test MUST FAIL at this point. Context: `{issue_number: 2146, sc_id: SC-2}`. (**sub-agent**)
- [ ] **z3-check-red.** Run `solve --task check` to validate RED phase state transition. Context: `{issue_number: 2146, contract_path: <path>}`. (**inline**)
- [ ] **red-doublecheck.** Dispatch `verify` from verification-before-completion. Verify the RED test exists and fails. Context: `{issue_number: 2146, sc_id: SC-2}`. (**sub-agent**)
- [ ] **z3-check-red-doublecheck.** Run `solve --task check` to validate red-doublecheck state transition. Context: `{issue_number: 2146, contract_path: <path>}`. (**inline**)
- [ ] **post-red-enforcement.** Dispatch `post-red-enforcement` from implementation-pipeline. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **z3-check-post-red.** Run `solve --task check` to validate post-RED state transition. Context: `{issue_number: 2146, contract_path: <path>}`. (**inline**)
- [ ] **green-phase.** Dispatch `green` from test-driven-development. Ensure the timestamp print line is positioned after the Git branch output and before the `## CLI Auth Status` section in `tools/session-init`. Context: `{issue_number: 2146, sc_id: SC-2, affected_file: tools/session-init}`. (**sub-agent**)
- [ ] **z3-check-green.** Run `solve --task check` to validate GREEN phase state transition. Context: `{issue_number: 2146, contract_path: <path>}`. (**inline**)
- [ ] **post-green-enforcement.** Dispatch `post-green-enforcement` from implementation-pipeline. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **z3-check-post-green.** Run `solve --task check` to validate post-GREEN state transition. Context: `{issue_number: 2146, contract_path: <path>}`. (**inline**)
- [ ] **checkpoint-tag-create.** Dispatch `checkpoint-tag-create` from implementation-pipeline. Context: `{issue_number: 2146, item: 2}`. (**sub-agent**)
- [ ] **checkpoint-commit.** Dispatch `commit-prep` from git-workflow. Commit RED test and GREEN implementation together. Context: `{issue_number: 2146, item: 2}`. (**sub-agent**)
- [ ] **structural-checks.** Dispatch `checklist` from finishing-a-development-branch. Context: `{issue_number: 2146, item: 2}`. (**sub-agent**)
- [ ] **green-doublecheck.** Dispatch `verify` from verification-before-completion. Verify the timestamp appears after Git branch line and before `## CLI Auth Status`. Context: `{issue_number: 2146, sc_id: SC-2}`. (**sub-agent**)
- [ ] **green-vbc.** Dispatch `completion` from verification-before-completion. Produce evidence artifact for SC-2. Context: `{issue_number: 2146, sc_id: SC-2}`. (**sub-agent**)
- [ ] **sc-count-gate.** Dispatch `sc-count-gate` from implementation-pipeline. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **pre-pr-gate.** Dispatch `verify` from verification-before-completion. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **audit.** Dispatch audit task. Remediate if non-clean-pass. Cross-validate on clean PASS. Context: `{issue_number: 2146}`. (**orchestrator**)
- [ ] **cross-validate.** Dispatch `cross-validate` from audit. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **regression-check.** Dispatch `patterns` from test-driven-development. Context: `{issue_number: 2146, sc_id: SC-2}`. (**sub-agent**)

### Item 3 — SC-3: Natural English prose format (string)

- [ ] **red-phase.** Dispatch `red` from test-driven-development. Write a string-matching enforcement test that greps session-init output and asserts the timestamp format is natural English prose (not structured key:value like `timestamp: ...`). The test MUST FAIL. Context: `{issue_number: 2146, sc_id: SC-3}`. (**sub-agent**)
- [ ] **z3-check-red.** Run `solve --task check`. (**inline**)
- [ ] **red-doublecheck.** Dispatch `verify` from verification-before-completion. Context: `{issue_number: 2146, sc_id: SC-3}`. (**sub-agent**)
- [ ] **z3-check-red-doublecheck.** Run `solve --task check`. (**inline**)
- [ ] **post-red-enforcement.** Dispatch `post-red-enforcement` from implementation-pipeline. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **z3-check-post-red.** Run `solve --task check`. (**inline**)
- [ ] **green-phase.** Dispatch `green` from test-driven-development. Ensure the timestamp print line uses natural English prose format (e.g. "Session started: Friday, July 25, 2026 at 10:15 PM EDT") — no colons separating key from value, no structured format. Context: `{issue_number: 2146, sc_id: SC-3, affected_file: tools/session-init}`. (**sub-agent**)
- [ ] **z3-check-green.** Run `solve --task check`. (**inline**)
- [ ] **post-green-enforcement.** Dispatch `post-green-enforcement` from implementation-pipeline. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **z3-check-post-green.** Run `solve --task check`. (**inline**)
- [ ] **checkpoint-tag-create.** Dispatch `checkpoint-tag-create` from implementation-pipeline. Context: `{issue_number: 2146, item: 3}`. (**sub-agent**)
- [ ] **checkpoint-commit.** Dispatch `commit-prep` from git-workflow. Context: `{issue_number: 2146, item: 3}`. (**sub-agent**)
- [ ] **structural-checks.** Dispatch `checklist` from finishing-a-development-branch. Context: `{issue_number: 2146, item: 3}`. (**sub-agent**)
- [ ] **green-doublecheck.** Dispatch `verify` from verification-before-completion. Verify the timestamp format is natural English prose, not structured key:value. Context: `{issue_number: 2146, sc_id: SC-3}`. (**sub-agent**)
- [ ] **green-vbc.** Dispatch `completion` from verification-before-completion. Produce evidence artifact for SC-3. Context: `{issue_number: 2146, sc_id: SC-3}`. (**sub-agent**)
- [ ] **sc-count-gate.** Dispatch `sc-count-gate` from implementation-pipeline. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **pre-pr-gate.** Dispatch `verify` from verification-before-completion. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **audit.** Dispatch audit task. Remediate if non-clean-pass. Cross-validate on clean PASS. Context: `{issue_number: 2146}`. (**orchestrator**)
- [ ] **cross-validate.** Dispatch `cross-validate` from audit. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **regression-check.** Dispatch `patterns` from test-driven-development. Context: `{issue_number: 2146, sc_id: SC-3}`. (**sub-agent**)

### Item 4 — SC-4: Runtime datetime.now() (structural)

- [ ] **red-phase.** Dispatch `red` from test-driven-development. Write a structural enforcement test that inspects `tools/session-init` source code and asserts it contains `datetime.now()` or equivalent runtime call (not a hardcoded date string). The test MUST FAIL. Context: `{issue_number: 2146, sc_id: SC-4}`. (**sub-agent**)
- [ ] **z3-check-red.** Run `solve --task check`. (**inline**)
- [ ] **red-doublecheck.** Dispatch `verify` from verification-before-completion. Context: `{issue_number: 2146, sc_id: SC-4}`. (**sub-agent**)
- [ ] **z3-check-red-doublecheck.** Run `solve --task check`. (**inline**)
- [ ] **post-red-enforcement.** Dispatch `post-red-enforcement` from implementation-pipeline. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **z3-check-post-red.** Run `solve --task check`. (**inline**)
- [ ] **green-phase.** Dispatch `green` from test-driven-development. Ensure the timestamp uses `datetime.now()` (or `datetime.now(datetime.timezone.utc).astimezone()`) at runtime — no hardcoded date strings. Context: `{issue_number: 2146, sc_id: SC-4, affected_file: tools/session-init}`. (**sub-agent**)
- [ ] **z3-check-green.** Run `solve --task check`. (**inline**)
- [ ] **post-green-enforcement.** Dispatch `post-green-enforcement` from implementation-pipeline. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **z3-check-post-green.** Run `solve --task check`. (**inline**)
- [ ] **checkpoint-tag-create.** Dispatch `checkpoint-tag-create` from implementation-pipeline. Context: `{issue_number: 2146, item: 4}`. (**sub-agent**)
- [ ] **checkpoint-commit.** Dispatch `commit-prep` from git-workflow. Context: `{issue_number: 2146, item: 4}`. (**sub-agent**)
- [ ] **structural-checks.** Dispatch `checklist` from finishing-a-development-branch. Context: `{issue_number: 2146, item: 4}`. (**sub-agent**)
- [ ] **green-doublecheck.** Dispatch `verify` from verification-before-completion. Verify the source code uses `datetime.now()` or equivalent runtime call — no hardcoded date. Context: `{issue_number: 2146, sc_id: SC-4}`. (**sub-agent**)
- [ ] **green-vbc.** Dispatch `completion` from verification-before-completion. Produce evidence artifact for SC-4. Context: `{issue_number: 2146, sc_id: SC-4}`. (**sub-agent**)
- [ ] **sc-count-gate.** Dispatch `sc-count-gate` from implementation-pipeline. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **pre-pr-gate.** Dispatch `verify` from verification-before-completion. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **audit.** Dispatch audit task. Remediate if non-clean-pass. Cross-validate on clean PASS. Context: `{issue_number: 2146}`. (**orchestrator**)
- [ ] **cross-validate.** Dispatch `cross-validate` from audit. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **regression-check.** Dispatch `patterns` from test-driven-development. Context: `{issue_number: 2146, sc_id: SC-4}`. (**sub-agent**)

### Item 5 — SC-5: Local timezone abbreviation (string)

- [ ] **red-phase.** Dispatch `red` from test-driven-development. Write a string-matching enforcement test that runs session-init and asserts the timezone is a local abbreviation (e.g. EDT, IST, CET) — not a UTC offset notation (e.g. UTC-4, +05:30). The test MUST FAIL. Context: `{issue_number: 2146, sc_id: SC-5}`. (**sub-agent**)
- [ ] **z3-check-red.** Run `solve --task check`. (**inline**)
- [ ] **red-doublecheck.** Dispatch `verify` from verification-before-completion. Context: `{issue_number: 2146, sc_id: SC-5}`. (**sub-agent**)
- [ ] **z3-check-red-doublecheck.** Run `solve --task check`. (**inline**)
- [ ] **post-red-enforcement.** Dispatch `post-red-enforcement` from implementation-pipeline. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **z3-check-post-red.** Run `solve --task check`. (**inline**)
- [ ] **green-phase.** Dispatch `green` from test-driven-development. Ensure the timestamp uses `datetime.now().astimezone().tzname()` to get the local timezone abbreviation (e.g. EDT, IST, CET) — not a UTC offset string. Context: `{issue_number: 2146, sc_id: SC-5, affected_file: tools/session-init}`. (**sub-agent**)
- [ ] **z3-check-green.** Run `solve --task check`. (**inline**)
- [ ] **post-green-enforcement.** Dispatch `post-green-enforcement` from implementation-pipeline. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **z3-check-post-green.** Run `solve --task check`. (**inline**)
- [ ] **checkpoint-tag-create.** Dispatch `checkpoint-tag-create` from implementation-pipeline. Context: `{issue_number: 2146, item: 5}`. (**sub-agent**)
- [ ] **checkpoint-commit.** Dispatch `commit-prep` from git-workflow. Context: `{issue_number: 2146, item: 5}`. (**sub-agent**)
- [ ] **structural-checks.** Dispatch `checklist` from finishing-a-development-branch. Context: `{issue_number: 2146, item: 5}`. (**sub-agent**)
- [ ] **green-doublecheck.** Dispatch `verify` from verification-before-completion. Verify the timezone is a local abbreviation (e.g. EDT, IST, CET) — not UTC offset. Context: `{issue_number: 2146, sc_id: SC-5}`. (**sub-agent**)
- [ ] **green-vbc.** Dispatch `completion` from verification-before-completion. Produce evidence artifact for SC-5. Context: `{issue_number: 2146, sc_id: SC-5}`. (**sub-agent**)
- [ ] **sc-count-gate.** Dispatch `sc-count-gate` from implementation-pipeline. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **pre-pr-gate.** Dispatch `verify` from verification-before-completion. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **audit.** Dispatch audit task. Remediate if non-clean-pass. Cross-validate on clean PASS. Context: `{issue_number: 2146}`. (**orchestrator**)
- [ ] **cross-validate.** Dispatch `cross-validate` from audit. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **regression-check.** Dispatch `patterns` from test-driven-development. Context: `{issue_number: 2146, sc_id: SC-5}`. (**sub-agent**)

## Exit Criteria

| SC ID | Criterion | Evidence Type | Phase | Item |
|-------|-----------|---------------|-------|------|
| SC-1 | Human-readable datetime with date, day of week, time, and timezone | behavioral | Phase 1 (Sub-Phase 1a) | Item 1 |
| SC-2 | Timestamp appears after Git branch line and before `## CLI Auth Status` | string | Phase 1 (Sub-Phase 1b) | Item 2 |
| SC-3 | Natural English prose format (not structured key:value) | string | Phase 1 (Sub-Phase 1a) | Item 3 |
| SC-4 | Uses `datetime.now()` at runtime — no hardcoded date | structural | Phase 1 (Sub-Phase 1c) | Item 4 |
| SC-5 | Local timezone abbreviation (e.g. EDT, IST, CET) — not UTC offset | string | Phase 1 (Sub-Phase 1a) | Item 5 |

All 5 SCs must have PASS verdicts from verification-before-completion before the pipeline advances to Post-Implementation.

## Post-Implementation

- [ ] **review-prep.** Dispatch `review-prep` from git-workflow. Prepare PR review context, assess readiness, generate reviewer summary. Context: `{issue_number: 2146}`. (**sub-agent**)
- [ ] **create-pr.** Dispatch `create` from pr-creation-workflow. Create the pull request on the `feature/2146-session-timestamp` branch targeting the submodule's default branch. Context: `{issue_number: 2146, authorization_scope: for_pr, halt_at: pr_created}`. (**sub-agent**)
- [ ] **exec-summary.** Dispatch `completion` from completion-core. Generate structured completion signal, append lifecycle events, report executive summary. Context: `{issue_number: 2146}`. (**sub-agent**)

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-07-25T00:00:00Z | `plan_created` | Plan file: `.opencode/.issues/2146/plan.md`, Phases: 1 (Session Timestamp with 3 sub-phases), Items: 5 (SC-1 through SC-5), Dispatch mode: sub-agent (primary) + inline (z3-check) + orchestrator (audit), Pipeline signal: `for_pr` → `halt_at: pr_created`
