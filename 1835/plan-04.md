# Phase 4 — Part A3+A4: Pipeline Ordering + SKILL.md Metadata

**Concern:** Fix operating-protocol.md pipeline ordering and spec-creation SKILL.md metadata

**Files:**
- `.opencode/skills/spec-creation/tasks/operating-protocol.md` (MODIFY)
- `.opencode/skills/spec-creation/SKILL.md` (MODIFY)

**SCs:** SC-14, SC-15, SC-16, SC-17, SC-18, SC-19, SC-20

**Dependencies:** Phase 3

**Entry Criteria:** Phase 3 complete, all task files exist and are deepened

**Exit Criteria:** operating-protocol.md has correct pipeline ordering with no numbering gaps; SKILL.md has no duplicate trigger entries and includes all 7 new tasks

## Step-by-Step

- [ ] 19. (**sub-agent**) Update `operating-protocol.md` — Insert new analytical tasks at correct pipeline positions:
    - `concern-analysis` after `requirements`, before `decompose`
    - `blast-radius` after `decompose`, before `traceability`
    - `cross-cutting` after `decompose`, before `traceability`
    - `code-path-analysis` after `traceability`, before `pipeline-readiness-gate`
    - `interface-compatibility` after `decompose`, before `pipeline-readiness-gate`
    - `state-analysis` after `decompose`, before `pipeline-readiness-gate`
    - `testability-assessment` after `pipeline-readiness-gate`, before `risk`
  - SC: SC-14

- [ ] 20. (**sub-agent**) Fix `operating-protocol.md` step numbering — Fix the numbering gap (step 5 is missing — steps go 1, 2, 3, 4, 4.5, 6, 7, 8, 9, 10, 11, 12, 13). Ensure globally sequential numbering with no gaps.
  - SC: SC-15

- [ ] 21. (**sub-agent**) Fix `spec-creation/SKILL.md` — Remove duplicate "create spec" entries in Trigger Dispatch Table (rows 1 and 7 both map to `create`)
  - SC: SC-16

- [ ] 22. (**sub-agent**) Add trigger entries to `spec-creation/SKILL.md` Trigger Dispatch Table for all 7 new analytical tasks
  - SC: SC-17

- [ ] 23. (**sub-agent**) Add all 7 new analytical tasks to `spec-creation/SKILL.md` Tasks table
  - SC: SC-18

- [ ] 24. (**sub-agent**) Add all 7 new analytical tasks to `spec-creation/SKILL.md` Invocation dispatch table
  - SC: SC-19

- [ ] 25. (**sub-agent**) Add prose enforcement to `spec-creation/SKILL.md` Overview and Mandatory Task Discipline: the pipeline now includes analytical discovery tasks that MUST complete before structural validation. Skipping analytical tasks produces structurally valid but analytically shallow specs.
  - SC: SC-20

## Phase Completion

- [ ] operating-protocol.md has correct pipeline ordering with no numbering gaps
- [ ] SKILL.md has no duplicate trigger entries
- [ ] SKILL.md includes all 7 new tasks in Trigger Dispatch Table, Tasks table, and Invocation table
- [ ] SKILL.md Overview and Mandatory Task Discipline include analytical discovery enforcement prose

## Concern Transition

Phase 4 fixes the spec-creation internals. Phase 5 updates the spec-audit downstream consumer.
