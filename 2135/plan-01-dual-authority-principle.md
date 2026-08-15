# Phase 1 — Dual-authority principle

**Concern:** Establish the dual-authority principle (spec authoritative for intent, code authoritative for current state) in `130-authority-source.md`.

**Files:**
- `.opencode/guidelines/130-authority-source.md`

**SCs:** SC-1

**Dependencies:** None

**Entry Conditions:**
- Spec #2135 is approved (`approved-for-pr` label present in local `issue.yaml`)
- Feature branch exists
- Coherence gate passed (pre-implementation)

**Exit Conditions:**
- The phrase `spec is authoritative for intent` is present in `130-authority-source.md`
- The dual-authority principle is stated (spec for intent, code for state)

**Cost frame:** Verifying the dual-authority phrase costs one grep over a single file — seconds of bounded delay. Skipping costs hours to days when the `code wins` contradiction ships to review and the rewrite's central principle is missing.

---

- [ ] 1. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Grep for `spec is authoritative for intent` in `130-authority-source.md`; confirm no match — the principle is absent before the rewrite. **→ SC-1**
- [ ] 2. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Write the dual-authority principle into the rewritten guideline: the spec is authoritative for intent, the code is authoritative for current state, neither wins absolutely. **→ SC-1**
- [ ] 3. **GREEN doublecheck (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Verify the phrase `spec is authoritative for intent` is present and the principle statement is complete. **→ SC-1**
- [ ] 4. **Checkpoint commit (**inline**).** Stage and commit `.opencode/guidelines/130-authority-source.md` (principle section).

#### Phase 1 VbC

- [ ] 5. **VbC (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Grep for `spec is authoritative for intent` in `130-authority-source.md` (SC-1 verification method). **→ SC-1**

**Concern transition:** Leaving dual-authority principle → entering six rules. Phase 2 depends on Phase 1's principle statement.
