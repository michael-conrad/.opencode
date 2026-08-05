# Phase 10 — Executor GB_* Suite + gb Config.toml Seeding (Concern C10)

**Concern:** C10 — executor full GB_* suite + gb config.toml seeding. When `BEHAVIOR_NEEDS_REMOTE=1` provisions a test GitBucket, the full `GB_*` env suite (`GB_TOKEN`, `GB_HOST`, `GITBUCKET_PORT`, `GB_REPO`, `GB_PROTOCOL`) is propagated into the isolated test env via `GB_ENV_ARGS` — the test-env constants (`GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GITBUCKET_PORT`) always set to the harness's constants, `GB_TOKEN` scoped to the provisioned test instance only (SC19) — and the test home seeds a pre-fabricated `gb` config.toml at `$TEST_HOME/.config/gb/config.toml` so `gb` authenticates deterministically without `gb auth login` (SC20). This phase is a prerequisite for the behavioral discovery SCs (SC10/SC11) because the executor cannot authenticate `gb` to discover merged PRs until both the complete `GB_*` env suite reaches it and the test home carries a seeded `gb` config.

**Files:**
- `.opencode/tests-v2/with-test-home` (GB_ENV_ARGS, env -i invocation, do_setup gb config.toml seeding)
- `.opencode/tests-v2/behaviors/helpers.sh` (`__ensure_gitbucket` GB_REPO/GB_PROTOCOL export + token scoping)

**SCs:** SC19, SC20

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: the test-env constants (`GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GITBUCKET_PORT`) always set and `GB_TOKEN` provisioned-scoped; VbC passed.
- `GB_ENV_ARGS`, the `env -i` invocation, `do_setup`/test-home provisioning in `with-test-home`, and `__ensure_gitbucket()` in `helpers.sh` read.
- The `gb` config.toml format validated in `.opencode/.issues/2059/spec.md` read to mirror the `default_host` + host-token format.

**Exit Conditions:**
- `GB_ENV_ARGS` carries the full `GB_*` suite (`GB_TOKEN`, `GB_HOST`, `GITBUCKET_PORT`, `GB_REPO`, `GB_PROTOCOL`) into the isolated test env when `BEHAVIOR_NEEDS_REMOTE=1`.
- The test-env constants are always set to the harness's constants; `GB_TOKEN` is scoped to the provisioned test instance only when `BEHAVIOR_NEEDS_REMOTE=1`, absent/empty otherwise.
- No value is sourced from the parent env.
- The test home seeds `$TEST_HOME/.config/gb/config.toml` with the harness's `default_host` constant and the host token only when GitBucket is provisioned, so `gb` authenticates without `gb auth login`.

---

- [ ] 46. **RED (**sub-agent**).** Write failing enforcement tests asserting: (a) the `GB_ENV_ARGS` array in `with-test-home` carries fewer than the full `GB_*` suite (`GB_TOKEN`, `GB_HOST`, `GITBUCKET_PORT`, `GB_REPO`, `GB_PROTOCOL`) when `BEHAVIOR_NEEDS_REMOTE=1`, or that the test-env constants (`GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GITBUCKET_PORT`) are not always set; (b) the test home has no `$TEST_HOME/.config/gb/config.toml` after `BEHAVIOR_NEEDS_REMOTE=1` setup. **→ SC19, SC20**

- [ ] 47. **GREEN (**sub-agent**).** In `with-test-home`: set the test-env constants (`GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GITBUCKET_PORT`) in `GB_ENV_ARGS`/`env -i` invocation to the harness's constant values always; add a `gb` config.toml seeding block to `do_setup`/test-home provisioning that writes `$TEST_HOME/.config/gb/config.toml` with the harness's `default_host` constant and the host token matching the provisioned test GitBucket instance (token present only when `BEHAVIOR_NEEDS_REMOTE=1`; mirroring the fixture in `.opencode/.issues/2059/spec.md`). In `helpers.sh` `__ensure_gitbucket()`, export `GB_REPO` and `GB_PROTOCOL` for the provisioned test instance and scope `GB_TOKEN` to the test instance when `BEHAVIOR_NEEDS_REMOTE=1`. The `env -i` allowlist guard (no parent-sourced `GB_*`) must hold. **→ SC19, SC20**

- [ ] 48. **GREEN doublecheck (**clean-room**).** Inspect the `GB_ENV_ARGS` array and `env -i` invocation in `with-test-home`; confirm the four test-env constants are always set to the harness's constants and `GB_TOKEN` is populated from the test instance only when `BEHAVIOR_NEEDS_REMOTE=1`. Run with `BEHAVIOR_NEEDS_REMOTE=1` and confirm `$TEST_HOME/.config/gb/config.toml` exists with the harness's `default_host` and the test instance's token; run with the flag unset and confirm `GB_TOKEN`/token absent and `default_host` still set. **→ SC19, SC20**

- [ ] 49. **Checkpoint commit (**inline**).** Commit `with-test-home` (`GB_ENV_ARGS`, `do_setup`, test-home provisioning) + `helpers.sh` (`__ensure_gitbucket` GB_REPO/GB_PROTOCOL export + token scoping). (No co-author trailer — added at squash time.)

#### Phase 10 VbC

- [ ] 50. **VbC (**clean-room**).** Verify SC19 and SC20 individually: confirm `GB_ENV_ARGS` carries the full `GB_*` suite with test-env constants always set and `GB_TOKEN` scoped to the provisioned instance only when `BEHAVIOR_NEEDS_REMOTE=1`, no parent-sourced value (SC19); confirm the seeded `$TEST_HOME/.config/gb/config.toml` carries the harness `default_host` constant and the host token only when GitBucket is provisioned, enabling `gb` auth without `gb auth login` (SC20). **→ SC19, SC20**

**Concern transition:** Leaving C10 (executor GB_* suite + gb config.toml seeding) → enabling C8 (2242-sc6 full-env opt-in + verification). Phase 7 depends on this phase's full `GB_*` suite + seeded `gb` config.toml so the executor can authenticate `gb` to discover merged PRs.
