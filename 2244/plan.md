---
plan_schema_version: "1.0"
issue: 2244
title: "Full-environment simulation support in .opencode/tests-v2 test harness"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 10
---

# Implementation Plan — #2244 — Full-Environment Simulation Support in `.opencode/tests-v2` Test Harness

> Issue: https://github.com/michael-conrad/.opencode/issues/2244

**Goal:** Add an opt-in full-environment simulation capability to the `.opencode/tests-v2` behavioral test harness — multi-submodule fixture repos and GitBucket origin wiring — so remote-dependent tests like `2242-sc6-cleanup-dispatch-no-task-card-read.sh` can complete merged-PR discovery and cleanup dispatch without halting, while preserving the default single-`.opencode`/`local` provisioning and the isolation wall.

**Architecture:** Three cooperating capabilities, all opt-in and mutually compatible under a strict env-isolation contract:
- Multi-submodule fixture provisioning (`BEHAVIOR_NEEDS_MULTI_SUBMODULES=1`) creates `test-submodule-1`/`test-submodule-2` as local git repos in the attempt workdir.
- GitBucket origin wiring (`BEHAVIOR_NEEDS_REMOTE=1`) attaches the provisioned GitBucket instance as the test repo's `origin` remote, enabling `gh pr list` discovery without GitHub auth.
- A strict env-set hardening (`SC13–SC17`) keeps the `env -i` allowlist at exactly the minimal infrastructure set and prevents any parent-sourced `GB_*`/secret/credential/token from leaking into the isolated test env.
- Executor authentication (`SC19–SC20`): the full `GB_*` env suite is propagated to the isolated env via `GB_ENV_ARGS` (test-env constants always set, `GB_TOKEN` scoped to the provisioned test instance), and the test home seeds a pre-fabricated `gb` config.toml at `$TEST_HOME/.config/gb/config.toml` so `gb` authenticates deterministically without `gb auth login`. These are prerequisites for the behavioral discovery SCs (SC10/SC11), which the executor cannot authenticate without them.

The phase DAG is enforced by a dependency contract validated by the Z3 solver. Each SC gets its own RED → GREEN → verify → commit cycle; no item covers more than one SC. Each of the 10 phases addresses exactly one concern (C1–C10), so no concern straddles phases and no two phases share a concern.

**Files (sub-folder references):**
- `.opencode/tests-v2/behaviors/helpers.sh` (`behavior_run()`, `__ensure_gitbucket()`, `__reset_gitbucket()`, `__kill_gitbucket()`, `BEHAVIOR_SET_BARE_REMOTE` block, origin-wiring block)
- `.opencode/tests-v2/with-test-home` (`env -i` allowlist, `set-env.sh`, `do_setup`, `seed_model_config`, `do_clean()`, `do_clean_all()`)
- `.opencode/tests-v2/AGENTS.md` (§5 Infrastructure Details, §12 GitBucket)
- `.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh` and its per-scenario fixture
- `.opencode/tests-v2/behaviors/fixtures/` (new multi-submodule fixture templates)

---

## Pre-Implementation Steps

These steps run once before any phase begins.

- [ ] **P1. Coherence gate (**clean-room**).** Verify the plan is coherent with the spec: every SC in the spec is mapped to exactly one item, no item covers multiple SCs, the phase DAG is acyclic and Z3-SAT validated, and no superseding/stale spec exists. **→ all SCs**
- [ ] **P2. Baseline check (**sub-agent**).** Verify the working tree is at trunk tip with zero pending changes, submodules synced, and no stale `tmp/.behavior-run.lock`. Confirm the target files (`with-test-home`, `helpers.sh`, `AGENTS.md`, `2242-sc6` test + fixture) exist. **→ all SCs**

---

## Phase Table

| Phase | Concern | Skill | Task | Target | SCs | Depends On |
|-------|---------|-------|------|--------|-----|------------|
| 1 — allowlist extension + isolation | C4 | `test-driven-development` | `red` | `.opencode/tests-v2/with-test-home` (env -i allowlist, set-env.sh) | SC5, SC6, SC7, SC14, SC15 | — |
| 2 — test-provisioned env rule + GB scoping | C5 | `test-driven-development` | `red` | `.opencode/tests-v2/with-test-home` (do_setup/seed_model_config, GB_* scoping) + `helpers.sh` (`__ensure_gitbucket` scoping) | SC13, SC16, SC17 | 1 |
| 3 — multi-submodule provisioning | C1 | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/helpers.sh` (behavior_run multi-submodule provisioning) | SC1 | 1 |
| 4 — remote-strategy mutual exclusion | C3 | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/helpers.sh` (behavior_run mutual-exclusion rejection) | SC4 | 1 |
| 5 — cleanup | C7 | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/helpers.sh` (`__kill_gitbucket`, `__reset_gitbucket`) + `with-test-home` (do_clean_all) | SC9 | 3, 4 |
| 6 — GitBucket origin wiring + discovery | C2 | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/helpers.sh` (behavior_run origin-wiring + gh pr list) | SC2, SC3 | 2, 3, 4 |
| 7 — 2242-sc6 full-env opt-in + verification | C8 | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh` + fixture setup variant | SC10, SC11, SC12 | 6, 10 |
| 8 — documentation | C9 | `test-driven-development` | `red` | `.opencode/tests-v2/AGENTS.md` (mutual-exclusion + full-env opt-in docs) | SC18 | 4 |
| 9 — no-regression default gate | C6 | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/helpers.sh` (default provisioning path) + `with-test-home` | SC8 | 1, 3, 4, 6 |
| 10 — executor GB_* suite + gb config.toml seeding | C10 | `test-driven-development` | `red` | `.opencode/tests-v2/with-test-home` (GB_ENV_ARGS, env -i invocation, do_setup gb config.toml seeding) + `helpers.sh` (`__ensure_gitbucket` GB_REPO/GB_PROTOCOL export) | SC19, SC20 | 2 |

---

## Phase Details

### Phase 1 — Allowlist Extension + Isolation (Concern C4)

| Field | Value |
|-------|-------|
| Concern | C4 — env -i allowlist extension + isolation |
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/with-test-home` (env -i allowlist, set-env.sh) |
| SCs | SC5, SC6, SC7, SC14, SC15 |
| Depends On | — |

**Context:**
```yaml
concern: C4
target: .opencode/tests-v2/with-test-home
scs: [SC5, SC6, SC7, SC14, SC15]
allowlist_flags_to_add:
  - BEHAVIOR_NEEDS_MULTI_SUBMODULES
  - BEHAVIOR_NEEDS_REMOTE
  - BEHAVIOR_SET_BARE_REMOTE
minimal_infrastructure_set:
  - PATH
  - SHELL
  - TERM
  - LANG
  - USER
  - LOGNAME
  - GIT_CONFIG_NOSYSTEM
  - XDG_*
  - SNAP_USER_DATA
  - SNAP_USER_COMMON
  - test-provisioned values
forbidden_parent_vars:
  - GB_*
  - GITHUB_*
  - GH_*
  - NODE_ENV
  - VIRTUAL_ENV
  - CONDA_DEFAULT_ENV
  - OPENCODE_CONFIG_CONTENT
  - API keys
```

### Phase 2 — Test-Provisioned Env Rule + GB Scoping (Concern C5)

| Field | Value |
|-------|-------|
| Concern | C5 — test-provisioned environment rule + GB_* scoping |
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/with-test-home` (do_setup/seed_model_config, GB_* scoping) + `helpers.sh` (`__ensure_gitbucket` scoping) |
| SCs | SC13, SC16, SC17 |
| Depends On | 1 |

**Context:**
```yaml
concern: C5
target:
  - .opencode/tests-v2/with-test-home
  - .opencode/tests-v2/behaviors/helpers.sh
scs: [SC13, SC16, SC17]
gb_vars: [GB_TOKEN, GB_HOST, GB_REPO, GB_PROTOCOL, GITBUCKET_PORT]
scoping_rule: "parent GB_*/GITBUCKET_PORT never inherited; test-env constants (GB_HOST, GB_REPO, GB_PROTOCOL, GITBUCKET_PORT) always set to harness constants; GB_TOKEN set only when BEHAVIOR_NEEDS_REMOTE=1 to the test instance's generated value"
env_set_rule: "every required test value set by do_setup/seed_model_config/test-home provisioning, never inherited from parent shell"
```

### Phase 3 — Multi-Submodule Provisioning (Concern C1)

| Field | Value |
|-------|-------|
| Concern | C1 — multi-submodule fixture provisioning |
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/helpers.sh` (behavior_run multi-submodule provisioning) |
| SCs | SC1 |
| Depends On | 1 |

**Context:**
```yaml
concern: C1
target: .opencode/tests-v2/behaviors/helpers.sh
scs: [SC1]
multi_submodule_flag: BEHAVIOR_NEEDS_MULTI_SUBMODULES
fixture_repos: [test-submodule-1, test-submodule-2]
```

### Phase 4 — Remote-Strategy Mutual Exclusion (Concern C3)

| Field | Value |
|-------|-------|
| Concern | C3 — remote strategy mutual exclusion |
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/helpers.sh` (behavior_run mutual-exclusion rejection) |
| SCs | SC4 |
| Depends On | 1 |

**Context:**
```yaml
concern: C3
target: .opencode/tests-v2/behaviors/helpers.sh
scs: [SC4]
mutual_exclusion: [BEHAVIOR_NEEDS_REMOTE, BEHAVIOR_SET_BARE_REMOTE]
harness_failure_exit: HARNESS_FAILURE
```

### Phase 5 — Cleanup (Concern C7)

| Field | Value |
|-------|-------|
| Concern | C7 — cleanup of provisioned state |
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/helpers.sh` (`__kill_gitbucket`, `__reset_gitbucket`) + `with-test-home` (do_clean_all) |
| SCs | SC9 |
| Depends On | 3, 4 |

**Context:**
```yaml
concern: C7
target:
  - .opencode/tests-v2/behaviors/helpers.sh
  - .opencode/tests-v2/with-test-home
scs: [SC9]
cleanup_commands: ["--clean-all", "__kill_gitbucket", "__reset_gitbucket"]
```

### Phase 6 — GitBucket Origin Wiring + Discovery (Concern C2)

| Field | Value |
|-------|-------|
| Concern | C2 — GitBucket origin wiring + merged-PR discovery |
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/helpers.sh` (behavior_run origin-wiring + gh pr list) |
| SCs | SC2, SC3 |
| Depends On | 2, 3, 4 |

**Context:**
```yaml
concern: C2
target: .opencode/tests-v2/behaviors/helpers.sh
scs: [SC2, SC3]
remote_flag: BEHAVIOR_NEEDS_REMOTE
origin_remote: origin
discovery_command: gh pr list
```

### Phase 7 — 2242-sc6 Full-Env Opt-In + Verification (Concern C8)

| Field | Value |
|-------|-------|
| Concern | C8 — 2242-sc6 full-env opt-in + cleanup-dispatch verification |
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh` + fixture setup variant |
| SCs | SC10, SC11, SC12 |
| Depends On | 6, 10 |

**Context:**
```yaml
concern: C8
target:
  - .opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh
  - .opencode/tests-v2/behaviors/fixtures/setup/2242-sc6-cleanup-dispatch-no-task-card-read.sh
scs: [SC10, SC11, SC12]
opt_in_flags:
  BEHAVIOR_NEEDS_MULTI_SUBMODULES: "1"
  BEHAVIOR_NEEDS_REMOTE: "1"
forbidden_tool_timeline: ["question-tool call", "PR/branch-context halt"]
measure_rule: "Discovery yielding the merged branch that lets cleanup execute correctly IS the measure (any discovery mechanism); the specific discovery command is NOT. Whether the orchestrator read the task card is NOT the measure; correct task-card instruction-following and completed dispatch IS."
sc11_measure: "git-workflow-cleanup dispatch follows the correct task card (tasks/cleanup.md) instructions and completes, producing a result contract"
```

### Phase 8 — Documentation (Concern C9)

| Field | Value |
|-------|-------|
| Concern | C9 — documentation of mutual-exclusion + full-env opt-in |
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/AGENTS.md` (mutual-exclusion + full-env opt-in docs) |
| SCs | SC18 |
| Depends On | 4 |

**Context:**
```yaml
concern: C9
target: .opencode/tests-v2/AGENTS.md
scs: [SC18]
mutual_exclusion_rule: "BEHAVIOR_NEEDS_MULTI_SUBMODULES / BEHAVIOR_SET_BARE_REMOTE"
sections: ["§5 Infrastructure Details", "§12 GitBucket"]
```

### Phase 9 — No-Regression Default Gate (Concern C6)

| Field | Value |
|-------|-------|
| Concern | C6 — no-regression default gate |
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/helpers.sh` (default provisioning path) + `with-test-home` |
| SCs | SC8 |
| Depends On | 1, 3, 4, 6 |

**Context:**
```yaml
concern: C6
target:
  - .opencode/tests-v2/behaviors/helpers.sh
  - .opencode/tests-v2/with-test-home
scs: [SC8]
default_provisioning: "single .opencode submodule + local platform, no origin remote"
```

### Phase 10 — Executor GB_* Suite + gb Config.toml Seeding (Concern C10)

| Field | Value |
|-------|-------|
| Concern | C10 — executor full GB_* suite (test-env constants always + GB_TOKEN scoped) + gb config.toml seeding |
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/with-test-home` (GB_ENV_ARGS, env -i invocation, do_setup gb config.toml seeding) + `helpers.sh` (`__ensure_gitbucket` GB_REPO/GB_PROTOCOL export + token scoping) |
| SCs | SC19, SC20 |
| Depends On | 2 |

**Context:**
```yaml
concern: C10
target:
  - .opencode/tests-v2/with-test-home
  - .opencode/tests-v2/behaviors/helpers.sh
scs: [SC19, SC20]
gb_full_suite: [GB_TOKEN, GB_HOST, GITBUCKET_PORT, GB_REPO, GB_PROTOCOL]
test_env_constants: [GB_HOST, GB_REPO, GB_PROTOCOL, GITBUCKET_PORT]
scoping_rule: "test-env constants always set to harness constants; GB_TOKEN scoped to provisioned test instance only when BEHAVIOR_NEEDS_REMOTE=1; no parent-sourced value"
gb_config_path: "$TEST_HOME/.config/gb/config.toml"
gb_default_host_constant: "harness test-env default_host"
```

---

## Exit Criteria

- [ ] C1. `env -i` allowlist in `with-test-home` passes through the three new flags (`BEHAVIOR_NEEDS_MULTI_SUBMODULES`, `BEHAVIOR_NEEDS_REMOTE`, `BEHAVIOR_SET_BARE_REMOTE`) as a strict superset with no removals, and `set-env.sh` records them (SC5, SC6). The isolation verification procedure still passes after the extension (SC7). The allowlist contains ONLY the minimal explicitly enumerated infrastructure set (SC14) and excludes all parent-sourced secret/credential/token/env-specific variables (SC15).
- [ ] C2. Every required test value is set by `do_setup`/`seed_model_config`/test-home provisioning, never inherited from the parent shell (SC13, SC16); `GB_*`/`GITBUCKET_PORT` are absent from the test env unless scoped to the provisioned test GitBucket instance (SC17).
- [ ] C3. `behavior_run()` provisions `test-submodule-1`/`test-submodule-2` when `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1`, and not when unset (SC1).
- [ ] C4. Both `BEHAVIOR_NEEDS_REMOTE=1` and `BEHAVIOR_SET_BARE_REMOTE=1` together exit with `HARNESS_FAILURE` and do not attempt origin wiring (SC4).
- [ ] C5. `--clean-all`/`__kill_gitbucket`/`__reset_gitbucket` remove all provisioned clones and GitBucket state, leaving no orphans; a repeated run starts clean (SC9).
- [ ] C6. With `BEHAVIOR_NEEDS_REMOTE=1` and GitBucket provisioned, `git remote -v` in the attempt workdir shows the GitBucket `origin` (SC2), and `gh pr list` in the isolated env discovers merged branches/open issues without GitHub auth and the agent does not halt for PR/branch context (SC3).
- [ ] C7. `2242-sc6-cleanup-dispatch-no-task-card-read.sh` with the full-env opt-in completes merged-PR discovery — the full-env opt-in enables the agent to discover the merged branch/PR state needed to execute cleanup (via any discovery mechanism; the specific command is NOT the measure) (SC10) — and the cleanup dispatch follows the correct task card (`tasks/cleanup.md`) instructions and completes, producing a result contract (SC11), and without halting for PR/branch context (SC12).
- [ ] C8. `.opencode/tests-v2/AGENTS.md` documents the mutual-exclusion rule and the new opt-in capability (SC18).
- [ ] C9. With no opt-in flags set, default provisioning remains byte-for-byte the single-`.opencode`/`local` platform for the ~80 existing tests (no regression, SC8).
- [ ] C10. When `BEHAVIOR_NEEDS_REMOTE=1` provisions a test GitBucket, `with-test-home` propagates the full `GB_*` env suite (`GB_TOKEN`, `GB_HOST`, `GITBUCKET_PORT`, `GB_REPO`, `GB_PROTOCOL`) into the isolated test env via `GB_ENV_ARGS` — the test-env constants (`GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GITBUCKET_PORT`) are always set to the harness's constants, `GB_TOKEN` is scoped to the provisioned test instance only when `BEHAVIOR_NEEDS_REMOTE=1`, and no value is sourced from the parent env (SC19); and the test home seeds a pre-fabricated `gb` config.toml at `$TEST_HOME/.config/gb/config.toml` with the harness's `default_host` constant and the host token only when GitBucket is provisioned, so `gb` authenticates without `gb auth login` (SC20).
- [ ] C11. All 20 SCs map to exactly one item each; no item covers multiple SCs; the phase DAG is acyclic and Z3-SAT validated; each of the 10 phases addresses exactly one concern (C1–C10).

---

## lifecycle_events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-04T18:21:00Z | `plan_created` | Plan file: `.opencode/.issues/2244/plan.md`, 9 phases |
| 2026-08-05T17:38:00Z | `plan_revised` | Plan file: `.opencode/.issues/2244/plan.md`, 10 phases — added Phase 10 (C10, SC19/SC20 executor GB_* suite + gb config.toml seeding) as a prerequisite of Phase 7; corrected SC17 semantics to test-env constants always set + GB_TOKEN provisioned-scoped; 20-SC coverage |
