# Phase 03 — Update routing-only-template.md

**Concern:** Canonical template — update `routing-only-template.md` to show Agent-Intent as canonical format, removing `User phrases:` as a mandatory element.

**Files:**
- `.opencode/skills/skill-creator/reference/routing-only-template.md`

**SCs:** SC-5

**Dependencies:** Phase 2 (validation script updated)

**Entry Criteria:**
- Phase 2 complete — validation script enforces Agent-Intent format

**Exit Criteria:**
- `routing-only-template.md` template description example updated to Agent-Intent format
- `User phrases:` removed as mandatory element in the description format specification
- Template shows `Dispatch when`, `Also dispatch when`, `Invoke for:` (optional), enforcement statement, `— distinct from`

**Code Path Coverage:** The template's description format section (lines 18-27) specifies the description format with `User phrases:` as mandatory.

**Cross-Cutting SCs:** None

**Interface Boundaries:** The routing-only-template.md is the single source of truth for skill card structure. Changes to the description format affect all new skills created via `skill-creator --task init`.

**State Transitions:** Template transitions from Farmage-influenced (User phrases mandatory) to pure Agent-Intent (User phrases removed, Invoke for optional).

## Step-by-step

- [ ] 3.1 (**sub-agent**) Update template description format — replace with Agent-Intent canonical format
  - SC: SC-5
  - Dispatch: `task(..., prompt: "execute write task from writing-plans. Read .opencode/skills/skill-creator/reference/routing-only-template.md first. In the template section (lines 15-30), update the description format specification: (1) Remove 'User phrases:' as a mandatory element from the description format. (2) Update the format to show Agent-Intent as canonical: 'Dispatch when' (primary triggers), 'Also dispatch when' (secondary triggers), 'Invoke for:' (optional structural reference), enforcement statement, '— distinct from' (exclusion clauses). (3) Update the bullet list below the description format to match — remove the 'User phrases:' bullet. (4) Keep 'Dispatch when' and 'Also dispatch when' as the primary elements. See spec #1883 for the canonical format specification.")`
  - Expected: routing-only-template.md description format updated to Agent-Intent canonical
  - Evidence: `read` of updated template confirms changes

- [ ] 3.2 (**inline**) Verify template update — read updated template and confirm Agent-Intent format
  - SC: SC-5
  - Command: `read .opencode/skills/skill-creator/reference/routing-only-template.md`
  - Expected: description format shows Agent-Intent canonical, no `User phrases:` as mandatory element

- [ ] 3.3 (**inline**) Z3 check — verify Phase 3 output satisfies SC-5
  - SC: SC-5
  - Expected: routing-only-template.md updated to show Agent-Intent as canonical

**Phase 03 — Safety/Rollback:**
- Destructive operations: None (text edits only)
- Rollback plan: `git checkout .opencode/skills/skill-creator/reference/routing-only-template.md` to restore original
- Data loss risk: None

**Phase 03 — SC-to-Step Traceability:**

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-5 | `routing-only-template.md` updated to show Agent-Intent as canonical | 3 | 3.1, 3.2 |

**Phase 03 — Feasibility Verification:**

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 3.1 | Template description format at lines 18-27 | ✅ | `read` confirmed section exists |

**Phase 03 — Evidence/Provenance:**

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| Template has User phrases as mandatory in description format | `read` of routing-only-template.md lines 18-27 | ✅ |

**Concern Transition:** Phase 3 completes → all plan phases complete → proceed to completion
