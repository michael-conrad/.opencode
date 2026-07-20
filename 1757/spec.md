> **Full spec and artifacts: `.opencode/.issues/1029/`**

## Exec Summary

When an auditor sub-agent writes a verdict artifact to disk but fails to return the frugal result contract as proof of completion, the orchestrator has no mechanism to detect the failure. The task() result may contain narrative text about methodology phases instead of the structured YAML contract the orchestrator needs to route the next pipeline step. During pipeline #884 step 10.4, auditor_1 produced a valid artifact but returned narrative text instead of the frugal contract. Separately, auditor_2 did not produce output at all — the resolve-models selection must be re-run to get a fresh randomized pair after any dispatch failure.

### Cards (dependency order)
1. **Add post-audit orchestrator gate after every auditor dispatch in verification-audit.md**
2. **Document resolve-models `--re-task` randomization guarantee — same pair is valid, no deliberation**
3. **Add behavioral enforcement tests for auditor contract return and resolve-models dispatch**

### Key Decisions
- **Frugal contract validation in verification-audit.md Step 9a** — task() result MUST contain artifact_path field; missing = FAIL + re-dispatch
- **resolve-models `--re-task` may return the same auditor pair** — this is valid output; the agent dispatches whatever resolve-models returns without deliberation

### Risk Callouts
- **resolve-models returns stale pairs** — successive calls return the same auditor types instead of fresh randomization; pool pruning results in insufficient candidate diversity
- **Orchestrator has no post-audit validation** — must check that task() result contains artifact_path before proceeding; missing contract = treat as FAIL + redispatch

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/1029/`.
After creation, `local-issues sync 1029` MUST be run and the result committed to create the local `.issues/1029/` entry.
The implementation plan will be created in `.issues/1029/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

---
*Migrated from local tracking. Original local directory: `.opencode/.issues/1029/`*