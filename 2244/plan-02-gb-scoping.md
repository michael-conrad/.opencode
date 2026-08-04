# Phase 2 — GB Scoping

**Concern:** The concrete instance of the general env-set rule — `GB_*`/`GITBUCKET_PORT` environment variables are absent from the isolated test env unless scoped to the provisioned test GitBucket instance, and no parent-sourced `GB_*` value leaks through.

**Files:**
- `.opencode/tests-v2/with-test-home` (env -i allowlist, set-env.sh)
- `.opencode/tests-v2/behaviors/helpers.sh` (`__ensure_gitbucket` scoping)

**SCs:** SC17

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `env -i` allowlist + set-env.sh refactored to minimal set; VbC passed.
- `__ensure_gitbucket()` in `helpers.sh` read to understand current `GB_*` sourcing.

**Exit Conditions:**
- Parent-sourced `GB_*`/`GITBUCKET_PORT` never propagate into the test env.
- When `BEHAVIOR_NEEDS_REMOTE=1` provisions GitBucket, `GB_TOKEN`/`GB_HOST`/`GITBUCKET_PORT` are set to the test instance's generated values.
- When no GitBucket is provisioned, these vars are absent/empty.

---

- [ ] 6. **RED (**sub-agent**).** Write a failing enforcement test showing `GB_TOKEN`/`GB_HOST`/`GITBUCKET_PORT` values present in the test env from the parent shell when no GitBucket is provisioned (or inherited values when GitBucket IS provisioned). **→ SC17**

- [ ] 7. **GREEN (**sub-agent**).** In `with-test-home`, remove parent-sourced `GB_*`/`GITBUCKET_PORT` from the `env -i` allowlist and `set-env.sh`; in `helpers.sh` `__ensure_gitbucket()`, set `GB_TOKEN`/`GB_HOST`/`GITBUCKET_PORT` to the test instance's generated values only when `BEHAVIOR_NEEDS_REMOTE=1`, and leave them absent/empty otherwise. **→ SC17**

- [ ] 8. **GREEN doublecheck (**clean-room**).** Inspect the `env -i` allowlist + `set-env.sh` for parent-sourced `GB_*`; with a parent `GB_TOKEN`/`GB_HOST`/`GITBUCKET_PORT` set, confirm the test env has no `GB_*` when no GitBucket is provisioned and the scoped test-instance values when provisioned. **→ SC17**

- [ ] 9. **Checkpoint commit (**inline**).** Commit `with-test-home` + `helpers.sh` GB_* scoping changes. (No co-author trailer — added at squash time.)

#### Phase 2 VbC

- [ ] 10. **VbC (**clean-room**).** Verify SC17 with a parent env carrying representative `GB_*` values: no `GB_*`/`GITBUCKET_PORT` in the test env when no GitBucket is provisioned; scoped test-instance values when provisioned. **→ SC17**

**Concern transition:** Leaving GB_* scoping → entering provisioning/cleanup/rejection primitives. Phase 3 depends on Phase 1's env isolation foundation; Phase 4 depends on this phase's scoped `GB_*` values.

---
