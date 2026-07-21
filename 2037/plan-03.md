# Phase 3 — Single-topic discipline enforcement

## Phase Metadata

- **Concern:** Elevate single-topic discipline from advisory text to a Tier 1 critical rule. Move existing advisory text from `020-go-prohibitions.md` §1.6 to 🚫 NEVER DO section. Add new critical rule entry in `000-critical-rules.md` Tier 1 section.
- **Files:** `.opencode/guidelines/020-go-prohibitions.md`, `.opencode/guidelines/000-critical-rules.md`
- **SCs:** SC-3 (behavioral)
- **Dependencies:** Phase 2 complete and committed
- **Entry conditions:** Phase 2 committed to feature branch
- **Exit conditions:** Both files modified and committed to feature branch

## Code Path Coverage

| File | Change Type | Code Path |
|------|------------|-----------|
| 020-go-prohibitions.md | Move + elevate | Advisory text from §1.6 → 🚫 NEVER DO section as critical rule |
| 000-critical-rules.md | Add | New critical-rules entry under Tier 1 section |

## Cross-Cutting SCs

- **020-go-prohibitions.md modification integrity:** Phase 3 moves text from §1.6 to the 🚫 NEVER DO section. Must not interfere with Phase 1's §1.6 edits or Phase 2's new bullet.
- **000-critical-rules.md new entries ordering:** Phase 3 adds a new entry after Phase 2's entry. Must maintain consistent numbering.

## Interface Boundaries

- `020-go-prohibitions.md §1.6 Discussion Mode section` — text moved from here
- `020-go-prohibitions.md §1 🚫 NEVER DO section` — text added here
- `000-critical-rules.md Tier 1 section` — new entry added

## State Transitions

- **From:** Single-topic discipline exists as advisory text in 020-go-prohibitions.md (not a critical rule)
- **To:** Single-topic discipline enforced as Tier 1 critical rule
- **Invariant:** Existing advisory text content is preserved — only its enforcement level changes.

## Step-by-step

- [ ] 20. **Pre-RED baseline (**clean-room**).** Run Phase 1 and Phase 2 behavioral tests to confirm they still pass. **→ SC-3**

- [ ] 21. **RED — Write behavioral enforcement test for SC-3 (**sub-agent**).** Create `.opencode/tests-v2/behaviors/universal-single-topic-discipline.sh` that sends a multi-topic message and asserts via `assert_semantic` that the agent decomposes into single-topic turns. Test MUST FAIL at this point. **→ SC-3**

- [ ] 22. **GREEN — Move single-topic discipline to 🚫 NEVER DO in 020-go-prohibitions.md (**sub-agent**).** Locate the existing advisory text about single-topic discipline in §1.6. Move it to the 🚫 NEVER DO section as a critical rule: "Never mix topics — every discussion addresses exactly one topic at a time. Multi-topic messages must be decomposed into single-topic turns." **→ SC-3**

- [ ] 23. **GREEN — Add single-topic critical rule to 000-critical-rules.md (**sub-agent**).** Add a new critical-rules entry under Tier 1 section: "Single-topic discipline — multi-topic messages must be decomposed into single-topic turns. Violation is a Tier 1 critical rule." **→ SC-3**

- [ ] 24. **GREEN doublecheck (**clean-room**).** Verify both files have correct changes. Run the RED test — it must now PASS. **→ SC-3**

- [ ] 25. **Checkpoint commit (**inline**).** `git add .opencode/guidelines/020-go-prohibitions.md .opencode/guidelines/000-critical-rules.md .opencode/tests-v2/behaviors/universal-single-topic-discipline.sh && git commit -m "Phase 3: Single-topic discipline enforcement"`

#### Phase 3 VbC

- [ ] 26. **VbC (**clean-room**).** Verify SC-3 (behavioral): dispatch `behavioral-test-evaluation` from `verification-before-completion`. Clean-room sub-agent reads behavioral evidence artifacts and evaluates whether the agent's behavior matches SC-3 (single-topic discipline enforced). **→ SC-3**

**Concern transition:** Leaving single-topic discipline → entering order of importance rule. Phase 4 depends on Phase 3's modified `020-go-prohibitions.md` and `000-critical-rules.md` as the baseline.
