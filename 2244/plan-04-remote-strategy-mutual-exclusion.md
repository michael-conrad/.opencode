# Phase 4 — Remote-Strategy Mutual Exclusion (Concern C3)

**Concern:** C3 — remote strategy mutual exclusion. Both `BEHAVIOR_NEEDS_REMOTE=1` and `BEHAVIOR_SET_BARE_REMOTE=1` set together triggers `HARNESS_FAILURE` and no origin wiring is attempted.

**Files:**
- `.opencode/tests-v2/behaviors/helpers.sh` (behavior_run mutual-exclusion rejection)

**SCs:** SC4

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: env isolation foundation in place; VbC passed.
- `behavior_run()` in `helpers.sh` read to understand the remote-strategy blocks.

**Exit Conditions:**
- Both `BEHAVIOR_NEEDS_REMOTE=1` and `BEHAVIOR_SET_BARE_REMOTE=1` together exit with `HARNESS_FAILURE` and do not attempt origin wiring.

---

- [ ] 16. **RED (**sub-agent**).** Write a failing enforcement test asserting both `BEHAVIOR_NEEDS_REMOTE=1` and `BEHAVIOR_SET_BARE_REMOTE=1` fail to reject with `HARNESS_FAILURE` (i.e., it proceeds to wire an origin). **→ SC4**

- [ ] 17. **GREEN (**sub-agent**).** In `helpers.sh` `behavior_run()`: add mutual-exclusion rejection between `BEHAVIOR_NEEDS_REMOTE` and `BEHAVIOR_SET_BARE_REMOTE` that exits `HARNESS_FAILURE` before either wiring block. **→ SC4**

- [ ] 18. **GREEN doublecheck (**clean-room**).** Run with both remote flags set; confirm the `HARNESS_FAILURE` rejection occurs and no origin wiring is attempted. **→ SC4**

- [ ] 19. **Checkpoint commit (**inline**).** Commit `helpers.sh` mutual-exclusion logic. (No co-author trailer — added at squash time.)

#### Phase 4 VbC

- [ ] 20. **VbC (**clean-room**).** Verify SC4: `HARNESS_FAILURE` exit + no origin wiring when both remote flags are set. **→ SC4**

**Concern transition:** Leaving C3 (remote-strategy mutual exclusion) → entering C7 (cleanup) and C2 (GitBucket origin wiring + discovery). Phase 5 depends on this phase's rejection; Phase 6 depends on this phase's rejection; Phase 8 documents this phase's mutual-exclusion rule.
