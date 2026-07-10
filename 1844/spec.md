# [SPEC-FIX] Plan Phase Dispatch Modes — Inline/Sub-Agent/Clean-Room Distinction

**CREATED:** 2026-07-10
**TYPE:** SPEC-FIX
**REPO:** michael-conrad/.opencode

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

**Intent:** Fix plan phase dispatch so the orchestrator respects per-step execution-mode markers instead of dispatching entire phases to sub-agents indiscriminately.

**Problem Statement:** Plan phase dispatch ignores per-step execution-mode markers. The orchestrator dispatches entire phases to sub-agents, and sub-agents execute all steps including those marked `(**inline**)`. Additionally, `(**sub-agent**)` and `(**clean-room**)` are defined as synonyms with no distinction between "sub-agent with plan context" and "sub-agent clean room."

**Root Cause:** The dispatch mechanism is phase-level only. There is no phase-level declaration telling the orchestrator how to handle the phase, and no mechanism for the orchestrator to interleave inline and sub-agent steps within a phase. The per-step markers `(**inline**)`, `(**sub-agent**)`, and `(**clean-room**)` exist in plan files but are ignored at dispatch time because the orchestrator dispatches the entire phase file to a single sub-agent.

**Design Approach:** Add a `Dispatch` column to the plan phase table (split plans) or `**Dispatch:**` field (non-split plans) declaring one of three modes: `inline` (orchestrator interleaves inline and sub-agent steps), `sub-agent-with-context` (entire phase to one sub-agent with context), or `sub-agent-clean-room` (entire phase to one sub-agent with routing metadata only). Per-step markers `(**inline**)`, `(**sub-agent**)`, and `(**clean-room**)` become distinct and meaningful only in `inline` mode. Validation rules catch mode/marker inconsistency. Plan auditor detects dispatch marking defects.

**Alternatives Considered & Why Discarded:**
- **Option A (chosen):** Phase-level `Dispatch` column/field — natural granularity matching existing orchestrator dispatch pattern; per-step markers become meaningful in `inline` mode.
- **Option B (rejected):** Make orchestrator always read and respect per-step markers — does not solve the phase-level dispatch problem; the orchestrator would still need to know whether to interleave or delegate the entire phase.

**Scope:** Three dispatch modes at phase level with distinct per-step markers. Declaration via Dispatch column in split-plan phase tables or `**Dispatch:**` field in non-split plan headers. Validation rules catch mode/marker inconsistency. Plan auditor detects dispatch marking defects. **Out of scope:** Changes to sub-agent step execution, `task()` API, checkpoint/rollback, or any skill other than writing-plans and implementation-pipeline.

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. See `080-code-standards.md` Test Integrity Mandate.

## Problem

Plan phase dispatch ignores per-step execution-mode markers. The orchestrator dispatches entire phases to sub-agents, and sub-agents execute all steps including those marked `(**inline**)`. Additionally, `(**sub-agent**)` and `(**clean-room**)` are defined as synonyms with no distinction between "sub-agent with plan context" and "sub-agent clean room."

**Motivating example:** In [issue #1835](https://github.com/michael-conrad/.opencode/issues/1835), phase 10 was dispatched to a sub-agent that executed inline steps — the sub-agent had no way to know which steps were meant for the orchestrator and which were meant for itself.

## Root Cause

The dispatch mechanism is phase-level only. There is no phase-level declaration telling the orchestrator how to handle the phase, and no mechanism for the orchestrator to interleave inline and sub-agent steps within a phase. The per-step markers `(**inline**)`, `(**sub-agent**)`, and `(**clean-room**)` exist in plan files but are ignored at dispatch time because the orchestrator dispatches the entire phase file to a single sub-agent.

## Scope

**In scope:**
- Three dispatch modes at phase level: `inline`, `sub-agent-with-context`, `sub-agent-clean-room`
- Distinct per-step markers with clear context semantics
- Declaration location in plan files (Dispatch column for split plans, `**Dispatch:**` field for non-split)
- Validation rules for dispatch mode / step marker consistency
- Plan auditor dispatch marking defect detection

**Out of scope:**
- Changes to how sub-agents execute individual steps (sub-agent behavior is unchanged)
- Changes to the `task()` API or sub-agent dispatch mechanism
- Changes to checkpoint/rollback behavior
- Changes to any skill other than writing-plans and implementation-pipeline

## Design

### Dispatch Modes (Phase Level)

Three dispatch modes declared at the phase level:

| Mode | Orchestrator Does | Sub-Agent Receives |
|------|-------------------|-------------------|
| `inline` | Reads phase file, executes `(**inline**)` steps directly, dispatches `(**sub-agent**)` / `(**clean-room**)` steps via `task()` | Per-step: `(**sub-agent**)` gets phase file + orchestrator-provided context; `(**clean-room**)` gets phase file only |
| `sub-agent-with-context` | Dispatches entire phase to one sub-agent, may include additional context as needed | Phase file + orchestrator-provided context + routing metadata |
| `sub-agent-clean-room` | Dispatches entire phase to one sub-agent | Phase file + routing metadata only |

### Per-Step Markers (Only Meaningful in `inline` Dispatch Mode)

| Step Marker | Meaning | Context |
|-------------|---------|---------|
| `(**inline**)` | Orchestrator executes directly | — |
| `(**sub-agent**)` | Dispatch via `task()` | Phase file + orchestrator-provided context |
| `(**clean-room**)` | Dispatch via `task()` | Phase file only |

In `sub-agent-with-context` and `sub-agent-clean-room` modes, per-step markers are informational only — the entire phase is dispatched to one sub-agent regardless of markers.

### Declaration Location

- **Split plans:** New `Dispatch` column in the main plan's phase table (in `plan.md`)
- **Non-split plans:** `**Dispatch:**` field in each phase section header

### Validation Rules

1. `inline` phases MUST NOT contain only sub-agent steps (wasteful — the orchestrator would read the file and dispatch every step, which is equivalent to `sub-agent-with-context` but with extra overhead)
2. `sub-agent-clean-room` phases MUST NOT contain `(**inline**)` steps (inline steps cannot execute inside a sub-agent)
3. Plan auditor MUST catch dispatch marking defects (mode/marker inconsistency, missing dispatch declaration)

## Affected Files

| File | Change Type | Description |
|------|-------------|-------------|
| `writing-plans/tasks/write.md` | MODIFY | Add Dispatch column/field to templates, update dispatch indicator definitions |
| `writing-plans/tasks/validate.md` | MODIFY | Add dispatch mode validation rules |
| `implementation-pipeline/SKILL.md` | MODIFY | Orchestrator reads Dispatch column/field and routes accordingly |

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [#1835](https://github.com/michael-conrad/.opencode/issues/1835) | RELATED | Motivating example — phase 10 dispatched to sub-agent that executed inline steps |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Three dispatch modes at phase level | Phase-level declaration is the natural granularity — the orchestrator already dispatches per-phase | MUST | SC-1, SC-2, SC-3 |
| DEC-2 | Per-step markers only meaningful in `inline` mode | In sub-agent modes, the entire phase goes to one sub-agent — per-step markers are irrelevant | MUST | SC-4, SC-5 |
| DEC-3 | Dispatch column in phase table for split plans | Consistent with existing phase table structure; avoids per-file header parsing | MUST | SC-1 |
| DEC-4 | `**Dispatch:**` field for non-split plans | Non-split plans have no phase table; header field is the natural location | MUST | SC-1 |

## Risk Traceability Table

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Orchestrator ignores Dispatch column and dispatches as before | Medium | High | Plan auditor catches missing dispatch; implementation-pipeline SKILL.md prose enforces reading Dispatch column | SC-6, SC-7 |
| RISK-2 | `inline` phase with only sub-agent steps wastes orchestrator context | Low | Medium | Validation rule in plan auditor catches this | SC-6 |
| RISK-3 | `sub-agent-clean-room` phase with `(**inline**)` steps causes sub-agent to execute orchestrator-only steps | Medium | High | Validation rule in plan auditor catches this | SC-6 |

## Success Criteria

**Cost frame:** Evidence type determines defect-discovery-latency (DDL). Behavioral evidence catches defects at the earliest gate (pre-commit / pre-RED) — the cheapest fix point. String evidence defers discovery to CI (100×–1000× cost multiplier). Structural evidence defers discovery to production (1000×+ cost multiplier, death spiral). Every SC's evidence type is chosen to minimize DDL: behavioral for runtime-behavioral changes, string for content-pattern changes. See `065-verification-honesty.md` §Cost Model for the complete death spiral / break dynamics.

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `writing-plans/tasks/write.md` includes Dispatch column in phase table template for split plans and `**Dispatch:**` field for non-split plans | `string` | `grep` for "Dispatch" in write.md phase table template and non-split section header template | Add Dispatch column/field to write.md templates | write | `.opencode/skills/writing-plans/tasks/write.md` | DEC-1, DEC-3, DEC-4 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-2 | `writing-plans/tasks/write.md` updates dispatch indicator definitions to distinguish `(**inline**)`, `(**sub-agent**)`, and `(**clean-room**)` with distinct context descriptions | `string` | `grep` for each marker in write.md, verify each has distinct context description | Update dispatch indicator definitions in write.md | write | `.opencode/skills/writing-plans/tasks/write.md` | DEC-2 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-3 | `writing-plans/tasks/validate.md` includes validation rules: (a) `inline` phases must not contain only sub-agent steps, (b) `sub-agent-clean-room` phases must not contain `(**inline**)` steps, (c) plan auditor catches dispatch marking defects | `string` | `grep` for each validation rule in validate.md | Add validation rules to validate.md | validate | `.opencode/skills/writing-plans/tasks/validate.md` | DEC-1 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-4 | `implementation-pipeline/SKILL.md` Trigger Dispatch Table includes entries for `inline`, `sub-agent-with-context`, and `sub-agent-clean-room` dispatch modes | `string` | `grep` for "inline", "sub-agent-with-context", "sub-agent-clean-room" in implementation-pipeline/SKILL.md Trigger Dispatch Table | Add dispatch mode entries to Trigger Dispatch Table | implementation-pipeline | `.opencode/skills/implementation-pipeline/SKILL.md` | DEC-1, DEC-2 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-5 | `implementation-pipeline/SKILL.md` Overview/Persona prose describes how the orchestrator reads the Dispatch column/field and routes accordingly | `string` | `grep` for "Dispatch" in implementation-pipeline/SKILL.md Overview/Persona sections | Add Dispatch routing prose to SKILL.md | implementation-pipeline | `.opencode/skills/implementation-pipeline/SKILL.md` | DEC-1, DEC-2 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-6 | Plan auditor (`audit/tasks/plan-fidelity.md` or equivalent) catches dispatch marking defects: missing Dispatch declaration, `inline` phase with only sub-agent steps, `sub-agent-clean-room` phase with `(**inline**)` steps | `behavioral` | `opencode-cli run` with a plan containing dispatch defects, verify auditor returns FAIL | Fix auditor to detect dispatch defects; re-run behavioral test | audit | `.opencode/skills/audit/tasks/plan-fidelity.md` | RISK-1, RISK-2, RISK-3 | Phase 1 | pre-approval-gate | standalone | — | — | — | Phase 1 |
| SC-7 | Orchestrator correctly routes `inline` phases (executes inline steps directly, dispatches sub-agent/clean-room steps via `task()`) | `behavioral` | `opencode-cli run` with an `inline` phase plan, verify stderr shows orchestrator executing inline steps and dispatching sub-agent steps | Fix orchestrator routing logic; re-run behavioral test | implementation-pipeline | `.opencode/skills/implementation-pipeline/SKILL.md` | RISK-1 | Phase 1 | pre-approval-gate | standalone | — | — | — | Phase 1 |
| SC-8 | No existing dispatch behavior is broken by the changes (regression: existing plans without Dispatch column still work) | `behavioral` | `opencode-cli run` with an existing plan that has no Dispatch column, verify orchestrator dispatches as before (default to `sub-agent-with-context`) | Fix backward compatibility; re-run behavioral test | implementation-pipeline | `.opencode/skills/implementation-pipeline/SKILL.md` | — | Phase 1 | pre-approval-gate | standalone | — | — | — | Phase 1 |
| SC-9 | Before any implementation, write behavioral enforcement tests in `.opencode/tests/behaviors/` that verify the new dispatch routing; confirm RED state (test fails before change). If the tests are missing from the working tree when implementation begins, they must be re-created before any source changes. | `behavioral` | `opencode-cli run` with behavioral test prompts, verify RED state before implementation, GREEN state after | Write behavioral tests before implementation; re-run to confirm RED then GREEN | red-phase | `.opencode/tests/behaviors/` | — | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-10 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | `behavioral` | Cross-reference SC table evidence types against implementation evidence; verify no downgrades | Restore original evidence type; re-verify | verification-before-completion | `.opencode/.issues/1844/` | — | Phase 1 | pre-approval-gate | standalone | — | — | — | Phase 1 |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `implementation-pipeline/SKILL.md` Trigger Dispatch Table | Understand current dispatch mechanism |
| Direct source search | `writing-plans/tasks/write.md` plan format requirements | Understand current plan template structure |
| Direct source search | `writing-plans/tasks/validate.md` validation checks | Understand current validation rules |
| GitHub Issue | [#1835](https://github.com/michael-conrad/.opencode/issues/1835) | Motivating example — phase 10 dispatch defect |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1844/plan.md` before implementation begins.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
