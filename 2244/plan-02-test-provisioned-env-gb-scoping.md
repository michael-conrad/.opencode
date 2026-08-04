# Phase 2 — Test-Provisioned Env Rule + GB Scoping (Concern C5)

**Concern:** C5 — test-provisioned environment rule + GB_* scoping. The general env-set rule holds — every required test value is provisioned by the test setup itself (SC13), required values are generated/set by the setup (SC16) — and the concrete GB_* instance: `GB_*`/`GITBUCKET_PORT` are absent from the isolated test env unless scoped to the provisioned test GitBucket instance (SC17).

**Files:**
- `.opencode/tests-v2/with-test-home` (do_setup, seed_model_config, GB_* scoping in allowlist/set-env.sh)
- `.opencode/tests-v2/behaviors/helpers.sh` (`__ensure_gitbucket` scoping)

**SCs:** SC13, SC16, SC17

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `env -i` allowlist + set-env.sh refactored to minimal set; VbC passed.
- `do_setup`/`seed_model_config` and `__ensure_gitbucket()` in `helpers.sh` read to understand current value generation and `GB_*` sourcing.

**Exit Conditions:**
- Parent-sourced `GB_*`/`GITBUCKET_PORT` never propagate into the test env.
- When `BEHAVIOR_NEEDS_REMOTE=1` provisions GitBucket, `GB_TOKEN`/`GB_HOST`/`GITBUCKET_PORT` are set to the test instance's generated values.
- When no GitBucket is provisioned, these vars are absent/empty.
- `do_setup`/`seed_model_config`/test-home provisioning set every required test value (model/config/token/host).

---

- [ ] 6. **RED (**sub-agent**).** Write failing enforcement tests asserting: (a) a required test value (model/config) is inherited rather than set by the setup; (b) `GB_TOKEN`/`GB_HOST`/`GITBUCKET_PORT` values present in the test env from the parent shell when no GitBucket is provisioned (or inherited values when GitBucket IS provisioned). **→ SC13, SC16, SC17**

- [ ] 7. **GREEN (**sub-agent**).** In `with-test-home`: ensure `do_setup`/`seed_model_config`/test-home provisioning set model/config values; remove parent-sourced `GB_*`/`GITBUCKET_PORT` from the `env -i` allowlist and `set-env.sh`. In `helpers.sh` `__ensure_gitbucket()`, set `GB_TOKEN`/`GB_HOST`/`GITBUCKET_PORT` to the test instance's generated values only when `BEHAVIOR_NEEDS_REMOTE=1`, and leave them absent/empty otherwise. **→ SC13, SC16, SC17**

- [ ] 8. **GREEN doublecheck (**clean-room**).** Inspect `do_setup`/`seed_model_config` for value generation; inspect the `env -i` allowlist + `set-env.sh` for parent-sourced `GB_*`; with a parent `GB_TOKEN`/`GB_HOST`/`GITBUCKET_PORT` set, confirm the test env has no `GB_*` when no GitBucket is provisioned and the scoped test-instance values when provisioned. **→ SC13, SC16, SC17**

- [ ] 9. **Checkpoint commit (**inline**).** Commit `with-test-home` + `helpers.sh` GB_* scoping and value-generation changes. (No co-author trailer — added at squash time.)

#### Phase 2 VbC

- [ ] 10. **VbC (**clean-room**).** Verify SC13, SC16, SC17 individually: confirm `do_setup`/`seed_model_config` set required values (SC13, SC16); run the isolation verification procedure with a parent env carrying representative `GB_*` values — no `GB_*`/`GITBUCKET_PORT` in the test env when no GitBucket is provisioned; scoped test-instance values when provisioned (SC17). **→ SC13, SC16, SC17**

**Concern transition:** Leaving C5 (test-provisioned env rule + GB scoping) → entering C1 (multi-submodule provisioning) and C3 (remote-strategy mutual exclusion). Phase 3 and Phase 4 depend on Phase 1's allowlist; Phase 6 depends on this phase's scoped `GB_*` values.
