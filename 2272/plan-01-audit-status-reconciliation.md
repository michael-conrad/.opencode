# Phase 1 — audit skill status reconciliation

**Concern:** After an implementation audit returns a PASS verdict, the agent checks the ticket's current status and updates it to reflect the verified-complete state if warranted.

**Files:**
- `.opencode/skills/audit/SKILL.md`
- `.opencode/skills/audit/tasks/verification-audit-arbiter.md`

**SCs:** SC-1

**Dependencies:** None

**Entry Conditions:**
- Spec #2272 is approved
- Feature branch exists
- Coherence gate and baseline check passed (pre-implementation steps)
- Pre-regression and pre-regression-verify passed

**Exit Conditions:**
- Audit skill workflow includes a status-check-and-update step after a PASS verdict
- The step reads the ticket's current status and updates it (review/PR-ready label or status transition) when an update is warranted
- SC-1 behavioral test passes

---

- [ ] 5. **RED (**sub-agent**).** Dispatch `task(..., prompt: "execute red task from test-driven-development")` to write a failing behavioral enforcement test asserting the agent checks the ticket's current status and updates it to the verified-complete state after an implementation audit PASS verdict. **→ SC-1**
- [ ] 6. **GREEN (**sub-agent**).** Dispatch `task(..., prompt: "execute green task from test-driven-development")` to add the status-check-and-update step to the audit skill workflow after a PASS verdict. **→ SC-1**
- [ ] 7. **GREEN doublecheck (**clean-room**).** Verify the audit skill workflow now instructs the agent to check the ticket's current status and update it to the verified-complete state when warranted. **→ SC-1**
- [ ] 8. **Post-regression (**sub-agent**).** Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")` to run regression test patterns after the GREEN phase. **→ SC-1**
- [ ] 9. **Verify (**sub-agent**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` to verify the implementation against SC-1. **→ SC-1**
- [ ] 10. **Checkpoint commit (**inline**).** Stage and commit the test and change together as one atomic slice. **→ SC-1**

#### Phase 1 VbC

- [ ] 11. **VbC (**clean-room**).** Verify SC-1 is satisfied: the audit skill workflow checks the ticket's current status and updates it to the verified-complete state after a PASS verdict when warranted. **→ SC-1**

**Concern transition:** Leaving audit skill status reconciliation → entering git-workflow-pr status reconciliation. Phase 2 is independent of Phase 1.
