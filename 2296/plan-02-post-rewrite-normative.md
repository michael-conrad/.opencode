# Phase 2 — Post-rewrite normative/enforcement

**Concern:** Lock the condensation source and format contracts in the two reference documents and add a structural condensation-format validation gate to skill-creator so future cards inherit the correct pattern.

**Files:**
- `.opencode/skills/skill-creator/SKILL.md`
- `.opencode/skills/skill-creator/scripts/validate_skill_cards.py`
- `.opencode/skills/skill-creator/tasks/validate.md`
- `.opencode/reference/task-card-structure-standards.md`
- `.opencode/reference/skill-card-description-standards.md`

**SCs:** SC-5, SC-6, SC-7

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: all 255 dispatch link `[text]` values are purpose condensations (SC-1)
- Phase 1 VbC passed
- The condensation format (SC-1) and its normative source (SC-6/SC-7) exist to validate against

**Exit Conditions:**
- skill-creator carries the normative condensation-anchor rule and a structural condensation-format validation gate
- `reference/task-card-structure-standards.md` §4 specifies the purpose statement as the dispatch-anchor source
- `reference/skill-card-description-standards.md` specifies the locked condensation dispatch template, consistent with SC-6

---

## Code Path Coverage

- `.opencode/skills/skill-creator/SKILL.md`, `.opencode/skills/skill-creator/scripts/validate_skill_cards.py`, `.opencode/skills/skill-creator/tasks/validate.md` (SC-5)
- `.opencode/reference/task-card-structure-standards.md` (SC-6)
- `.opencode/reference/skill-card-description-standards.md` (SC-7)

## Cross-Cutting SCs

- **Normative source consistency** (SC-6, SC-7, SC-5): the condensation SOURCE (purpose, SC-6) and FORMAT (`<condensation>`, SC-7) must be consistent with the skill-creator validation gate (SC-5).
- **Structural (non-behavioral) enforcement** (SC-5): the validation gate is a structural condensation-format check, NOT a behavioral RED test (spec Notes).

## Interface Boundaries

- **validate_skill_cards.py condensation check** — new, internal only: new structural validation rule; existing validation output format (violation array) preserved.
- **skill-creator SKILL.md / validate.md** — modified, internal only: adds normative condensation rule and gate documentation.
- **task-card-structure-standards.md §4** — modified, internal only: adds purpose-as-dispatch-anchor-source normative spec.
- **skill-card-description-standards.md base prompt template** — modified, internal only: adds locked condensation dispatch template `[<condensation>](<path>)`.

## State Transitions

- **SC-5:** `no condensation validation gate` → `condensation-format gate active on card create/edit` (trigger: SC-5 add gate; invariant: gate is structural, not behavioral; PASS on compliant, FAIL on path-restatement).
- **SC-6:** `§4 no purpose-source spec` → `§4 purpose = dispatch-anchor source (condensable, outcome-subject, distinctive)` (trigger: SC-6 doc update; invariant: consistent with ITEM-7 template).
- **SC-7:** `no locked dispatch template` → `locked template: 'You are a sub-agent. Follow the instructions in [<condensation>](<path>). <context-fields>'` (trigger: SC-7 doc update; invariant: consistent with ITEM-6 purpose-source spec).

---

**Cost frame:** Unit-testing the new condensation-format validation gate costs running validate_skill_cards.py against sample cards. Skipping means the gate ships untested — either too strict (flags valid condensations, blocking legitimate card creation) or too loose (path-restatement passes, letting the dead-weight pattern back in). Correctness is the only success metric — there is no score for tool-call economy.

---

- [ ] 24. **RED (**sub-agent**).** Write a failing unit test asserting that no condensation-format check exists in validate_skill_cards.py. **→ SC-5**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-5, validate_skill_cards.py, no condensation check present
- [ ] 25. **GREEN (**sub-agent**).** Add the normative condensation-anchor rule to skill-creator and a structural condensation-format validation check in validate_skill_cards.py and/or the validate.md workflow. **→ SC-5**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-5, normative rule, structural condensation-format check, gate on card create/edit
- [ ] 26. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the new gate does not break existing validation output. **→ SC-5**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-5, post-GREEN regression
- [ ] 27. **verify (**sub-agent**).** Run validate_skill_cards.py against a sample of rewritten cards; gate PASS on compliant cards, FAIL on path-restatement. **→ SC-5**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-5, positive case (condensation passes), negative case (path-restatement FAILs)
- [ ] 28. **commit-inline (**inline**).** Stage and commit skill-creator/SKILL.md, scripts/validate_skill_cards.py, and tasks/validate.md. **→ SC-5**
  - Command: `git add skill-creator/SKILL.md scripts/validate_skill_cards.py tasks/validate.md && git commit -m "<message>"`
- [ ] 29. **RED (**sub-agent**).** Write a failing structural doc review asserting that `reference/task-card-structure-standards.md` §4 lacks purpose-as-dispatch-anchor-source normative language. **→ SC-6**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-6, task-card-structure-standards.md §4, no purpose-source spec
- [ ] 30. **GREEN (**sub-agent**).** Add to `reference/task-card-structure-standards.md` §4 the normative spec that the purpose statement is the dispatch-anchor source (condensable, outcome-as-subject, distinctive). **→ SC-6**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-6, purpose-as-dispatch-anchor-source, condensable/outcome-subject/distinctive
- [ ] 31. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the §4 update is internally consistent. **→ SC-6**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-6, post-GREEN regression
- [ ] 32. **verify (**sub-agent**).** Run the structural doc review; cross-reference check with the SC-7 template for consistency. **→ SC-6**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-6, §4 purpose-source spec, SC-7 template consistency
- [ ] 33. **commit-inline (**inline**).** Stage and commit `reference/task-card-structure-standards.md`. **→ SC-6**
  - Command: `git add reference/task-card-structure-standards.md && git commit -m "<message>"`
- [ ] 34. **RED (**sub-agent**).** Write a failing structural doc review asserting that the base prompt format in `reference/skill-card-description-standards.md` lacks the locked condensation dispatch template. **→ SC-7**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-7, skill-card-description-standards.md, no locked template
- [ ] 35. **GREEN (**sub-agent**).** Add to `reference/skill-card-description-standards.md` the locked dispatch template: `You are a sub-agent. Follow the instructions in [<condensation>](<path>). <context-fields>`. **→ SC-7**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-7, locked condensation dispatch template
- [ ] 36. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the template update is internally consistent. **→ SC-7**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-7, post-GREEN regression
- [ ] 37. **verify (**sub-agent**).** Run the structural doc review; cross-reference check with the SC-6 purpose-source spec for consistency. **→ SC-7**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-7, locked template present, SC-6 consistency
- [ ] 38. **commit-inline (**inline**).** Stage and commit `reference/skill-card-description-standards.md`. **→ SC-7**
  - Command: `git add reference/skill-card-description-standards.md && git commit -m "<message>"`

#### Phase 2 VbC

- [ ] 39. **VbC (**clean-room**).** Verify all three SCs (SC-5, SC-6, SC-7) pass their structural checks: the condensation-format gate is active and unit-tested (positive/negative); §4 specifies purpose as dispatch-anchor source; the locked template is present and consistent with SC-6. **→ SC-5, SC-6, SC-7**

**Concern transition:** Leaving post-rewrite normative/enforcement → entering post-implementation verification, audit, and PR preparation.

---

## Post-Implementation Steps

- [ ] 40. **audit (**sub-agent**).** Run the adversarial audit of the deliverable via the DiMo 4-role chain (investigator, validator, evaluator, arbiter). **→ all SCs**
  - Dispatch: `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence
  - Context: all SC verdicts, evidence artifacts
- [ ] 41. **z3-check (**inline**).** Run the Z3 constraint solver verification against the dependency contract. **→ all SCs**
  - Command: `.opencode/tools/solve check --state-path ... --contract-path ...`
  - Context: dependency contract, phase DAG
- [ ] 42. **structural-checks (**sub-agent**).** Run the finishing checklist (lint, typecheck, etc.). **→ all SCs**
  - Dispatch: `task(..., prompt: "execute checklist task from finishing-a-development-branch")`
  - Context: all modified files
- [ ] 43. **pre-pr-gate (**sub-agent**).** Verify all SC verdicts; BLOCK if any FAIL. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: all SC verdicts
- [ ] 44. **regression-check (**sub-agent**).** Run the final regression check before PR. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: all SCs, final regression
- [ ] 45. **review-prep (**sub-agent**).** Prepare the PR review context. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`
  - Context: all SCs, PR scope
- [ ] 46. **create-pr (**sub-agent**).** Create the pull request. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute create task from git-workflow-pr")`
  - Context: all SCs, PR scope
- [ ] 47. **exec-summary (**sub-agent**).** Generate the completion executive summary. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute completion task from completion-core")`
  - Context: all SCs, PR status
