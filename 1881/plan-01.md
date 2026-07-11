# Phase 1 — Validate and Update (Pre-Flight)

**Concern:** Shared infrastructure required by all 5 skill splits

**Files:**
- `.opencode/skills/skill-creator/tasks/validate.md` — Agent-Intent Pattern update
- `.opencode/reference/dispatcher-template.md` — New shared template
- `.opencode/guidelines/INDEX.md` — Add dispatcher-template reference

**SCs:** SC-1 (validate.md accepts Agent-Intent Pattern descriptions)

**Dependencies:** None

**Entry conditions:**
- Feature branch `feature/1881-skill-split-plan` exists
- Global pre-steps (coherence gate, baseline, branch verification) complete

**Exit conditions:**
- skill-creator validation accepts Agent-Intent Pattern descriptions (≤1024 chars, canonical template)
- dispatcher-template.md exists with shared boilerplate sections
- INDEX.md references dispatcher-template.md

**Code Path Coverage:**
- skill-creator: validate.md validation logic
- No application source code modified

**Cross-Cutting SCs:** SC-1 (first SC — shared infrastructure)

**Interface Boundaries:**
- Dispatcher template must be generic enough for all 5 parent skills
- Agent-Intent Pattern applies to sub-skill descriptions only (not parent dispatchers)

**State Transitions:**
- `validate.md` before: accepts full 591-898 char template → after: also accepts ≤1024 char Agent-Intent Pattern
- `dispatcher-template.md` before: doesn't exist → after: exists with shared sections

---

- [ ] 4. **Global pre-step: Coherence gate (**clean-room**).** Dispatch clean-room sub-agent to verify spec integrity: all 8 SCs present, no contradictory requirements, phase ordering matches dependency DAG. **→ SC-ALL**
- [ ] 5. **Global pre-step: Pre-RED baseline (**inline**).** Capture `git status`, `git diff --stat`, `git log --oneline -5`. Record baseline SHA. **→ SC-ALL**
- [ ] 6. **Global pre-step: Verify feature branch (**inline**).** Confirm branch `feature/1881-skill-split-plan` exists and is based on `main`. **→ SC-ALL**

- [ ] 7. **RED: Write behavioral test for Agent-Intent Pattern validation (**sub-agent**).** Write behavioral test that sends a sub-agent prompt to create a sub-skill description. Assert via `assert_semantic` that the description follows Agent-Intent Pattern (≤1024 chars, canonical template). Test must FAIL before validation fix. **→ SC-1**
- [ ] 8. **GREEN: Update skill-creator validate.md (**sub-agent**).** Update `.opencode/skills/skill-creator/tasks/validate.md` to accept Agent-Intent Pattern descriptions. Add validation rules: ≤1024 character limit, canonical template sections (description, key behaviors, usage). **→ SC-1**
- [ ] 9. **GREEN: Create dispatcher template (**sub-agent**).** Create `.opencode/reference/dispatcher-template.md` with shared boilerplate sections: Worktree Mode notice, Mandatory Task Discipline notice, DISPATCH_GATE protocol stub, Trigger Dispatch Table skeleton, Sub-Agent Routing skeleton. **→ SC-1**
- [ ] 10. **GREEN: Update INDEX.md reference (**sub-agent**).** Add `dispatcher-template` entry to `.opencode/guidelines/INDEX.md` with trigger pattern and load-when guidance. **→ SC-1**
- [ ] 11. **GREEN doublecheck: Verify Phase 1 output (**sub-agent**).** Confirm validate.md updated, dispatcher-template.md exists, INDEX.md has new entry. Re-run Phase 1 RED test — must PASS. **→ SC-1**
- [ ] 12. **Checkpoint commit (**inline**).** `git add .opencode/skills/skill-creator/ .opencode/reference/ .opencode/guidelines/INDEX.md .opencode/tests/behaviors/ && git commit -m "Phase 1: Fix skill-creator validation and create dispatcher template"` **→ SC-1**

#### Phase 1 VbC

- [ ] 13. **VbC (**clean-room**).** Verify: (1) validate.md accepts Agent-Intent Pattern, (2) dispatcher-template.md exists with shared sections, (3) INDEX.md updated, (4) RED test PASSes. **→ SC-1**

**Concern transition:** Leaving shared infrastructure → entering issue-operations split. Phase 2 depends on Phase 1 (dispatcher template exists, validate.md accepts sub-skill descriptions).
