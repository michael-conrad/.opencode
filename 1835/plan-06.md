# Phase 6 — Part B2: writing-plans Changes

**Concern:** Update writing-plans task files to consume analytical artifacts; add artifact-validation task

**Files:**
- `.opencode/skills/writing-plans/tasks/research.md` (MODIFY)
- `.opencode/skills/writing-plans/tasks/structure.md` (MODIFY)
- `.opencode/skills/writing-plans/tasks/validate.md` (MODIFY)
- `.opencode/skills/writing-plans/tasks/write.md` (MODIFY)
- `.opencode/skills/writing-plans/tasks/create.md` (MODIFY)
- `.opencode/skills/writing-plans/tasks/artifact-validation.md` (NEW)

**SCs:** SC-26, SC-27, SC-28, SC-29, SC-30, SC-31

**Dependencies:** Phase 5

**Entry Criteria:** Phase 5 complete, spec-audit updated

**Exit Criteria:** All writing-plans task files updated to consume analytical artifacts; artifact-validation.md created

## Step-by-Step

- [ ] 29. (**sub-agent**) Update `research.md` — Add artifact loading steps (1a-1g): Load blast radius, concern map, code path inventory, cross-cutting matrix, interface compatibility, state analysis, and testability assessment from `.issues/{N}/`. Return BLOCKED with `MISSING_SPEC_ARTIFACT` if any required artifact is missing.
  - SC: SC-26

- [ ] 30. (**sub-agent**) Update `structure.md` — Use artifacts instead of deriving from scratch: concern map determines phase count, blast radius determines full file scope, code path inventory ensures every path has a RED/GREEN item, cross-cutting matrix annotates cross-cutting SCs, testability assessment assigns correct evidence types, state analysis adds state transition dependencies. Add Step 9: validate plan phase structure against interface compatibility analysis.
  - SC: SC-27

- [ ] 31. (**sub-agent**) Update `validate.md` — Add 7 new validation checks (21-27): blast radius coverage, concern map alignment, code path coverage, cross-cutting SC coverage, interface compatibility, state transition coverage, testability alignment.
  - SC: SC-28

- [ ] 32. (**sub-agent**) Update `write.md` — Add new required sections to plan format: Blast Radius section, Concern Map Reference, per-phase Code Path Coverage, Cross-Cutting SCs, Interface Boundaries, State Transitions.
  - SC: SC-29

- [ ] 33. (**sub-agent**) Update `create.md` — Add Step 4a: Artifact validation sub-agent that validates all spec-creation analytical artifacts exist and are well-formed.
  - SC: SC-30

- [ ] 34. (**sub-agent**) Create `artifact-validation.md` — New task file that validates all expected analytical artifacts from spec-creation exist, are non-empty, and are well-formed YAML. Returns BLOCKED if any required artifact is missing.
  - SC: SC-31

- [ ] 35. (**inline**) Verify all writing-plans task files are updated correctly
  - Command: Read each modified file, verify changes match spec requirements
  - SC: SC-26, SC-27, SC-28, SC-29, SC-30, SC-31

## Phase Completion

- [ ] research.md loads all 7 analytical artifacts
- [ ] structure.md consumes analytical artifacts
- [ ] validate.md includes 7 new validation checks
- [ ] write.md includes new plan format sections
- [ ] create.md includes artifact validation sub-agent step
- [ ] artifact-validation.md exists and validates all analytical artifacts

## Concern Transition

Phase 6 updates writing-plans. Phase 7 updates verification-before-completion.
