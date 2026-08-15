> **Full spec and artifacts: [`2254/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2254)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2254/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

### Problem Statement

This spec was originally scoped as a total remediation of the spec-writer (`spec-creation`) and spec-auditor (`audit`) skill card sets plus the consolidated `.opencode/reference/` standards, addressing internal-consistency drifts, format gaps, linter enforcement, markdown-link correctness, and functional end-to-end verification. The original SC set (SC-1..SC-18 drift repair, SC-23..SC-31 format conformance, SC-35..SC-37 reference/URL root-cause) described defects claimed to exist on disk.

A spec-audit FAIL (5 of 11 holistic dimensions: Implementability, Internal Consistency, Testability, Provenance, Correctness) found that the spec's stated current on-disk state contradicts the actual state. Re-verification during this revision confirms the audit finding and extends it: **the drift-repair and format remediation described by SC-1..SC-18, SC-23..SC-31, and SC-35..SC-37 is already complete on disk.** The defects those SCs claim to fix do not exist:

- **SC-8** claimed 40 defective audit role-card files (28 flat + 12 subdirectory) with frontmatter `name:` fields mismatching filenames. On disk, `audit/tasks/` has **no subdirectories** — 50 flat files — and all 48 role-card files already have `name:` fields matching their filenames (zero mismatches). The SC-8 verification glob `*-role.md` matches zero files.
- **SC-10** claimed broken cross-references to non-existent monolithic role-task files (`tasks/spec-audit.md`, `tasks/plan-fidelity.md`). On disk, no such references exist; `reference/holistic-dimensions.yaml` already points at the actual role-split files (`spec-audit-evaluator.md`, `plan-fidelity-evaluator.md`).
- **SC-12** claimed three subdirectory audit tasks (`closure-verification/`, `coherence-extraction/`, `spec-summary/`) needed flattening. On disk these are already flat files (`closure-verification-arbiter.md`, etc.), not subdirectories.
- **SC-14** claimed a redundant `behavioral-sc-evaluator.md` needed removal. On disk the file does not exist.
- **SC-1..SC-7, SC-9, SC-11, SC-13, SC-15..SC-18** (dispatch format, Task Files table removal, audit Workflows structure, description format, Task headings, reference task names, completion routing, taxonomy citations, missing-type hard FAIL, analyze issue anchoring, dynamic dimension loading) are all already satisfied on disk.
- **SC-23, SC-24, SC-31** (numbered-checkbox Workflows with execution-mode sub-bullets, orchestrator-step framing) are already satisfied in both `spec-creation/SKILL.md` and `audit/SKILL.md`.
- **SC-28** (skildeck linter format rules) is already implemented — `skildeck-lint` enforces rules R1-R5 (numbered-checkbox workflow, execution-mode sub-bullet, clean-room unit, dispatch-contract completeness, markdown-link correctness).
- **SC-35, SC-36, SC-37** (reference-doc numbered-checkbox formats, issues-data URL template fix) are already satisfied — `skill-card-description-standards.md` and `task-card-structure-standards.md` specify the numbered-checkbox format with clean-room/dispatch-contract mandates, and `issue-operations-core/tasks/creation.md` Step 5 already uses `tree/issues-data/N/` with `{{SPEC_PATH}}` = `N/`.

The actual remaining remediation, re-grounded in the current on-disk state, is:

1. **Residual format conformance gap (SC-25):** `spec-creation/tasks/create.md` contains plain numbered lists (not numbered-checkbox) inside its Procedure sub-steps (Step 3, Step 3.1, Step 3.2, Step 6, Step 7), violating the canonical numbered-checkbox task-card Procedure format defined in `task-card-structure-standards.md`.
2. **Functional end-to-end verification (SC-32, SC-33, SC-34):** The drift-repair and format SCs prove the remediated cards are well-formed on disk, but they do not prove the remediated skills actually work when dispatched. The goal is a working set of spec skills. These behavioral SCs run the remediated `spec-creation` pipeline and the audit DiMo 4-role chain end-to-end against a fixture in a shared test home with a test gitbucket instance, asserting correct output — no mis-routing, no missing task cards, no broken cross-references, no deprecated dispatch strings. The behavioral test scripts for these SCs already exist (`2254-sc32-functional-spec-creation-pipeline.sh`, `2254-sc33-audit-dimo-chain.sh`, `2254-sc34-shared-test-home.sh`); the SCs require them to pass.

### Root Cause / Motivation

The original spec was authored against a stale/imagined on-disk state. Its SCs claimed to fix drifts that a prior remediation pass had already resolved. Because agent-facing text is consumed as routing instructions, a spec that misstates the on-disk state is itself a defect vector: an implementor following SC-8/SC-10/SC-12/SC-14 would search for and "repair" defects that do not exist, or verify against globs (`*-role.md`) that match zero files. This revision re-grounds the spec in the actual on-disk state so the remaining work is precisely scoped: the residual `create.md` format gap and the functional end-to-end proof that the remediated skills work when dispatched.

### Approach Chosen

Re-ground the spec's problem statement and success criteria in the verified on-disk state. Remove the fabricated drift-repair and format SCs that are already satisfied (SC-1..SC-18, SC-23, SC-24, SC-26..SC-31, SC-35..SC-37), and retain the SCs that represent the actual remaining remediation: SC-25 (residual `create.md` format conformance) and SC-32..SC-34 (functional end-to-end verification). Apply exactly one prescriptive resolution per retained SC, each mapped one-to-one to a success criterion. Fix the traceability table's phase numbering to match the 29-phase implementation plan and analytical artifacts.

### Alternatives Considered & Why Discarded

- **Keep the fabricated drift-repair SCs and mark them "already satisfied" rather than removing them.** Discarded: the spec is a requirements document, not a tracking document. Retaining SCs for already-complete work misstates the remaining scope and forces the implementor to re-verify work that is done. The drift-repair and format remediation is recorded in the change-control history; the active SC set must reflect the actual remaining work.
- **Re-ground every already-satisfied SC as a "verify already complete" behavioral check.** Discarded: re-verifying already-complete work adds execution cost without changing the deliverable. The verified on-disk state is recorded in this revision's problem statement and change-control entry; the active SC set focuses on the remaining work.
- **Leave the traceability table at Phase 1..7.** Discarded: the implementation plan and analytical artifacts use a 29-phase model (plan.md `phase_count: 29`, `interface-compatibility.yaml`/`cross-cutting-matrix.yaml` Phase 1..29). The traceability table must align with the actual phase structure.

### Key Design Decisions

- **Remove already-satisfied SCs; retain only the actual remaining remediation.** Tradeoff: the SC set shrinks substantially, but the spec accurately reflects the on-disk state and the implementor's scope is precisely bounded.
- **Retain the functional end-to-end SCs (SC-32..SC-34) as the primary remaining work.** Tradeoff: running the full `spec-creation` pipeline and audit DiMo chain end-to-end costs minutes of execution time per test, but is the only way to prove the remediated skills actually work when dispatched — the difference between a working set of spec skills and a well-formed set of spec cards.
- **Retain SC-25 for the residual `create.md` format gap.** Tradeoff: a narrow, verifiable format-conformance item, but it is the one genuine on-disk format defect found by re-verification.
- **Align the traceability table with the 29-phase plan.** Tradeoff: the traceability table maps each requirement to the phase that implements it in the actual plan, resolving the Phase 1..7 vs Phase 1..29 inconsistency.

### User Intent / Original Prompt

A history-grounded read-only audit of the spec-writer and spec-audit skill card sets and the consolidated reference standards, identifying internal-consistency drifts and prescribing one resolution per finding, subsequently expanded into a total remediation scope. A spec-audit FAIL found the spec's on-disk state claims contradicted actual state; this revision re-grounds the spec so its problem statement and success criteria accurately reflect the actual on-disk state and the actual remaining remediation.

## 2. Not Included

- **Already-complete drift-repair and format remediation** — SC-1..SC-18, SC-23, SC-24, SC-26..SC-31, SC-35..SC-37 describe work already satisfied on disk; they are removed from the active SC set and recorded in the change-control history.
- **Application `src/` code changes** — All affected files are agent-facing markdown in `.opencode/` plus the skildeck linter under `.opencode/tools/impl/skildeck/`; no application `src/` runtime code changes.
- **Non-agent-facing documentation** — Changes confined to skill cards, task cards, reference standards, and the skildeck linter consumed by agents.
- **Behavioral test suite changes beyond what the SCs require** — The functional end-to-end SCs (SC-32..SC-34) require their own behavioral tests; no other test-suite changes are in scope.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-25 | Every task card Procedure section in `spec-creation` and `audit` SHALL use numbered checkbox lists (`- [ ] N.`), including the Procedure sub-steps of `spec-creation/tasks/create.md` (Step 3, Step 3.1, Step 3.2, Step 6, Step 7 currently use plain numbered lists). | string | grep all task cards in spec-creation and audit for numbered checkbox procedure steps; assert no plain numbered lists remain in Procedure sections |
| SC-32 | Dispatching the full spec-creation pipeline (analyze → create → validate) against a fixture problem in the shared test home SHALL produce a valid spec with no mis-routing, no missing task cards, no broken cross-references, and no deprecated dispatch strings. | behavioral | opencode run (with-test-home): dispatch the remediated spec-creation pipeline end-to-end against the test gitbucket instance and assert correct output |
| SC-33 | Dispatching the audit DiMo 4-role chain (investigator → validator → evaluator → arbiter) against a fixture spec in the shared test home SHALL produce a valid verdict, with each role dispatching to the correct split task card with a complete dispatch contract. | behavioral | opencode run (with-test-home): dispatch the remediated audit chain end-to-end and assert correct output |
| SC-34 | The spec-creation and audit behavioral tests SHALL share a common test home with a test project and test gitbucket instance, sequenced so later tests build upon the state created by earlier tests in an incremental fashion. | behavioral | verify the behavioral test setup uses the shared with-test-home infrastructure with the gitbucket instance |

## 4. Requirements

- R-23. Task card Procedure sections SHALL use numbered checkbox lists (`- [ ] N.`). Task cards SHALL be designed for non-task-capable sub-agents; a task card whose procedure would require internal sub-agent dispatch SHALL be split into multiple task cards, and the SKILL.md workflow SHALL dispatch each split task card as a separate step. (SC-25 implements the numbered-checkbox Procedure requirement; the clean-room split is already satisfied on disk.)
- R-28. The spec-creation behavioral test SHALL dispatch the full spec-creation pipeline (analyze → create → validate) end-to-end against a fixture problem in the shared test home and assert correct output (a valid spec with no mis-routing, no missing task cards, no broken cross-references, and no deprecated dispatch strings).
- R-29. The audit behavioral test SHALL dispatch the DiMo 4-role chain (investigator → validator → evaluator → arbiter) end-to-end against a fixture spec in the shared test home and assert a valid verdict with each role dispatching to the correct split task card with a complete dispatch contract.
- R-30. The spec-creation and audit behavioral tests SHALL share a common test home with a test project and test gitbucket instance, sequenced so later tests build upon the state created by earlier tests in an incremental fashion.
- R-15. No application `src/` code changes; changes SHALL be confined to agent-facing skill/reference markdown files and the skildeck linter under `.opencode/tools/impl/skildeck/`. Application `src/` code remains excluded.
- R-16. Behavioral SCs SHALL apply only where the change affects runtime dispatch behavior; string/structural elsewhere.
- R-17. No bifurcated/backwards-compat paths SHALL be introduced in agent-facing instructions (anti-bifurcation mandate).

## 5. Items

### Item 25 (SC-25): Convert create.md Procedure sub-steps to numbered-checkbox format

- RED: grep `spec-creation/tasks/create.md` asserts no plain numbered lists remain in Procedure sub-steps (Step 3, Step 3.1, Step 3.2, Step 6, Step 7) — fails on current content (plain numbered lists at lines 71-72, 80-82, 88-90, 130-133, 147-148)
- GREEN: Convert the plain numbered lists in create.md Procedure sub-steps to numbered checkbox lists (`- [ ] N.`)
- verify: grep conformance
- commit: spec-creation/tasks/create.md

### Item 32 (SC-32): Functional end-to-end spec-creation pipeline

- RED: opencode run (with-test-home) dispatches the remediated spec-creation pipeline (analyze → create → validate) end-to-end against a fixture problem in the shared test home and asserts correct output — fails if the pipeline mis-routes, references missing task cards, or uses deprecated dispatch strings
- GREEN: Ensure the remediated spec-creation pipeline dispatches end-to-end against the test gitbucket instance and produces a valid spec with no mis-routing, no missing task cards, no broken cross-references, and no deprecated dispatch strings
- verify: behavioral test via opencode run (with-test-home) against the test gitbucket instance
- commit: behavioral test script (`2254-sc32-functional-spec-creation-pipeline.sh`), fixtures

### Item 33 (SC-33): Functional end-to-end audit DiMo chain

- RED: opencode run (with-test-home) dispatches the remediated audit DiMo 4-role chain (investigator → validator → evaluator → arbiter) end-to-end against a fixture spec in the shared test home and asserts correct output — fails if roles mis-route, dispatch to missing task cards, or carry incomplete dispatch contracts
- GREEN: Ensure the remediated audit chain dispatches end-to-end and produces a valid verdict, with each role dispatching to the correct split task card with a complete dispatch contract
- verify: behavioral test via opencode run (with-test-home)
- commit: behavioral test script (`2254-sc33-audit-dimo-chain.sh`), fixtures

### Item 34 (SC-34): Shared test home with gitbucket instance

- RED: verify the spec-creation and audit behavioral test setup uses the shared with-test-home infrastructure with the gitbucket instance, sequenced incrementally — fails if no shared test home / gitbucket instance
- GREEN: Ensure the spec-creation and audit behavioral tests share a common test home with a test project and test gitbucket instance, sequenced so later tests build upon the state created by earlier tests in an incremental fashion
- verify: behavioral test setup check (shared with-test-home infrastructure with the gitbucket instance)
- commit: behavioral test scripts (`2254-sc34-shared-test-home.sh`), fixtures

## 6. Dependencies

- **Infrastructure: `with-test-home` + GitBucket instance** — Relationship: the functional behavioral SCs (SC-32, SC-33, SC-34) depend on the shared test home with a test project and the test gitbucket instance provisioned by `BEHAVIOR_NEEDS_REMOTE`. Status: satisfied (`.opencode/tests-v2/with-test-home` and `__ensure_gitbucket` in `behaviors/helpers.sh` exist; the SC-32/SC-33/SC-34 behavioral test scripts exist).
- **Reference: `task-card-structure-standards.md`** — Relationship: defines the numbered-checkbox task-card Procedure format that SC-25 conforms to. Status: satisfied (the reference doc already specifies the numbered-checkbox Procedure format with the clean-room unit and dispatch-contract completeness mandates).
- **Tool: skildeck linter (`.opencode/tools/impl/skildeck/`)** — Relationship: enforces the numbered-checkbox format rules that SC-25 conforms to. Status: satisfied (skildeck-lint enforces rules R1-R5).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-23 | SC-25 | Phase 21 |
| R-28 | SC-32 | Phase 27 |
| R-29 | SC-33 | Phase 28 |
| R-30 | SC-34 | Phase 29 |
| R-15 | SC-25, SC-32, SC-33, SC-34 | All |
| R-16 | SC-32, SC-33, SC-34 | Phase 27, Phase 28, Phase 29 |
| R-17 | SC-25, SC-32, SC-33, SC-34 | All |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| spec-creation/tasks/create.md | code | `.opencode/skills/spec-creation/tasks/create.md` | read + grep during analysis |
| spec-creation/SKILL.md | code | `.opencode/skills/spec-creation/SKILL.md` | read + grep during analysis |
| audit/SKILL.md | code | `.opencode/skills/audit/SKILL.md` | read + grep during analysis |
| audit/tasks/*.md | code | `.opencode/skills/audit/tasks/*.md` | read during analysis |
| reference/task-card-structure-standards.md | doc | `.opencode/reference/task-card-structure-standards.md` | read during analysis |
| reference/skill-card-description-standards.md | doc | `.opencode/reference/skill-card-description-standards.md` | read during analysis |
| reference/spec-structure-standards.md | doc | `.opencode/reference/spec-structure-standards.md` | read during analysis |
| reference/holistic-dimensions.yaml | config | `.opencode/reference/holistic-dimensions.yaml` | read during analysis |
| issue-operations-core/tasks/creation.md | code | `.opencode/skills/issue-operations-core/tasks/creation.md` | read + grep during analysis |
| skildeck linter | code | `.opencode/tools/impl/skildeck/` | read during analysis |
| with-test-home | infra | `.opencode/tests-v2/with-test-home` | read during analysis |
| behaviors/helpers.sh | infra | `.opencode/tests-v2/behaviors/helpers.sh` | read during analysis |
| behavioral test scripts | infra | `.opencode/tests-v2/behaviors/2254-sc{32,33,34}-*.sh` | read during analysis |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-25: Verifying the create.md Procedure format costs one grep search. Skipping means a task card keeps a non-canonical procedure format that diverges from the reference standard.
- SC-32: Running the functional spec-creation pipeline behavioral test costs minutes of execution time. Skipping means the remediated spec-creation pipeline is never proven to work end-to-end — a mis-routing, a missing task card, a broken cross-reference, or a deprecated dispatch string ships undetected and every spec created through the pipeline inherits the defect.
- SC-33: Running the functional audit DiMo chain behavioral test costs minutes of execution time. Skipping means the remediated audit chain is never proven to work end-to-end — a role mis-routing to a missing task card or carrying an incomplete dispatch contract ships undetected and every audit verdict inherits the defect.
- SC-34: Verifying the shared test home with the gitbucket instance costs a behavioral test setup check. Skipping means the functional tests run in isolation without shared state, so the incremental build-up (the spec created by SC-32 becomes the fixture audited by SC-33) is lost and the remote API for remote-stub/issue-creation tests is unavailable.

## 11. Edge Cases

- **Condition: A task card's Procedure sub-step uses a plain numbered list instead of a numbered-checkbox list.** Expected behavior: the sub-step is converted to a numbered-checkbox list per SC-25. Resolution: the Procedure section of every task card in spec-creation and audit conforms to the canonical numbered-checkbox format.
- **Condition: The functional spec-creation pipeline (SC-32) mis-routes, references a missing task card, or uses a deprecated dispatch string when dispatched end-to-end.** Expected behavior: the behavioral test asserts correct output and FAILs on any of these defects. Resolution: the residual format gap (SC-25) is fixed first; SC-32 verifies the remediated pipeline works end-to-end.
- **Condition: The functional audit DiMo chain (SC-33) mis-routes a role to a missing task card or carries an incomplete dispatch contract.** Expected behavior: the behavioral test asserts a valid verdict and FAILs on any of these defects. Resolution: the role-card and dispatch-contract remediation (already satisfied on disk) is confirmed; SC-33 verifies the remediated chain works end-to-end.
- **Condition: The spec-creation and audit behavioral tests do not share a common test home with a test project and test gitbucket instance.** Expected behavior: SC-34 requires the shared with-test-home infrastructure with the gitbucket instance. Resolution: the tests are sequenced so later tests build upon the state created by earlier tests in an incremental fashion; the gitbucket instance provides the remote API for remote-stub/issue-creation tests.
- **Condition: The functional behavioral tests (SC-32, SC-33) cannot execute (model unavailable, gitbucket provisioning failure).** Expected behavior: the SCs are reported FAIL per the functional/behavioral test substitution prohibition. Resolution: remediation-first protocol applies before any escalation.

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-15 | Re-grounded the spec in the verified on-disk state following a spec-audit FAIL. Removed the already-satisfied drift-repair and format SCs (SC-1..SC-18, SC-23, SC-24, SC-26..SC-31, SC-35..SC-37) from the active SC set; retained only the actual remaining remediation: SC-25 (residual `create.md` Procedure plain-numbered-list format gap) and SC-32..SC-34 (functional end-to-end verification). Rewrote the Problem Statement to acknowledge the drift-repair and format remediation is already complete on disk. Removed the fabricated SC-8/SC-10/SC-12/SC-14 claims (audit/tasks/ has no subdirectories, all role-card `name:` fields already match filenames, no monolithic cross-references, behavioral-sc-evaluator.md does not exist). Fixed the traceability table phase numbering from Phase 1..7 to the 29-phase plan (Phase 21 for SC-25, Phase 27/28/29 for SC-32/33/34). Updated Requirements, Items, Dependencies, Documentation Sources, Cost Frame, and Edge Cases to match the re-grounded SC set. | Spec-audit FAIL (5 of 11 holistic dimensions: Implementability, Internal Consistency, Testability, Provenance, Correctness): the spec's stated current on-disk state contradicts actual state. SC-8/SC-10/SC-12/SC-14 claim to fix defects that do not exist on disk; the traceability table uses Phase 1..7 while the analytical artifacts and plan use Phase 1..29. The spec must be revised so its problem statement and SCs accurately reflect the actual on-disk state. | spec-creation revision pipeline |

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
