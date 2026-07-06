# Phase 03 — write.md Structural Renumbering

**Concern:** Fix write.md structural defects: duplicate labels, 7r ordering, Pre-Step naming, content templates as numbered steps, numbering gaps, and Plan Format Requirements mandate for skill/task routing and full pipeline enumeration.

**Files:**
- `.opencode/skills/spec-creation/tasks/write.md` — all structural changes
- `.opencode/tests/behaviors/` — behavioral test for local-issues sync discipline

**SCs:** SC-8, SC-9, SC-10, SC-11, SC-12, SC-13, SC-14

**Dependencies:** Phase 2 (same skill directory — write.md is a task of spec-creation)

**Entry conditions:** Phase 2 checkpoint committed, feature branch current

**Exit conditions:** All 7 SCs verified PASS

---

- [ ] 20. **Coherence gate (**clean-room**).** Read `.opencode/skills/spec-creation/tasks/write.md`. Confirm all 6 defect categories: duplicate Step 1a/1b, 7r after 7, Pre-Step/Step 0.x naming, content templates as numbered steps, numbering gaps, missing Plan Format Requirements mandate. Report current line numbers. **→ SC-8, SC-9, SC-10, SC-11, SC-12, SC-13**

- [ ] 21. **Pre-red-baseline (**clean-room**).** Run `grep -c "Step 1a" .opencode/skills/spec-creation/tasks/write.md` (expect 2), `grep -c "Pre-Step\|Step 0\." .opencode/skills/spec-creation/tasks/write.md` (expect 4). Record baselines. **→ SC-8, SC-10**

- [ ] 22. **RED: behavioral test (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/write-structural-fixes.sh` that verifies the agent applies local-issues sync discipline (SC-14). Run the test — it MUST FAIL (RED). **→ SC-14**

- [ ] 23. **GREEN: fix duplicate Step 1a/1b (**sub-agent**).** Edit `.opencode/skills/spec-creation/tasks/write.md`. Rename second `Step 1a` (Forward-Looking Mandate) to `Step 1c`. Rename second `Step 1b` (Sub-Folder References) to `Step 1d`. **→ SC-8**

- [ ] 24. **GREEN: fix 7r ordering (**sub-agent**).** Edit `.opencode/skills/spec-creation/tasks/write.md`. Move `Step 7r` (Remote Issue Body Format) before `Step 7` (Create Issue). Renumber `7a`/`7b`/`7c`/`7d` accordingly. **→ SC-9**

- [ ] 25. **GREEN: fix Pre-Step naming (**sub-agent**).** Edit `.opencode/skills/spec-creation/tasks/write.md`. Rename `Pre-Step`, `Pre-Step 0.8`, `Step 0.5`, `Step 0.5a` to a consistent sequential scheme. **→ SC-10**

- [ ] 26. **GREEN: fix content templates (**sub-agent**).** Edit `.opencode/skills/spec-creation/tasks/write.md`. Move Decision Ledger, Risk Traceability, Revision Policy, Decomposition Classification, Spec Family Annotation, Non-Goals, Regression Invariants, and Cross-Cutting SC Designation from numbered steps to sub-bullets under the Assemble Spec step. **→ SC-11**

- [ ] 27. **GREEN: fix numbering gaps (**sub-agent**).** Edit `.opencode/skills/spec-creation/tasks/write.md`. Re-number all step labels to a consistent scheme (no 19a → 20 gaps). **→ SC-8, SC-10**

- [ ] 28. **GREEN: add Plan Format Requirements mandate (**sub-agent**).** Edit `.opencode/skills/spec-creation/tasks/write.md` Plan Format Requirements section. Add mandate: every dispatch step in a plan MUST use `skill({name: "..."})` → `task(..., prompt: "execute <task> from <skill>")` form. Plan steps MUST NOT contain inline procedure text. Add mandate: full implementation pipeline MUST be enumerated (coherence gate, pre-red-baseline, RED/GREEN per item, VbC, adversarial audit, cross-validate, regression check, finishing checklist, review-prep, cleanup) with no skipped or combined steps. **→ SC-12, SC-13**

- [ ] 29. **GREEN doublecheck (**clean-room**).** Verify all 6 structural fixes: `grep -c "Step 1a"` == 1 (SC-8), line number of "Step 7r" < line number of "Step 7: Create Issue" (SC-9), `grep -c "Pre-Step\|Step 0\."` == 0 (SC-10), content templates indented under Step 5 (SC-11), `grep -q "skill({name:"` in Plan Format Requirements (SC-12), `grep -q "coherence gate"` in Plan Format Requirements (SC-13). **→ SC-8, SC-9, SC-10, SC-11, SC-12, SC-13**

- [ ] 30. **Checkpoint commit (**inline**).** Commit: `git add .opencode/skills/spec-creation/tasks/write.md && git commit -m "Phase 3: Fix write.md structural defects and add Plan Format Requirements mandate"`. Create checkpoint tag. **→ SC-8, SC-9, SC-10, SC-11, SC-12, SC-13**

- [ ] 31. **VbC (**clean-room**).** Verify all 7 SCs: SC-8 (no duplicate labels), SC-9 (7r before 7), SC-10 (no Pre-Step), SC-11 (content templates as sub-bullets), SC-12 (skill/task routing mandate), SC-13 (pipeline enumeration mandate), SC-14 (behavioral test passes). **→ SC-8, SC-9, SC-10, SC-11, SC-12, SC-13, SC-14**

#### Phase 03 VbC

- [ ] 31. **VbC (**clean-room**).** Verify: SC-8 (no duplicate Step 1a/1b), SC-9 (7r before 7), SC-10 (no Pre-Step/Step 0.x), SC-11 (content templates as sub-bullets), SC-12 (skill/task routing mandate), SC-13 (pipeline enumeration mandate), SC-14 (local-issues sync behavioral test passes). **→ SC-8, SC-9, SC-10, SC-11, SC-12, SC-13, SC-14**

**Concern transition:** Leaving write.md structural renumbering → entering writing-plans execution model contradiction. Phase 4 is independent — it modifies writing-plans SKILL.md only, not spec-creation files.
