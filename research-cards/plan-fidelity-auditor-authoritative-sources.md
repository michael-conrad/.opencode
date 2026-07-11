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

**Current problem:** PF-DISPATCH-MODE (line 121) and PF-6 (line 114) only list `(**clean-room**)` and `(**inline**)` — missing `(**sub-agent**)`.

**Required fix:** Change expected result to: "valid dispatch indicator per `writing-plans/tasks/write.md` §Dispatch Indicators — one of `(**inline**)`, `(**sub-agent**)`, or `(**clean-room**)`"

### 2. Z3 Contract Schema — `solve/tasks/contract.md`

**Live URL:** https://github.com/michael-conrad/.opencode/blob/main/skills/solve/tasks/contract.md

The contract schema uses typed variables with Z3 expressions. Variables have `type`, `domain`, and `nullable` fields. Constraints are Z3 expression strings. **No `P1_I1_G1` naming convention exists.**

**Current problem:** PF-Z3-CONTRACT (line 118) checks for `P1_I1_G1` format which has no authoritative source.

**Required fix:** Change expected result to reference the `solve` skill's contract schema format, or remove the fabricated format check.

### 3. Implementation Pipeline Gate Sequence — `implementation-pipeline/SKILL.md` §Trigger Dispatch Table

**Live URL:** https://github.com/michael-conrad/.opencode/blob/main/skills/implementation-pipeline/SKILL.md

The Trigger Dispatch Table defines the canonical gate sequence. PF-SEQUENCE-MATCHES already correctly reads this dynamically.

### 4. Target File — `audit/tasks/plan-fidelity.md`

**Live URL:** https://github.com/michael-conrad/.opencode/blob/main/skills/audit/tasks/plan-fidelity.md

The file to be modified. Note: the spec references `adversarial-audit/tasks/plan-fidelity.md` but the actual path is `audit/tasks/plan-fidelity.md`.

## Key Findings

1. **PF-DISPATCH-MODE** hard-codes 2 indicators instead of referencing the authoritative source which defines 3
2. **PF-Z3-CONTRACT** uses a fabricated `P1_I1_G1` format with no authoritative source
3. **PF-SEQUENCE-MATCHES** already does it correctly — reads dynamically
4. **File path in spec is stale**: `adversarial-audit/` → `audit/`
