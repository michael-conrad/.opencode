# Phase 5 — Part B1: spec-audit Changes

**Concern:** Add analytical artifact validation to spec-audit task file

**Files:**
- `.opencode/skills/audit/tasks/spec-audit.md` (MODIFY)

**SCs:** SC-23, SC-24, SC-25

**Dependencies:** Phase 4

**Entry Criteria:** Phase 4 complete, spec-creation internals updated

**Exit Criteria:** spec-audit.md includes 7 new SC criteria, 7 new validation steps, and dispatch contract fields for analytical artifacts

## Step-by-Step

- [ ] 26. (**sub-agent**) Add 7 new SC criteria to `spec-audit.md` evaluation table: SC-BLAST-RADIUS, SC-CONCERN-MAP, SC-CODE-PATH, SC-CROSS-CUTTING, SC-INTERFACE, SC-STATE, SC-TESTABILITY — each verifying the corresponding analytical artifact is present and complete
  - SC: SC-23

- [ ] 27. (**sub-agent**) Add 7 new validation steps (3i through 3o) to `spec-audit.md`: Validate blast radius artifact, concern map artifact, code path inventory, cross-cutting matrix, interface compatibility, state analysis, and testability assessment. Each step reads the artifact, cross-references against spec content, and flags gaps.
  - SC: SC-23

- [ ] 28. (**sub-agent**) Update `spec-audit.md` dispatch contract with 7 new fields: `blast_radius_path`, `concern_map_path`, `code_path_inventory_path`, `cross_cutting_matrix_path`, `interface_compatibility_path`, `state_analysis_path`, `testability_assessment_path`. Update pre-flight validation gate to check new artifact paths. Update completion dependency chain to include steps 3i-3o.
  - SC: SC-24, SC-25

## Phase Completion

- [ ] spec-audit.md includes 7 new SC criteria
- [ ] spec-audit.md includes 7 new validation steps (3i-3o)
- [ ] spec-audit.md dispatch contract includes 7 new artifact path fields
- [ ] Pre-flight validation gate checks new artifact paths
- [ ] Completion dependency chain includes steps 3i-3o

## Concern Transition

Phase 5 updates spec-audit. Phase 6 updates the writing-plans downstream consumer.
