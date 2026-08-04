# Phase 3 — Provisioning, Cleanup, Rejection

**Concern:** Add the provisioning, cleanup, and mutual-exclusion-rejection primitives: opt-in multi-submodule fixture repos (SC1), mutual-exclusion rejection of `BEHAVIOR_NEEDS_REMOTE` + `BEHAVIOR_SET_BARE_REMOTE` (SC4), and cleanup of provisioned state (SC9).

**Files:**
- `.opencode/tests-v2/behaviors/helpers.sh` (behavior_run provisioning/cleanup)
- `.opencode/tests-v2/with-test-home` (do_clean_all)

**SCs:** SC1, SC4, SC9

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: env isolation foundation in place; VbC passed.
- `behavior_run()`, `__ensure_gitbucket()`, `__reset_gitbucket()`, `__kill_gitbucket()` in `helpers.sh` and `do_clean_all()` in `with-test-home` read.

**Exit Conditions:**
- `behavior_run()` provisions `test-submodule-1`/`test-submodule-2` when `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1`, and not when unset.
- Both `BEHAVIOR_NEEDS_REMOTE=1` and `BEHAVIOR_SET_BARE_REMOTE=1` together exit with `HARNESS_FAILURE` and do not attempt origin wiring.
- `--clean-all`/`__kill_gitbucket`/`__reset_gitbucket` remove provisioned clones and GitBucket state, leaving no orphans.

---

- [ ] 11. **RED (**sub-agent**).** Write failing enforcement tests asserting: (a) no `test-submodule-1`/`test-submodule-2` dirs appear when `BEHAVIOR_NEEDS_MULTI_SUBMODULES` is unset, but do appear when set; (b) both `BEHAVIOR_NEEDS_REMOTE=1` and `BEHAVIOR_SET_BARE_REMOTE=1` fail to reject with `HARNESS_FAILURE`; (c) a provisioned run leaves an orphan GitBucket process / stale clones after `--clean-all`. **→ SC1, SC4, SC9**

- [ ] 12. **GREEN (**sub-agent**).** In `helpers.sh` `behavior_run()`: add the `BEHAVIOR_NEEDS_MULTI_SUBMODULES` branch that `git init`s the two fixture repos from fixture templates; add mutual-exclusion rejection between `BEHAVIOR_NEEDS_REMOTE` and `BEHAVIOR_SET_BARE_REMOTE` that exits `HARNESS_FAILURE` before either wiring block. In `with-test-home` `do_clean_all()` and `helpers.sh` `__kill_gitbucket()`/`__reset_gitbucket()`: remove provisioned submodule clones, kill the GitBucket process, and remove stale `tmp/` state. **→ SC1, SC4, SC9**

- [ ] 13. **GREEN doublecheck (**clean-room**).** Verify flag-on/flag-off submodule provisioning, the `HARNESS_FAILURE` rejection when both remote flags set, and that `--clean-all`/`__kill_gitbucket` leave no orphan clones or GitBucket process; rerun confirms clean start. **→ SC1, SC4, SC9**

- [ ] 14. **Checkpoint commit (**inline**).** Commit `helpers.sh` + `with-test-home` + new fixture templates. (No co-author trailer — added at squash time.)

#### Phase 3 VbC

- [ ] 15. **VbC (**clean-room**).** Verify each of SC1, SC4, SC9 with its own evidence: `ls` workdir + `git submodule status` for SC1; `HARNESS_FAILURE` exit + no origin wiring for SC4; no orphan GitBucket process + no stale `tmp/` state + clean rerun for SC9. **→ SC1, SC4, SC9**

**Concern transition:** Leaving provisioning/cleanup/rejection → entering GitBucket origin wiring. Phase 4 depends on this phase's fixtures, rejection, and cleanup primitives.

---
