---
plan_schema_version: "1.0"
issue: 2108
title: "Add connectivity verification gate and behavioral enforcement test"
dispatch:
  - phase: 1
    skill: test-driven-development
    task: green
    scs: [SC-1]
  - phase: 2
    skill: test-driven-development
    task: red
    scs: [SC-2]
---

## Pre-Implementation

- [ ] **Coherence gate** — dispatch `audit --task coherence-extraction` to verify spec/plan coherence before any file modification. Context: `{issue_number: 2108}`. (**sub-agent**)
- [ ] **Baseline check** — dispatch `implementation-pipeline --task pre-red-baseline` to capture pre-change state. Context: `{issue_number: 2108}`. (**sub-agent**)

## Phase 1: Add connectivity verification gate to .opencode/AGENTS.md

**SCs:** SC-1 | **Concern:** C1 | **Dispatch:** `test-driven-development --task green`

- [ ] **Green phase** — dispatch `test-driven-development --task green` to implement the change. Sub-agent reads `test-driven-development/tasks/green.md`, then:
  - Adds a verification gate section to `.opencode/AGENTS.md` requiring tool-call evidence before any connectivity constraint claim is included in agent-facing text
  - Context: `{issue_number: 2108, scs: [SC-1]}`. (**sub-agent**)
- [ ] **Z3 check GREEN** — dispatch `solve --task check` to verify state transition. Context: `{issue_number: 2108, contract_path: <auto>}`. (**inline**)
- [ ] **Post-GREEN enforcement** — dispatch `implementation-pipeline --task post-green-enforcement` to verify GREEN output. Context: `{issue_number: 2108}`. (**sub-agent**)
- [ ] **Z3 check post-GREEN** — dispatch `solve --task check` to verify post-GREEN state. Context: `{issue_number: 2108, contract_path: <auto>}`. (**inline**)
- [ ] **Checkpoint tag create** — dispatch `implementation-pipeline --task checkpoint-tag-create` to create a checkpoint tag. Context: `{issue_number: 2108}`. (**sub-agent**)
- [ ] **Checkpoint commit** — dispatch `git-workflow --task commit-prep` to commit changes with checkpoint. Context: `{issue_number: 2108}`. (**sub-agent**)
- [ ] **Structural checks** — dispatch `finishing-a-development-branch --task checklist` for lint/typecheck. Context: `{issue_number: 2108}`. (**sub-agent**)
- [ ] **GREEN doublecheck** — dispatch `verification-before-completion --task verify` to verify SC-1. Context: `{issue_number: 2108, scs: [SC-1]}`. (**sub-agent**)
- [ ] **GREEN VbC** — dispatch `verification-before-completion --task completion` for SC-1. Context: `{issue_number: 2108}`. (**sub-agent**)

## Phase 2: Behavioral enforcement test for connectivity verification

**SCs:** SC-2 | **Concern:** C2 | **Dispatch:** `test-driven-development --task red` | **Depends on:** Phase 1

- [ ] **SC coherence gate** — dispatch `audit --task coherence-extraction` to verify Phase 2 coherence against Phase 1 output. Context: `{issue_number: 2108}`. (**sub-agent**)
- [ ] **Pre-RED baseline** — dispatch `implementation-pipeline --task pre-red-baseline` to capture pre-change state. Context: `{issue_number: 2108}`. (**sub-agent**)
- [ ] **RED phase** — dispatch `test-driven-development --task red` to write the failing behavioral test. Sub-agent reads `test-driven-development/tasks/red.md`, then:
  - Creates `.opencode/tests-v2/behaviors/connectivity-verification.sh` with a behavioral enforcement test
  - Test sends a prompt asking about database connectivity and verifies the agent does NOT fabricate VPN/network constraints without a tool call
  - Uses `with-test-home` wrapper for `opencode run`
  - Context: `{issue_number: 2108, scs: [SC-2]}`. (**sub-agent**)
- [ ] **Z3 check RED** — dispatch `solve --task check` to verify RED state. Context: `{issue_number: 2108, contract_path: <auto>}`. (**inline**)
- [ ] **RED doublecheck** — dispatch `verification-before-completion --task verify` to verify RED test fails as expected. Context: `{issue_number: 2108, scs: [SC-2]}`. (**sub-agent**)
- [ ] **Z3 check RED doublecheck** — dispatch `solve --task check` to verify RED doublecheck state. Context: `{issue_number: 2108, contract_path: <auto>}`. (**inline**)
- [ ] **Post-RED enforcement** — dispatch `implementation-pipeline --task post-red-enforcement` to verify RED output. Context: `{issue_number: 2108}`. (**sub-agent**)
- [ ] **Z3 check post-RED** — dispatch `solve --task check` to verify post-RED state. Context: `{issue_number: 2108, contract_path: <auto>}`. (**inline**)
- [ ] **Checkpoint tag create** — dispatch `implementation-pipeline --task checkpoint-tag-create` to create a checkpoint tag. Context: `{issue_number: 2108}`. (**sub-agent**)
- [ ] **Checkpoint commit** — dispatch `git-workflow --task commit-prep` to commit the RED test. Context: `{issue_number: 2108}`. (**sub-agent**)
- [ ] **Structural checks** — dispatch `finishing-a-development-branch --task checklist` for lint/typecheck. Context: `{issue_number: 2108}`. (**sub-agent**)
- [ ] **GREEN doublecheck** — dispatch `verification-before-completion --task verify` to verify SC-2. Context: `{issue_number: 2108, scs: [SC-2]}`. (**sub-agent**)
- [ ] **GREEN VbC** — dispatch `verification-before-completion --task completion` for SC-2. Context: `{issue_number: 2108}`. (**sub-agent**)

## Post-Implementation

- [ ] **SC count gate** — dispatch `implementation-pipeline --task sc-count-gate` to verify all 2 SCs have verdicts. Context: `{issue_number: 2108}`. (**sub-agent**)
- [ ] **Pre-PR gate** — dispatch `verification-before-completion --task verify` to check all SC verdicts are PASS. Context: `{issue_number: 2108}`. (**sub-agent**)
- [ ] **Audit** — dispatch audit task from `audit` skill with `{spec_local_dir: .opencode/.issues/2108, artifact_evidence_dir: .opencode/.issues/2108/artifacts}`. (**sub-agent**)
- [ ] **Cross-validate** — dispatch `audit --task cross-validate` for consensus check. Context: `{issue_number: 2108}`. (**sub-agent**)
- [ ] **Regression check** — dispatch `test-driven-development --task patterns` for regression test patterns. Context: `{issue_number: 2108}`. (**sub-agent**)
- [ ] **Review prep** — dispatch `git-workflow --task review-prep` to prepare PR review. Context: `{issue_number: 2108}`. (**sub-agent**)
- [ ] **Create PR** — dispatch `pr-creation-workflow --task create` to create the pull request. Context: `{issue_number: 2108, authorization_scope: for_pr, halt_at: pr_created}`. (**sub-agent**)
- [ ] **Exec summary** — dispatch `completion-core --task completion` for final summary. Context: `{issue_number: 2108}`. (**sub-agent**)

## Lifecycle Events

| Event | Timestamp | Issuer | Description |
|-------|-----------|--------|-------------|
| plan_created | 2026-07-24 | OpenCode (deepseek-v4-flash) | Plan created for issue 2108 — 3 phases, 4 SCs, sub-agent dispatch mode |
| plan_revised | 2026-07-24 | OpenCode (deepseek-v4-flash) | Removed Phase 1 (WeekliesXmlExport SC-1/SC-2 — removed from spec); renumbered Phase 2→Phase 1 (SC-3→SC-1), Phase 3→Phase 2 (SC-4→SC-2); updated dispatch, title, and SC count gate to 2 SCs |
