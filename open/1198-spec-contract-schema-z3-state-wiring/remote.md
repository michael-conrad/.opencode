---
remote_issue: 1198
remote_url: "https://github.com/michael-conrad/.opencode/issues/1198"
last_sync: 2026-06-14T20:50:47Z
source: github.com
---

> **Scope reduced by `.opencode#1222` (Enforcement-Gated Contract Schema).** The evidence-gating and artifact-mandatory design is now part of the holistic hand-off contract schema. What remains below is the Z3 state wiring implementation — how the standardized contract YAML is ingested by the solve tool and used to drive state transitions.

## Summary

Wire the standardized hand-off contract schema (defined in `#1222`) into the solve tool's state management. The solve tool must read contract YAML fields (`gate_result`, `artifact_hashes`, `verdict_source`, `evidence_types`) and use them to determine state transitions — rather than accepting unconstrained `state update` calls.

## Remaining Scope

### Phase 1: Extend solve tool to accept standardized contract YAML

The solve tool's `state update` subcommand needs a new mode that accepts a contract YAML (per `#1222` Part 1 schema) and:

1. Reads `gate.gate_result` — only `PASS` permits state transition
2. Reads `gate.artifact_hashes` — verifies each path exists with matching sha256
3. Reads `gate.verdict_source` — validates against the dispatch table's `auditor_type` for this step
4. Reads `evidence_types[]` — rejects if any `declared_type != actual_type`
5. Only if all pass: transitions the step variable in Z3 state

### Phase 2: Replace unconstrained state update calls

Replace all existing `solve state update <var>=true` calls in pipeline task files with the contract-based variant. Each call reads the previous step's hand-off contract YAML and passes it to the solve tool.

### Phase 3: Remove verification significance from work state file

Per superseding `#1222` SC-8 and SC-14, the work state file loses verification significance. Strip work-state-file verification requirements from skill task files while retaining it as an orchestrator planning artifact for resume/rollback.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | solve tool accepts standardized contract YAML as input for state update | `behavioral` | Pipe valid contract YAML → `solve state update-contract` → Z3 transitions |
| SC-2 | Contract with gate_result=FAIL → solve rejects transition | `behavioral` | Pipe FAIL contract → solve exits non-zero, state unchanged |
| SC-3 | Missing artifact_hash for behavioral SC → solve rejects transition | `behavioral` | Contract missing hashes → solve exits non-zero |
| SC-4 | verdict_source mismatch → solve rejects transition | `behavioral` | auditor_type mismatch → solve UNSAT |
| SC-5 | Evidence type mismatch → solve rejects transition | `behavioral` | declared===actual mismatch → solve UNSAT |
| SC-6 | All unconstrained state update calls replaced with contract-based variant | `string` | grep for bare `state update <var>=true` in task files → 0 matches |
| SC-7 | Work state file stripped of verification significance | `string` | grep for work-state verification in skill files → 0 matches (planning-only references preserved) |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)