# Phase 3 — solicitation-gate

**Concern:** Define solicitation detection gate — before any output containing "want me to", "should I", "I can implement", or similar patterns, agent checks whether user asked for it.

**Files:**
- `.opencode/guidelines/020-go-prohibitions.md`

**SCs:** SC-3

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: discuss-boundary guidelines exist in `020-go-prohibitions.md`
- Phase 2 VbC passed

**Exit Conditions:**
- `020-go-prohibitions.md` contains a new section defining the solicitation detection gate
- The gate specifies: before any output with solicitation patterns, check if user asked for implementation
- If user did not ask, suppress the output

---

- [ ] 17. **SC coherence gate (**sub-agent**).** Dispatch `audit --task coherence-extraction` to verify SC-3 is coherent with existing guideline structure. **→ SC-3**
- [ ] 18. **Pre-RED baseline (**sub-agent**).** Dispatch `implementation-pipeline --task pre-red-baseline` to capture current state of `020-go-prohibitions.md`. **→ SC-3**
- [ ] 19. **GREEN (**sub-agent**).** Add new section to `020-go-prohibitions.md` defining the solicitation detection gate: before any output containing "want me to", "should I", "I can implement", or similar patterns, agent checks whether user asked for implementation. If not, suppress. **→ SC-3**
- [ ] 20. **Z3 check GREEN (**inline**).** Run `solve --task check` to verify pre-output gate state transition is valid. **→ SC-3**
- [ ] 21. **Post-GREEN enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement` to verify guideline changes are structurally sound. **→ SC-3**
- [ ] 22. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to verify SC-3 is met. **→ SC-3**
- [ ] 23. **Checkpoint commit (**inline**).** Commit Phase 3 changes.

#### Phase 3 VbC

- [ ] 24. **VbC (**clean-room**).** Verify `020-go-prohibitions.md` contains solicitation gate language with pre-output check pattern. **→ SC-3**

**Concern transition:** Leaving solicitation gate definition → entering behavioral test creation. Phase 4 depends on Phase 3's guideline changes being in place.
