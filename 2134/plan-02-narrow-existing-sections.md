# Phase 2 — Narrow Existing Sections

**Concern:** Narrow the existing No-Echo, Trigger Behavior Map, and Suppression sections as specific cases of the new Self-Simulation Prohibition, preserving their actionable instructions.

**Files:**
- `.opencode/guidelines/117-session-trigger-behavior.md`

**SCs:** SC-3, SC-4, SC-5, SC-9

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: Self-Simulation Prohibition section exists
- Phase 1 VbC passed

**Exit Conditions:**
- Session Trigger No-Echo section narrowed (SC-3)
- Trigger Behavior Map with the two remaining triggers (SC-4)
- Suppression Rule present (SC-5)
- All four original actionable instructions preserved with equivalent semantic force (SC-9)

---

- [ ] 16. **RED (**sub-agent**).** grep for 'No-Echo' in the rewritten guideline — expect FAIL (not yet narrowed). **→ SC-3**
- [ ] 17. **GREEN (**sub-agent**).** Narrow the existing No-Echo section as a specific case of the Self-Simulation Prohibition. **→ SC-3**
- [ ] 18. **GREEN doublecheck (**clean-room**).** Re-run the grep — confirms the 'No-Echo' section exists. **→ SC-3**
- [ ] 19. **Checkpoint commit (**inline**).** `checkpoint(#2134): item-3 — No-Echo section narrowed`

- [ ] 20. **RED (**sub-agent**).** grep for 'pair_mode_resume' and 'nested_opencode_fatal' — expect FAIL (not yet narrowed). **→ SC-4**
- [ ] 21. **GREEN (**sub-agent**).** Narrow the Trigger Behavior Map to the two remaining triggers. **→ SC-4**
- [ ] 22. **GREEN doublecheck (**clean-room**).** Re-run the grep — confirms both trigger entries exist. **→ SC-4**
- [ ] 23. **Checkpoint commit (**inline**).** `checkpoint(#2134): item-4 — Trigger Behavior Map narrowed`

- [ ] 24. **RED (**sub-agent**).** grep for 'Suppression Rule' — expect FAIL (not yet preserved). **→ SC-5**
- [ ] 25. **GREEN (**sub-agent**).** Ensure the Suppression Rule section is present in the rewritten guideline. **→ SC-5**
- [ ] 26. **GREEN doublecheck (**clean-room**).** Re-run the grep — confirms 'Suppression Rule' exists. **→ SC-5**
- [ ] 27. **Checkpoint commit (**inline**).** `checkpoint(#2134): item-5 — Suppression Rule preserved`

- [ ] 28. **RED (**sub-agent**).** Verifier runs the V-SC-9 checklist and expects FAIL (original instructions not all preserved). **→ SC-9**
- [ ] 29. **GREEN (**sub-agent**).** Ensure all four original actionable instructions are preserved with equivalent semantic force. **→ SC-9**
- [ ] 30. **GREEN doublecheck (**clean-room**).** Re-run V-SC-9 — all four checks must PASS. **→ SC-9**
- [ ] 31. **Checkpoint commit (**inline**).** `checkpoint(#2134): item-9 — semantic preservation verified`

#### Phase 2 VbC

- [ ] 32. **VbC (**clean-room**).** Verify the No-Echo section, the Trigger Behavior Map with two triggers, the Suppression Rule, and the semantic preservation of the original instructions. **→ SC-3, SC-4, SC-5, SC-9**

**Concern transition:** Leaving narrowing of existing sections → entering removal of stale content. Phase 3 depends on Phase 2's narrowed sections.
