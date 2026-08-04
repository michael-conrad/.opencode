# Phase 6 — GitBucket Origin Wiring + Discovery (Concern C2)

**Concern:** C2 — GitBucket origin wiring + merged-PR discovery. Wire the provisioned GitBucket instance as the test repo's `origin` remote (SC2) so `gh pr list` has something to query in the isolated test env, and verify discovery succeeds without GitHub auth and without halting for PR/branch context (SC3).

**Files:**
- `.opencode/tests-v2/behaviors/helpers.sh` (behavior_run origin-wiring + __ensure_gitbucket + gh pr list in isolated env)

**SCs:** SC2, SC3

**Dependencies:** Phase 2, Phase 3, Phase 4

**Entry Conditions:**
- Phase 2 complete: scoped `GB_*` values in place; VbC passed.
- Phase 3 complete: multi-submodule fixtures in place; VbC passed.
- Phase 4 complete: mutual-exclusion rejection in place; VbC passed.
- `__ensure_gitbucket()` and the origin-wiring block in `helpers.sh` read.

**Exit Conditions:**
- When `BEHAVIOR_NEEDS_REMOTE=1` and GitBucket is provisioned, `git remote -v` in the attempt workdir shows the GitBucket `origin`.
- Mutual exclusion with `BEHAVIOR_SET_BARE_REMOTE` is preserved (no ambiguous wiring).
- `gh pr list` in the isolated env returns merged-branch/issue results without GitHub auth.
- The agent does not halt for missing PR/branch context.

---

- [ ] 26. **RED (**sub-agent**).** Write failing enforcement tests asserting: (a) with `BEHAVIOR_NEEDS_REMOTE=1` no `origin` remote is attached in the attempt workdir; (b) `opencode run` with `BEHAVIOR_NEEDS_REMOTE=1` fails to produce `gh pr list` output or halts for missing PR context. **→ SC2, SC3**

- [ ] 27. **GREEN (**sub-agent**).** In `helpers.sh` `behavior_run()`: ensure the origin-wiring block attaches the GitBucket instance as `origin` when `BEHAVIOR_NEEDS_REMOTE=1` and GitBucket is provisioned. If GitBucket provisioning fails, print `HARNESS_FAILURE: GitBucket provisioning failed` and return 1. Discovery depends on the wired origin; only adjust if wiring proves insufficient for `gh pr list`. **→ SC2, SC3**

- [ ] 28. **GREEN doublecheck (**clean-room**).** Run with `BEHAVIOR_NEEDS_REMOTE=1`; confirm `git remote -v` in the attempt workdir shows the GitBucket `origin`. Confirm both-remote-flags rejection from Phase 4 still prevents ambiguous wiring. Run `opencode run` and evaluate `session.yaml` to confirm `gh pr list` returns merged-branch/issue results and no PR-context halt. **→ SC2, SC3**

- [ ] 29. **Checkpoint commit (**inline**).** Commit `helpers.sh` origin-wiring + discovery logic. (No co-author trailer — added at squash time.)

#### Phase 6 VbC

- [ ] 30. **VbC (**clean-room**).** Verify SC2 and SC3 individually: with `BEHAVIOR_NEEDS_REMOTE=1` and GitBucket provisioned, `git remote -v` shows the GitBucket `origin` (SC2); clean-room `session.yaml` evaluation confirms `gh pr list` returned merged branches/open issues without GitHub auth and no PR-context halt (SC3). **→ SC2, SC3**

**Concern transition:** Leaving C2 (GitBucket origin wiring + discovery) → entering C8 (2242-sc6 full-env opt-in + verification). Phase 7 depends on this phase's wired origin; Phase 9 depends on this phase's origin wiring.
