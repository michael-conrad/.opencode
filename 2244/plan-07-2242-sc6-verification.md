# Phase 7 — 2242-sc6 Verification

**Concern:** Verify the `2242-sc6` run completes the git-workflow cleanup dispatch without the orchestrator reading a cleanup task card (SC11) and without halting for PR/branch context (SC12).

**Files:**
- `.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh` (session.yaml tool timeline)

**SCs:** SC11, SC12

**Dependencies:** Phase 6

**Entry Conditions:**
- Phase 6 complete: full-env opt-in set; SC10 run produced a `session.yaml`; VbC passed.

**Exit Conditions:**
- The cleanup dispatch produces a result contract and no file-read tool call targets `tasks/cleanup.md`.
- No question-tool call or PR/branch-context halt appears in the tool timeline.

---

- [ ] 31. **RED (**sub-agent**).** Write a failing behavioral assertion: the `2242-sc6` run shows a read of `tasks/cleanup.md` in the tool timeline, or no result contract, or a question-tool/PR-context halt. **→ SC11, SC12**

- [ ] 32. **GREEN (**sub-agent**).** Verify the dispatch completes without the orchestrator reading the cleanup task card and without a PR-context halt. No source change expected unless the test needs assertion strengthening. **→ SC11, SC12**

- [ ] 33. **GREEN doublecheck (**clean-room**).** Clean-room evaluation of the SC10 `session.yaml` confirms the cleanup dispatch produced a result contract, no `tasks/cleanup.md` read appears in the tool timeline, and no question-tool/PR-context halt occurred. **→ SC11, SC12**

- [ ] 34. **Checkpoint commit (**inline**).** Commit no source change (or assertion strengthening if needed). (No co-author trailer — added at squash time.)

#### Phase 7 VbC

- [ ] 35. **VbC (**clean-room**).** Verify SC11 and SC12 individually from the SC10 `session.yaml`: no `tasks/cleanup.md` read + result contract (SC11); no question-tool call or PR-context halt (SC12). **→ SC11, SC12**

**Concern transition:** Leaving 2242-sc6 verification → entering documentation. Phase 8 is an independent string gate.

---
