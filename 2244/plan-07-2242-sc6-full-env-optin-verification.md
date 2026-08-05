# Phase 7 — 2242-sc6 Full-Env Opt-In + Verification (Concern C8)

**Concern:** C8 — 2242-sc6 full-env opt-in + cleanup-dispatch verification. Set the full-env opt-in (`BEHAVIOR_NEEDS_MULTI_SUBMODULES=1` and `BEHAVIOR_NEEDS_REMOTE=1`) on the `2242-sc6-cleanup-dispatch-no-task-card-read.sh` test so the agent can discover the merged branch/PR state needed to execute cleanup (via any discovery mechanism; the specific command is NOT the measure) (SC10), and verify the run completes cleanup dispatch by following the correct task card (`tasks/cleanup.md`) instructions, producing a result contract (SC11), without halting for PR/branch context (SC12).

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
- The agent discovered the merged branch/PR state needed to execute cleanup via some discovery mechanism, and cleanup proceeded against it (SC10).
- The cleanup dispatch followed the correct task card (`tasks/cleanup.md`) instructions and completed, producing a result contract (SC11).
- No question-tool call or PR/branch-context halt appears in the tool timeline (SC12).

---

- [ ] 31. **RED (**sub-agent**).** Write failing behavioral assertions: (a) the `2242-sc6` test with the full-env opt-in fails to enable the agent to discover the merged branch/PR state needed to execute cleanup (by whatever mechanism it uses), so cleanup does not proceed; (b) the `2242-sc6` run shows the cleanup dispatch did not follow the correct task card (`tasks/cleanup.md`) instructions or produced no result contract, or shows a question-tool/PR-context halt. **→ SC10, SC11, SC12**

- [ ] 32. **GREEN (**sub-agent**).** Extend `2242-sc6-cleanup-dispatch-no-task-card-read.sh` and its per-scenario fixture to set `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1` and `BEHAVIOR_NEEDS_REMOTE=1`. Verify the cleanup dispatch follows the correct task card (`tasks/cleanup.md`) instructions, completes, and produces a result contract, without a PR-context halt. No further source change expected unless the test needs assertion strengthening. **→ SC10, SC11, SC12**

- [ ] 33. **GREEN doublecheck (**clean-room**).** Run `2242-sc6` with the full-env opt-in; clean-room evaluation of `session.yaml` confirms the agent discovered the merged branch (by whatever discovery mechanism it used) and cleanup proceeded against it (SC10), the cleanup dispatch followed the correct task card instructions and produced a result contract (SC11), and no question-tool/PR-context halt occurred (SC12). **→ SC10, SC11, SC12**

- [ ] 34. **Checkpoint commit (**inline**).** Commit `2242-sc6` test + per-scenario fixture. (No co-author trailer — added at squash time.)

#### Phase 7 VbC

- [ ] 35. **VbC (**clean-room**).** Verify SC10, SC11, SC12 individually from the SC10 `session.yaml`: merged-branch/PR discovery enabling cleanup to proceed for SC10 (specific command NOT the measure); correct task-card instruction-following + result contract for SC11 (orchestrator read/no-read NOT the measure); no question-tool call or PR-context halt for SC12. **→ SC10, SC11, SC12**

**Concern transition:** Leaving C8 (2242-sc6 full-env opt-in + verification) → entering C9 (documentation) and C6 (final no-regression default gate).
