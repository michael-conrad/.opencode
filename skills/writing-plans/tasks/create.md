# Task: create

## Purpose

Generates a structured implementation plan with a routing-table format (skill+task references), phase DAG, and dependency contract from an approved spec's analysis summary.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- The issue number `{N}` must be provided
- The project root and issues prefix must be set
- The analysis summary must exist at `{issues_prefix}/{N}/artifacts/analysis-summary.yaml`

## Procedure

1. Read the analysis summary from `{issues_prefix}/{N}/artifacts/analysis-summary.yaml`.
   - If missing: return BLOCKED with `ANALYSIS_SUMMARY_NOT_FOUND`.
2. Read the spec file from `{issues_prefix}/{N}/spec.md` to extract all success criteria.
3. Read the implementation-pipeline SKILL.md Trigger Dispatch Table to identify available skill+task dispatch targets.
4. Decompose the success criteria into phases:
   - Group SCs by concern boundary from the concern-map artifact.
   - Each concern maps to exactly one phase.
   - Order phases by dependency: global pre-phase first, per-file phases, global post-phase last.
5. For each phase, select the appropriate skill+task reference from the implementation-pipeline TDT.
   - Record the dispatch mode (inline, clean-room) per phase.
6. Build the phase DAG:
   - Define dependency edges between phases.
   - Ensure no circular dependencies.
   - Verify all phases are reachable from the start node.
7. Write the plan to `{issues_prefix}/{N}/plan.md`:
   - Phase table with phase ID, name, concern, skill+task reference, dispatch mode.
   - Per-phase procedure steps with RED/GREEN/TDD structure.
   - Exit criteria section with SC-to-phase mapping and evidence types.
8. Write the dependency contract to `{issues_prefix}/{N}/dependency-contract.yaml`:
   - Phase nodes with IDs and metadata.
   - Dependency edges with source, target, and condition.
   - State transitions per phase.
9. Return the result contract.

## Exit Criteria

- The plan has been written to `{issues_prefix}/{N}/plan.md` with phase table and per-phase steps
- The dependency contract has been written to `{issues_prefix}/{N}/dependency-contract.yaml`
- All SCs are mapped to at least one phase
- No circular dependencies in the phase DAG
- The artifact path has been set in the result contract

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences summarizing phase count, DAG structure, and SC coverage>"
artifact_path: "<{issues_prefix}/{N}/plan.md>"
blocker_reason: "<reason if BLOCKED>"
```
