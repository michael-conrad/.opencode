# Phase 1 — stop-terminal-halt

**Concern:** Define "stop" as terminal halt with zero-output, zero-tool-call, zero-proposal semantics, and no recovery without explicit restart.

**Files:**
- `.opencode/guidelines/000-critical-rules.md`
- `.opencode/guidelines/020-go-prohibitions.md`

**SCs:** SC-1, SC-5

**Dependencies:** None

**Entry Conditions:**
- Spec #2109 is approved
- Feature branch exists
- Pre-implementation coherence gate passed

**Exit Conditions:**
- `000-critical-rules.md` contains a new Tier 1 section defining "stop" as terminal halt
- `020-go-prohibitions.md` contains a new prohibition section for stop semantics
- Both files contain no-recovery language requiring explicit restart

---

- [ ] 1. **SC coherence gate (**sub-agent**).** Dispatch `audit --task coherence-extraction` to verify spec SCs are coherent with existing guideline structure. **→ SC-1, SC-5**
- [ ] 2. **Pre-RED baseline (**sub-agent**).** Dispatch `implementation-pipeline --task pre-red-baseline` to capture current state of affected files. **→ SC-1, SC-5**
- [ ] 3. **GREEN (**sub-agent**).** Add new Tier 1 critical rule section to `000-critical-rules.md` defining "stop" as terminal halt with zero output, zero tool calls, zero proposals. Add corresponding prohibition to `020-go-prohibitions.md`. Add no-recovery clause to both files. **→ SC-1, SC-5**
- [ ] 4. **Z3 check GREEN (**inline**).** Run `solve --task check` to verify state transition from active to terminal-halt is valid. **→ SC-1, SC-5**
- [ ] 5. **Post-GREEN enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement` to verify guideline changes are structurally sound. **→ SC-1, SC-5**
- [ ] 6. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to verify SC-1 and SC-5 are met. **→ SC-1, SC-5**
- [ ] 7. **Checkpoint commit (**inline**).** Commit Phase 1 changes.

#### Phase 1 VbC

- [ ] 8. **VbC (**clean-room**).** Verify `000-critical-rules.md` contains "stop" + "terminal halt" language, `020-go-prohibitions.md` contains stop prohibition, both files contain no-recovery clause. **→ SC-1, SC-5**

**Concern transition:** Leaving stop-terminal-halt definition → entering discuss-boundary enforcement. Phase 2 depends on Phase 1's guideline structure being in place.
