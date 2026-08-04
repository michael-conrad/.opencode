# Phase 4 — GitBucket Origin Wiring

**Concern:** Wire the provisioned GitBucket instance as the test repo's `origin` remote so `gh pr list` has something to query in the isolated test env.

**Files:**
- `.opencode/tests-v2/behaviors/helpers.sh` (behavior_run origin-wiring + __ensure_gitbucket)

**SCs:** SC2

**Dependencies:** Phase 1, Phase 2, Phase 3

**Entry Conditions:**
- Phases 1, 2, 3 complete: env isolation, scoped `GB_*`, fixtures/cleanup/rejection primitives in place; VbCs passed.
- `__ensure_gitbucket()` and the origin-wiring block in `helpers.sh` read.

**Exit Conditions:**
- When `BEHAVIOR_NEEDS_REMOTE=1` and GitBucket is provisioned, `git remote -v` in the attempt workdir shows the GitBucket `origin`.
- Mutual exclusion with `BEHAVIOR_SET_BARE_REMOTE` is preserved (no ambiguous wiring).

---

- [ ] 16. **RED (**sub-agent**).** Write a failing enforcement test with `BEHAVIOR_NEEDS_REMOTE=1` showing no `origin` remote attached in the attempt workdir. **→ SC2**

- [ ] 17. **GREEN (**sub-agent**).** In `helpers.sh` `behavior_run()`, ensure the origin-wiring block attaches the GitBucket instance as `origin` when `BEHAVIOR_NEEDS_REMOTE=1` and GitBucket is provisioned. If GitBucket provisioning fails, print `HARNESS_FAILURE: GitBucket provisioning failed` and return 1. **→ SC2**

- [ ] 18. **GREEN doublecheck (**clean-room**).** Run with `BEHAVIOR_NEEDS_REMOTE=1`; confirm `git remote -v` in the attempt workdir shows the GitBucket `origin`. Confirm both-remote-flags rejection from Phase 3 still prevents ambiguous wiring. **→ SC2**

- [ ] 19. **Checkpoint commit (**inline**).** Commit `helpers.sh` origin-wiring logic. (No co-author trailer — added at squash time.)

#### Phase 4 VbC

- [ ] 20. **VbC (**clean-room**).** Verify SC2: with `BEHAVIOR_NEEDS_REMOTE=1` and GitBucket provisioned, `git remote -v` shows the GitBucket `origin` in the attempt workdir. **→ SC2**

**Concern transition:** Leaving GitBucket origin wiring → entering merged-PR discovery. Phase 5 and Phase 6 depend on Phase 4's wired origin.

---
