# Phase 2 — Six rules

**Concern:** Write the six rules (SC-2 through SC-7) into `130-authority-source.md`, each building on the dual-authority principle.

**Files:**
- `.opencode/guidelines/130-authority-source.md`

**SCs:** SC-2, SC-3, SC-4, SC-5, SC-6, SC-7

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: dual-authority principle present
- Phase 1 VbC passed

**Exit Conditions:**
- All six rules are present with the required content assertions per SC
- No forbidden exception phrases in Rule 2 (SC-3)

**Cost frame:** Verifying each rule's content elements costs one clean-room sub-agent read of one file — minutes of bounded delay. Skipping lets the intent/state distinction erode silently, weakens the spec-before-code mandate, or leaves plan-approval revocation unstated — each discovered at review 10x-100x later.

---

- [ ] 6. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Clean-room sub-agent reads `130-authority-source.md` and fails at least one of the three Rule 1 content assertions — content absent pre-change. **→ SC-2**
- [ ] 7. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Write Rule 1 (Spec for intent, code for state) with all three content elements: the phrase `spec is authoritative for intent`, the phrase `code is authoritative for current state`, and a statement that when spec and code diverge on matters of fact, the spec is updated to match reality. **→ SC-2**
- [ ] 8. **GREEN doublecheck (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Verify all three Rule 1 content elements per SC-2 verification method. **→ SC-2**
- [ ] 9. **Checkpoint commit (**inline**).** Stage and commit `.opencode/guidelines/130-authority-source.md` (Rule 1).

- [ ] 10. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Confirm `every code change requires an approved spec` is absent, or any of the forbidden exception phrases (`unless`, `except when`, `may be skipped`, `optionally`) is present. **→ SC-3**
- [ ] 11. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Write Rule 2 (Spec before code) stating the mandate `every code change requires an approved spec` without exception phrases. **→ SC-3**
- [ ] 12. **GREEN doublecheck (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Verify the phrase is present and grep for absence of `unless`, `except when`, `may be skipped`, `optionally` in the rule's section per SC-3 verification method. **→ SC-3**
- [ ] 13. **Checkpoint commit (**inline**).** Stage and commit `.opencode/guidelines/130-authority-source.md` (Rule 2).

- [ ] 14. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Confirm the phrase `Documentation Drift Protocol` is absent from `130-authority-source.md`. **→ SC-4**
- [ ] 15. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Write Rule 3 (Documentation Drift Protocol) with the administrative-sync statement: updating the spec to match code state is an administrative sync, not a code change. **→ SC-4**
- [ ] 16. **GREEN doublecheck (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Verify the phrase `Documentation Drift Protocol` is present and the administrative-sync statement is present per SC-4 verification method. **→ SC-4**
- [ ] 17. **Checkpoint commit (**inline**).** Stage and commit `.opencode/guidelines/130-authority-source.md` (Rule 3).

- [ ] 18. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Confirm the phrase `spec revision revokes plan approval` is absent from `130-authority-source.md`. **→ SC-5**
- [ ] 19. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Write Rule 4 (Spec revision revokes plan approval) with the approval-gate-006 reference. **→ SC-5**
- [ ] 20. **GREEN doublecheck (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Verify the phrase `spec revision revokes plan approval` is present and the approval-gate-006 reference is present per SC-5 verification method. **→ SC-5**
- [ ] 21. **Checkpoint commit (**inline**).** Stage and commit `.opencode/guidelines/130-authority-source.md` (Rule 4).

- [ ] 22. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Confirm the phrase `Suppression of Reactive Remediation` is absent from `130-authority-source.md`. **→ SC-6**
- [ ] 23. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Write Rule 5 (Suppression of Reactive Remediation) with the statement that code must not be changed to match a spec that is wrong about current state. **→ SC-6**
- [ ] 24. **GREEN doublecheck (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Verify the phrase `Suppression of Reactive Remediation` is present and the no-code-change-to-match-wrong-spec statement is present per SC-6 verification method. **→ SC-6**
- [ ] 25. **Checkpoint commit (**inline**).** Stage and commit `.opencode/guidelines/130-authority-source.md` (Rule 5).

- [ ] 26. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Confirm the phrase `Verification against spec` is absent from `130-authority-source.md`. **→ SC-7**
- [ ] 27. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Write Rule 6 (Verification against spec) with the spec-as-benchmark statement. **→ SC-7**
- [ ] 28. **GREEN doublecheck (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Verify the phrase `Verification against spec` is present and the spec-as-benchmark statement is present per SC-7 verification method. **→ SC-7**
- [ ] 29. **Checkpoint commit (**inline**).** Stage and commit `.opencode/guidelines/130-authority-source.md` (Rule 6).

#### Phase 2 VbC

- [ ] 30. **VbC (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Verify all six rules (SC-2 through SC-7) are present with their required content assertions per their verification methods. **→ SC-2, SC-3, SC-4, SC-5, SC-6, SC-7**

**Concern transition:** Leaving six rules → entering relocation of superseded sections. Phase 3 depends on Phase 2's rules being present.
