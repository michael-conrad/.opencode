<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| **Problem Statement** | The gap-fill cascade is a flat action list ("auto-create spec+plan+auto-approve+auto-PR") that agents interpret as a skip-list rather than a state-verification checklist, bypassing all quality gates |
| **Root Cause / Motivation** | The cascade reads like "you may do X, Y, Z" — not "check if X is done; if not, do X; then check Y." Agent training reward is progression, and the flat list provides a progression path that skips quality gates |
| **Approach Chosen** | Replace the cascade with a routing dispatcher that loads per-scope state-verification checklist files. Each item verifies a state and, if missing, reports which action to dispatch next. The orchestrator loops: dispatch cascade → if blocked, dispatch reported action → re-dispatch cascade → repeat |
| **Alternatives Considered & Why Discarded** | Keeping the flat list with stronger wording — wording changes do not change agent behavior, as demonstrated by repeated regression. Removing gap-fill entirely — would break the auto-progression that for_pr scope depends on |
| **Key Design Decisions** | Per-scope checklist files over monolithic; YAML-only for LLM-to-LLM data transfers; remove for_pr_only and for_review_only scopes |

## Objective

Replace the gap-fill cascade with a state-verification checklist model. The cascade becomes a routing-only dispatcher that loads per-scope checklist files. Each checklist item verifies a state and, if missing, reports which action to take next. The orchestrator loops: dispatch cascade -> if blocked, dispatch the reported next action -> re-dispatch cascade -> repeat until all states are verified.

## Problem

The gap-fill cascade is structured as an authorization list ("auto-create spec+plan+auto-approve+auto-PR") rather than a state-verification checklist. When an agent reads this, it interprets the gap-fill as "I have permission to skip to the end" rather than "I must verify each state sequentially and stop at the first gap."

This was demonstrated in session `ses_0ffeba217ffeyz4dmcrgle5cLK` (and previously in #1346): the agent received `for_pr` scope, read the gap-fill as a skip-list, bypassed plan creation, bypassed the implementation pipeline, and started reading files to modify directly. The agent never created a plan, never loaded `writing-plans` or `implementation-pipeline`, and never dispatched sub-agents for implementation work.

**Root cause:** The gap-fill is a flat action list that reads like "you may do X, Y, Z" — not "check if X is done; if not, do X; then check Y." The agent's training reward is progression, and the gap-fill provides a progression path that skips all quality gates.

## Scope

### In Scope

- Rewrite `gap-fill-cascade.md` as routing dispatcher
- Create per-scope checklist files: `for-pr.md`, `for-implementation.md`, `for-plan.md`
- Remove `for_pr_only` and `for_review_only` from all scope-parsing, auto-dispatch, and template files
- Remove gap-fill column from `010-approval-gate.md` scope table
- Add YAML-only rule for LLM-to-LLM data transfers to `080-code-standards.md`
- Remove `pr_strategy` from all `authorization_scope` template blocks

### Out of Scope

- Changes to the verify-authorization task itself (only the gap-fill cascade is restructured)
- Changes to the orchestrator loop logic (the orchestrator already supports dispatch-loop patterns)
- Behavioral changes to `for_spec`, `for_analysis`, or `for_review_prep` scopes (they have no gap-fill)

## Files Affected

### New Files

| File | Purpose |
|------|---------|
| `skills/approval-gate/tasks/gap-fill-cascade/for-pr.md` | State-verification checklist for `for_pr` scope |
| `skills/approval-gate/tasks/gap-fill-cascade/for-implementation.md` | State-verification checklist for `for_implementation` scope |
| `skills/approval-gate/tasks/gap-fill-cascade/for-plan.md` | State-verification checklist for `for_plan` scope |

### Modified Files

| File | Change |
|------|--------|
| `skills/approval-gate/tasks/gap-fill-cascade.md` | Rewrite as routing dispatcher: reads scope from context, loads per-scope checklist, reports state |
| `guidelines/010-approval-gate.md` | Remove gap-fill column from scope table |
| `skills/approval-gate/enforcement/scope-parsing.md` | Remove `for_pr_only` and `for_review_only` scope definitions |
| `skills/approval-gate/enforcement/auto-dispatch-table.md` | Remove `for_pr_only` and `for_review_only` entries |
| `skills/approval-gate/tasks/verify-authorization/scope-auto-resolve.md` | Remove `for_pr_only` and `for_review_only` from parsing table |
| `skills/approval-gate/tasks/verify-authorization/gap-fill-cascade.md` | Remove (replaced by `gap-fill-cascade/` directory) |
| `guidelines/000-critical-rules.md` | Remove obsolete scope references |
| `guidelines/080-code-standards.md` | Add YAML-only rule for LLM-to-LLM data transfers |
| All skill task files with `authorization_scope` template blocks (~29 files) | Remove `pr_strategy` from template; remove `for_pr_only` and `for_review_only` from enum |

## Design

### Orchestrator Loop

After `verify-authorization` returns the scope and halt boundary, the orchestrator enters a dispatch loop:

1. Dispatch `gap-fill-cascade` sub-agent with the authorization scope and issue number
2. The sub-agent reports either that all states are verified, or that a state is missing and what action to take next
3. If all states verified: proceed to the halt boundary
4. If a state is missing with a next action specified: dispatch that action, then loop back to step 1
5. If a state is missing with no next action available: HALT with blocker report

The orchestrator holds only routing metadata — it never decides what to do. The cascade file determines the next action.

### Gap-Fill Cascade Dispatcher (`gap-fill-cascade.md`)

Single task file that reads `authorization_scope` from context and loads the corresponding per-scope checklist file. Scopes with gap-fill (`for_pr`, `for_implementation`, `for_plan`) each have a dedicated checklist. Scopes without gap-fill (`for_spec`, `for_analysis`, `for_review_prep`) report all states verified immediately.

The sub-agent loads the checklist file, walks items sequentially, and reports the first missing state or that all states are verified.

### Per-Scope Checklist Format

Each checklist item follows this structure:

- A state description (what is being verified)
- A verification method (how to check the state)
- A PASS outcome (proceed to next item)
- A FAIL outcome (report which action should be dispatched next and why)

Items are sequential — the sub-agent processes them in order and reports the first missing state.

### `for-pr.md` Checklist

- [ ] Spec exists and is approved
      Verify: issue has spec label
      If PASS: proceed
      If FAIL: report `spec-creation` should be dispatched

- [ ] Plan exists and is faithful to spec
      Verify: `*/.issues/{N}/plan.md` exists
      If PASS: proceed
      If FAIL: report `writing-plans` should be dispatched

- [ ] Plan is approved
      Verify: issue has `approved-for-plan` label (or scope >= `for_plan` auto-approves)
      If PASS: proceed
      If FAIL: report the `approved-for-plan` label should be applied

- [ ] Implementation complete (all SCs verified PASS)
      Verify: verification artifacts exist for all SCs in spec
      If PASS: proceed
      If FAIL: report `implementation-pipeline` should be dispatched

- [ ] PR exists
      Verify: open PR for this branch exists
      If PASS: report all states verified
      If FAIL: report `git-workflow` should be dispatched for PR creation

### `for-implementation.md` Checklist

Same as `for-pr.md` but without the PR item — halts after implementation complete.

### `for-plan.md` Checklist

- [ ] Spec exists and is approved
      Verify: issue has spec label
      If PASS: proceed
      If FAIL: report `spec-creation` should be dispatched

- [ ] Plan exists and is faithful to spec
      Verify: `*/.issues/{N}/plan.md` exists
      If PASS: report all states verified
      If FAIL: report `writing-plans` should be dispatched

### Scope Removal

`for_pr_only` and `for_review_only` are removed. Their only purpose was "skip gap-fill" — but the state-verification checklist already skips itself when artifacts exist. `for_pr` with existing spec+plan+branch behaves identically to `for_pr_only`. The removed scopes were silent-failure traps when preconditions were not met.

### `010-approval-gate.md` Simplification

The scope table is reduced to declarative properties only — no gap-fill column. The gap-fill routing is implicit: authorization always triggers dispatch `gap-fill-cascade`, which reads the scope and walks its checklist. The guideline states principles; enforcement files define mechanics.

### YAML Standard for LLM-to-LLM Data Transfers

All structured data exchanged between AI agents (result contracts, work state files, task context, evidence artifacts) MUST use YAML format. JSON is prohibited for LLM-to-LLM communication. Exceptions: external API calls (GitHub API, GitBucket API), configuration files that require JSON (`opencode.jsonc`), data interchange with non-LLM systems.

## Non-Goals

- **Changes to verify-authorization task logic** — Only the gap-fill cascade is restructured; the authorization verification flow is unchanged
- **Changes to orchestrator loop infrastructure** — The orchestrator already supports dispatch-loop patterns; no new infrastructure needed
- **Behavioral changes to for_spec, for_analysis, for_review_prep** — These scopes have no gap-fill and are unaffected

## Regression Invariants

1. `for_pr` scope with all artifacts existing MUST proceed directly to PR creation (same behavior as current `for_pr_only`)
2. `for_pr` scope with missing spec MUST dispatch `spec-creation` before any other action
3. `for_implementation` scope MUST halt after implementation complete, never create a PR
4. All existing authorization scope values in skill task files MUST continue to parse correctly

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Per-scope checklist files over monolithic | Each scope has different verification items; monolithic file would be harder to maintain | MUST | SC-1, SC-2, SC-3, SC-4 |
| DEC-2 | Remove for_pr_only and for_review_only | State-verification checklist already skips itself when artifacts exist; removed scopes were silent-failure traps | MUST | SC-6 |
| DEC-3 | YAML-only for LLM-to-LLM data | YAML is more readable for AI agents; JSON is error-prone in multi-line contexts | MUST | SC-11 |
| DEC-4 | Remove pr_strategy from template blocks | pr_strategy is derived from authorization scope, not a template variable | MUST | SC-10 |

## Risk Traceability

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Per-scope checklist files drift from skill task structure | Low | Medium | Each checklist item routes to a skill's public entry point — never duplicates procedural logic | SC-2, SC-3, SC-4 |
| RISK-2 | Removing for_pr_only breaks existing workflows | Low | Medium | for_pr with existing artifacts behaves identically. No behavioral change for any real use case | SC-6 |
| RISK-3 | 010-approval-gate.md loses too much information | Low | Low | Guideline states principles; enforcement files define mechanics. Correct separation of concerns | SC-7 |
| RISK-4 | Bulk update of ~29 task files misses some files | Medium | High | Use grep to enumerate all files with authorization_scope template blocks before applying changes. Verify with grep after | SC-10 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Per-scope checklist files | MUST | Update checklist items to match revised scope definitions |
| Risk traceability | MAY | Update if new risks introduced |

## Decomposition Classification

| Classification | Number of Phases | Sub-Issue Requirements | PR Strategy |
| -------------- | ---------------- | ---------------------- | ----------- |
| multi-phase | 3 | One sub-issue per phase | stacked PRs per phase |

## Dependencies

- Supersedes gap-fill concerns in [.opencode#1007](https://github.com/michael-conrad/.opencode/issues/1007)
- [.opencode#1007](https://github.com/michael-conrad/.opencode/issues/1007) SHOULD be revised to depend on this spec

## Changelog

- 2026-06-25: Initial draft

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/4/plan.md` before implementation begins.

## Success Criteria

| ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `gap-fill-cascade.md` rewritten as routing dispatcher that loads per-scope checklist based on `authorization_scope` | `grep -r "loads.*checklist" skills/approval-gate/tasks/gap-fill-cascade.md` — MUST match | If FAIL: rewrite dispatcher to load per-scope checklist | pre-commit | `.opencode/.issues/4/` | DEC-1 | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-2 | `gap-fill-cascade/for-pr.md` exists with state-verification checklist (spec → plan → approval → implementation → PR) | `ls skills/approval-gate/tasks/gap-fill-cascade/for-pr.md` — MUST exist and be non-empty | If FAIL: create file with 5-item checklist | pre-commit | `.opencode/.issues/4/` | DEC-1 | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-3 | `gap-fill-cascade/for-implementation.md` exists with state-verification checklist (spec → plan → approval → implementation) | `ls skills/approval-gate/tasks/gap-fill-cascade/for-implementation.md` — MUST exist and be non-empty | If FAIL: create file with 4-item checklist | pre-commit | `.opencode/.issues/4/` | DEC-1 | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-4 | `gap-fill-cascade/for-plan.md` exists with state-verification checklist (spec → plan) | `ls skills/approval-gate/tasks/gap-fill-cascade/for-plan.md` — MUST exist and be non-empty | If FAIL: create file with 2-item checklist | pre-commit | `.opencode/.issues/4/` | DEC-1 | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-5 | Each checklist item follows verify/create pair format: verify state, if PASS proceed, if FAIL report which action to dispatch next | `grep -c "If PASS:" skills/approval-gate/tasks/gap-fill-cascade/for-pr.md` — MUST be >= 5 | If FAIL: rewrite checklist items to use verify/create pair format | pre-commit | `.opencode/.issues/4/` | DEC-1 | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-6 | `for_pr_only` and `for_review_only` removed from all scope-parsing, auto-dispatch, and template files | `grep -r "for_pr_only\|for_review_only" skills/approval-gate/ guidelines/` — MUST return no matches | If FAIL: remove remaining references from matched files | pre-commit | `.opencode/.issues/4/` | DEC-2 | Phase 2 | pre-commit | sequential | — | — | — | Phase 2 |
| SC-7 | `010-approval-gate.md` scope table has no gap-fill column | `grep "gap-fill\|Gap-Fill\|Gap Fill" guidelines/010-approval-gate.md` — MUST return no matches | If FAIL: remove gap-fill column from scope table | pre-commit | `.opencode/.issues/4/` | DEC-4 | Phase 2 | pre-commit | sequential | — | — | — | Phase 2 |
| SC-8 | **BEHAVIORAL:** agent with `for_pr` scope and existing spec+plan dispatches `gap-fill-cascade`, routes through `implementation-pipeline` — does not skip to PR creation | `opencode-cli run` with `for_pr` scope prompt → verify stderr contains `Skill "gap-fill-cascade"` and `Skill "implementation-pipeline"` | If FAIL: fix dispatcher routing logic; re-run behavioral test | post-implementation | `.opencode/.issues/4/behavioral/` | DEC-1 | Phase 3 | post-implementation | sequential | — | — | `behaviors/gap-fill-cascade-for-pr.sh` | Phase 3 |
| SC-9 | **BEHAVIORAL:** agent with `for_pr` scope and missing plan dispatches `writing-plans` via `next_action` routing | `opencode-cli run` with `for_pr` scope + missing plan → verify stderr contains `Skill "writing-plans"` | If FAIL: fix checklist FAIL routing; re-run behavioral test | post-implementation | `.opencode/.issues/4/behavioral/` | DEC-1 | Phase 3 | post-implementation | sequential | — | — | `behaviors/gap-fill-cascade-missing-plan.sh` | Phase 3 |
| SC-10 | `pr_strategy` removed from all `authorization_scope` template blocks across skill task files | `grep -r "pr_strategy" skills/` — MUST return no matches (except in scope-parsing.md where it is derived) | If FAIL: remove `pr_strategy` from remaining template blocks | pre-commit | `.opencode/.issues/4/` | DEC-4 | Phase 2 | pre-commit | sequential | — | — | — | Phase 2 |
| SC-11 | `080-code-standards.md` has a section mandating YAML for LLM-to-LLM data transfers, with JSON prohibited | `grep "YAML.*LLM\|LLM.*YAML" guidelines/080-code-standards.md` — MUST match | If FAIL: add YAML-only section to 080-code-standards.md | pre-commit | `.opencode/.issues/4/` | DEC-3 | Phase 2 | pre-commit | sequential | — | — | — | Phase 2 |

### Evidence Type Classification

| SC | Affects Runtime Behavior? | Declared Evidence Type | Required Minimum |
|----|--------------------------|----------------------|------------------|
| SC-1 | No (file structure) | string | string |
| SC-2 | No (file existence) | string | string |
| SC-3 | No (file existence) | string | string |
| SC-4 | No (file existence) | string | string |
| SC-5 | No (file content) | string | string |
| SC-6 | No (text removal) | string | string |
| SC-7 | No (text removal) | string | string |
| SC-8 | **YES** (agent dispatch behavior) | behavioral | behavioral |
| SC-9 | **YES** (agent dispatch behavior) | behavioral | behavioral |
| SC-10 | No (text removal) | string | string |
| SC-11 | No (text addition) | string | string |

### Determinism Gate

Each SC above has an executable verification command producing deterministic PASS/FAIL. SC-8 and SC-9 use `opencode-cli run` with stderr assertions. All others use `grep` or `ls` with specific expected values. No SC uses adverbs without thresholds, comparatives without baselines, or open-ended quality requirements.

### Cross-Cutting SCs

None — all SCs are phase-specific.

### Semantic Intent

- **SC-8**: The behavioral test verifies that the agent routes through the implementation pipeline rather than skipping to PR creation. This is the core behavioral change — the agent MUST NOT interpret `for_pr` as "skip to PR."
- **SC-9**: The behavioral test verifies that a missing plan triggers `writing-plans` dispatch via the checklist's FAIL routing, not via the agent's own reasoning about what to do next.

### Cost-Frame Reformation

- **SC-8, SC-9 (behavioral)**: A behavioral test costs minutes to execute — a bounded delay that catches agent routing defects at the earliest gate. Skipping behavioral verification costs the full pipeline rework when the agent skips to PR creation without implementation: diagnosis, fix, re-review, re-CI — each costing more roundtrips than the behavioral test would have consumed. Behavioral PASS is a break (zero downstream cost); structural-only PASS is a death spiral (compounding exponential cost).
- **SC-1 through SC-7, SC-10, SC-11 (string/structural)**: A grep or ls check costs ~1 second. The cost of a missed file reference is a CI failure caught within minutes — bounded, not compounding. String evidence is sufficient for structural changes because the defect-discovery-latency is measured in minutes, not weeks.

## Phases

### Phase 1: Checklist Files and Dispatcher

- Create `gap-fill-cascade/for-pr.md`, `for-implementation.md`, `for-plan.md`
- Rewrite `gap-fill-cascade.md` as routing dispatcher
- SCs: SC-1, SC-2, SC-3, SC-4, SC-5

### Phase 2: Scope Removal and Guideline Updates

- Remove `for_pr_only` and `for_review_only` from all scope-parsing, auto-dispatch, and template files
- Remove gap-fill column from `010-approval-gate.md`
- Add YAML-only rule to `080-code-standards.md`
- Remove `pr_strategy` from template blocks
- SCs: SC-6, SC-7, SC-10, SC-11

### Phase 3: Behavioral Tests

- Write behavioral enforcement tests for SC-8 and SC-9
- SCs: SC-8, SC-9

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep -r "gap-fill" skills/approval-gate/` | Identify all gap-fill references |
| Direct source search | `grep -r "for_pr_only\|for_review_only" skills/ guidelines/` | Identify all scope references to remove |
| Direct source search | `grep -r "pr_strategy" skills/` | Identify all template blocks with pr_strategy |
| Local docs | `guidelines/010-approval-gate.md` | Understand current scope table structure |
| Local docs | `guidelines/080-code-standards.md` | Identify insertion point for YAML-only rule |
| Session evidence | Session `ses_0ffeba217ffeyz4dmcrgle5cLK` | Root cause analysis of gap-fill regression |

Co-authored with AI: OpenCode (deepseek-v4-flash)
