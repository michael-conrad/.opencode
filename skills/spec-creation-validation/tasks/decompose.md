# Task: decompose

## Purpose

Decompose the problem into success criteria for the spec.

## Entry Criteria

- `concern_artifact_path` is provided
- Concern analysis is complete

## Procedure

- [ ] 1. Read concern analysis from `concern_artifact_path`
- [ ] 2. Decompose each concern into specific, testable success criteria
- [ ] 3. Assign evidence types to each SC
      - [ ] 3a. For each SC, ask: "Does this change affect runtime behavior?"
            (Runtime behavior includes: agent dispatch decisions, enforcement gate outcomes,
            tool selection, pipeline routing, conditional branching, test execution results,
            and any observable system output. This question is substrate-determined —
            it applies to ALL SCs in ALL specs, regardless of language or domain.)
      - [ ] 3b. Presumptive YES for file types: SKILL.md, tasks/*.md, guidelines/*.md,
            enforcement/*.md — these files control agent behavior at runtime.
            Any SC modifying them is automatically behavioral.
      - [ ] 3c. If YES → evidence type MUST be `behavioral` (automatic uplift per
            critical-rules-BEH-EV in 000-critical-rules.md)
      - [ ] 3d. If NO → choose from: `behavioral`, `semantic`, `string`, `structural`
      - [ ] 3e. Record classification in decomposition artifact
- [ ] 4. Write decomposition artifact to `./tmp/{issue-N}/artifacts/decomposition.yaml`

## Exit Criteria

- Decomposition artifact written with SCs and evidence types
- Artifact path returned

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "Decomposed into N success criteria" |
| artifact_path | `./tmp/{issue-N}/artifacts/decomposition.yaml` |
