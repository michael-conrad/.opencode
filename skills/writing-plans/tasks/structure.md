---
name: structure
description: Decompose SCs into phases, build dependency DAG, select skill+task from implementation-pipeline TDT
provenance: AI-generated
---

# Task: structure

## Purpose

Decompose success criteria into implementation phases, build a dependency DAG between phases, and select the skill+task from the implementation-pipeline Trigger Dispatch Table for each phase.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- The analysis summary must exist at `{issues_prefix}/{N}/artifacts/analysis-summary.yaml`
- The issue number must be provided
- The project root must be set
- The issues prefix must be set

## Procedure

1. Read the analysis summary from `{issues_prefix}/{N}/artifacts/analysis-summary.yaml`.
2. Extract all success criteria from the analysis summary.
3. Group related SCs into phases based on concern boundaries and implementation dependencies.
4. Build a dependency DAG between phases:
   - Identify which phases depend on the output of other phases
   - Record the dependency edges in the structure artifact
5. For each phase, select the skill+task from the implementation-pipeline Trigger Dispatch Table that will implement it:
   - Load `skill({name: "implementation-pipeline"})` and read its Trigger Dispatch Table
   - Map each phase to the appropriate skill+task entry
6. Write the structure artifact to `{issues_prefix}/{N}/artifacts/structure.yaml`:
   - Phase list with SC assignments
   - Dependency DAG edges
   - Skill+task selection per phase
7. Return the result contract.

## Exit Criteria

- The structure artifact has been written to `{issues_prefix}/{N}/artifacts/structure.yaml`
- The artifact contains phase decomposition, dependency DAG, and skill+task selection
- The artifact path has been set in the result contract

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences of routing-significant output>"
artifact_path: "<path to structure.yaml on disk>"
blocker_reason: "<reason if BLOCKED>"
```
