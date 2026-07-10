# Phase 3 — Part A2: Deepen 6 Existing Task Files

**Concern:** Deepen existing spec-creation task files with additional analytical methodology

**Files:**
- `.opencode/skills/spec-creation/tasks/requirements.md` (MODIFY)
- `.opencode/skills/spec-creation/tasks/decompose.md` (MODIFY)
- `.opencode/skills/spec-creation/tasks/risk.md` (MODIFY)
- `.opencode/skills/spec-creation/tasks/pipeline-readiness-gate.md` (MODIFY)
- `.opencode/skills/spec-creation/tasks/traceability.md` (MODIFY)
- `.opencode/skills/spec-creation/tasks/change-control.md` (MODIFY)

**SCs:** SC-8, SC-9, SC-10, SC-11, SC-12, SC-13

**Dependencies:** Phase 2

**Entry Criteria:** Phase 2 complete, all 7 new task files exist

**Exit Criteria:** All 6 existing task files include spec-required additions

## Step-by-Step

- [ ] 13. (**sub-agent**) Deepen `requirements.md` — Add adversarial verification of extracted requirements against the codebase, structured output format, explicit non-requirements documentation
  - Read current file first, then append/modify
  - SC: SC-8

- [ ] 14. (**sub-agent**) Deepen `decompose.md` — Add decomposition-depth mandate: "Decompose until each unit is a single independently verifiable claim whose PASS/FAIL cannot be split across two assertions." Add explicit stopping criterion. Add reference to incremental-build discipline.
  - SC: SC-9

- [ ] 15. (**sub-agent**) Deepen `risk.md` — Add concurrency/race condition analysis methodology, backward compatibility impact analysis, security threat modeling (attack surface analysis, trust boundary mapping)
  - SC: SC-10

- [ ] 16. (**sub-agent**) Deepen `pipeline-readiness-gate.md` — Add semantic single-concern check (not just file category + verification domain — verify the SC's actual problem domain is singular). Add decomposition-depth validation.
  - SC: SC-11

- [ ] 17. (**sub-agent**) Deepen `traceability.md` — Add code-path-to-test mapping: for each identified code path, verify at least one SC exercises it
  - SC: SC-12

- [ ] 18. (**sub-agent**) Deepen `change-control.md` — Add code-level backward compatibility impact analysis: when a spec changes an API signature, config key, or data format, assess what existing consumers would break
  - SC: SC-13

## Phase Completion

- [ ] All 6 existing task files updated with spec-required additions
- [ ] No existing analytical capability removed (SC-22 baseline verified)

## Concern Transition

Phase 3 deepens existing files. Phase 4 fixes pipeline ordering in operating-protocol.md and updates SKILL.md metadata.
