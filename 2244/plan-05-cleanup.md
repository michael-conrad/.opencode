# Phase 5 — Cleanup (Concern C7)

**Concern:** C7 — cleanup of provisioned state. `--clean-all`/`__kill_gitbucket`/`__reset_gitbucket` remove provisioned submodule clones and GitBucket state, leaving no orphans; a repeated run starts clean.

**Files:**
- `.opencode/tests-v2/behaviors/helpers.sh` (`__kill_gitbucket`, `__reset_gitbucket`)
- `.opencode/tests-v2/with-test-home` (do_clean_all)

**SCs:** SC9

**Dependencies:** Phase 3, Phase 4

**Entry Conditions:**
- Phase 3 complete: multi-submodule fixture provisioning in place; VbC passed.
- Phase 4 complete: remote-strategy mutual-exclusion rejection in place; VbC passed.
- `do_clean_all()` in `with-test-home` and `__kill_gitbucket()`/`__reset_gitbucket()` in `helpers.sh` read.

**Exit Conditions:**
- `--clean-all`/`__kill_gitbucket`/`__reset_gitbucket` remove all provisioned clones and GitBucket state, leaving no orphans.
- A repeated run starts clean.

---

- [ ] 21. **RED (**sub-agent**).** Write a failing enforcement test asserting a provisioned run leaves an orphan GitBucket process / stale clones after `--clean-all`. **→ SC9**

- [ ] 22. **GREEN (**sub-agent**).** In `with-test-home` `do_clean_all()` and `helpers.sh` `__kill_gitbucket()`/`__reset_gitbucket()`: remove provisioned submodule clones, kill the GitBucket process, and remove stale `tmp/` state. **→ SC9**

- [ ] 23. **GREEN doublecheck (**clean-room**).** Verify `--clean-all`/`__kill_gitbucket` leave no orphan clones or GitBucket process; rerun confirms clean start. **→ SC9**

- [ ] 24. **Checkpoint commit (**inline**).** Commit `helpers.sh` + `with-test-home` cleanup changes. (No co-author trailer — added at squash time.)

#### Phase 5 VbC

- [ ] 25. **VbC (**clean-room**).** Verify SC9: no orphan GitBucket process + no stale `tmp/` state + clean rerun after `--clean-all`. **→ SC9**

**Concern transition:** Leaving C7 (cleanup) → entering C2 (GitBucket origin wiring + discovery). Phase 6 depends on Phase 2 (scoped GB_*), Phase 3 (fixture repos), and Phase 4 (mutual-exclusion rejection); Phase 9 depends on Phase 3 and Phase 4.
