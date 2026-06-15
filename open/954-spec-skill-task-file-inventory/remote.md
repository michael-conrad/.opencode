---
remote_issue: 954
remote_url: "https://github.com/michael-conrad/.opencode/issues/954"
last_sync: 2026-06-14T20:50:47Z
source: github.com
---

> **Scope revision: `.opencode#1222` (Enforcement-Gated Contract Schema) replaces the evidence-gating and artifact-mandatory aspects of this spec. The standardized hand-off contract schema with mandatory `gate_result`, `verifier_identity`, and `artifact_hash` fields is now defined holistically in #1222. What remains: the frugal contract size limits, inventory classification, and solve gate integration — less the enforcement-field additions (~5 extra fields on the minimum contract).**

## Problem

The frugal contract disk-offload pattern (defined in #932 for auditors) and the solve contract/state integration (defined in #951 for pre/post condition gates) must be applied systematically across all 36 skill task files that dispatch sub-agents. Currently:

1. Most skill task files pass unstructured results through orchestrator context (verdicts, analysis, full content)
2. No standardized protocol exists for sub-agents recording step completion in Z3 state
3. No standardized naming convention exists for disk artifacts beyond the auditor scope
4. No orchestrator discipline guarantees that it never reads intermediate artifacts — the design intent exists (#911) but is not enforced across task files

## Z3-Verified Placement

This spec is in **Phase 3** of the 909 cluster ordering. Depends on #915 (Phase 1), #932 (Phase 1), and #951 (Phase 2).

## Remaining Scope

### Frugal Contract Size Limits & Inventory

The minimum frugal contract remains `{status, artifact_path, summary}` (3 fields). The `#1222` enforcement schema adds `gate.gate_result`, `gate.verdict_source`, `gate.artifact_hashes`, and `evidence_types[]` to the artifact on disk — approximately 5 additional YAML fields. The frugal contract returned by sub-agents does NOT include these fields (they are added by the orchestrator when constructing the hand-off contract). The inventory classification (Tier A/B/C for all 36 skill task files) remains fully in scope.

### Solve Gate Integration (Excluding #1222's Pre-Dispatch Gate)

Add pre-dispatch `solve check` and post-return `solve check` gates to every skill task file that dispatches sub-agents. These validate step-position constraints (previous_step/current_step consistency per the state machine) — distinct from `#1222`'s artifact-content validation gate.

### Two-Tier Protocol (Unchanged)

Tier 1 (bash: allow) — sub-agent records pipeline position via `solve state update`. Tier 2 (bash: deny) — orchestrator records pipeline position after sub-agent returns. Both unchanged by #1222.

### Phase Scoping

**Phase 1:** Classification audit of all 36 skill task files (unchanged)
**Phase 2:** Disk-offload pattern for Tier A files (unchanged — #932 naming convention)
**Phase 3:** Solve gate integration for all tiers (removes evidence-type checking — that's in #1222)
**Phase 4:** Behavioral tests (unchanged)

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | All 36 skills have verified classification (A/B/C) in the inventory | `structural` | Inventory table exists with per-file classification |
| SC-2 | All Tier A files implement disk-offload pattern (write artifact + frugal contract) | `behavioral` | opencode-cli run each skill → artifact exists on disk, contract ≤8 fields (3 core + ~5 enforcement) |
| SC-3 | All Tier A files dispatch remediator sub-agent on FAIL | `behavioral` | opencode-cli run with FAIL scenario → remediator dispatched |
| SC-4 | All dispatching task files have pre-dispatch `solve check` gate (position validation) | `structural` | grep for `solve check` in each task file |
| SC-5 | All dispatching task files have post-return `solve check` gate (position validation) | `structural` | grep for `solve check` in each task file |
| SC-6 | Tier 1 sub-agents advance pipeline position via per-variable `solve state update` | `behavioral` | opencode-cli run → sub-agent stderr shows state update calls |
| SC-7 | Tier 2 orchestrator advances pipeline position after contract return | `behavioral` | opencode-cli run auditor → orchestrator stderr shows state update |
| SC-8 | Orchestrator never reads artifact content during normal routing | `behavioral` | opencode-cli run → grep orchestrator stderr for artifact read patterns → 0 matches |
| SC-9 | All disk artifacts follow #932 naming convention | `string` | grep across all task files for artifact path pattern |

🤖 OpenCode (deepseek-v4-flash)