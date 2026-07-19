# Task: structure

## Purpose

Define the plan phase structure: combined/separate decision, file mapping, phase structure, TDD definition, and dependency contract generation. Uses analytical artifacts from spec-creation instead of deriving structure from scratch.

## Entry Criteria

- Readiness step completed with PASS
- Spec content available
- All 7 analytical artifacts loaded by research step (blast radius, concern map, code path inventory, cross-cutting matrix, interface compatibility, state analysis, testability assessment)

## Exit Criteria

- Combined/separate decision made and documented
- File structure mapped with clear boundaries
- Phase structure defined with concern boundary annotations
- Phase structure uses three-tier organization: global pre-phase (once), per-file RED/GREEN phases (one chain each), global post-phase (once)
- TDD tasks defined with mandatory RED checkpoints
- Dependency contract generated
- Phase structure validated against interface compatibility analysis

## Procedure

- [ ] 1. Read approved spec content
- [ ] 2. Make combined/separate decision
- [ ] 3. Map file structure (sub-folder references, not individual files) — use blast radius artifact to determine full file scope
- [ ] 4. Define phase structure with concern boundary annotations — use concern map artifact to determine phase count and boundaries
- [ ] 5. Define TDD tasks with RED/GREEN conditions — use code path inventory artifact to ensure every code path has a RED/GREEN item; use cross-cutting matrix artifact to annotate cross-cutting SCs; use testability assessment artifact to assign correct evidence types
- [ ] 6. Generate dependency-ordering solve contract — use state analysis artifact to add state transition dependencies
- [ ] 7. Write phase-to-skill-mapping.yaml per #1311 format
- [ ] 8. Return structure output with phase definitions
- [ ] 9. (**inline**) Validate plan phase structure against interface compatibility analysis — verify that phase boundaries respect interface boundaries from the interface compatibility artifact. If any phase crosses an interface boundary that the artifact marks as incompatible, return BLOCKED with `INTERFACE_BOUNDARY_VIOLATION`.

## Context Required

- Load [create](tasks/create.md)
- Load [solve](skills/solve/SKILL.md), Load [plan](skills/plan/SKILL.md)
