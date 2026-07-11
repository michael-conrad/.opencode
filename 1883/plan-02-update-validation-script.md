# Phase 02 — Update validate_skill_cards.py

**Concern:** Validation script logic — update `validate_skill_cards.py` to validate Agent-Intent format, REJECT Farmage format and `User phrases:`/`Trigger phrases:` as mandatory elements, and ensure all 37 existing skills pass.

**Files:**
- `.opencode/skills/skill-creator/scripts/validate_skill_cards.py`

**SCs:** SC-2, SC-3, SC-4

**Dependencies:** Phase 1 (validate.md REQ-2 updated)

**Entry Criteria:**
- Phase 1 complete — validate.md REQ-2 specifies Agent-Intent as canonical

**Exit Criteria:**
- `validate_skill_cards.py` REJECTS Farmage format (`Use when`, `Also use when`, `Trigger phrases:`)
- `User phrases:` removed as mandatory element (no longer required)
- `Invoke for:` remains rejected (old pattern)
- All 37 existing skills pass validation in their current Agent-Intent format
- New skills created via `skill-creator --task init` use Agent-Intent format

**Code Path Coverage:**
- `validate_req1()` — description format checks (lines 141-197)
- `validate_sc_lint_001()` — SC-LINT-001 description format checks (lines 227-275)

**Cross-Cutting SCs:** None

**Interface Boundaries:** The validation script is called by the skill-creator validation workflow. Changes to validation rules affect which skills pass/fail mechanical validation.

**State Transitions:** Validation script transitions from Farmage-accepting to Farmage-rejecting, from User-phrases-mandatory to User-phrases-optional.

## Step-by-step

- [ ] 2.1 (**sub-agent**) Update `validate_req1()` — remove `User phrases:` mandatory check, add `Use when` rejection
  - SC: SC-2
  - Dispatch: `task(..., prompt: "execute write task from writing-plans. Read .opencode/skills/skill-creator/scripts/validate_skill_cards.py first. In validate_req1() (lines 141-197), make these changes: (1) Remove the 'User phrases:' mandatory check (lines 187-197) — User phrases is no longer a required element per spec #1883. (2) Add a check that rejects 'Use when' in descriptions — this is the Farmage pattern that must be rejected. (3) Keep existing checks for 'Invoke for:' rejection, 'Trigger phrases:' rejection, 'Also use when' rejection, and 'Dispatch when' requirement. See spec #1883 for the canonical format specification.")`
  - Expected: validate_req1() updated — User phrases not required, Use when rejected
  - Evidence: `read` of updated function confirms changes

- [ ] 2.2 (**sub-agent**) Update `validate_sc_lint_001()` — remove `User phrases:` mandatory check, add `Use when` rejection
  - SC: SC-2
  - Dispatch: `task(..., prompt: "execute write task from writing-plans. Read .opencode/skills/skill-creator/scripts/validate_skill_cards.py first. In validate_sc_lint_001() (lines 227-275), make these changes: (1) Remove the 'User phrases:' mandatory check (lines 239-247) — User phrases is no longer a required element per spec #1883. (2) Add a check that rejects 'Use when' in descriptions — this is the Farmage pattern. (3) Keep existing checks for 'Invoke for:' rejection, 'Trigger phrases:' rejection, 'Also use when' rejection, and 'Dispatch when' requirement. See spec #1883 for the canonical format specification.")`
  - Expected: validate_sc_lint_001() updated — User phrases not required, Use when rejected
  - Evidence: `read` of updated function confirms changes

- [ ] 2.3 (**inline**) Run validation script — verify all 37 existing skills pass
  - SC: SC-3
  - Command: `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py`
  - Expected: exit code 0, all skills pass
  - On FAIL: inspect output, identify which skills fail, remediate (but per spec #1883, all 37 existing skills already use Agent-Intent format and should pass without changes)

- [ ] 2.4 (**inline**) Verify Farmage format rejection — run validation with a test Farmage-format description
  - SC: SC-2
  - Command: Create a temp file with Farmage-format description (`Use when ... Also use when ... Trigger phrases: ...`), run validation, confirm it is REJECTED
  - Expected: validation reports violations for Farmage pattern elements

- [ ] 2.5 (**inline**) Z3 check — verify Phase 2 output satisfies SC-2, SC-3, SC-4
  - SC: SC-2, SC-3, SC-4
  - Expected: validation script rejects Farmage, passes all 37 existing skills, and Agent-Intent format is enforced for new skills

**Phase 02 — Safety/Rollback:**
- Destructive operations: None (text edits only)
- Rollback plan: `git checkout .opencode/skills/skill-creator/scripts/validate_skill_cards.py` to restore original
- Data loss risk: None

**Phase 02 — SC-to-Step Traceability:**

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-2 | Validation script REJECTS Farmage format and `User phrases:`/`Trigger phrases:` as mandatory elements | 2 | 2.1, 2.2, 2.4 |
| SC-3 | All 37 existing skills pass validation in current Agent-Intent format | 2 | 2.3 |
| SC-4 | New skills created via `skill-creator --task init` use Agent-Intent format | 2 | 2.1, 2.2 |

**Phase 02 — Feasibility Verification:**

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 2.1 | `validate_req1()` at lines 141-197 | ✅ | `read` confirmed function exists |
| 2.2 | `validate_sc_lint_001()` at lines 227-275 | ✅ | `read` confirmed function exists |
| 2.3 | All 37 skill SKILL.md files | ✅ | `discover_skill_cards()` returns all cards |

**Phase 02 — Evidence/Provenance:**

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| validate_req1() has User phrases mandatory check at lines 187-197 | `read` of validate_skill_cards.py | ✅ |
| validate_sc_lint_001() has User phrases mandatory check at lines 239-247 | `read` of validate_skill_cards.py | ✅ |
| All 37 skills use Agent-Intent format | Spec #1883 states this | ✅ |

**Concern Transition:** Phase 2 completes → Phase 3 begins (template update depends on validation rules being finalized)
