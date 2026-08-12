# Phase 1 — Create vision-agent card

**Concern:** Create `.opencode/agents/vision-agent.md` with the exact frontmatter and body from the spec.

**Files:**
- `.opencode/agents/vision-agent.md` (new)
- `.opencode/tests-v2/test-2268-sc1-vision-agent-card.sh` (new)

**SCs:** SC-1

**Dependencies:** None

**Entry Conditions:**
- Spec #2268 is approved (`approved-for-pr` label present in local `issue.yaml`)
- Feature branch exists
- `.opencode/agents/vision-agent.md` does not exist (confirmed missing)

**Exit Conditions:**
- `.opencode/agents/vision-agent.md` exists with the exact frontmatter and body from spec #2268 "File 1" block
- Content-verification test `test-2268-sc1-vision-agent-card.sh` passes

**Code Path Coverage:** SC-1 new-file path — `.opencode/agents/vision-agent.md`, no existing code path modified.

**Cross-Cutting SCs:** SC-3 (valid sub-agent card format applies to this file in phase 3), SC-4 (name check applies in phase 4).

**Interface Boundaries:** Purely additive file creation; agent discovery scans `.opencode/agents/` automatically. No existing card references change.

**State Transitions:** `.opencode/agents/vision-agent.md` transitions from "does not exist" to "exists with exact spec content" (phase 1).

---

## Pre-implementation (global)

- [ ] 1. **Coherence gate (**clean-room**).** Verify the spec SCs match the phase decomposition in `structure.yaml` (4 phases, one SC per phase) and the dependency DAG has no cycles. **→ all SCs**
- [ ] 2. **Baseline check (**clean-room**).** Verify feature branch exists, `.opencode/agents/` contains only the pre-existing `steps-value-analysis.md`, and neither new card file exists. **→ SC-1, SC-2**

## Phase 1 steps

- [ ] 3. **RED (**sub-agent**).** Write content-verification test `test-2268-sc1-vision-agent-card.sh` asserting `.opencode/agents/vision-agent.md` matches the exact spec #2268 "File 1" frontmatter and body (fails — file doesn't exist yet). **→ SC-1**
- [ ] 4. **GREEN (**sub-agent**).** Create `.opencode/agents/vision-agent.md` with the exact frontmatter (description, mode: subagent, model: ollama-cloud/qwen3.5:397b-cloud, temperature: 0.3, top_p: 0.8, top_k: 20, options, permission edit/bash/webfetch deny) and exact body from the spec. **→ SC-1**
- [ ] 5. **GREEN doublecheck (**clean-room**).** Verify the file content matches the spec "File 1" block character-for-character and the content-verification test passes. **→ SC-1**
- [ ] 6. **Checkpoint commit (**inline**).** Commit the card file and its content-verification test together as one atomic slice.

#### Phase 1 VbC

- [ ] 7. **VbC (**clean-room**).** Run `bash .opencode/tests-v2/test-2268-sc1-vision-agent-card.sh`; assert the test passes and the file content matches the spec exactly. **→ SC-1**

**Concern transition:** Leaving vision-agent card creation → entering visual-design-agent card creation. Phase 2 is independent (disjoint file). Phases 3 and 4 depend on this phase's output.
