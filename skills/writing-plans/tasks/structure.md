# Task: structure

## Purpose

Define the plan phase structure: combined/separate decision, file mapping, phase structure, TDD definition, and dependency contract generation.

## Entry Criteria

- Readiness step completed with PASS
- Spec content available

## Exit Criteria

- Combined/separate decision made and documented
- File structure mapped with clear boundaries
- Phase structure defined with concern boundary annotations
- Phase structure uses three-tier organization: global pre-phase (once), per-file RED/GREEN phases (one chain each), global post-phase (once)
- TDD tasks defined with mandatory RED checkpoints
- Dependency contract generated

## Procedure

- [ ] 1. Read approved spec content
- [ ] 2. Make combined/separate decision
- [ ] 3. Map file structure (sub-folder references, not individual files)
- [ ] 4. Define phase structure with concern boundary annotations
- [ ] 5. Define TDD tasks with RED/GREEN conditions
- [ ] 6. Generate dependency-ordering solve contract
- [ ] 7. Write phase-to-skill-mapping.yaml per #1311 format
- [ ] 8. Return structure output with phase definitions

## Context Required

- Related tasks: `create` (21-step pipeline)
- Related skills: `solve`, `plan`
