# Phase 5 — Always discuss as default

## Phase Metadata

- **Concern:** Reframe discussion from an opt-in mode to the default communication paradigm. Edit `020-go-prohibitions.md` §1.6 section header and framing text to establish discussion as default, structured output as opt-in. Add new critical rule in `000-critical-rules.md` Tier 1 section.
- **Files:** `.opencode/guidelines/020-go-prohibitions.md`, `.opencode/guidelines/000-critical-rules.md`
- **SCs:** SC-5 (behavioral)
- **Dependencies:** Phase 4 complete and committed
- **Entry conditions:** Phase 4 committed to feature branch
- **Exit conditions:** Both files modified and committed to feature branch

## Code Path Coverage

| File | Change Type | Code Path |
|------|------------|-----------|
| 020-go-prohibitions.md | Edit | §1.6 section header and framing text — discussion is default, structured output is opt-in |
| 000-critical-rules.md | Add | New critical-rules entry under Tier 1 section |

## Cross-Cutting SCs

- **020-go-prohibitions.md modification integrity:** Phase 5 reframes §1.6. Must not interfere with Phase 1's §1.6 edits (scope qualifier removal) or Phase 3's text movement.
- **000-critical-rules.md new entries ordering:** Phase 5 adds a new entry after Phase 4's entry. Must maintain consistent numbering.

## Interface Boundaries

- `020-go-prohibitions.md §1.6 Discussion Mode section` — reframed
- `000-critical-rules.md Tier 1 section` — new entry added

## State Transitions

- **From:** Discussion framed as a "mode" (opt-in) in 020-go-prohibitions.md §1.6
- **To:** Discussion established as the default communication paradigm (structured output is opt-in)
- **Invariant:** Existing discussion rules (no question tool, no pigeon-holing, single topic) remain intact — only the framing changes.

## Step-by-step

- [ ] 34. **Pre-RED baseline (**clean-room**).** Run Phase 1-4 behavioral tests to confirm they still pass. **→ SC-5**

- [ ] 35. **RED — Write behavioral enforcement test for SC-5 (**sub-agent**).** Create `.opencode/tests-v2/behaviors/universal-always-discuss.sh` that sends a general inquiry (no explicit request for structure) and asserts via `assert_semantic` that the agent defaults to open-ended discussion, not structured output. Test MUST FAIL at this point. **→ SC-5**

- [ ] 36. **GREEN — Reframe §1.6 in 020-go-prohibitions.md (**sub-agent**).** Edit the §1.6 section header from "Discussion Mode Mandates" to "Discussion Mandates" or similar. Reframe the opening text to establish discussion as the default communication paradigm. Add: "Assume chat mode (open-ended discussion) unless the developer explicitly requests structured output (spec, plan, checklist, table). Brainstorming is the default — structured output is the exception." **→ SC-5**

- [ ] 37. **GREEN — Add always-discuss critical rule to 000-critical-rules.md (**sub-agent**).** Add a new critical-rules entry under Tier 1 section: "Always discuss as default — open-ended discussion is the default communication mode. Structured output (specs, plans, checklists, tables) is opt-in and requires explicit developer request." **→ SC-5**

- [ ] 38. **GREEN doublecheck (**clean-room**).** Verify both files have correct changes. Run the RED test — it must now PASS. **→ SC-5**

- [ ] 39. **Checkpoint commit (**inline**).** `git add .opencode/guidelines/020-go-prohibitions.md .opencode/guidelines/000-critical-rules.md .opencode/tests-v2/behaviors/universal-always-discuss.sh && git commit -m "Phase 5: Always discuss as default"`

#### Phase 5 VbC

- [ ] 40. **VbC (**clean-room**).** Verify SC-5 (behavioral): dispatch `behavioral-test-evaluation` from `verification-before-completion`. Clean-room sub-agent reads behavioral evidence artifacts and evaluates whether the agent's behavior matches SC-5 (discussion as default, structured output as opt-in). **→ SC-5**

**Concern transition:** Leaving always-discuss default → entering behavioral enforcement test. Phase 6 depends on Phase 5's complete rule set — all 5 discussion discipline rules must exist in guideline files.
