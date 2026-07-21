# Phase 4 — Order of importance rule

## Phase Metadata

- **Concern:** Add a new rule requiring agents to order topics by importance in all communications (most important topic first). Add to `020-go-prohibitions.md` 🚫 NEVER DO section and `000-critical-rules.md` Tier 1 section.
- **Files:** `.opencode/guidelines/020-go-prohibitions.md`, `.opencode/guidelines/000-critical-rules.md`
- **SCs:** SC-4 (behavioral)
- **Dependencies:** Phase 3 complete and committed
- **Entry conditions:** Phase 3 committed to feature branch
- **Exit conditions:** Both files modified and committed to feature branch

## Code Path Coverage

| File | Change Type | Code Path |
|------|------------|-----------|
| 020-go-prohibitions.md | Add | New bullet under §1 🚫 NEVER DO section |
| 000-critical-rules.md | Add | New critical-rules entry under Tier 1 section |

## Cross-Cutting SCs

- **020-go-prohibitions.md modification integrity:** Phase 4 adds a new bullet. Must not interfere with Phase 1-3 changes.
- **000-critical-rules.md new entries ordering:** Phase 4 adds a new entry after Phase 3's entry. Must maintain consistent numbering.

## Interface Boundaries

- `020-go-prohibitions.md §1 🚫 NEVER DO section` — new entry added
- `000-critical-rules.md Tier 1 section` — new entry added

## State Transitions

- **From:** No rule exists for topic ordering by importance
- **To:** Order of importance rule established as Tier 1 critical rule
- **Invariant:** No existing text is modified — this is a net-new addition.

## Step-by-step

- [ ] 27. **Pre-RED baseline (**clean-room**).** Run Phase 1-3 behavioral tests to confirm they still pass. **→ SC-4**

- [ ] 28. **RED — Write behavioral enforcement test for SC-4 (**sub-agent**).** Create `.opencode/tests-v2/behaviors/universal-order-of-importance.sh` that sends a multi-topic message with clear priority differences and asserts via `assert_semantic` that the agent orders topics by importance (most important first). Test MUST FAIL at this point. **→ SC-4**

- [ ] 29. **GREEN — Add order of importance rule to 020-go-prohibitions.md (**sub-agent**).** Add a new bullet under §1 🚫 NEVER DO section: "Never order topics arbitrarily — always present the most important topic first in all communications." **→ SC-4**

- [ ] 30. **GREEN — Add order of importance critical rule to 000-critical-rules.md (**sub-agent**).** Add a new critical-rules entry under Tier 1 section: "Order of importance — agents must order topics by importance in all communications, presenting the most important topic first." **→ SC-4**

- [ ] 31. **GREEN doublecheck (**clean-room**).** Verify both files have correct changes. Run the RED test — it must now PASS. **→ SC-4**

- [ ] 32. **Checkpoint commit (**inline**).** `git add .opencode/guidelines/020-go-prohibitions.md .opencode/guidelines/000-critical-rules.md .opencode/tests-v2/behaviors/universal-order-of-importance.sh && git commit -m "Phase 4: Order of importance rule"`

#### Phase 4 VbC

- [ ] 33. **VbC (**clean-room**).** Verify SC-4 (behavioral): dispatch `behavioral-test-evaluation` from `verification-before-completion`. Clean-room sub-agent reads behavioral evidence artifacts and evaluates whether the agent's behavior matches SC-4 (order of importance rule followed). **→ SC-4**

**Concern transition:** Leaving order of importance rule → entering always discuss as default. Phase 5 depends on Phase 4's modified `020-go-prohibitions.md` and `000-critical-rules.md` as the baseline.
