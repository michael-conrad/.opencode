# Phase 1 — Branch-Finishing Gate Removal

**Concern:** Remove/rewrite the unconditional Sub-Issue Linkage Verification gate in `checklist.md` and the sub-issue closure readiness gates in `operating-protocol.md` so branch finishing NEVER creates or verifies plan-phase sub-issues.

**Files:**
- `.opencode/skills/finishing-a-development-branch/tasks/checklist.md`
- `.opencode/skills/finishing-a-development-branch/tasks/operating-protocol.md`

**SCs:** SC-1, SC-2

**Dependencies:** None

**Entry Conditions:**
- Spec #2283 is approved (issue labeled `approved-for-pr`)
- Feature branch exists on trunk tip (pre-implementation P1 coherence gate, P2 baseline check passed)
- `checklist.md` Sub-Issue Linkage Verification section (line 109-110) still contains the unconditional `link-sub-issue` creation mandate
- `operating-protocol.md` (lines 15, 24) still contains the sub-issue closure readiness gates

**Exit Conditions:**
- `checklist.md` has no `link-sub-issue` creation instruction at branch-finishing time (a no-create rule may replace it)
- `operating-protocol.md` has no "Plan sub-issue closure verification" readiness gate or "Plan sub-issues verified" exit criterion
- All other checklist gates and readiness checks (commit verification, VbC, audit) preserved
- SC-1 and SC-2 string verifications pass

---

- [ ] 1. **RED (**sub-agent**).** Dispatch `task(..., prompt: "execute red task from test-driven-development")` to write a failing content-verification assertion: `grep` `checklist.md` for the `link-sub-issue` creation mandate in the Sub-Issue Linkage Verification section returns a match (the defect is still present). Confirm the assertion fails. **→ SC-1**
- [ ] 2. **GREEN (**sub-agent**).** Dispatch `task(..., prompt: "execute green task from test-driven-development")` to remove or rewrite the Sub-Issue Linkage Verification section in `checklist.md` so it NEVER instructs creating sub-issues for plan phases at branch-finishing time; if sub-issues exist they are read-only references, never created. Preserve all other checklist gates. **→ SC-1**
- [ ] 3. **GREEN doublecheck (**clean-room**).** Verify `checklist.md` no longer contains any `link-sub-issue` creation instruction for plan-phase sub-issues at finishing time and that the other checklist gates remain intact. **→ SC-1**
- [ ] 4. **Post-regression (**sub-agent**).** Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")` to run regression test patterns after the GREEN phase. **→ SC-1**
- [ ] 5. **Verify (**sub-agent**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` to verify the implementation against SC-1 (grep `checklist.md` for `link-sub-issue` → absent or replaced with a no-create rule). **→ SC-1**
- [ ] 6. **Checkpoint commit (**inline**).** Stage `checklist.md` and commit the change as one atomic slice. (No co-author trailer — added at squash time.) **→ SC-1**

---

- [ ] 7. **RED (**sub-agent**).** Dispatch `task(..., prompt: "execute red task from test-driven-development")` to write a failing content-verification assertion: `grep` `operating-protocol.md` for the sub-issue closure verification readiness gate and exit criterion returns a match (the defect is still present). Confirm the assertion fails. **→ SC-2**
- [ ] 8. **GREEN (**sub-agent**).** Dispatch `task(..., prompt: "execute green task from test-driven-development")` to remove the "Plan sub-issue closure verification" readiness gate (item 6) and the "Plan sub-issues verified" exit criterion from `operating-protocol.md`. Preserve all other readiness checks (commit verification, VbC, audit). **→ SC-2**
- [ ] 9. **GREEN doublecheck (**clean-room**).** Verify `operating-protocol.md` no longer requires sub-issue closure verification or "Plan sub-issues verified" as a readiness gate and that the other readiness checks remain intact. **→ SC-2**
- [ ] 10. **Post-regression (**sub-agent**).** Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")` to run regression test patterns after the GREEN phase. **→ SC-2**
- [ ] 11. **Verify (**sub-agent**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` to verify the implementation against SC-2 (grep `operating-protocol.md` for `sub-issue` → absent or replaced). **→ SC-2**
- [ ] 12. **Checkpoint commit (**inline**).** Stage `operating-protocol.md` and commit the change as one atomic slice. (No co-author trailer — added at squash time.) **→ SC-2**

#### Phase 1 VbC

- [ ] 13. **VbC (**clean-room**).** Verify SC-1 and SC-2 are satisfied: `checklist.md` contains no `link-sub-issue` creation mandate at finishing time and `operating-protocol.md` contains no sub-issue closure verification readiness gate; other gates preserved. **→ SC-1, SC-2**

**Concern transition:** Leaving branch-finishing gate removal → entering behavioral enforcement. Phase 2 depends on the SC-1-modified checklist committed in Phase 1.
