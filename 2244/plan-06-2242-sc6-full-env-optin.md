# Phase 6 — 2242-sc6 Full-Env Opt-In

**Concern:** Set the full-env opt-in (`BEHAVIOR_NEEDS_MULTI_SUBMODULES=1` and `BEHAVIOR_NEEDS_REMOTE=1`) on the `2242-sc6-cleanup-dispatch-no-task-card-read.sh` test so merged-PR discovery succeeds during the run.

**Files:**
- `.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh`
- `.opencode/tests-v2/behaviors/fixtures/setup/2242-sc6-cleanup-dispatch-no-task-card-read.sh`

**SCs:** SC10

**Dependencies:** Phase 4

**Entry Conditions:**
- Phase 4 complete: GitBucket origin wiring in place; VbC passed.
- The 2242-sc6 test and its per-scenario fixture read.

**Exit Conditions:**
- The 2242-sc6 test runs with the full-env opt-in.
- `session.yaml` shows `gh pr list` returned a merged branch and an open issue during the run.

---

- [ ] 26. **RED (**sub-agent**).** Write a failing behavioral test: the `2242-sc6` test with the full-env opt-in fails to show `gh pr list` discovering a merged branch + open issue. **→ SC10**

- [ ] 27. **GREEN (**sub-agent**).** Extend `2242-sc6-cleanup-dispatch-no-task-card-read.sh` and its per-scenario fixture to set `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1` and `BEHAVIOR_NEEDS_REMOTE=1`. **→ SC10**

- [ ] 28. **GREEN doublecheck (**clean-room**).** Run `2242-sc6` with the full-env opt-in; clean-room evaluation of `session.yaml` confirms `gh pr list` returned the merged branch and open issue. **→ SC10**

- [ ] 29. **Checkpoint commit (**inline**).** Commit `2242-sc6` test + per-scenario fixture. (No co-author trailer — added at squash time.)

#### Phase 6 VbC

- [ ] 30. **VbC (**clean-room**).** Verify SC10: clean-room `session.yaml` evaluation of the `2242-sc6` run confirms merged-PR discovery (merged branch + open issue). **→ SC10**

**Concern transition:** Leaving 2242-sc6 full-env opt-in → entering 2242-sc6 verification. Phase 7 verifies during the SC10 run.

---
