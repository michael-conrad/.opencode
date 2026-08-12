# Phase 4 — Verify agent names

**Concern:** Verify the agent names are exactly `vision-agent` and `visual-design-agent` — no suffix appended to either filename.

**Files:**
- `.opencode/agents/` (directory listing — both new files)
- `.opencode/tests-v2/test-2268-sc4-agent-names.sh` (new)

**SCs:** SC-4

**Dependencies:** Phase 1, Phase 2

**Entry Conditions:**
- Phase 1 complete: `.opencode/agents/vision-agent.md` exists
- Phase 2 complete: `.opencode/agents/visual-design-agent.md` exists
- Phase 1 and Phase 2 VbC passed

**Exit Conditions:**
- `.opencode/agents/` contains exactly the two new agent cards named `vision-agent.md` and `visual-design-agent.md`
- No suffix appended to either filename
- Pre-existing `steps-value-analysis.md` present and unmodified
- Content-verification test `test-2268-sc4-agent-names.sh` passes

**Code Path Coverage:** SC-4 validation path — `.opencode/agents/` directory listing.

**Cross-Cutting SCs:** SC-4 is the cross-cutting concern itself — it applies to both Phase 1 and Phase 2 outputs and is verified once in this phase.

**Interface Boundaries:** Agent names must match the canonical names exactly; a suffixed filename would break name-based routing references. `steps-value-analysis.md` is a documentation file, not an agent card, and must not be renamed.

**State Transitions:** Both files remain at "exists with exact spec content" (no content change in this phase); name verification state transitions from unverified to verified-exact.

---

## Phase 4 steps

- [ ] 18. **RED (**sub-agent**).** Write content-verification test `test-2268-sc4-agent-names.sh` asserting `.opencode/agents/` contains exactly `vision-agent.md` and `visual-design-agent.md` as the new agent cards with no suffix, and that `steps-value-analysis.md` is present and unmodified (fails — files don't exist yet). **→ SC-4**
- [ ] 19. **GREEN (**sub-agent**).** Confirm both files are named exactly `vision-agent.md` and `visual-design-agent.md`; if any file carries a suffix, rename it to the canonical name. **→ SC-4**
- [ ] 20. **GREEN doublecheck (**clean-room**).** Run the content-verification test; assert both names are exact with no suffix and `steps-value-analysis.md` is untouched. **→ SC-4**
- [ ] 21. **Checkpoint commit (**inline**).** Commit the name-verification test (and any rename) as one atomic slice.

#### Phase 4 VbC

- [ ] 22. **VbC (**clean-room**).** Run `bash .opencode/tests-v2/test-2268-sc4-agent-names.sh`; assert the test passes, confirming both names are exact with no suffix. **→ SC-4**

**Concern transition:** Leaving agent-name verification → entering post-implementation global gates.

---

## Post-implementation (global)

- [ ] 23. **Structural checks (**sub-agent**).** Run the finishing checklist: verify only the two new card files and four new test files are added, `steps-value-analysis.md` is unchanged, and no other `.opencode/` content was modified. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 24. **Verification (**clean-room**).** Run all four content-verification tests together: `test-2268-sc1-vision-agent-card.sh`, `test-2268-sc2-visual-design-agent-card.sh`, `test-2268-sc3-valid-sub-agent-cards.sh`, `test-2268-sc4-agent-names.sh`; assert all pass. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 25. **Z3 check (**inline**).** Run `.opencode/tools/solve check --state-path .opencode/.issues/2268/artifacts/state-analysis.yaml --contract-path .opencode/.issues/2268/dependency-contract.yaml`; assert SAT. **→ all SCs**
- [ ] 26. **Pre-PR gate (**clean-room**).** Read all SC verdicts (SC-1 string, SC-2 string, SC-3 structural, SC-4 string); if any verdict is FAIL, block PR creation. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 27. **Audit (**clean-room**).** Dispatch the verification-audit investigator: audit the deliverable (two new card files + four tests) against the spec SCs, confirming exact content, valid card structure, and exact names. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 28. **Regression check (**clean-room**).** Run `bash .opencode/tests-v2/test-enforcement.sh --tag content-verification` to confirm no existing content-verification enforcement test regressed. **→ all SCs**
- [ ] 29. **Review-prep (**sub-agent**).** Dispatch the review-prep task to prepare the PR review context. **→ all SCs**
- [ ] 30. **Create PR (**sub-agent**).** Dispatch the create task to open the stacked PR for this feature branch. **→ all SCs**
- [ ] 31. **Exec summary (**sub-agent**).** Dispatch the completion task to generate the executive summary and report once. **→ all SCs**
