# Phase 5 — Re-justify 36 skill cards

**Concern:** Re-justify the "Orchestrator Entry Criteria" in all 36 DISPATCH_GATE skill cards under the context-economy rationale, with the no-preloaded-context substance unchanged.

**Files:**
- 36 skill cards under `.opencode/skills/` with DISPATCH_GATE sections (approval-gate, brainstorming, changelog-generator, completeness-gate, completion-core, conflict-resolution, correspondence, engineering-approach, finishing-a-development-branch, issue-operations-comments, issue-operations-core, issue-operations, issue-operations-sub-issues, issue-operations-sync, issue-review, mcp-tool-usage, multimodal-dispatch, plan, playwright-cli, pre-analysis, programming-principles, receiving-code-review, release-promoter, requesting-code-review, research, skill-creator, solve, spec-creation, sre-runbook, sync-guidelines, systematic-debugging, test-driven-development, using-git-worktrees, verification, verification-before-completion, verification-enforcement)

**SCs:** SC-5

**Dependencies:** Phase 4

**Entry Conditions:**
- Phase 4 complete: critical-rules-XXX re-justified under context-economy
- Phase 4 VbC passed

**Exit Conditions:**
- All 36 DISPATCH_GATE skill cards' Orchestrator Entry Criteria re-justified under context-economy
- No-preloaded-context substance unchanged in all cards

---

**Cost frame:** Verifying the skill card alignment costs a grep across 36 cards. Skipping means the DISPATCH_GATE sections diverge from the re-scoped rule, recreating the contradiction at the point of dispatch.

- [ ] 24. **RED (**sub-agent**).** Write an enforcement test asserting the 36 skill cards are not yet re-justified under context-economy (fails). **→ SC-5**
- [ ] 25. **GREEN (**sub-agent**).** Re-justify the "Orchestrator Entry Criteria" in all 36 DISPATCH_GATE skill cards under the context-economy rationale, preserving the no-preloaded-context substance. **→ SC-5**
- [ ] 26. **GREEN doublecheck (**clean-room**).** Verify all 36 cards carry a consistent context-economy justification and no-preloaded-context substance unchanged. **→ SC-5**
- [ ] 27. **Checkpoint commit (**inline**).** Commit the 36 skill card DISPATCH_GATE updates. **→ SC-5**

#### Phase 5 VbC

- [ ] 28. **VbC (**clean-room**).** Verify all 36 DISPATCH_GATE skill cards re-justify Orchestrator Entry Criteria under context-economy with no-preloaded-context substance unchanged. **→ SC-5**

**Concern transition:** Leaving skill card alignment → entering contradiction elimination. Phase 6 depends on Phases 1-5.
