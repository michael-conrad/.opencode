# Phase 3 — Add Workflows Section to git-workflow-pr SKILL.md, Fix Description

**Concern:** Replace the Trigger Dispatch Table and DISPATCH_GATE with a Workflows section containing 5 separate workflows, each starting with an orchestrator inline authorization scope check. Fix the description field to use agent-intent format.

**Files:**
- `.opencode/skills/git-workflow-pr/SKILL.md`

**SCs:** SC-16, SC-17, SC-18, SC-19

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: skill deleted, closing-keywords.md moved, auth check added
- Phase 2 VbC passed

**Exit Conditions:**
- SKILL.md has `## Workflows` section replacing `## Trigger Dispatch Table` and DISPATCH_GATE
- Workflows section contains 5 separate workflows: Create PR, Prepare review, Create pair mode PR, Post-implementation, Complete workflow
- Each workflow starts with orchestrator inline authorization scope check (no task() call)
- Description field uses agent-intent format — no "Load via skill() when", "Also load when", or "User phrases:" patterns

**Cost frame:** Implementation cost is measured in defect-discovery latency, not tool-call count. Rewriting the SKILL.md with Workflows section costs ~5 structural edits — each edit is a discovery point where a missing workflow or wrong section format would be caught. Skipping any SC costs a broken dispatch table that silently routes to the wrong workflow. Correctness is the only success metric — there is no score for speed.

---

### Item 16 — SC-16: Workflows section replaces Trigger Dispatch Table

- [ ] 90. **RED (**sub-agent**).** Write a failing enforcement test asserting the SKILL.md has `## Workflows` and does NOT have `## Trigger Dispatch Table`. **→ SC-16**
- [ ] 91. **GREEN (**sub-agent**).** Replace the Trigger Dispatch Table and DISPATCH_GATE sections with a `## Workflows` section. **→ SC-16**
- [ ] 92. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 93. **Verify (**clean-room**).** Verify `## Workflows` is present and `## Trigger Dispatch Table` is absent. **→ SC-16**
- [ ] 94. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/SKILL.md && git commit -m "Phase 3 Item 16: Replace Trigger Dispatch Table with Workflows section"`

### Item 17 — SC-17: Workflows section contains 5 separate workflows

- [ ] 95. **RED (**sub-agent**).** Write a failing enforcement test asserting the Workflows section contains all 5 workflow headings: Create PR, Prepare review, Create pair mode PR, Post-implementation, Complete workflow. **→ SC-17**
- [ ] 96. **GREEN (**sub-agent**).** Add all 5 workflow headings to the Workflows section. **→ SC-17**
- [ ] 97. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 98. **Verify (**clean-room**).** Verify all 5 workflow headings are present. **→ SC-17**
- [ ] 99. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/SKILL.md && git commit -m "Phase 3 Item 17: Add 5 workflow headings to Workflows section"`

### Item 18 — SC-18: Each workflow starts with orchestrator inline auth check

- [ ] 100. **RED (**sub-agent**).** Write a failing enforcement test asserting each workflow starts with "orchestrator inline" authorization scope check. **→ SC-18**
- [ ] 101. **GREEN (**sub-agent**).** Add orchestrator inline authorization scope check as the first step of each workflow. **→ SC-18**
- [ ] 102. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 103. **Verify (**clean-room**).** Verify "orchestrator inline" appears after each workflow heading. **→ SC-18**
- [ ] 104. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/SKILL.md && git commit -m "Phase 3 Item 18: Add orchestrator inline auth check to each workflow"`

### Item 19 — SC-19: git-workflow-pr description uses agent-intent format

- [ ] 105. **RED (**sub-agent**).** Write a failing enforcement test asserting the description field does NOT contain "Load via skill() when", "Also load when", or "User phrases:" patterns. **→ SC-19**
- [ ] 106. **GREEN (**sub-agent**).** Rewrite the description field to use agent-intent format. **→ SC-19**
- [ ] 107. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 108. **Verify (**clean-room**).** Verify the description field is free of prohibited patterns. **→ SC-19**
- [ ] 109. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/SKILL.md && git commit -m "Phase 3 Item 19: Fix description to use agent-intent format"`

#### Phase 3 VbC

- [ ] 110. **VbC (**clean-room**).** Verify all 4 SCs in Phase 3 (SC-16, SC-17, SC-18, SC-19) pass with correct evidence types. **→ SC-16, SC-17, SC-18, SC-19**

**Concern transition:** Leaving Workflows section creation → entering PR body audit task creation. Phase 4 depends on Phase 1's template existing for the audit to verify against.
