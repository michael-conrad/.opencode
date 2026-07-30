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
5. For each phase, map SCs to items by reading `sc-summary.yaml` and creating one item per SC:
    - Read the implementation-pipeline Trigger Dispatch Table
    - Map each SC to an individual item with its own RED/GREEN/verify/commit cycle
    - Each item references exactly one SC-ID
5a. Verify triplet co-location: for each SC, confirm that its RED, GREEN, and COMMIT steps are all assigned to the same phase. If any SC has steps split across phases, return BLOCKED with reason `"TRIPLET_SPLIT: SC-N has RED in phase X and GREEN in phase Y"`.
5b. Document the triplet integrity rule in the procedure text: "Each SC's RED, GREEN, and COMMIT steps MUST be in the same phase. No SC may have its test in one phase and its implementation in another."
5c. Verify cross-phase dependency: for each phase, check whether any RED test depends on SC output that is not yet committed in the same phase. A RED test in phase X that depends on SC-M output from phase Y (where Y > X) is a cross-phase dependency violation. If found, return BLOCKED with reason `"CROSS_PHASE_DEP: SC-N RED in phase X depends on SC-M output from phase Y"`.
5d. Document the cross-phase dependency rule in the procedure text: "A RED test in one phase MUST NOT depend on uncommitted SC output from another phase. Cross-phase RED dependencies are structural defects — they create implicit ordering constraints that bypass the dependency DAG."
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
