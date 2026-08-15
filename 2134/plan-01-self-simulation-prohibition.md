# Phase 1 — Self-Simulation Prohibition

**Concern:** Write the new Self-Simulation Prohibition section covering all five unauthorized mechanisms with the authorization-provenance carve-out.

**Files:**
- `.opencode/guidelines/117-session-trigger-behavior.md`

**SCs:** SC-1, SC-2, SC-10

**Dependencies:** None

**Entry Conditions:**
- Spec #2134 is approved (`approved-for-pr` label present)
- Feature branch exists
- Pre-implementation coherence gate and baseline check passed

**Exit Conditions:**
- Self-Simulation Prohibition section exists (SC-1)
- All five unauthorized mechanisms and the authorized-pipeline carve-out present (SC-2)
- Authorization carve-out covers all four categories (SC-10)

---

- [ ] 3. **RED (**sub-agent**).** Write an enforcement test that greps the rewritten guideline for 'Self-Simulation' and expects FAIL (section not yet added). **→ SC-1**
- [ ] 4. **GREEN (**sub-agent**).** Write the Self-Simulation Prohibition section per Proposed Solution §1 of the spec. **→ SC-1**
- [ ] 5. **GREEN doublecheck (**clean-room**).** Re-run the RED test — it must now PASS (section present). **→ SC-1**
- [ ] 6. **Checkpoint commit (**inline**).** `checkpoint(#2134): item-1 — Self-Simulation Prohibition section`

- [ ] 7. **RED (**sub-agent**).** Verifier runs the V-SC-2 checklist against the guideline and expects FAIL (not all mechanisms covered). **→ SC-2**
- [ ] 8. **GREEN (**sub-agent**).** Ensure the five mechanisms and the authorization-boundary carve-out are present in the guideline body. **→ SC-2**
- [ ] 9. **GREEN doublecheck (**clean-room**).** Re-run V-SC-2 — all seven checks must PASS. **→ SC-2**
- [ ] 10. **Checkpoint commit (**inline**).** `checkpoint(#2134): item-2 — 5 mechanisms + carve-out verified`

- [ ] 11. **RED (**sub-agent**).** Verifier runs the V-SC-10 checklist and expects FAIL (carve-out incomplete). **→ SC-10**
- [ ] 12. **GREEN (**sub-agent**).** Ensure the guideline covers all four carve-out categories. **→ SC-10**
- [ ] 13. **GREEN doublecheck (**clean-room**).** Re-run V-SC-10 — all four checks must PASS. **→ SC-10**
- [ ] 14. **Checkpoint commit (**inline**).** `checkpoint(#2134): item-10 — carve-out coverage verified`

#### Phase 1 VbC

- [ ] 15. **VbC (**clean-room**).** Verify the Self-Simulation section exists, all five mechanisms and the carve-out are present, and the carve-out covers all four categories. **→ SC-1, SC-2, SC-10**

**Concern transition:** Leaving Self-Simulation Prohibition definition → entering narrowing of the existing sections. Phase 2 depends on Phase 1's prohibition.
