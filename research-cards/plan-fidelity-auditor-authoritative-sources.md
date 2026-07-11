---
title: "Plan-Fidelity Auditor Authoritative Sources"
created: 2026-07-10
confidence: 1.0
tags: [plan-fidelity, audit, authoritative-sources, dispatch-indicators, z3-contract]
sources:
  - url: https://github.com/michael-conrad/.opencode/blob/main/skills/writing-plans/tasks/write.md
    section: "Dispatch Indicators"
    verified: 2026-07-10
    relevance: "Defines the three valid dispatch indicators: (**inline**), (**sub-agent**), (**clean-room**). The plan-fidelity auditor's PF-DISPATCH-MODE criterion must reference this section dynamically rather than hard-coding only two indicators."
  - url: https://github.com/michael-conrad/.opencode/blob/main/skills/solve/tasks/contract.md
    section: "Contract YAML Schema"
    verified: 2026-07-10
    relevance: "Defines the Z3 contract schema with typed variables, constraints (preconditions, invariants, postconditions), and theorems. No P1_I1_G1 naming convention exists. The plan-fidelity auditor's PF-Z3-CONTRACT criterion must reference this schema rather than a fabricated format."
  - url: https://github.com/michael-conrad/.opencode/blob/main/skills/audit/tasks/plan-fidelity.md
    section: "Evaluation Criteria"
    verified: 2026-07-10
    relevance: "The target file for the spec-fix. Contains hard-coded evaluation criteria that must be updated to reference authoritative sources dynamically."
  - url: https://github.com/michael-conrad/.opencode/blob/main/skills/implementation-pipeline/SKILL.md
    section: "Trigger Dispatch Table"
    verified: 2026-07-10
    relevance: "Defines the canonical gate sequence for the implementation pipeline. The plan-fidelity auditor's PF-SEQUENCE-MATCHES criterion already correctly reads this dynamically."
---

# Plan-Fidelity Auditor Authoritative Sources

## Summary

The plan-fidelity auditor at `audit/tasks/plan-fidelity.md` embeds expected values directly in its evaluation criteria instead of reading them dynamically from authoritative skill cards. This research card documents the authoritative sources that the criteria MUST reference.

## Authoritative Sources

### 1. Dispatch Indicators — `writing-plans/tasks/write.md` §Dispatch Indicators

**Live URL:** https://github.com/michael-conrad/.opencode/blob/main/skills/writing-plans/tasks/write.md

The Dispatch Indicators section defines **three** valid indicators:

| Indicator | Meaning |
|-----------|---------|
| `(**inline**)` | Orchestrator executes directly (no sub-agent) |
| `(**sub-agent**)` | Dispatch via `task()` with phase file + orchestrator-provided context |
| `(**clean-room**)` | Dispatch via `task()` with phase file only (routing metadata) |

**Current problem:** PF-DISPATCH-MODE (§Build Evaluation Criteria) and PF-6 both only list `(**clean-room**)` and `(**inline**)` — missing `(**sub-agent**)`.

**Required fix:** Change PF-DISPATCH-MODE expected result to: "valid dispatch indicator per `writing-plans/tasks/write.md` §Dispatch Indicators — one of `(**inline**)`, `(**sub-agent**)`, or `(**clean-room`)**". Change PF-6 expected result to match — replace the hard-coded two-indicator list with the same dynamic reference. Both criteria MUST reference the same authoritative source. No alternative dispatch indicators are valid — only these three.

### 2. Z3 Contract Schema — `solve/tasks/contract.md`

**Live URL:** https://github.com/michael-conrad/.opencode/blob/main/skills/solve/tasks/contract.md

The contract schema uses typed variables with Z3 expressions. Variables have `type`, `domain`, and `nullable` fields. Constraints are Z3 expression strings. **No `P1_I1_G1` naming convention exists.**

**Current problem:** PF-Z3-CONTRACT (§Build Evaluation Criteria) checks for `P1_I1_G1` format which has no authoritative source. The `solve/tasks/contract.md` schema uses typed variables (bool, int, string, real) with Z3 expressions — no `P1_I1_G1` naming convention exists anywhere in the codebase.

**Required fix:** Replace the `P1_I1_G1` check with a reference to the `solve/tasks/contract.md` schema format. The new expected result MUST be: "Z3 contract variables use typed declarations per `solve/tasks/contract.md` §Contract YAML Structure — `type`, `domain`, `nullable` fields with Z3 expression constraints". The `P1_I1_G1` format MUST be removed — there is no alternative valid format to keep.

### 3. Implementation Pipeline Gate Sequence — `implementation-pipeline/SKILL.md` §Trigger Dispatch Table

**Live URL:** https://github.com/michael-conrad/.opencode/blob/main/skills/implementation-pipeline/SKILL.md

The Trigger Dispatch Table defines the canonical gate sequence. PF-SEQUENCE-MATCHES already correctly reads this dynamically.

### 4. Target File — `audit/tasks/plan-fidelity.md`

**Live URL:** https://github.com/michael-conrad/.opencode/blob/main/skills/audit/tasks/plan-fidelity.md

The file to be modified. Note: the spec references `adversarial-audit/tasks/plan-fidelity.md` but the actual path is `audit/tasks/plan-fidelity.md`.

## Required Actions (Deterministic — No Alternatives)

1. **PF-DISPATCH-MODE**: Replace hard-coded `(**clean-room**) or (**inline**)` with dynamic reference to `writing-plans/tasks/write.md` §Dispatch Indicators. The authoritative source defines exactly three valid indicators: `(**inline**)`, `(**sub-agent**)`, `(**clean-room**)`. No other indicators are valid.
2. **PF-Z3-CONTRACT**: Remove the `P1_I1_G1` format check. Replace with reference to `solve/tasks/contract.md` §Contract YAML Structure. The authoritative schema uses typed variables (`type`, `domain`, `nullable`) with Z3 expression constraints. No naming convention format exists — do not invent one.
3. **PF-6**: Replace hard-coded `(**clean-room**) or (**inline**)` with same dynamic reference as PF-DISPATCH-MODE. Both criteria MUST reference the same authoritative source.
4. **General principle**: Add a note to the evaluation criteria section stating criteria expected values MUST reference authoritative skill cards, not hard-code values. This applies to ALL criteria, not just the ones listed above.
5. **Full review**: Scan all other criteria for hard-coded values that should be dynamic. Any found MUST be flagged for follow-up.
