# Phase 7 — Condensation-format validation gate

**Concern:** Add a structural condensation-format validation gate to skill-creator.

**Files:**
- `.opencode/skills/skill-creator/SKILL.md`
- `.opencode/skills/skill-creator/scripts/validate_skill_cards.py`
- `.opencode/skills/skill-creator/tasks/validate.md`

**SCs:** SC-5

**Dependencies:** Phase 2, Phase 5, Phase 6

**Entry Conditions:**
- Phase 2 complete: all 255 dispatch link `[text]` values are purpose condensations (SC-1)
- Phase 5 complete: `reference/task-card-structure-standards.md` §4 specifies the purpose statement as the dispatch-anchor source (SC-6)
- Phase 6 complete: `reference/skill-card-description-standards.md` specifies the locked condensation dispatch template (SC-7)
- The condensation format (SC-1) and its normative source (SC-6/SC-7) exist to validate against

**Exit Conditions:**
- skill-creator carries the normative condensation-anchor rule and a structural condensation-format validation gate on card create/edit

---

## Code Path Coverage

- `.opencode/skills/skill-creator/SKILL.md`, `.opencode/skills/skill-creator/scripts/validate_skill_cards.py`, `.opencode/skills/skill-creator/tasks/validate.md` (SC-5)

## Cross-Cutting SCs

- **Normative source consistency** (SC-6, SC-7, SC-5): the condensation SOURCE (purpose, SC-6) and FORMAT (`<condensation>`, SC-7) must be consistent with the skill-creator validation gate (SC-5).
- **Structural (non-behavioral) enforcement** (SC-5): the validation gate is a structural condensation-format check, NOT a behavioral RED test (spec Notes).

## Interface Boundaries

- **validate_skill_cards.py condensation check** — new, internal only: new structural validation rule; existing validation output format (violation array) preserved.
- **skill-creator SKILL.md / validate.md** — modified, internal only: adds normative condensation rule and gate documentation.

## State Transitions

- **SC-5:** `no condensation validation gate` → `condensation-format gate active on card create/edit` (trigger: SC-5 add gate; invariant: gate is structural, not behavioral; PASS on compliant, FAIL on path-restatement).

---

**Cost frame:** Unit-testing the new condensation-format validation gate costs running validate_skill_cards.py against sample cards. Skipping means the gate ships untested — either too strict (flags valid condensations, blocking legitimate card creation) or too loose (path-restatement passes, letting the dead-weight pattern back in). Correctness is the only success metric — there is no score for tool-call economy.

---

- [ ] 39. **RED (**sub-agent**).** Write a failing unit test asserting that no condensation-format check exists in validate_skill_cards.py. **→ SC-5**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-5, validate_skill_cards.py, no condensation check present
- [ ] 40. **GREEN (**sub-agent**).** Add the normative condensation-anchor rule to skill-creator and a structural condensation-format validation check in validate_skill_cards.py and/or the validate.md workflow. **→ SC-5**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-5, normative rule, structural condensation-format check, gate on card create/edit
- [ ] 41. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the new gate does not break existing validation output. **→ SC-5**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-5, post-GREEN regression
- [ ] 42. **verify (**sub-agent**).** Run validate_skill_cards.py against a sample of rewritten cards; gate PASS on compliant cards, FAIL on path-restatement. **→ SC-5**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-5, positive case (condensation passes), negative case (path-restatement FAILs)
- [ ] 43. **commit-inline (**inline**).** Stage and commit skill-creator/SKILL.md, scripts/validate_skill_cards.py, and tasks/validate.md. **→ SC-5**
  - Command: `git add skill-creator/SKILL.md scripts/validate_skill_cards.py tasks/validate.md && git commit -m "<message>"`

#### Phase 7 VbC

- [ ] 44. **VbC (**clean-room**).** Verify SC-5 passes its structural check: the condensation-format gate is active and unit-tested (positive/negative). **→ SC-5**

**Concern transition:** Leaving condensation-format validation gate → entering post-implementation verification, audit, and PR preparation.
