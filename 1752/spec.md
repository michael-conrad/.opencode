> **Full spec and artifacts: `.opencode/.issues/1032/`**

## Exec Summary

Cross-validate receives pre-resolved `auditor_artifact_paths` from the orchestrator and computes consensus by reading YAML verdicts from disk. It has no mechanism to validate that those artifacts are from the same audit run, contain consistent criteria, are parseable, or are not fabricated/stale. During pipeline #884, a stale cross-validate artifact from a poisoned pipeline remained on disk alongside the fresh one, risking consensus against wrong auditor verdicts.

### Cards (dependency order)
1. **Input validation gate** — verify file existence, same issue_number, same audit_phase, same SC count
2. **Frugal contract requirement** — cross-validate returns YAML contract, not narrative
3. **Staleness guard** — reject artifacts older than pipeline restart timestamp

### Key Decisions
- **Fail on any mismatch** — any CONTEXT_POLLUTION check failure returns BLOCKED, not degraded consensus
- **Frugal contract enforced** — narrative output treated as FAIL

### Risk Callouts
- **Stale artifacts from prior runs are indistinguishable by filename alone** — timestamp-based guard required
- **Cross-validate trusts input paths** — root cause of the contamination vulnerability

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/1032/`.
After creation, `local-issues sync 1032` MUST be run and the result committed to create the local `.issues/1032/` entry.
The implementation plan will be created in `.issues/1032/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

---
*Migrated from local tracking. Original local directory: `.opencode/.issues/1032/`*