# Phase 2 — Create visual-design-agent card

**Concern:** Create `.opencode/agents/visual-design-agent.md` with the exact frontmatter and body from the spec.

**Files:**
- `.opencode/agents/visual-design-agent.md` (new)
- `.opencode/tests-v2/test-2268-sc2-visual-design-agent-card.sh` (new)

**SCs:** SC-2

**Dependencies:** None (independent of Phase 1 — disjoint file)

**Entry Conditions:**
- Spec #2268 is approved (`approved-for-pr` label present in local `issue.yaml`)
- Feature branch exists
- `.opencode/agents/visual-design-agent.md` does not exist (confirmed missing)

**Exit Conditions:**
- `.opencode/agents/visual-design-agent.md` exists with the exact frontmatter and body from spec #2268 "File 2" block
- Content-verification test `test-2268-sc2-visual-design-agent-card.sh` passes

**Code Path Coverage:** SC-2 new-file path — `.opencode/agents/visual-design-agent.md`, no existing code path modified.

**Cross-Cutting SCs:** SC-3 (valid sub-agent card format applies to this file in phase 3), SC-4 (name check applies in phase 4).

**Interface Boundaries:** Purely additive file creation; agent discovery scans `.opencode/agents/` automatically. No existing card references change.

**State Transitions:** `.opencode/agents/visual-design-agent.md` transitions from "does not exist" to "exists with exact spec content" (phase 2).

---

## Phase 2 steps

- [ ] 8. **RED (**sub-agent**).** Write content-verification test `test-2268-sc2-visual-design-agent-card.sh` asserting `.opencode/agents/visual-design-agent.md` matches the exact spec #2268 "File 2" frontmatter and body (fails — file doesn't exist yet). **→ SC-2**
- [ ] 9. **GREEN (**sub-agent**).** Create `.opencode/agents/visual-design-agent.md` with the exact frontmatter (description, mode: subagent, model: ollama-cloud/qwen3.5:397b-cloud, temperature: 0.8, top_p: 1.0, top_k: 40, options, permission edit allow / bash allowlist) and exact body from the spec. **→ SC-2**
- [ ] 10. **GREEN doublecheck (**clean-room**).** Verify the file content matches the spec "File 2" block character-for-character and the content-verification test passes. **→ SC-2**
- [ ] 11. **Checkpoint commit (**inline**).** Commit the card file and its content-verification test together as one atomic slice.

#### Phase 2 VbC

- [ ] 12. **VbC (**clean-room**).** Run `bash .opencode/tests-v2/test-2268-sc2-visual-design-agent-card.sh`; assert the test passes and the file content matches the spec exactly. **→ SC-2**

**Concern transition:** Leaving visual-design-agent card creation → entering card validation. Phase 3 depends on both Phase 1 and Phase 2 outputs.
