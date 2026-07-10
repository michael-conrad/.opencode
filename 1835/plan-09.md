# Phase 9 — Part C1-C4: SKILL.md Prose + Trigger Dispatch Table Updates

**Concern:** Update all 4 downstream SKILL.md files with analytical artifact enforcement prose and Trigger Dispatch Table entries

**Files:**
- `.opencode/skills/audit/SKILL.md` (MODIFY)
- `.opencode/skills/writing-plans/SKILL.md` (MODIFY)
- `.opencode/skills/verification-before-completion/SKILL.md` (MODIFY)
- `.opencode/skills/brainstorming/SKILL.md` (MODIFY)

**SCs:** SC-40, SC-41, SC-42, SC-43, SC-44, SC-45, SC-46, SC-47, SC-48, SC-49, SC-50, SC-51, SC-52

**Dependencies:** Phase 8

**Entry Criteria:** Phase 8 complete, all task files updated

**Exit Criteria:** All 4 SKILL.md files have updated Overview, Mandatory Task Discipline, and Trigger Dispatch Table with analytical artifact entries. No YAML symbolic rules added.

## Step-by-Step

- [ ] 44. (**sub-agent**) Update `audit/SKILL.md` Overview — Add paragraph stating that spec-audit now validates analytical artifacts (blast radius, concern map, code path inventory, cross-cutting matrix, interface compatibility, state analysis, testability assessment). Missing artifacts produce warning; stale artifacts produce HALT.
  - SC: SC-40

- [ ] 45. (**sub-agent**) Update `audit/SKILL.md` Mandatory Task Discipline — Add item requiring analytical artifact validation before any audit task that depends on them. Spec-audit requires all 7 artifacts; concern-separation requires concern-map; plan-fidelity requires interface-compatibility; verification-audit requires code-path-inventory; cross-validate requires cross-cutting-matrix; coherence-maintenance requires state-analysis; test-quality-audit requires testability-assessment.
  - SC: SC-41

- [ ] 46. (**sub-agent**) Update `audit/SKILL.md` Trigger Dispatch Table — Add 9 new entries for analytical artifact presence/absence (7 artifact-specific HALT entries, 1 "all artifacts ready" → spec-audit, 1 "stale artifacts" → HALT)
  - SC: SC-42

- [ ] 47. (**sub-agent**) Update `writing-plans/SKILL.md` Overview — Add paragraph stating that plan creation now consumes analytical artifacts from spec-creation. Phase structure, file scope, and test strategy derived from artifacts.
  - SC: SC-43

- [ ] 48. (**sub-agent**) Update `writing-plans/SKILL.md` Mandatory Task Discipline — Add item requiring analytical artifact validation before plan creation. All 7 artifacts must be present and non-empty. Missing artifacts produce BLOCKED with `MISSING_SPEC_ARTIFACT`.
  - SC: SC-44

- [ ] 49. (**sub-agent**) Update `writing-plans/SKILL.md` Trigger Dispatch Table — Add 7 new entries for analytical artifact presence/absence
  - SC: SC-45

- [ ] 50. (**sub-agent**) Update `verification-before-completion/SKILL.md` Overview — Add paragraph stating that VbC now cross-references analytical artifacts against implementation evidence before allowing completion claims.
  - SC: SC-46

- [ ] 51. (**sub-agent**) Update `verification-before-completion/SKILL.md` Mandatory Task Discipline — Add item requiring analytical artifact cross-reference before completion claim. Contradictions produce HALT. Unverified artifacts produce HALT.
  - SC: SC-47

- [ ] 52. (**sub-agent**) Update `verification-before-completion/SKILL.md` Trigger Dispatch Table — Add 7 new entries for analytical artifact presence/absence
  - SC: SC-48

- [ ] 53. (**sub-agent**) Update `brainstorming/SKILL.md` Overview — Add paragraph stating that brainstorming now produces preliminary analytical artifacts before handing off to spec-creation.
  - SC: SC-49

- [ ] 54. (**sub-agent**) Update `brainstorming/SKILL.md` Mandatory Task Discipline — Add item requiring preliminary analytical artifact production before spec-creation handoff. Artifact requirements are conditional per spec.
  - SC: SC-50

- [ ] 55. (**sub-agent**) Update `brainstorming/SKILL.md` Trigger Dispatch Table — Add 9 new entries for analytical artifact presence/absence
  - SC: SC-51

## Phase Completion

- [ ] All 4 SKILL.md files have updated Overview prose
- [ ] All 4 SKILL.md files have updated Mandatory Task Discipline
- [ ] All 4 SKILL.md files have updated Trigger Dispatch Table
- [ ] No YAML symbolic rules added to any SKILL.md (SC-52)

## Concern Transition

Phase 9 completes all implementation phases. Phase 10 runs the global post-phase: audit, cross-validate, review prep, and completion.
