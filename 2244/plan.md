---
plan_schema_version: "1.0"
issue: 2244
title: "Full-environment simulation support in .opencode/tests-v2 test harness"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 9
---

# Implementation Plan — #2244 — Full-Environment Simulation Support in `.opencode/tests-v2` Test Harness

> Issue: https://github.com/michael-conrad/.opencode/issues/2244

**Goal:** Add an opt-in full-environment simulation capability to the `.opencode/tests-v2` behavioral test harness — multi-submodule fixture repos and GitBucket origin wiring — so remote-dependent tests like `2242-sc6-cleanup-dispatch-no-task-card-read.sh` can complete merged-PR discovery and cleanup dispatch without halting, while preserving the default single-`.opencode`/`local` provisioning and the isolation wall.

**Architecture:** Three cooperating capabilities, all opt-in and mutually compatible under a strict env-isolation contract:
- Multi-submodule fixture provisioning (`BEHAVIOR_NEEDS_MULTI_SUBMODULES=1`) creates `test-submodule-1`/`test-submodule-2` as local git repos in the attempt workdir.
- GitBucket origin wiring (`BEHAVIOR_NEEDS_REMOTE=1`) attaches the provisioned GitBucket instance as the test repo's `origin` remote, enabling `gh pr list` discovery without GitHub auth.
- A strict env-set hardening (`SC13–SC17`) keeps the `env -i` allowlist at exactly the minimal infrastructure set and prevents any parent-sourced `GB_*`/secret/credential/token from leaking into the isolated test env.

The phase DAG is enforced by a dependency contract validated by the Z3 solver (SAT, 9-phase linear order: 1 → 3 → 2 → 4 → 6 → 5 → 7 → 8 → 9). Each SC gets its own RED → GREEN → verify → commit cycle; no item covers more than one SC.

**Files (sub-folder references):**
- `.opencode/tests-v2/behaviors/helpers.sh` (`behavior_run()`, `__ensure_gitbucket()`, `__reset_gitbucket()`, `__kill_gitbucket()`, `BEHAVIOR_SET_BARE_REMOTE` block, origin-wiring block)
- `.opencode/tests-v2/with-test-home` (`env -i` allowlist, `set-env.sh`, `do_setup`, `seed_model_config`, `do_clean()`, `do_clean_all()`)
- `.opencode/tests-v2/AGENTS.md` (§5 Infrastructure Details, §12 GitBucket)
- `.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh` and its per-scenario fixture
- `.opencode/tests-v2/behaviors/fixtures/` (new multi-submodule fixture templates)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — env isolation foundation | `test-driven-development` | `red` | `.opencode/tests-v2/with-test-home` (env -i allowlist, set-env.sh, do_setup, seed_model_config) | SC5, SC6, SC13, SC14, SC15, SC16 | — |
| 2 — GB scoping | `test-driven-development` | `red` | `.opencode/tests-v2/with-test-home` (allowlist/set-env.sh) + `helpers.sh` (`__ensure_gitbucket` scoping) | SC17 | 1 |
| 3 — provisioning, cleanup, rejection | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/helpers.sh` (behavior_run provisioning/cleanup) + `with-test-home` (do_clean_all) | SC1, SC4, SC9 | 1 |
| 4 — GitBucket origin wiring | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/helpers.sh` (behavior_run origin-wiring + __ensure_gitbucket) | SC2 | 1, 2, 3 |
| 5 — merged-PR discovery | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/helpers.sh` (gh pr list in isolated env) | SC3 | 4 |
| 6 — 2242-sc6 full-env opt-in | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh` + fixture setup variant | SC10 | 4 |
| 7 — 2242-sc6 verification | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh` (session.yaml tool timeline) | SC11, SC12 | 6 |
| 8 — documentation | `test-driven-development` | `red` | `.opencode/tests-v2/AGENTS.md` (mutual-exclusion + full-env opt-in docs) | SC18 | — |
| 9 — no-regression default gate | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/helpers.sh` (default provisioning path) + `with-test-home` | SC8 | 1, 3, 4 |

---

## Phase Details

### Phase 1 — Env Isolation Foundation

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/with-test-home` (env -i allowlist, set-env.sh, do_setup, seed_model_config) |
| SCs | SC5, SC6, SC13, SC14, SC15, SC16 |
| Depends On | — |

**Context:**
```yaml
target: .opencode/tests-v2/with-test-home
scs: [SC5, SC6, SC13, SC14, SC15, SC16]
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

### Phase 2 — GB Scoping

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/with-test-home` (allowlist/set-env.sh) + `helpers.sh` (`__ensure_gitbucket` scoping) |
| SCs | SC17 |
| Depends On | 1 |

**Context:**
```yaml
target:
  - .opencode/tests-v2/with-test-home
  - .opencode/tests-v2/behaviors/helpers.sh
scs: [SC17]
gb_vars: [GB_TOKEN, GB_HOST, GITBUCKET_PORT]
scoping_rule: "parent GB_*/GITBUCKET_PORT never inherited; set to test instance generated values only when BEHAVIOR_NEEDS_REMOTE=1"
```

### Phase 3 — Provisioning, Cleanup, Rejection

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/helpers.sh` (behavior_run provisioning/cleanup) + `with-test-home` (do_clean_all) |
| SCs | SC1, SC4, SC9 |
| Depends On | 1 |

**Context:**
```yaml
target:
  - .opencode/tests-v2/behaviors/helpers.sh
  - .opencode/tests-v2/with-test-home
scs: [SC1, SC4, SC9]
multi_submodule_flag: BEHAVIOR_NEEDS_MULTI_SUBMODULES
fixture_repos: [test-submodule-1, test-submodule-2]
mutual_exclusion: [BEHAVIOR_NEEDS_REMOTE, BEHAVIOR_SET_BARE_REMOTE]
harness_failure_exit: HARNESS_FAILURE
```

### Phase 4 — GitBucket Origin Wiring

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/helpers.sh` (behavior_run origin-wiring + __ensure_gitbucket) |
| SCs | SC2 |
| Depends On | 1, 2, 3 |

**Context:**
```yaml
target: .opencode/tests-v2/behaviors/helpers.sh
scs: [SC2]
remote_flag: BEHAVIOR_NEEDS_REMOTE
origin_remote: origin
```

### Phase 5 — Merged-PR Discovery

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/helpers.sh` (gh pr list in isolated env) |
| SCs | SC3 |
| Depends On | 4 |

**Context:**
```yaml
target: .opencode/tests-v2/behaviors/helpers.sh
scs: [SC3]
discovery_command: gh pr list
remote_flag: BEHAVIOR_NEEDS_REMOTE
```

### Phase 6 — 2242-sc6 Full-Env Opt-In

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh` + fixture setup variant |
| SCs | SC10 |
| Depends On | 4 |

**Context:**
```yaml
target:
  - .opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh
  - .opencode/tests-v2/behaviors/fixtures/setup/2242-sc6-cleanup-dispatch-no-task-card-read.sh
scs: [SC10]
opt_in_flags:
  BEHAVIOR_NEEDS_MULTI_SUBMODULES: "1"
  BEHAVIOR_NEEDS_REMOTE: "1"
```

### Phase 7 — 2242-sc6 Verification

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh` (session.yaml tool timeline) |
| SCs | SC11, SC12 |
| Depends On | 6 |

**Context:**
```yaml
target: .opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh
scs: [SC11, SC12]
forbidden_tool_timeline: ["read tasks/cleanup.md", "question-tool call", "PR/branch-context halt"]
```

### Phase 8 — Documentation

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/AGENTS.md` (mutual-exclusion + full-env opt-in docs) |
| SCs | SC18 |
| Depends On | — |

**Context:**
```yaml
target: .opencode/tests-v2/AGENTS.md
scs: [SC18]
mutual_exclusion_rule: "BEHAVIOR_NEEDS_MULTI_SUBMODULES / BEHAVIOR_SET_BARE_REMOTE"
sections: ["§5 Infrastructure Details", "§12 GitBucket"]
```

### Phase 9 — No-Regression Default Gate

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/helpers.sh` (default provisioning path) + `with-test-home` |
| SCs | SC8 |
| Depends On | 1, 3, 4 |

**Context:**
```yaml
target:
  - .opencode/tests-v2/behaviors/helpers.sh
  - .opencode/tests-v2/with-test-home
scs: [SC8]
default_provisioning: "single .opencode submodule + local platform, no origin remote"
```

---

## Exit Criteria

- [ ] C1. `env -i` allowlist in `with-test-home` passes through the three new flags (`BEHAVIOR_NEEDS_MULTI_SUBMODULES`, `BEHAVIOR_NEEDS_REMOTE`, `BEHAVIOR_SET_BARE_REMOTE`) as a strict superset with no removals, and `set-env.sh` records them.
- [ ] C2. `env -i` allowlist contains ONLY the minimal explicitly enumerated infrastructure set and excludes all parent-sourced secret/credential/token/env-specific variables; every required test value is generated/set by `do_setup`/`seed_model_config`/test-home provisioning.
- [ ] C3. `GB_*`/`GITBUCKET_PORT` are absent from the test env unless scoped to the provisioned test GitBucket instance; no parent `GB_*` leaks through.
- [ ] C4. `behavior_run()` provisions `test-submodule-1`/`test-submodule-2` when `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1`, wires GitBucket `origin` when `BEHAVIOR_NEEDS_REMOTE=1`, and rejects both-remote-flags with `HARNESS_FAILURE`.
- [ ] C5. `gh pr list` in the isolated env (wired origin) discovers merged branches/open issues without GitHub auth and the agent does not halt for PR/branch context.
- [ ] C6. `--clean-all`/`__kill_gitbucket`/`__reset_gitbucket` remove all provisioned clones and GitBucket state, leaving no orphans; a repeated run starts clean.
- [ ] C7. `2242-sc6-cleanup-dispatch-no-task-card-read.sh` with the full-env opt-in completes merged-PR discovery and cleanup dispatch without reading a cleanup task card and without halting for PR/branch context.
- [ ] C8. `.opencode/tests-v2/AGENTS.md` documents the mutual-exclusion rule and the new opt-in capability.
- [ ] C9. With no opt-in flags set, default provisioning remains byte-for-byte the single-`.opencode`/`local` platform for the ~80 existing tests (no regression).
- [ ] C10. All 18 SCs map to exactly one item each; no item covers multiple SCs; the phase DAG is acyclic and Z3-SAT validated.
