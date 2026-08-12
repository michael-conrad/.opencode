# Phase 3 — Validate both cards

**Concern:** Verify both files are valid opencode sub-agent cards — correct frontmatter fields, `mode: subagent`, and provider-prefixed model ID.

**Files:**
- `.opencode/agents/vision-agent.md` (validation target)
- `.opencode/agents/visual-design-agent.md` (validation target)
- `.opencode/tests-v2/test-2268-sc3-valid-sub-agent-cards.sh` (new)

**SCs:** SC-3

**Dependencies:** Phase 1, Phase 2

**Entry Conditions:**
- Phase 1 complete: `.opencode/agents/vision-agent.md` exists
- Phase 2 complete: `.opencode/agents/visual-design-agent.md` exists
- Phase 1 and Phase 2 VbC passed

**Exit Conditions:**
- Both files parse as valid opencode sub-agent cards
- `mode: subagent` present in both frontmatter blocks
- Model IDs are provider-prefixed (`ollama-cloud/qwen3.5:397b-cloud`)
- Content-verification test `test-2268-sc3-valid-sub-agent-cards.sh` passes

**Code Path Coverage:** SC-3 validation paths — frontmatter fields (description, mode, model, temperature, top_p, top_k, options, permission) on both files.

**Cross-Cutting SCs:** SC-3 is the cross-cutting concern itself — it applies to both Phase 1 and Phase 2 outputs and is verified once in this phase.

**Interface Boundaries:** Agent discovery requires valid card frontmatter; `mode: subagent` and provider-prefixed model are required for correct sub-agent loading. Existing cards are unaffected.

**State Transitions:** Both files remain at "exists with exact spec content" (no content change in this phase); verification state transitions from unverified to verified-valid.

---

## Phase 3 steps

- [ ] 13. **RED (**sub-agent**).** Write content-verification test `test-2268-sc3-valid-sub-agent-cards.sh` asserting both files parse as valid opencode sub-agent cards, each contains `mode: subagent`, and each model ID starts with the `ollama-cloud/` provider prefix (fails — files don't exist yet). **→ SC-3**
- [ ] 14. **GREEN (**sub-agent**).** Confirm both card files exist with valid frontmatter; if any frontmatter field, mode value, or model ID is incorrect, correct it to match the spec. **→ SC-3**
- [ ] 15. **GREEN doublecheck (**clean-room**).** Run the content-verification test; assert both files parse as valid sub-agent cards and model IDs are provider-prefixed. **→ SC-3**
- [ ] 16. **Checkpoint commit (**inline**).** Commit the validation test (and any frontmatter corrections) as one atomic slice.

#### Phase 3 VbC

- [ ] 17. **VbC (**clean-room**).** Run `bash .opencode/tests-v2/test-2268-sc3-valid-sub-agent-cards.sh`; assert the test passes, confirming both files are valid sub-agent cards with `mode: subagent` and provider-prefixed model IDs. **→ SC-3**

**Concern transition:** Leaving card validation → entering agent-name verification. Phase 4 depends on both Phase 1 and Phase 2 outputs.
