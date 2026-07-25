# Phase 4 — behavioral-test

**Concern:** Write and verify behavioral enforcement tests for stop-command compliance, discuss-boundary enforcement, and solicitation gate.

**Files:**
- `.opencode/tests-v2/behaviors/stop-command.sh` (new)
- `.opencode/tests-v2/behaviors/discuss-boundary.sh` (new)
- `.opencode/tests-v2/behaviors/solicitation-gate.sh` (new)

**SCs:** SC-4

**Dependencies:** Phase 3

**Entry Conditions:**
- Phase 3 complete: solicitation gate guidelines exist in `020-go-prohibitions.md`
- Phase 3 VbC passed
- Behavioral test infrastructure exists (`.opencode/tests-v2/behaviors/helpers.sh`, `with-test-home`)

**Exit Conditions:**
- `stop-command.sh` exists and sends "stop" prompt, asserting terminal halt
- `discuss-boundary.sh` exists and sends "discuss" prompt, asserting no implementation proposal
- `solicitation-gate.sh` exists and sends complaint prompt, asserting no solicitation output
- All three tests use `assert_semantic` for clean-room evaluation

---

- [ ] 25. **SC coherence gate (**sub-agent**).** Dispatch `audit --task coherence-extraction` to verify SC-4 is coherent with existing test infrastructure. **→ SC-4**
- [ ] 26. **Pre-RED baseline (**sub-agent**).** Dispatch `implementation-pipeline --task pre-red-baseline` to capture current state of behavioral test directory. **→ SC-4**
- [ ] 27. **RED (**sub-agent**).** Create `stop-command.sh` — behavioral test that sends "stop" prompt via `with-test-home opencode run` and asserts terminal halt using `assert_semantic`. Create `discuss-boundary.sh` — behavioral test that sends "discuss" prompt and asserts no implementation proposal. Create `solicitation-gate.sh` — behavioral test that sends complaint prompt and asserts no solicitation output. **→ SC-4**
- [ ] 28. **Z3 check RED (**inline**).** Run `solve --task check` to verify test state transitions are valid. **→ SC-4**
- [ ] 29. **RED doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to verify test files exist and have correct structure. **→ SC-4**
- [ ] 30. **Post-RED enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement` to verify test files are structurally sound. **→ SC-4**
- [ ] 31. **Checkpoint commit (**inline**).** Commit Phase 4 changes.

#### Phase 4 VbC

- [ ] 32. **VbC (**clean-room**).** Verify all three behavioral test files exist, use `assert_semantic`, and follow the behavioral test pattern from existing tests. **→ SC-4**

**Concern transition:** Leaving behavioral test creation → entering post-implementation verification and PR creation.
