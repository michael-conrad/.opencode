# Phase 2 — Test-Provisioned Env Rule + GB Scoping (Concern C5)

**Concern:** C5 — test-provisioned environment rule + GB_* scoping. The general env-set rule holds — every required test value is provisioned by the test setup itself (SC13), required values are generated/set by the setup (SC16) — and the concrete GB_* instance: the test-env constants (`GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GITBUCKET_PORT`) are ALWAYS set to the harness's test-env constant values in the isolated test env, and only `GB_TOKEN` (the secret credential) is scoped to the provisioned test GitBucket instance when `BEHAVIOR_NEEDS_REMOTE=1` (SC17). No parent-sourced `GB_*`/`GITBUCKET_PORT` value is ever inherited.

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
- The test-env constants (`GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GITBUCKET_PORT`) are always set to the harness's test-env constant values.
- When `BEHAVIOR_NEEDS_REMOTE=1` provisions GitBucket, `GB_TOKEN` is set to the test instance's generated value; otherwise it is absent/empty.
- `do_setup`/`seed_model_config`/test-home provisioning set every required test value (model/config/token/host).

---

- [ ] 6. **RED (**sub-agent**).** Write failing enforcement tests asserting: (a) a required test value (model/config) is inherited rather than set by the setup; (b) the test-env constants (`GB_HOST`/`GB_REPO`/`GB_PROTOCOL`/`GITBUCKET_PORT`) are absent from the test env, or a parent-sourced `GB_*`/`GITBUCKET_PORT` value (including a parent `GB_TOKEN`) is present in the test env when no GitBucket is provisioned (or inherited values when GitBucket IS provisioned). **→ SC13, SC16, SC17**

- [ ] 7. **GREEN (**sub-agent**).** In `with-test-home`: ensure `do_setup`/`seed_model_config`/test-home provisioning set model/config values; remove parent-sourced `GB_*`/`GITBUCKET_PORT` from the `env -i` allowlist and `set-env.sh`; set the test-env constants (`GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GITBUCKET_PORT`) to the harness's constant values always. In `helpers.sh` `__ensure_gitbucket()`, scope `GB_TOKEN` to the test instance's generated value only when `BEHAVIOR_NEEDS_REMOTE=1`, and leave it absent/empty otherwise. **→ SC13, SC16, SC17**

- [ ] 8. **GREEN doublecheck (**clean-room**).** Inspect `do_setup`/`seed_model_config` for value generation; inspect the `env -i` allowlist + `set-env.sh` for parent-sourced `GB_*`; with a parent `GB_TOKEN`/`GB_HOST`/`GITBUCKET_PORT` set, confirm the test env has the harness's test-env constants (no parent-sourced value), with `GB_TOKEN` scoped to the test instance only when provisioned. **→ SC13, SC16, SC17**

- [ ] 9. **Checkpoint commit (**inline**).** Commit `with-test-home` + `helpers.sh` GB_* scoping and value-generation changes. (No co-author trailer — added at squash time.)

#### Phase 2 VbC

- [ ] 10. **VbC (**clean-room**).** Verify SC13, SC16, SC17 individually: confirm `do_setup`/`seed_model_config` set required values (SC13, SC16); run the isolation verification procedure with a parent env carrying representative `GB_*` values — no parent-sourced `GB_*`/`GITBUCKET_PORT` in the test env; the test-env constants always present as harness constants; `GB_TOKEN` scoped to the test instance only when provisioned (SC17). **→ SC13, SC16, SC17**

**Concern transition:** Leaving C5 (test-provisioned env rule + GB scoping) → entering C1 (multi-submodule provisioning) and C3 (remote-strategy mutual exclusion). Phase 3 and Phase 4 depend on Phase 1's allowlist; Phase 6 depends on this phase's scoped `GB_*` values; Phase 10 depends on this phase's test-env constants + `GB_TOKEN` scoping.
