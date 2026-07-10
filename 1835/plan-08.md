# Phase 8 — Part B4: brainstorming Changes

**Concern:** Add preliminary analytical artifact production to brainstorming

**Files:**
- `.opencode/skills/brainstorming/tasks/explore/pre-spec-inspection.md` (MODIFY)
- `.opencode/skills/brainstorming/tasks/explore/exploration-workflow.md` (MODIFY)
- `.opencode/skills/brainstorming/tasks/enforcement.md` (MODIFY)

**SCs:** SC-36, SC-37, SC-38, SC-39

**Dependencies:** Phase 7

**Entry Criteria:** Phase 7 complete, verification-before-completion updated

**Exit Criteria:** All brainstorming task files include preliminary analytical artifact production

## Step-by-Step

- [ ] 40. (**sub-agent**) Update `pre-spec-inspection.md` — Add 6 new checklist items (7-12): preliminary blast radius, preliminary concern map, code path inventory, interface compatibility, state analysis, testability assessment
  - SC: SC-36

- [ ] 41. (**sub-agent**) Update `exploration-workflow.md` — Add Step 2.5: Produce Preliminary Analytical Artifacts. Write preliminary versions of all 7 analytical artifacts to `{project_root}/tmp/{issue-N}/artifacts/preliminary/`
  - SC: SC-37

- [ ] 42. (**sub-agent**) Update `enforcement.md` — Add 7 new investigation completion criteria: blast radius assessed, concern map drafted, code paths inventoried, cross-cutting concerns identified, interface compatibility checked, state analysis performed, testability assessed
  - SC: SC-38

- [ ] 43. (**sub-agent**) Add new handoff contract to brainstorming: brainstorming→spec-creation handoff artifact at `{project_root}/tmp/{issue-N}/artifacts/preliminary/handoff.yaml` listing all preliminary artifacts with paths and completion status
  - SC: SC-39

## Phase Completion

- [ ] pre-spec-inspection.md includes 6 new checklist items
- [ ] exploration-workflow.md includes preliminary artifact production step
- [ ] enforcement.md includes 7 new investigation completion criteria
- [ ] Handoff contract documented

## Concern Transition

Phase 8 updates brainstorming. Phase 9 updates all 4 downstream SKILL.md files with prose and Trigger Dispatch Table entries.
