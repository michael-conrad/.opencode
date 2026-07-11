# Phase 01 — Update validate.md REQ-2

**Concern:** Validation specification — rewrite REQ-2 in `validate.md` to specify Agent-Intent as canonical format, replacing the Farmage Description Pattern section.

**Files:**
- `.opencode/skills/skill-creator/tasks/validate.md`

**SCs:** SC-1

**Dependencies:** None

**Entry Criteria:**
- Spec #1883 is approved with `approved-for-pr` label
- Feature branch `spec-fix/skill-description-format-alignment` exists

**Exit Criteria:**
- `validate.md` REQ-2 section rewritten to specify Agent-Intent as canonical
- Farmage Description Pattern section removed
- All references to `Use when`, `Also use when`, `Trigger phrases:` as mandatory elements removed

**Code Path Coverage:** The validate.md file's Phase 2 section (Content and Intent Analysis for Failing Skills) contains the Farmage Description Pattern subsection that must be replaced.

**Cross-Cutting SCs:** None

**Interface Boundaries:** The validate.md task is consumed by the skill-creator validation workflow. Changes to REQ-2 affect how the validation script's output is interpreted by the agent.

**State Transitions:** validate.md transitions from Farmage-mandatory to Agent-Intent-canonical.

## Step-by-step

- [ ] 1.1 (**sub-agent**) Read `validate.md` Phase 2 section — locate the "Farmage Description Pattern (MANDATORY)" subsection (lines 25-42)
  - SC: SC-1
  - Dispatch: `task(..., prompt: "execute write task from writing-plans. Read .opencode/skills/skill-creator/tasks/validate.md first. Locate the 'Farmage Description Pattern (MANDATORY)' subsection in Phase 2. Replace it with an 'Agent-Intent Description Pattern (CANONICAL)' subsection that specifies Agent-Intent as the single canonical format. The new section must document: Dispatch when (primary agent-facing triggers), Also dispatch when (secondary triggers), Invoke for: (optional structural reference), Enforcement statement, — distinct from (exclusion clauses). Remove all references to Use when, Also use when, Trigger phrases: as mandatory elements. Max 1024 characters. See spec #1883 for the canonical format specification.")`
  - Expected: validate.md Phase 2 updated with Agent-Intent canonical format section
  - Evidence: `read` of updated validate.md confirms Farmage section replaced

- [ ] 1.2 (**inline**) Verify REQ-2 update — read updated validate.md and confirm Farmage Description Pattern section is replaced with Agent-Intent section
  - SC: SC-1
  - Command: `read .opencode/skills/skill-creator/tasks/validate.md` — search for "Farmage" and "Agent-Intent"
  - Expected: "Farmage" absent from Phase 2, "Agent-Intent" present with canonical format specification

- [ ] 1.3 (**inline**) Z3 check — verify Phase 1 output satisfies SC-1
  - SC: SC-1
  - Expected: validate.md REQ-2 updated to specify Agent-Intent as canonical

**Phase 01 — Safety/Rollback:**
- Destructive operations: None (text edits only)
- Rollback plan: `git checkout .opencode/skills/skill-creator/tasks/validate.md` to restore original
- Data loss risk: None

**Phase 01 — SC-to-Step Traceability:**

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | `validate.md` REQ-2 updated to specify Agent-Intent as canonical | 1 | 1.1, 1.2 |

**Phase 01 — Feasibility Verification:**

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `.opencode/skills/skill-creator/tasks/validate.md` | ✅ | `read` confirmed file exists with Farmage section at lines 25-42 |

**Phase 01 — Evidence/Provenance:**

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| validate.md has Farmage Description Pattern section | `read` of validate.md lines 25-42 | ✅ |
| validate.md is in skill-creator tasks directory | `read` of file path | ✅ |

**Concern Transition:** Phase 1 completes → Phase 2 begins (validation script logic depends on updated REQ-2 specification)
