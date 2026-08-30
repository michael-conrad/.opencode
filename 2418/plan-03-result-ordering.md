# Phase 3 — RESULT_ORDERING

**Concern:** Reinforce submodule-first ordering in result contract reporting sections of `cleanup.md`.

**Files:**
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md`

**SCs:** SC-3

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: guard note added to cleanup.md
- Phase 2 VbC passed
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` exists and is readable

**Exit Conditions:**
- Cleanup sub-agent's result contract reports submodules before parent repo
- All submodule entries precede parent entries in the relevant sections

---

**Cost frame:** This phase modifies a single file (cleanup.md) with structural ordering changes. The change is confined to result contract reporting sections and verified by inspecting the task card — submodule entries must precede parent entries. One sub-agent dispatch per daisy-chain step is sufficient.

- [ ] 17. **Pre-regression (**sub-agent**).** Run regression test patterns before RED phase. **→ SC-3**
- [ ] 18. **Pre-regression verify (**clean-room**).** Verify pre-regression results. **→ SC-3**

- [ ] 19. **RED (**sub-agent**).** Write a failing enforcement test asserting cleanup.md result contract sections list submodules before parent repo. **→ SC-3**
- [ ] 20. **GREEN (**sub-agent**).** Reorder result contract reporting sections in cleanup.md so submodule entries precede parent entries. **→ SC-3**
- [ ] 21. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ SC-3**
- [ ] 22. **Verify (**clean-room**).** Verify SC-3: inspect cleanup.md task card — submodule entries precede parent entries in result contract sections. **→ SC-3**
- [ ] 23. **Commit (**inline**).** `git add .opencode/skills/git-workflow-cleanup/tasks/cleanup.md && git commit -m "Phase 3: reinforce submodule-first ordering in result contract"`. **→ SC-3**

#### Phase 3 VbC

- [ ] 24. **VbC (**clean-room**).** Verify SC-3: inspect cleanup.md — submodule entries precede parent entries in all result contract reporting sections. **→ SC-3**

---

## Post-Implementation

- [ ] 25. **Audit (**sub-agent**).** Adversarial audit of all phase deliverables. **→ All SCs**
- [ ] 26. **Structural checks (**sub-agent**).** Run finishing checklist (lint, typecheck, enforcement tests). **→ All SCs**
- [ ] 27. **Pre-PR gate (**clean-room**).** Verify all SC verdicts — BLOCK if any FAIL. **→ All SCs**
- [ ] 28. **Regression check (**sub-agent**).** Final regression check before PR. **→ All SCs**
- [ ] 29. **Review prep (**sub-agent**).** Prepare PR review context. **→ All SCs**
- [ ] 30. **Create PR (**sub-agent**).** Create the pull request. **→ All SCs**
- [ ] 31. **Executive summary (**sub-agent**).** Generate completion executive summary. **→ All SCs**
