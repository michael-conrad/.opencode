# [SPEC-FIX] Invert Hard-Fail Gate from FAIL-is-Blocker to DONE-is-Only-Pass

**STATUS:** DRAFT
**CREATED:** 2026-06-23
**TYPE:** SPEC-FIX
**REPO:** michael-conrad/.opencode

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Content |
|-------|---------|
| **Problem Statement** | The hard-fail gate in `000-critical-rules.md` §critical-rules-hard-fail is inverted — it treats anything not FAIL as PASS. The gate logic is `gate_result == 'FAIL' → HALT` — everything else (BLOCKED, DONE_WITH_CONCERNS, OVERFLOW, any unknown status) passes through. This creates a bypass path where orchestrators can reclassify BLOCKED as "false negative" and proceed without remediation. |
| **Root Cause / Motivation** | The gate was designed as a FAIL-is-blocker model: only explicit FAIL triggers remediation. This leaves three gaps: (1) BLOCKED can be rationalized as "false negative" and bypassed, (2) DONE_WITH_CONCERNS has no routing rule and silently degrades to completion, (3) future unknown status enums would pass through by default. The gate should be a DONE-is-only-pass model: only clean DONE proceeds; everything else is coerced to FAIL. |
| **Approach Chosen** | Invert the gate from "FAIL is the only blocker" to "only clean DONE passes": `gate_result == 'DONE' AND concerns == empty → PROCEED`. Everything else — FAIL, BLOCKED, DONE_WITH_CONCERNS, OVERFLOW, unknown — is coerced to FAIL and routed to remediation. This single inversion closes four gaps simultaneously. |
| **Alternatives Considered & Why Discarded** | (1) Add individual routing rules for BLOCKED and DONE_WITH_CONCERNS — rejected because it patches symptoms instead of fixing the gate architecture; each new status enum would require a new rule. (2) Remove DONE_WITH_CONCERNS from the status enum — rejected because it serves a legitimate purpose in `writing-plans/tasks/revisit.md` (partial resolution signaling). (3) Keep FAIL-is-blocker and add a separate BLOCKED gate — rejected because it creates two parallel gates with different semantics, increasing complexity. |
| **Key Design Decisions** | DEC-1: Gate inversion is bright-line — `gate_result != 'DONE' OR concerns != empty → FAIL`. No gray zone. DEC-2: DONE_WITH_CONCERNS is preserved in the status enum but coerced to FAIL at the gate — the status value remains valid for sub-agents to return, but the orchestrator treats it as a failure. DEC-3: The inversion applies to four files: the primary enforcement file (`000-critical-rules.md`), the orchestrator routing table (`pipeline-executor.md`), and two secondary enforcement files (`065-verification-honesty.md`, `020-go-prohibitions.md`). |

## Objective

Invert the hard-fail gate from a FAIL-is-blocker model to a DONE-is-only-pass model, closing four bypass gaps: BLOCKED-as-false-negative, DONE_WITH_CONCERNS coercion gap (#1355), future unknown status enums, and DONE-with-caveats silent degradation.

## Problem

The hard-fail gate in `000-critical-rules.md` §critical-rules-hard-fail is inverted — it treats anything not FAIL as PASS. The gate logic is `gate_result == 'FAIL' → HALT` — everything else (BLOCKED, DONE_WITH_CONCERNS, OVERFLOW, any unknown status) passes through. This creates a bypass path where orchestrators can reclassify BLOCKED as "false negative" and proceed without remediation.

This was discovered during implementation of #1346: a pre-flight-handoff sub-agent returned BLOCKED, and the orchestrator rationalized "false negative" and tried to proceed instead of remediating. The rule text existed but the gate logic allowed the bypass.

## Context

The hard-fail gate is defined in `000-critical-rules.md` §critical-rules-hard-fail as a symbolic rule with conditions `gate_result == 'FAIL'` and actions `HALT + REMEDIATE + RE_VERIFY`. The gate fires at five pipeline stages: `verdict`, `sub_agent_result`, `cleanup_gate`, `sc_verification_gate`, `phase_completion_gate`.

The orchestrator's routing table is `pipeline-executor.md` Step 0 (pre-dispatch gate), which lists valid statuses and routes based on them. The Remediation-First Protocol in `065-verification-honesty.md` covers FAIL signals. The discard rule in `020-go-prohibitions.md` covers sub-agent failure.

The current gate architecture is:

```
gate_result == 'FAIL' → HALT + REMEDIATE
gate_result != 'FAIL' → PROCEED  (BLOCKED, DONE_WITH_CONCERNS, OVERFLOW, unknown all pass)
```

The target gate architecture is:

```
gate_result == 'DONE' AND concerns == empty → PROCEED
gate_result == 'DONE' AND concerns != empty → coerced to FAIL → REMEDIATE
gate_result != 'DONE' → HALT + REMEDIATE  (FAIL, BLOCKED, DONE_WITH_CONCERNS, OVERFLOW, unknown)
```

## Affected Files

| File | Change |
|------|--------|
| `.opencode/guidelines/000-critical-rules.md` | Invert `critical-rules-hard-fail` from FAIL-is-blocker to DONE-is-only-pass. Add DONE-with-concerns coercion rule. Update symbolic rule conditions. |
| `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md` | Change Remediation Routing trigger from FAIL to not-clean-DONE. Add DONE-with-concerns coercion step. |
| `.opencode/guidelines/065-verification-honesty.md` | Update Remediation-First Protocol to cover all non-clean-DONE results, not just FAIL. |
| `.opencode/guidelines/020-go-prohibitions.md` | Update "Discard on sub-agent failure" rule to cover DONE-with-concerns as a failure case. |

## Fix Approach

### Gate Inversion

The core change is inverting the gate condition from `gate_result == 'FAIL'` to `gate_result != 'DONE' OR concerns != empty`. This is a single condition change that closes four gaps:

1. **BLOCKED-as-false-negative bypass** (this session's defect): BLOCKED currently passes through the gate. After inversion, BLOCKED is coerced to FAIL and routed to remediation.
2. **DONE_WITH_CONCERNS coercion gap** (#1355): DONE_WITH_CONCERNS currently has no routing rule. After inversion, it is coerced to FAIL.
3. **Future unknown status enums**: Any new status enum added in the future would pass through the current gate. After inversion, unknown statuses are coerced to FAIL by default.
4. **DONE-with-caveats silent degradation**: DONE with non-empty concerns currently passes. After inversion, it is coerced to FAIL.

### DONE-with-Concerns Coercion Rule

A new rule is added: `DONE + non-empty concerns → coerced to FAIL`. This prevents sub-agents from returning DONE with caveats that silently degrade to completion. The coercion is bright-line — any non-empty concerns field on a DONE status triggers FAIL routing.

### File-Specific Changes

**`000-critical-rules.md`:**
- Update prose: change "FAIL signal at any pipeline stage" to "any non-clean-DONE result at any pipeline stage"
- Update symbolic rule conditions: `gate_result == 'FAIL'` → `gate_result != 'DONE' OR concerns != empty`
- Add DONE-with-concerns coercion rule prose
- Add symbolic rule for DONE-with-concerns coercion

**`pipeline-executor.md`:**
- Change Remediation Routing trigger from `status == FAIL` to `status != DONE OR (status == DONE AND concerns != empty)`
- Add coercion step: "If status == DONE and concerns is non-empty → coerce to FAIL before routing"

**`065-verification-honesty.md`:**
- Update Remediation-First Protocol: "When a FAIL signal is received" → "When any non-clean-DONE result is received (FAIL, BLOCKED, DONE_WITH_CONCERNS, OVERFLOW, unknown)"
- Add DONE-with-concerns coercion to the protocol steps

**`020-go-prohibitions.md`:**
- Update "Discard on sub-agent failure" rule: "BLOCKED or fails" → "BLOCKED, DONE_WITH_CONCERNS, or any non-clean-DONE result"
- Add DONE-with-concerns as a discard-triggering case

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `critical-rules-hard-fail` gate condition changed from `gate_result == 'FAIL'` to `gate_result != 'DONE' OR concerns != empty` | `string` | `grep 'gate_result != .DONE. OR concerns != empty' .opencode/guidelines/000-critical-rules.md` — must return at least one match | Re-edit the condition text in the symbolic rule block | implementation | `.opencode/.issues/1356/` | REQ-1 (gate inversion) | Phase 1 | pre-commit | exact | — | — | — | Phase 1 |
| SC-2 | DONE-with-concerns coercion rule added: `DONE + non-empty concerns → coerced to FAIL` | `string` | `grep 'coerced to FAIL' .opencode/guidelines/000-critical-rules.md` — must return at least one match | Re-edit the coercion rule prose | implementation | `.opencode/.issues/1356/` | REQ-2 (coercion rule) | Phase 1 | pre-commit | exact | — | — | — | Phase 1 |
| SC-3 | Symbolic rule `critical-rules-hard-fail` conditions updated to match new gate logic | `string` | `grep 'gate_result != .DONE.' .opencode/guidelines/000-critical-rules.md` — must return at least one match in the yaml+symbolic block | Re-edit the symbolic rule conditions | implementation | `.opencode/.issues/1356/` | REQ-1 (gate inversion) | Phase 1 | pre-commit | exact | — | — | — | Phase 1 |
| SC-4 | `pipeline-executor.md` Remediation Routing trigger changed from FAIL to not-clean-DONE | `string` | `grep 'status != DONE' .opencode/skills/implementation-pipeline/tasks/pipeline-executor.md` — must return at least one match | Re-edit the routing trigger text | implementation | `.opencode/.issues/1356/` | REQ-1 (gate inversion) | Phase 1 | pre-commit | exact | — | — | — | Phase 1 |
| SC-5 | `065-verification-honesty.md` Remediation-First Protocol covers all non-clean-DONE results | `string` | `grep 'non-clean-DONE' .opencode/guidelines/065-verification-honesty.md` — must return at least one match | Re-edit the protocol text | implementation | `.opencode/.issues/1356/` | REQ-1 (gate inversion) | Phase 1 | pre-commit | exact | — | — | — | Phase 1 |
| SC-6 | `020-go-prohibitions.md` discard rule covers DONE-with-concerns as failure case | `string` | `grep 'DONE_WITH_CONCERNS' .opencode/guidelines/020-go-prohibitions.md` — must return at least one match in the discard rule section | Re-edit the discard rule text | implementation | `.opencode/.issues/1356/` | REQ-2 (coercion rule) | Phase 1 | pre-commit | exact | — | — | — | Phase 1 |
| SC-7 | Agent does not bypass BLOCKED with "false negative" rationalization | `behavioral` | `opencode-cli run` with prompt that triggers BLOCKED from sub-agent, verify agent remediates instead of rationalizing. Use `assert_semantic` (clean-room AI inspector) to judge whether the agent took remediation action rather than rationalizing the BLOCKED away. | Increase timeout, retry with alternative model, diagnose root cause | verification | `.opencode/.issues/1356/behavioral/` | REQ-1 (gate inversion) | Phase 1 | pre-commit | exact | — | — | `.opencode/tests/behaviors/hard-fail-gate-inversion.sh` | Phase 1 |
| SC-8 | Agent does not accept DONE_WITH_CONCERNS as completion | `behavioral` | `opencode-cli run` with prompt that triggers DONE_WITH_CONCERNS from sub-agent, verify agent coerces to FAIL and remediates. Use `assert_semantic` (clean-room AI inspector) to judge whether the agent coerced DONE_WITH_CONCERNS to FAIL rather than accepting it as completion. | Increase timeout, retry with alternative model, diagnose root cause | verification | `.opencode/.issues/1356/behavioral/` | REQ-2 (coercion rule) | Phase 1 | pre-commit | exact | — | — | `.opencode/tests/behaviors/hard-fail-gate-inversion.sh` | Phase 1 |
| SC-9 | Before any implementation, write behavioral enforcement tests in `.opencode/tests/behaviors/` that verify the new gate logic; confirm RED state (test fails before change). If the tests are missing from the working tree when implementation begins, they must be re-created before any source changes. | `behavioral` | `bash .opencode/tests/behaviors/hard-fail-gate-inversion.sh` — must FAIL (RED) before implementation, PASS (GREEN) after implementation | Write the behavioral test file, run it to confirm RED, then implement changes and re-run to confirm GREEN | pre-implementation | `.opencode/tests/behaviors/` | REQ-3 (behavioral TDD) | Phase 1 | pre-commit | exact | — | — | `.opencode/tests/behaviors/hard-fail-gate-inversion.sh` | Phase 1 |

### Semantic Intent

- **SC-1 through SC-6**: These are string evidence SCs that verify the rule text exists in the correct files. They are secondary enforcement — they confirm the text was written but do not prove the agent follows it. The behavioral SCs (SC-7, SC-8) are the primary enforcement gate.
- **SC-7**: The semantic intent is to verify that the orchestrator takes remediation action when a sub-agent returns BLOCKED, rather than rationalizing it as a "false negative" and proceeding. The distinction is between "agent remediates" (correct) and "agent rationalizes and proceeds" (defect). Exit code 0 with remediation tool calls in stderr signals correct behavior; exit code 0 without remediation tool calls signals the bypass defect.
- **SC-8**: The semantic intent is to verify that the orchestrator coerces DONE_WITH_CONCERNS to FAIL rather than accepting it as completion. The distinction is between "agent coerces to FAIL and remediates" (correct) and "agent accepts DONE_WITH_CONCERNS as DONE" (defect). The coercion action must be visible in stderr as a remediation dispatch.
- **SC-9**: The semantic intent is to enforce the behavioral TDD cycle — the test must be RED before implementation begins. This prevents the #1217 pattern where content-verification alone was insufficient. The test file must exist and fail before any source file is modified.

## Edge Cases

| Case | Handling |
|------|----------|
| Sub-agent returns `status: DONE` with empty/null concerns | PROCEED — clean DONE |
| Sub-agent returns `status: DONE` with non-empty concerns | Coerce to FAIL → REMEDIATE |
| Sub-agent returns `status: BLOCKED` | Coerce to FAIL → REMEDIATE (closes false-negative bypass) |
| Sub-agent returns `status: DONE_WITH_CONCERNS` | Coerce to FAIL → REMEDIATE (closes #1355 gap) |
| Sub-agent returns `status: OVERFLOW` | Coerce to FAIL → REMEDIATE |
| Sub-agent returns unknown/unrecognized status | Coerce to FAIL → REMEDIATE (future-proof) |
| Sub-agent returns no status field | Coerce to FAIL → REMEDIATE |
| `writing-plans/tasks/revisit.md` uses DONE_WITH_CONCERNS | Preserved — revisit.md is a different pipeline stage with different semantics |

## Dependencies

- `000-critical-rules.md` is the primary enforcement file — all other changes derive from it
- `pipeline-executor.md` is the orchestrator's routing table — must match the gate logic
- `065-verification-honesty.md` and `020-go-prohibitions.md` are secondary enforcement files — must be consistent with the gate
- This spec subsumes #1355 (DONE_WITH_CONCERNS coercion gap) — the coercion rule in this spec closes that gap

## Out of Scope

- Changes to sub-agent result contract schemas (the status enum values remain the same — only the gate logic changes)
- Changes to `adversarial-audit` task files (auditors already use PASS/FAIL binary)
- #1355 as a separate implementation — this spec subsumes it
- Changes to `writing-plans/tasks/revisit.md` (DONE_WITH_CONCERNS is preserved there for partial resolution signaling)

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Gate inversion is bright-line: `gate_result != 'DONE' OR concerns != empty → FAIL` | No gray zone between DONE and FAIL prevents soft-passing and rationalization bypasses | MUST | SC-1, SC-3, SC-4, SC-5, SC-6 |
| DEC-2 | DONE_WITH_CONCERNS preserved in status enum but coerced to FAIL at gate | The status value remains valid for sub-agents to return; the orchestrator treats it as failure. This preserves backward compatibility with sub-agent contracts while closing the coercion gap. | MUST | SC-2, SC-8 |
| DEC-3 | Behavioral enforcement tests use `assert_semantic` (clean-room AI inspector) | The coercion decision is an agent action, not a text pattern. grep/string assertions on agent output prose are EVIDENCE_TYPE_MISMATCH for behavioral SCs. | MUST | SC-7, SC-8, SC-9 |

## Risk Traceability Table

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Orchestrator rationalizes BLOCKED as "false negative" despite new gate | Medium | High | Behavioral enforcement test (SC-7) verifies agent remediates instead of rationalizing | SC-7 |
| RISK-2 | DONE_WITH_CONCERNS silently degrades to completion despite coercion rule | Medium | High | Behavioral enforcement test (SC-8) verifies agent coerces to FAIL | SC-8 |
| RISK-3 | `writing-plans/tasks/revisit.md` DONE_WITH_CONCERNS usage is accidentally broken | Low | Medium | Explicit out-of-scope declaration; revisit.md is not modified | — |
| RISK-4 | Future status enum added without updating gate | Low | High | Gate inversion is future-proof — unknown statuses are coerced to FAIL by default | SC-1 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | MUST | Review and update assertions for revised gate logic |
| sc-summary.yaml | MUST | Regenerate to match revised SC table |
| verification-consistency-contract.yaml | MUST | Regenerate to match revised SC bindings |
| revision-re-entry-contract.yaml | MUST | Regenerate to match revised scope |

## Decomposition Classification

| Classification | Number of Phases | Sub-Issue Requirements | PR Strategy |
|----------------|------------------|------------------------|-------------|
| single-task | 1 | None | single PR |

## Explicit Non-Goals

- **Sub-agent result contract schema changes** — The status enum values (DONE, BLOCKED, DONE_WITH_CONCERNS, OVERFLOW) remain unchanged. Only the gate logic changes.
- **Adversarial audit task file changes** — Auditors already use PASS/FAIL binary verdicts and are not affected by the gate inversion.
- **`writing-plans/tasks/revisit.md` changes** — DONE_WITH_CONCERNS is preserved there for partial resolution signaling, which is a different semantic from pipeline completion.
- **Separate #1355 implementation** — This spec subsumes #1355; the coercion rule here closes that gap.

## Regression Invariants

1. Sub-agents MUST continue to return the same status enum values (DONE, BLOCKED, DONE_WITH_CONCERNS, OVERFLOW) — the enum is unchanged.
2. `writing-plans/tasks/revisit.md` MUST continue to use DONE_WITH_CONCERNS for partial resolution signaling — its semantics are preserved.
3. Adversarial audit PASS/FAIL binary verdicts MUST remain unchanged — auditors are not affected.
4. The remediation-first protocol (diagnose → remediate → re-verify → proceed on PASS → HALT on double-failure) MUST remain structurally intact — only the trigger condition changes.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Local docs | `.opencode/guidelines/000-critical-rules.md` §critical-rules-hard-fail | Verify current gate condition and actions |
| Local docs | `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md` | Verify current Remediation Routing trigger |
| Local docs | `.opencode/guidelines/065-verification-honesty.md` §Remediation-First Protocol | Verify current protocol coverage |
| Local docs | `.opencode/guidelines/020-go-prohibitions.md` §Discard on sub-agent failure | Verify current discard rule scope |
| Local docs | `.opencode/.issues/1355/spec.md` | Verify DONE_WITH_CONCERNS coercion gap scope |
| Direct source search | `grep 'critical-rules-hard-fail' .opencode/guidelines/000-critical-rules.md` | Confirm rule location and current text |
| Direct source search | `grep 'DONE_WITH_CONCERNS' .opencode/skills/implementation-pipeline/tasks/pipeline-executor.md` | Confirm current status enum listing |

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1356/plan.md` before implementation begins.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.
