# Phase 2 — Pigeon-holing in natural language prohibition

## Phase Metadata

- **Concern:** Add a new Tier 1 critical rule prohibiting pigeon-holing in natural language (presenting constrained options in prose, e.g., "Should we do X or Y?"). Add to `020-go-prohibitions.md` 🚫 NEVER DO section and `000-critical-rules.md` Tier 1 section.
- **Files:** `.opencode/guidelines/020-go-prohibitions.md`, `.opencode/guidelines/000-critical-rules.md`
- **SCs:** SC-2 (behavioral)
- **Dependencies:** Phase 1 complete and committed
- **Entry conditions:** Phase 1 committed to feature branch
- **Exit conditions:** Both files modified and committed to feature branch

## Code Path Coverage

| File | Change Type | Code Path |
|------|------------|-----------|
| 020-go-prohibitions.md | Add | New bullet under §1 🚫 NEVER DO section |
| 000-critical-rules.md | Add | New critical-rules entry under Tier 1 section |

## Cross-Cutting SCs

- **020-go-prohibitions.md modification integrity:** Phase 2 adds a new bullet. Must not interfere with Phase 1's changes (top-level prohibition and §1.6 edits).
- **000-critical-rules.md new entries ordering:** Phase 2 adds a new entry after critical-rules-037 (modified in Phase 1). Must maintain consistent numbering.

## Interface Boundaries

- `020-go-prohibitions.md §1 🚫 NEVER DO section` — new entry added
- `000-critical-rules.md Tier 1 section` — new entry added

## State Transitions

- **From:** Natural language pigeon-holing not explicitly prohibited (same anti-pattern as question tool but no rule exists)
- **To:** Natural language pigeon-holing explicitly prohibited as Tier 1 critical rule
- **Invariant:** Existing question tool prohibition is unchanged. This is a new rule, not a modification.

## Step-by-step

- [ ] 13. **Pre-RED baseline (**clean-room**).** Run the Phase 1 behavioral test to confirm it still passes. Record baseline. **→ SC-2**

- [ ] 14. **RED — Write behavioral enforcement test for SC-2 (**sub-agent**).** Create `.opencode/tests-v2/behaviors/universal-pigeon-holing-prohibition.sh` that sends a prompt where the agent presents constrained options in prose (e.g., "Should we do X or Y?"). Assert via `assert_semantic` that the agent does NOT present constrained options. Test MUST FAIL at this point. **→ SC-2**

- [ ] 15. **GREEN — Add pigeon-holing prohibition to 020-go-prohibitions.md (**sub-agent**).** Add a new bullet under §1 🚫 NEVER DO section: "Never pigeon-hole in natural language — presenting constrained options in prose ('Should we do X or Y?') is the same anti-pattern as the question tool." **→ SC-2**

- [ ] 16. **GREEN — Add pigeon-holing critical rule to 000-critical-rules.md (**sub-agent**).** Add a new critical-rules entry under Tier 1 section: "Natural language pigeon-holing — presenting constrained options in prose — is prohibited as a Tier 1 critical rule." **→ SC-2**

- [ ] 17. **GREEN doublecheck (**clean-room**).** Verify both files have correct changes. Run the RED test — it must now PASS. **→ SC-2**

- [ ] 18. **Checkpoint commit (**inline**).** `git add .opencode/guidelines/020-go-prohibitions.md .opencode/guidelines/000-critical-rules.md .opencode/tests-v2/behaviors/universal-pigeon-holing-prohibition.sh && git commit -m "Phase 2: Pigeon-holing in natural language prohibition"`

#### Phase 2 VbC

- [ ] 19. **VbC (**clean-room**).** Verify SC-2 (behavioral): dispatch `behavioral-test-evaluation` from `verification-before-completion`. Clean-room sub-agent reads behavioral evidence artifacts and evaluates whether the agent's behavior matches SC-2 (natural language pigeon-holing prohibited). **→ SC-2**

**Concern transition:** Leaving pigeon-holing prohibition → entering single-topic discipline enforcement. Phase 3 depends on Phase 2's modified `020-go-prohibitions.md` and `000-critical-rules.md` as the baseline.
