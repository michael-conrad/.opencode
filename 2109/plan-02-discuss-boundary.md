# Phase 2 — discuss-boundary

**Concern:** Define discussion/implementation boundary enforcement — when user says "discuss," agent MUST NOT propose implementation.

**Files:**
- `.opencode/guidelines/020-go-prohibitions.md`

**SCs:** SC-2

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: stop-terminal-halt guidelines exist in `000-critical-rules.md` and `020-go-prohibitions.md`
- Phase 1 VbC passed

**Exit Conditions:**
- `020-go-prohibitions.md` contains a new section defining "discuss" as a hard gate blocking implementation proposals
- The gate is positioned in the pre-output section of the guidelines

---

- [ ] 9. **SC coherence gate (**sub-agent**).** Dispatch `audit --task coherence-extraction` to verify SC-2 is coherent with existing guideline structure. **→ SC-2**
- [ ] 10. **Pre-RED baseline (**sub-agent**).** Dispatch `implementation-pipeline --task pre-red-baseline` to capture current state of `020-go-prohibitions.md`. **→ SC-2**
- [ ] 11. **GREEN (**sub-agent**).** Add new section to `020-go-prohibitions.md` defining that when user says "discuss," agent MUST NOT propose implementation. Position as a pre-output gate. **→ SC-2**
- [ ] 12. **Z3 check GREEN (**inline**).** Run `solve --task check` to verify state transition from discussion-mode to discussion-mode (no transition to implementation-mode) is valid. **→ SC-2**
- [ ] 13. **Post-GREEN enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement` to verify guideline changes are structurally sound. **→ SC-2**
- [ ] 14. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to verify SC-2 is met. **→ SC-2**
- [ ] 15. **Checkpoint commit (**inline**).** Commit Phase 2 changes.

#### Phase 2 VbC

- [ ] 16. **VbC (**clean-room**).** Verify `020-go-prohibitions.md` contains "discuss" + "implement" boundary language. **→ SC-2**

**Concern transition:** Leaving discuss-boundary enforcement → entering solicitation gate definition. Phase 3 depends on Phase 2's boundary enforcement being in place.
