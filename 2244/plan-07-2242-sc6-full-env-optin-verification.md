# Phase 7 — 2242-sc6 Full-Env Opt-In + Verification (Concern C8)

**Concern:** C8 — 2242-sc6 full-env opt-in + cleanup-dispatch verification. Set the full-env opt-in (`BEHAVIOR_NEEDS_MULTI_SUBMODULES=1` and `BEHAVIOR_NEEDS_REMOTE=1`) on the `2242-sc6-cleanup-dispatch-no-task-card-read.sh` test so merged-PR discovery succeeds (SC10), and verify the run completes cleanup dispatch without reading a cleanup task card (SC11) and without halting for PR/branch context (SC12).

**Files:**
- `.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh`
- `.opencode/tests-v2/behaviors/fixtures/setup/2242-sc6-cleanup-dispatch-no-task-card-read.sh`

**SCs:** SC10, SC11, SC12

**Dependencies:** Phase 6

**Entry Conditions:**
- Phase 6 complete: GitBucket origin wiring + discovery in place; VbC passed.
- The 2242-sc6 test and its per-scenario fixture read.

**Exit Conditions:**
- The 2242-sc6 test runs with the full-env opt-in.
- `session.yaml` shows `gh pr list` returned a merged branch and an open issue during the run (SC10).
- The cleanup dispatch produces a result contract and no file-read tool call targets `tasks/cleanup.md` (SC11).
- No question-tool call or PR/branch-context halt appears in the tool timeline (SC12).

---

- [ ] 31. **RED (**sub-agent**).** Write failing behavioral assertions: (a) the `2242-sc6` test with the full-env opt-in fails to show `gh pr list` discovering a merged branch + open issue; (b) the `2242-sc6` run shows a read of `tasks/cleanup.md` in the tool timeline, or no result contract, or a question-tool/PR-context halt. **→ SC10, SC11, SC12**

- [ ] 32. **GREEN (**sub-agent**).** Extend `2242-sc6-cleanup-dispatch-no-task-card-read.sh` and its per-scenario fixture to set `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1` and `BEHAVIOR_NEEDS_REMOTE=1`. Verify the dispatch completes without reading the cleanup task card and without a PR-context halt. No further source change expected unless the test needs assertion strengthening. **→ SC10, SC11, SC12**

- [ ] 33. **GREEN doublecheck (**clean-room**).** Run `2242-sc6` with the full-env opt-in; clean-room evaluation of `session.yaml` confirms `gh pr list` returned the merged branch and open issue, the cleanup dispatch produced a result contract, no `tasks/cleanup.md` read appears in the tool timeline, and no question-tool/PR-context halt occurred. **→ SC10, SC11, SC12**

- [ ] 34. **Checkpoint commit (**inline**).** Commit `2242-sc6` test + per-scenario fixture. (No co-author trailer — added at squash time.)

#### Phase 7 VbC

- [ ] 35. **VbC (**clean-room**).** Verify SC10, SC11, SC12 individually from the SC10 `session.yaml`: merged-PR discovery (merged branch + open issue) for SC10; no `tasks/cleanup.md` read + result contract for SC11; no question-tool call or PR-context halt for SC12. **→ SC10, SC11, SC12**

**Concern transition:** Leaving C8 (2242-sc6 full-env opt-in + verification) → entering C9 (documentation) and C6 (final no-regression default gate).
