---
issue_number: 1615
title: "[SPEC-FIX] Document BEHAVIOR_SUBMODULE_COMMIT precondition in behavioral test harness"
status: draft
labels:
  - SPEC-FIX
created: 2026-06-30
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# [SPEC-FIX] Document BEHAVIOR_SUBMODULE_COMMIT precondition in behavioral test harness

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| **Problem Statement** | The behavioral test harness creates an isolated git repo, clones `.opencode` from remote as a submodule. `BEHAVIOR_SUBMODULE_COMMIT` exists to pin the submodule checkout to a specific SHA but is undocumented. Feature branch commits must be pushed to remote before test runs, but this workflow is not documented anywhere. |
| **Root Cause / Motivation** | `BEHAVIOR_SUBMODULE_COMMIT` is set in `helpers.sh` but has no documentation in `tests/AGENTS.md`. New agents and developers are unaware of the push-before-test requirement, leading to test runs that use stale submodule state. |
| **Approach Chosen** | Add a "Submodule Commit Precondition" section to `tests/AGENTS.md` documenting `BEHAVIOR_SUBMODULE_COMMIT`, the push-before-test workflow, and what happens if the precondition is not met. |
| **Alternatives Considered & Why Discarded** | Auto-push in `behavior_run()` (rejected — side effect violates test harness isolation). Document in `helpers.sh` comments only (rejected — insufficient visibility). |
| **Key Design Decisions** | Documentation-only fix. No changes to `helpers.sh` or `behavior_run()`. Single section in `tests/AGENTS.md`. |

## Problem

The behavioral test harness creates an isolated git repo, clones `.opencode` from remote as a submodule. `BEHAVIOR_SUBMODULE_COMMIT` exists to pin the submodule checkout to a specific SHA but is undocumented. Feature branch commits must be pushed to remote before test runs, but this workflow is not documented anywhere. New agents and developers are unaware of the push-before-test requirement, leading to test runs that use stale submodule state.

## Root Cause

`BEHAVIOR_SUBMODULE_COMMIT` is set in `helpers.sh` but has no documentation in `tests/AGENTS.md`. The push-before-test workflow is implicit — there is no written precondition that feature branch commits must be pushed to remote before a behavioral test can use them.

## Scope

### In Scope

- Add "Submodule Commit Precondition" section to `.opencode/tests/AGENTS.md` documenting:
  - `BEHAVIOR_SUBMODULE_COMMIT` environment variable and its purpose
  - Push-before-test workflow: feature branch commits must be pushed to remote before test runs
  - What happens if the precondition is not met (test uses stale submodule state)

### Out of Scope

- Changes to `helpers.sh` or `behavior_run()` logic
- Changes to the test harness infrastructure
- Auto-push or auto-sync mechanisms
- Changes to any other documentation files

## Affected Files

| File | Change Type | Anchor |
|------|-------------|--------|
| `.opencode/tests/AGENTS.md` | Add "Submodule Commit Precondition" section | New section |

## Approach

1. Add a new "Submodule Commit Precondition" section to `.opencode/tests/AGENTS.md` that documents:
   - `BEHAVIOR_SUBMODULE_COMMIT`: what it is, where it is set, what it pins
   - Push-before-test workflow: feature branch commits must be pushed to remote before `behavior_run()` is called
   - Consequence of not meeting the precondition: the test repo clones the submodule at the pinned SHA, not the feature branch HEAD

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `.opencode/tests/AGENTS.md` documents the push-before-test requirement for behavioral tests | `string` | `grep` for "push" in `.opencode/tests/AGENTS.md` | If missing, add the push requirement documentation | Phase 1 | `.opencode/tests/AGENTS.md` | REQ-1 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-2 | `.opencode/tests/AGENTS.md` documents `BEHAVIOR_SUBMODULE_COMMIT` and its purpose | `string` | `grep` for "BEHAVIOR_SUBMODULE_COMMIT" in `.opencode/tests/AGENTS.md` | If missing, add the variable documentation | Phase 1 | `.opencode/tests/AGENTS.md` | REQ-2 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-3 | `.opencode/tests/AGENTS.md` documents the workflow sequence (push → run test) | `string` | `grep` for "workflow" or "sequence" in `.opencode/tests/AGENTS.md` | If missing, add the workflow sequence documentation | Phase 1 | `.opencode/tests/AGENTS.md` | REQ-3 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1615/plan.md` before implementation begins.

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| `BEHAVIOR_SUBMODULE_COMMIT` is unset | Document that the submodule clones at remote HEAD — no pinning |
| Feature branch not pushed | Document that the test uses the pinned SHA, not the feature branch — stale state |
| Multiple feature branches | Document that each branch must be pushed independently before its test run |

## Risk Traceability

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Documentation is not read by agents | Medium | Medium | Section in AGENTS.md is the canonical test harness doc — agents read it during test setup | SC-1, SC-2, SC-3 |
| RISK-2 | Push-before-test is forgotten in practice | High | Medium | Documentation makes the precondition explicit; no behavioral change needed | SC-1 |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Documentation-only fix | The precondition is already enforced by the harness — only the documentation is missing | MUST | SC-1, SC-2, SC-3 |
| DEC-2 | Single section in AGENTS.md | AGENTS.md is the canonical test harness documentation — the precondition belongs there | MUST | SC-1, SC-2, SC-3 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Risk traceability | MAY | Update if new risks introduced |

## Decomposition Classification

| Classification | Number of Phases | Sub-Issue Requirements | PR Strategy |
| -------------- | ---------------- | ---------------------- | ----------- |
| single-task | 1 | None | single PR |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep` for "BEHAVIOR_SUBMODULE_COMMIT" in `.opencode/` | Identify existing references and verify no prior documentation |
| Local docs | `.opencode/tests/AGENTS.md` | Verify no existing submodule precondition section |
| Local docs | `.opencode/tests/behaviors/helpers.sh` | Verify `BEHAVIOR_SUBMODULE_COMMIT` usage |

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/1615/`.
After creation, `local-issues sync` MUST be run and the result committed to create the local `.issues/1615/` entry.
The implementation plan will be created in `.opencode/.issues/1615/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
