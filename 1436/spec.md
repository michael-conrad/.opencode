# [SPEC-FIX] Plan-fidelity auditor hard-codes evaluation criteria instead of reading from authoritative skill cards

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| Problem Statement | The plan-fidelity auditor embeds expected values directly in its evaluation criteria instead of reading them dynamically from authoritative skill cards, causing false FAIL verdicts when authoritative sources change |
| Root Cause / Motivation | The evaluation criteria table embeds expected values directly instead of referencing authoritative skill cards |
| Approach Chosen | Replace hard-coded expected values with dynamic references to authoritative skill cards; add a general principle requiring dynamic references |
| Alternatives Considered & Why Discarded | Rewriting the entire auditor — too invasive for a vocabulary mismatch; adding a validation layer — over-engineering for a single-file fix |
| Key Design Decisions | Follow the PF-SEQUENCE-MATCHES pattern which already does it correctly |

## Documentation References

All authoritative sources verified live on 2026-07-10. See [research card](https://github.com/michael-conrad/.opencode/tree/issues-data/research-cards/plan-fidelity-auditor-authoritative-sources.md) for full details.

| Source | Live URL | Relevance |
|--------|----------|-----------|
| `writing-plans/tasks/write.md` §Dispatch Indicators | https://github.com/michael-conrad/.opencode/blob/main/skills/writing-plans/tasks/write.md | Defines the three valid dispatch indicators (`(**inline**)`, `(**sub-agent**)`, `(**clean-room**)`). PF-DISPATCH-MODE must reference this dynamically. |
| `solve/tasks/contract.md` — Contract YAML Schema | https://github.com/michael-conrad/.opencode/blob/main/skills/solve/tasks/contract.md | Defines the Z3 contract schema with typed variables and Z3 expressions. No `P1_I1_G1` naming convention exists. PF-Z3-CONTRACT must reference this schema. |
| `audit/tasks/plan-fidelity.md` — Evaluation Criteria | https://github.com/michael-conrad/.opencode/blob/main/skills/audit/tasks/plan-fidelity.md | Target file for this spec-fix. Contains hard-coded criteria that must be updated. |
| `implementation-pipeline/SKILL.md` — Trigger Dispatch Table | https://github.com/michael-conrad/.opencode/blob/main/skills/implementation-pipeline/SKILL.md | Canonical gate sequence. PF-SEQUENCE-MATCHES already reads this dynamically — correct pattern to follow. |

## Problem

The plan-fidelity auditor (`audit/tasks/plan-fidelity.md`) embeds expected values directly in its evaluation criteria descriptions instead of reading them dynamically from the authoritative skill cards. This causes false FAIL verdicts when the authoritative source changes but the auditor's hard-coded values don't.

### 1. PF-DISPATCH-MODE — Vocabulary Mismatch

**Current hard-coded value** (`audit/tasks/plan-fidelity.md` §PF-DISPATCH-MODE):
> Every step title contains `(**clean-room**)` or `(**inline**)` — exactly one of the two

**Authoritative source** (`writing-plans/tasks/write.md` §Dispatch Indicators) defines **three** valid indicators: `(**sub-agent**)`, `(**clean-room**)`, `(**inline**)`. The `writing-plans` skill's own operating protocol uses `(**sub-agent**)` in 14 of 22 steps. The auditor rejects `(**sub-agent**)` because its internal list only has two entries.

### 2. PF-Z3-CONTRACT — Fabricated Format

**Current hard-coded value** (`audit/tasks/plan-fidelity.md` §PF-Z3-CONTRACT):
> Hierarchical phase→item→gate booleans exist (e.g., P1_I1_G1, P1_I2_G1)

**No authoritative source defines this format.** The `solve` skill's contract schema uses typed variables with Z3 expressions — no `P1_I1_G1` naming convention exists.

### 3. PF-6 — Same Vocabulary Mismatch

**Current hard-coded value** (`audit/tasks/plan-fidelity.md` §PF-6):
> every step has `(**clean-room**)` or `(**inline**)` dispatch mode indicator in title

**Same root cause** as PF-DISPATCH-MODE — only lists two indicators, missing `(**sub-agent**)`. The authoritative source (`writing-plans/tasks/write.md` §Dispatch Indicators) defines three.

### 4. PF-SEQUENCE-MATCHES — Correct Pattern

This criterion (`audit/tasks/plan-fidelity.md` §PF-SEQUENCE-MATCHES) does it correctly:
> Gate sequence matches `implementation-pipeline/SKILL.md` dispatch routing table — **read dynamically, not hardcoded**

## Root Cause

The evaluation criteria table embeds expected values directly instead of referencing authoritative skill cards.

## Scope

Single file: `audit/tasks/plan-fidelity.md`

## Approach

1. Change PF-DISPATCH-MODE expected result to dynamic reference: "valid dispatch indicator per `writing-plans/tasks/write.md` §Dispatch Indicators"
2. Change PF-6 expected result to same dynamic reference as PF-DISPATCH-MODE — both criteria reference the same authoritative source
3. Change PF-Z3-CONTRACT expected result: remove the `P1_I1_G1` format check (no authoritative source defines this convention) and replace with reference to `solve/tasks/contract.md` §Contract YAML Structure — typed variables (`type`, `domain`, `nullable`) with Z3 expression constraints
4. Add a general principle to the evaluation criteria section stating criteria MUST reference authoritative skill cards
5. Review all other criteria for hard-coded values that should be dynamic

## Success Criteria

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

**🚫 ALL-OR-NOTHING GATE: ALL success criteria MUST pass for implementation to be considered complete.**

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | PF-DISPATCH-MODE expected result changed from hard-coded `(**clean-room**) or (**inline**)` to dynamic reference: "valid dispatch indicator per `writing-plans/tasks/write.md` §Dispatch Indicators" | `string` | `grep -n "valid dispatch indicator per" .opencode/skills/audit/tasks/plan-fidelity.md` — MUST return at least one match | On FAIL: update the criterion text and re-grep | pre-commit | `.opencode/skills/audit/tasks/plan-fidelity.md` | Problem §1 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-2 | PF-Z3-CONTRACT expected result: `P1_I1_G1` format removed (no authoritative source defines this convention) and replaced with reference to `solve/tasks/contract.md` §Contract YAML Structure — typed variables (`type`, `domain`, `nullable`) with Z3 expression constraints | `string` | (1) `grep -n "P1_I1_G1" .opencode/skills/audit/tasks/plan-fidelity.md` — MUST return no matches. (2) `grep -n "contract.*schema\|typed.*variable\|Z3 expression" .opencode/skills/audit/tasks/plan-fidelity.md` — MUST return at least one match | On FAIL: remove P1_I1_G1 reference and add contract schema reference, then re-grep both | pre-commit | `.opencode/skills/audit/tasks/plan-fidelity.md` | Problem §2 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-3 | A general principle added to the evaluation criteria section stating criteria expected values MUST reference authoritative skill cards, not hard-code values | `string` | `grep -n "MUST reference\|authoritative skill card" .opencode/skills/audit/tasks/plan-fidelity.md` — MUST return at least one match | On FAIL: add the principle text and re-grep | pre-commit | `.opencode/skills/audit/tasks/plan-fidelity.md` | Approach §3 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-4 | All other criteria in the evaluation criteria table reviewed for hard-coded concrete values in the Expected Result column that are not sourced from an authoritative skill card; any found are flagged for follow-up | `string` | (1) `grep -n "e\.g\.,\|e\.g\. \|hard-coded\|hardcoded" .opencode/skills/audit/tasks/plan-fidelity.md` — review output. (2) For each match, check if the Expected Result column contains a concrete value (e.g., `(**clean-room**)`, `P1_I1_G1`) that is NOT a reference to an authoritative source (e.g., `per writing-plans/tasks/write.md`). If any such value exists, FAIL. | On FAIL: flag each remaining hard-coded concrete value for follow-up | pre-commit | `.opencode/skills/audit/tasks/plan-fidelity.md` | Approach §5 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-5 | PF-6 expected result changed from hard-coded `(**clean-room**) or (**inline**)` to same dynamic reference as PF-DISPATCH-MODE: "valid dispatch indicator per `writing-plans/tasks/write.md` §Dispatch Indicators" | `string` | `grep -n "valid dispatch indicator per" .opencode/skills/audit/tasks/plan-fidelity.md` — MUST return at least 2 matches (one for PF-DISPATCH-MODE, one for PF-6) | On FAIL: update PF-6 criterion text and re-grep | pre-commit | `.opencode/skills/audit/tasks/plan-fidelity.md` | Problem §3 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |

### Determinism Gate

For each SC:
- **SC-1**: `grep` produces deterministic PASS/FAIL — the string either exists or it doesn't
- **SC-2**: Two `grep` checks produce deterministic PASS/FAIL — `P1_I1_G1` is either absent (PASS) or present (FAIL); contract schema reference is either present (PASS) or absent (FAIL)
- **SC-3**: `grep` produces deterministic PASS/FAIL — the principle text either exists or it doesn't
- **SC-4**: `grep` produces deterministic PASS/FAIL — remaining hard-coded values are either found or not
- **SC-5**: `grep` produces deterministic PASS/FAIL — the string either appears twice (both criteria fixed) or it doesn't

### Evidence Type Classification

| SC | Change Affects Runtime Behavior? | Declared Evidence Type | Justification |
|----|--------------------------------|----------------------|---------------|
| SC-1 | NO — changes criterion description text only | `string` | The criterion text is a static string in the task file; changing it does not alter the auditor's runtime dispatch or evaluation logic |
| SC-2 | NO — changes criterion description text only | `string` | Same as SC-1 — text change only |
| SC-3 | NO — adds a prose principle to the task file | `string` | The principle is documentation for the next person editing the file; it does not execute at runtime |
| SC-4 | NO — review action only | `string` | Review produces a finding, not a runtime behavior change |

## Files Affected

- `audit/tasks/plan-fidelity.md` — evaluation criteria table (§Build Evaluation Criteria)

## Risks

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Criterion description change does not propagate to auditor sub-agent | Low | Medium | The auditor sub-agent reads the task file independently on each dispatch; no cache invalidation needed | SC-1, SC-2 |
| RISK-2 | Other hard-coded values missed in review | Medium | Low | SC-4 mandates a full review; any missed values are flagged for follow-up | SC-4 |

## Dependencies

None.

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Use dynamic references instead of hard-coded values | Follows the PF-SEQUENCE-MATCHES pattern which already does it correctly | MUST | SC-1, SC-2 |
| DEC-2 | Add general principle to evaluation criteria section | Prevents future hard-coding by documenting the requirement | MUST | SC-3 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Decomposition Classification

| Classification | Number of Phases | Sub-Issue Requirements | PR Strategy |
| -------------- | ---------------- | ---------------------- | ----------- |
| single-task | 1 | None | single PR |

## Explicit Non-Goals

- **Rewriting the entire plan-fidelity auditor** — Only the evaluation criteria descriptions are changed; the audit logic itself is not modified
- **Adding a validation layer** — No new infrastructure is introduced; the fix is limited to text changes in one file

## Regression Invariants

- [ ] 1. All existing evaluation criteria IDs (PF-DISPATCH-MODE, PF-Z3-CONTRACT, PF-SEQUENCE-MATCHES, etc.) MUST remain unchanged
- [ ] 2. The audit logic that evaluates each criterion MUST remain unchanged
- [ ] 3. The plan-fidelity auditor's dispatch interface MUST remain unchanged

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep -n "clean-room\|inline\|sub-agent" .opencode/skills/writing-plans/tasks/write.md` | Verify valid dispatch indicators |
| Direct source search | `grep -rn "P1_I1_G1\|contract.*schema" .opencode/skills/solve/` | Verify Z3 contract format |
| Direct source search | `grep -n "read dynamically" .opencode/skills/audit/tasks/plan-fidelity.md` | Verify correct pattern reference |

---

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1436/plan.md` before implementation begins.

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
