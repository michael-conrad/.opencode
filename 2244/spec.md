# [SPEC] Full-Environment Simulation Support in `.opencode/tests-v2` Test Harness

> **Full spec and artifacts: [`.opencode/.issues/2244/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2244)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2244/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

### 1.1 Problem Statement

The behavioral test harness in `.opencode/tests-v2/` provisions only a single `.opencode` submodule in the isolated test environment and defaults to the `local` platform (no remote, no GitHub auth). Tests that require real remote-PR or branch-discovery behavior cannot complete because the agent's PR/branch discovery calls (via `gh pr list`) fail against a `local` platform with no origin remote, causing the model to halt and ask the developer for PR/branch context instead of completing the workflow.

### 1.2 Root Cause / Motivation

The motivating test `2242-sc6-cleanup-dispatch-no-task-card-read.sh` dead-ended in exactly this way: the model loaded git-workflow-cleanup, tried `gh pr list` (which fails with no GitHub remote/auth in the isolated `local`-platform test repo), and asked the user for the PR/branch instead of dispatching cleanup. The root cause is that the harness provisions no origin remote and no sibling submodule fixture repos, so remote-dependent cleanup discovery has nothing to operate against. Correcting this requires a **full-environment simulation** capability: provision optional sibling submodule fixture repos and/or wire a GitBucket instance as the test repo's `origin` remote so merged-PR discovery and cleanup dispatch succeed.

### 1.3 Approach Chosen

Add an opt-in capability to the harness: a `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1` flag provisions `test-submodule-1` and `test-submodule-2` as local git repos in the attempt workdir, and the existing `BEHAVIOR_NEEDS_REMOTE=1` flag wires a GitBucket instance as the test repo's `origin` remote. Both capabilities are opt-in and mutually exclusive with the existing `BEHAVIOR_SET_BARE_REMOTE=1` bare-remote flag. The env `env -i` allowlist in `with-test-home` is extended (superset only) to pass the new flags through, and `GB_*`/`GITBUCKET_PORT` are scoped so they never leak from the parent shell (SC13–SC17). Cleanup is extended so `--clean-all` removes all newly provisioned state. The harness enforces a general environment-set principle: all environment variables required by tests are set within the test environment setup itself, and the `env -i` allowlist carries only the minimal infrastructure set — so no parent/production secret, credential, or platform token is ever inherited into the isolated test env (SC13–SC16).

### 1.4 Alternatives Considered & Why Discarded

- **Wire real GitHub as the origin remote** — Discarded: the isolated test env has no GitHub credentials (`GITHUB_TOKEN`/`GH_TOKEN` are in the FORBIDDEN set of `with-test-home`), so pushing/discovering against real GitHub would require leaking production auth into the test environment, violating the isolation contract. GitBucket provides a local, credentialed origin without leaking production state.
- **Provision sibling submodules as remote `git clone`s of the private GitHub repos** — Discarded: the private fixture repos require GitHub auth to clone, which is unavailable in the isolated env. Local `git init` from fixture templates is deterministic and requires no auth.
- **Make full-environment simulation the universal default** — Discarded: the ~80 existing tests provision a single `.opencode` submodule and `local` platform; changing the default would alter their behavior and require re-verification of every existing test. Opt-in preserves the no-regression guarantee.

### 1.5 Key Design Decisions

- **Multi-submodule fixtures as local git repos, not remote clones:** `test-submodule-1` and `test-submodule-2` are created via local `git init` from fixture templates inside the attempt workdir. Tradeoff: no GitHub auth needed (deterministic), but the fixtures do not reflect the real remote state (acceptable — the test only needs the sibling repos to exist as discoverable `.gitmodules` entries).
- **GitBucket origin wiring reuses the existing `BEHAVIOR_NEEDS_REMOTE` provisioner:** The `__ensure_gitbucket()` function already provisions GitBucket; the origin-wiring block in `behavior_run()` attaches it as `origin`. Tradeoff: reuses proven provisioning machinery, but couples this feature to GitBucket's availability in the environment.
- **Mutual exclusion between `BEHAVIOR_NEEDS_REMOTE` and `BEHAVIOR_SET_BARE_REMOTE`:** A test MUST NOT set both because both try to configure the `origin` remote and would conflict. Contradictory config is rejected with `HARNESS_FAILURE`. Tradeoff: forces test authors to pick exactly one remote strategy, preventing ambiguous origin state.
- **Env passthrough as a strict superset:** New fixture/remote flags are added to the `env -i` allowlist in `with-test-home`; no existing variable is removed or reordered. Tradeoff: keeps the isolation wall intact while extending reach.
- **Test-provisioned environment only (general env-set rule):** The test harness (with-test-home) sets every environment variable a test requires within the test environment setup (`do_setup`/`seed_model_config`/test-home provisioning) — never inheriting them from the parent/production shell. The `env -i` allowlist carries ONLY a minimal, explicitly enumerated infrastructure set (PATH, SHELL, TERM, LANG, USER, LOGNAME, GIT_CONFIG_NOSYSTEM, XDG_* into the test home, SNAP_USER_DATA/COMMON, and test-provisioned values). It MUST NOT include any parent-sourced variable carrying secrets, credentials, platform tokens, or environment-specific configuration (GB_*, GITHUB_*, GH_*, NODE_ENV, VIRTUAL_ENV, CONDA_DEFAULT_ENV, OPENCODE_CONFIG_CONTENT, API keys). Tradeoff: test authors must opt in to provisioning the values they need, but the default path never leaks a production secret, credential, or environment-specific value into the isolated test env.
- **GB_* is the concrete instance of the general env-set rule:** The test-env-specific `GB_*` values (`GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GITBUCKET_PORT`) are test-env constants that the harness ALWAYS sets to its own test-env constant values in the isolated test environment — regardless of whether a test GitBucket is running. Only `GB_TOKEN` (the secret credential) is set when and only when the harness provisioned a test GitBucket (`BEHAVIOR_NEEDS_REMOTE=1`); it is absent/empty otherwise. Parent-sourced `GB_*`/`GITBUCKET_PORT` values are NEVER passed through the `env -i` allowlist. Tradeoff: tests that need GitBucket must opt in to provisioning the token, but the default path never leaks a production GitBucket credential into the isolated test env.

### 1.6 User Intent / Original Prompt

The `.opencode` #2242 SC6/SC7 cleanup-dispatch behavioral test (`.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh`) requires the agent to discover a merged PR and dispatch cleanup correctly, without halting for PR/branch context. The user's intent is that this test be able to complete against a full-environment simulation (sibling submodules and/or a GitBucket origin) so the skill-card migration is verifiable. The measure of success is that the task was executed correctly — the correct cleanup task card's instructions were followed and the cleanup completed — not whether a specific discovery command or a specific read/no-read pattern occurred.

## 2. Not Included

- **Real GitHub / GitBucket as the default remote** — The full-environment simulation is opt-in only; the default single-`.opencode`/`local` provisioning is preserved. Rationale: SC8 no-regression gate.
- **Modification of the ~80 existing test scripts** — Only `2242-sc6-cleanup-dispatch-no-task-card-read.sh` is extended to set the opt-in. Rationale: existing tests are regression fixtures and must remain byte-for-byte unchanged.
- **Provisioning more than two sibling submodules** — Only `test-submodule-1` and `test-submodule-2` are in scope. Rationale: the motivating test needs exactly two sibling repos; more would be speculative.
- **GitHub Actions / CI integration** — The capability is scoped to the local behavioral harness only. Rationale: CI is out of scope for this spec.
- **Relaxation of the general env-set isolation wall** — The `env -i` allowlist is not loosened to admit parent-sourced secrets, credentials, platform tokens, or environment-specific configuration beyond the minimal infrastructure set (SC13–SC16). Rationale: the isolation contract is a firm rule, not a per-test convenience.

## 3. Success Criteria

### SC Table

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC1 | When `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1` is set in the environment, `behavior_run()` in `helpers.sh` provisions `test-submodule-1` and `test-submodule-2` as local git repos (created via `git init` from fixture templates) inside the attempt workdir, in addition to the existing `.opencode` clone. When the flag is unset or absent, `behavior_run()` provisions only the existing single `.opencode` clone. | structural | `ls` the attempt workdir for `test-submodule-1` and `test-submodule-2` directories and confirm `git submodule status` lists them when the flag is set; confirm their absence when the flag is unset. | `.opencode/tests-v2/behaviors/helpers.sh` (`behavior_run()` submodule provisioning block); `.opencode/tests-v2/behaviors/fixtures/` |
| SC2 | When `BEHAVIOR_NEEDS_REMOTE=1` is set in the environment and GitBucket is provisioned, `behavior_run()` in `helpers.sh` wires the GitBucket instance as the test repo's `origin` remote in the attempt workdir. | structural | Inspect the `behavior_run()` origin-wiring block in `helpers.sh`; run with `BEHAVIOR_NEEDS_REMOTE=1` and confirm `git remote -v` in the attempt workdir shows the GitBucket `origin`. | `.opencode/tests-v2/behaviors/helpers.sh` (`__ensure_gitbucket()`, origin-wiring block) |
| SC3 | When the GitBucket origin is wired (SC2), the agent's `gh pr list` call in the isolated test env discovers merged branches and open issues without GitHub auth. | behavioral | `opencode run` with `BEHAVIOR_NEEDS_REMOTE=1`; clean-room evaluation of `session.yaml` confirms `gh pr list` returns merged-branch/issue results and the agent does not halt for missing PR context. | `.opencode/tests-v2/behaviors/helpers.sh` (`__ensure_gitbucket()`, origin-wiring block); `.opencode/tests-v2/AGENTS.md` §12 |
| SC4 | When both `BEHAVIOR_NEEDS_REMOTE=1` and `BEHAVIOR_SET_BARE_REMOTE=1` are set, `behavior_run()` rejects the configuration with a `HARNESS_FAILURE` exit and does not attempt ambiguous origin wiring. | behavioral | Run `behavior_run()` with both flags set; assert the `HARNESS_FAILURE` exit and that no origin-wiring is attempted. | `.opencode/tests-v2/behaviors/helpers.sh` (`BEHAVIOR_SET_BARE_REMOTE` block, mutual-exclusion rejection check) |
| SC5 | The `env -i` allowlist in `with-test-home` passes through `BEHAVIOR_NEEDS_MULTI_SUBMODULES`, `BEHAVIOR_NEEDS_REMOTE`, and `BEHAVIOR_SET_BARE_REMOTE` as a strict superset — no existing allowlisted variable is removed or reordered. | structural | Inspect the `env -i` invocation and the allowlist block in `with-test-home` for the three new variable names; confirm all previously allowlisted variables remain. | `.opencode/tests-v2/with-test-home` (`env -i` invocation + allowlist block) |
| SC6 | `set-env.sh` records the three new flags (`BEHAVIOR_NEEDS_MULTI_SUBMODULES`, `BEHAVIOR_NEEDS_REMOTE`, `BEHAVIOR_SET_BARE_REMOTE`) so the test env sees them as documented debugging aids. | structural | Inspect `set-env.sh` for the three new variable names. | `.opencode/tests-v2/with-test-home` (`set-env.sh`) |
| SC7 | The isolation verification procedure (no production state leaked into the test env) still passes after the allowlist extension with the three new flags. | structural | Run the isolation verification procedure against the extended allowlist; confirm no production secret, credential, platform token, or environment-specific configuration is admitted. | `.opencode/tests-v2/with-test-home` (`env -i` invocation + allowlist block); `.opencode/tests-v2/AGENTS.md` §5 (Isolation Verification Procedure) |
| SC8 | With no opt-in flags set, a representative non-opt-in behavioral test provisions exactly one `.opencode` submodule and the `local` platform (no origin remote) — byte-for-byte identical to the current default provisioning of the ~80 existing tests. | behavioral | Run a representative non-opt-in behavioral test; clean-room evaluation of `session.yaml` confirms single-`.opencode` provisioning and no origin remote. | `.opencode/tests-v2/behaviors/helpers.sh`; `.opencode/tests-v2/with-test-home` |
| SC9 | After a full-env provisioned run, `--clean-all` in `with-test-home` (via `do_clean_all()`) and `__kill_gitbucket()` / `__reset_gitbucket()` in `helpers.sh` remove the provisioned `test-submodule-1`/`test-submodule-2` clones, the GitBucket process, and all stale `tmp/` state, leaving no orphan clones or processes; a repeated run starts clean. | behavioral | After a provisioned run, invoke `--clean-all` and `__kill_gitbucket()`; assert no orphan GitBucket process is running and no stale `tmp/` submodule clones/state remain; then run again and confirm a clean start. | `.opencode/tests-v2/with-test-home` (`do_clean()`, `do_clean_all()`); `.opencode/tests-v2/behaviors/helpers.sh` (`__reset_gitbucket()`, `__kill_gitbucket()`) |
| SC10 | When the full-env opt-in (`BEHAVIOR_NEEDS_MULTI_SUBMODULES=1` and `BEHAVIOR_NEEDS_REMOTE=1`) is set for `2242-sc6-cleanup-dispatch-no-task-card-read.sh`, the full-env opt-in enables the agent to discover the merged branch/PR state needed to execute cleanup (via any discovery mechanism the agent uses — git primitives, `gb pull-request list`, `gh pr list`, or any other), and cleanup proceeds. Discovery yielding the merged branch that lets cleanup execute correctly IS the measure; the specific discovery command is NOT the measure. | behavioral | Run `2242-sc6-cleanup-dispatch-no-task-card-read.sh` with the full-env opt-in; clean-room evaluation of `session.yaml` confirms the agent discovered the merged branch (by whatever discovery mechanism it used) and cleanup executed against it. | `.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh`; `.opencode/tests-v2/behaviors/fixtures/setup/2242-sc6-cleanup-dispatch-no-task-card-read.sh` |
| SC11 | The git-workflow-cleanup cleanup dispatch is correctly routed to the `tasks/cleanup.md` task card and the executor follows its instructions to verify the merged PR and discover the merged branch. The measure is correct routing + instruction-following (executor reads the correct task card and acts on its steps), NOT terminal completion within a single timeout window. | behavioral | Clean-room evaluation of the SC10 `session.yaml` confirms the cleanup dispatch was routed to the `tasks/cleanup.md` task card and the executor followed its instructions to verify the merged PR and discover the merged branch. The measure is correct routing + instruction-following, NOT terminal completion within a single timeout window. | `.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh` |
| SC12 | In the SC10 run, `session.yaml` shows the agent never halted to ask the user for PR/branch context (no question-tool call or "provide PR" style halt). | behavioral | Clean-room evaluation of the SC10 `session.yaml` confirms no PR/branch-context halt or question-tool invocation. | `.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh` |
| SC13 | The isolated test environment SHALL be provisioned entirely by the test harness setup itself: every environment variable a test requires is set within the test environment setup (`do_setup`/`seed_model_config`/test-home provisioning), never inherited from the parent/production shell. | string | Inspect `with-test-home` (`do_setup`, `seed_model_config`) and test-home provisioning; confirm every required test value is set within the setup, not read through from the parent shell. | `.opencode/tests-v2/with-test-home` (`do_setup`, `seed_model_config`, test-home provisioning) |
| SC14 | The `env -i` allowlist in `with-test-home` SHALL contain ONLY the minimal, explicitly enumerated infrastructure set needed to locate tools and run the binary, namely exactly: `PATH`, `SHELL`, `TERM`, `LANG`, `USER`, `LOGNAME`, `GIT_CONFIG_NOSYSTEM`, `XDG_*` pointing into the test home, `SNAP_USER_DATA`/`SNAP_USER_COMMON`, and test-provisioned values. | string | Inspect the `env -i` invocation and allowlist block in `with-test-home`; confirm the allowlist enumerates exactly this minimal infrastructure set and nothing more. | `.opencode/tests-v2/with-test-home` (`env -i` invocation + allowlist block) |
| SC15 | The `env -i` allowlist in `with-test-home` SHALL NOT include any parent-sourced variable that carries secrets, credentials, platform tokens, or environment-specific configuration — namely none of: `GB_*`, `GITHUB_*`, `GH_*`, `NODE_ENV`, `VIRTUAL_ENV`, `CONDA_DEFAULT_ENV`, `OPENCODE_CONFIG_CONTENT`, or API keys. | string | Inspect the `env -i` invocation and allowlist block in `with-test-home`; confirm none of the enumerated secret/credential/token/env-specific variables is admitted from the parent env. | `.opencode/tests-v2/with-test-home` (`env -i` invocation + allowlist block) |
| SC16 | Any value a test needs (GitBucket token/host, model, config) SHALL be generated/set by the test setup, never read through from the parent env. | string | Confirm `do_setup`/`seed_model_config`/test-home provisioning in `with-test-home` generate or set model, config, and (when provisioned) GitBucket token/host values rather than inheriting them. | `.opencode/tests-v2/with-test-home` (`do_setup`, `seed_model_config`, test-home provisioning) |
| SC17 | The test-env-specific `GB_*`/`GITBUCKET_PORT` values (`GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GITBUCKET_PORT`) SHALL be ALWAYS set to the harness's test-env constants in the isolated test environment — regardless of whether a test GitBucket is running — as the concrete instance of the general env-set rule in SC13–SC16. (a) The harness SHALL set these test-env constants in the isolated test env (via `env -i` allowlist / `GB_ENV_ARGS` / `set-env.sh`); only `GB_TOKEN` (the secret credential) is set when and only when `BEHAVIOR_NEEDS_REMOTE=1` provisions a test GitBucket, to the test instance's own generated value — never inherited from the parent env. (b) The harness SHALL NOT pass through any parent-sourced `GB_*`/`GITBUCKET_PORT` value via the `env -i` allowlist or `set-env.sh` in `with-test-home`; no parent-sourced `GB_*`/`GITBUCKET_PORT` ever leaks into the isolated test env. | string | Inspect the `env -i` allowlist, `GB_ENV_ARGS`, and `set-env.sh` in `with-test-home` for `GB_*` sourcing; confirm the test-env constants (`GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GITBUCKET_PORT`) are always set to the harness's constants and `GB_TOKEN` is scoped to the test instance only when `BEHAVIOR_NEEDS_REMOTE=1`; confirm no parent-sourced `GB_*`/`GITBUCKET_PORT` values propagate. | `.opencode/tests-v2/with-test-home` (`env -i` allowlist, `GB_ENV_ARGS`, `set-env.sh`); `.opencode/tests-v2/behaviors/helpers.sh` (`__ensure_gitbucket()`); `.opencode/tests-v2/AGENTS.md` §5 (Isolation Verification Procedure) |
| SC18 | `.opencode/tests-v2/AGENTS.md` SHALL document the `BEHAVIOR_NEEDS_MULTI_SUBMODULES` / `BEHAVIOR_SET_BARE_REMOTE` mutual-exclusion rule and the new full-environment opt-in capability (multi-submodule fixtures and GitBucket origin wiring). | string | Inspect `.opencode/tests-v2/AGENTS.md` for a section documenting the mutual-exclusion rule and the opt-in capability. | `.opencode/tests-v2/AGENTS.md` |
| SC19 | When `BEHAVIOR_NEEDS_REMOTE=1` provisions a test GitBucket, `with-test-home` SHALL propagate the full `GB_*` env suite — `GB_TOKEN`, `GB_HOST`, `GITBUCKET_PORT`, `GB_REPO`, `GB_PROTOCOL` — into the isolated test environment via `GB_ENV_ARGS`. The test-env constants (`GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GITBUCKET_PORT`) SHALL be set to the harness's test-env constant values always (whether or not GitBucket is provisioned); `GB_TOKEN` (the credential secret) SHALL be set to the provisioned test instance's value only when `BEHAVIOR_NEEDS_REMOTE=1`, and SHALL be absent/empty otherwise. No value is ever sourced from the parent env. | structural | Inspect the `GB_ENV_ARGS` array and the `env -i` invocation in `with-test-home` for all five variable names; confirm the four test-env constants are always set to the harness's constants and `GB_TOKEN` is populated only when `BEHAVIOR_NEEDS_REMOTE=1` from the provisioned test instance (not the parent env). | `.opencode/tests-v2/with-test-home` (`GB_ENV_ARGS`, `env -i` invocation); `.opencode/tests-v2/behaviors/helpers.sh` (`__ensure_gitbucket()`) |
| SC20 | When `BEHAVIOR_NEEDS_REMOTE=1` provisions a test GitBucket, the test home SHALL seed a pre-fabricated `gb` config.toml at `$TEST_HOME/.config/gb/config.toml` with `default_host` and host token matching the provisioned test GitBucket instance, so `gb` authenticates deterministically without `gb auth login`. The config SHALL seed the harness's test-env `default_host` constant; the host token SHALL be present only when a test GitBucket was provisioned (`BEHAVIOR_NEEDS_REMOTE=1`). | structural | Inspect `do_setup`/test-home provisioning in `with-test-home` for the `gb` config.toml seeding block writing `$TEST_HOME/.config/gb/config.toml` with the test instance's `default_host` and token. | `.opencode/tests-v2/with-test-home` (`do_setup`, test-home provisioning); `.opencode/tests-v2/behaviors/helpers.sh` (`__ensure_gitbucket()`) |

### Per-SC Cost-Frame (dark-prose-007)

| ID | Cost-Frame |
|----|------------|
| SC1 | Failing to provision fixture submodules means every remote-sensitive test inherits the dead-end halt. A test that cannot see its merged branch and open issue cannot exercise cleanup — it burns a model run to end in a question. You will accept that cost every single time you skip this. |
| SC2 | Wiring GitBucket as origin is the difference between a workflow that completes and one that stalls at `gh pr list`. An unwired origin leaves `gh pr list` with nothing to query — the capability silently does nothing. |
| SC3 | A `gh pr list` that returns nothing is not proof of isolation — it is proof of nothing to discover. The discovery claim must be verified against the wired origin, not assumed from the wiring. |
| SC4 | Allowing both remote flags to be set simultaneously produces an ambiguous `origin` — a harness that silently picks one strategy corrupts the isolation contract. Contradictory config rejected early is a harness that fails loudly instead of failing silently. |
| SC5 | Leaking production state through a careless allowlist extension silently corrupts every test that follows. The isolation contract is the wall between your test and your real repo. A breach here is not a flaky test — it is a data-integrity event in your working tree. |
| SC6 | A flag that is not recorded in `set-env.sh` is a flag a debugging session cannot see. Documentation-by-recording is cheap; a silent gap costs a confused test author an afternoon. |
| SC7 | An allowlist that passes the diff but fails the isolation check has not been verified — it has been edited. The isolation procedure is the proof that the extension did not open a pipe to production. |
| SC8 | A regression in the default single-`.opencode` path breaks all ~80 existing tests at once. The opt-in design is the shield; SC8 is the proof the shield holds. Without it, you ship a change whose blast radius you have not measured. |
| SC9 | Orphan GitBucket processes and stale clones poison every subsequent run and hold the flock. A harness that cannot clean itself is a harness that eventually stops working for reasons nobody can reproduce. Cleanup is not housekeeping — it is the precondition for a reliable next run. |
| SC10 | The motivating test exists to prove the git-workflow cleanup dispatch completes. If the full-env opt-in does not let the agent discover the merged branch it needs to execute cleanup, the #2242 SC6/SC7 evidence is unobtainable and the whole skill-card migration is unverifiable. This SC is not optional scope — it is the point of the capability. |
| SC11 | A cleanup dispatch that does not follow the correct task card (`tasks/cleanup.md`) and complete is not a completed cleanup — it is a stalled or mis-routed one. If the dispatch does not execute cleanup per the correct task card, the behavioral evidence is invalid and the migration claim is unsupported. |
| SC12 | A run that halts to ask the user for PR/branch context is not a completed cleanup dispatch — it is a deferred question. If the agent asks instead of acting, the SC10/SC11 evidence is unobtainable and the capability has not delivered. |
| SC13 | A test env that does not set its own required values is not a test env at all — it is a sandbox that begs values from a production shell it has no business reading. Every value a test needs must be set by the test setup itself. |
| SC14 | An allowlist that admits anything beyond the minimal infrastructure set is an isolation wall with a door in it. The wall holds only if the enumerated set is exhaustive — not illustrative. |
| SC15 | A single parent-sourced credential in the allowlist silently authenticates a test you believed was sandboxed — that is a data-integrity event, not a flaky test. The exclusion must be enumerated, because "and so on" is how a credential slips through. |
| SC16 | A required value read through from the parent is a value you did not control. If model, config, or GitBucket token comes from the parent shell, the test is exercising your environment, not the harness. |
| SC17 | Treating `GB_*` as absent-unless-provisioned means the isolated test env is missing the test-env constants the executor needs to address any GitBucket host — so even a provisioned run cannot authenticate. But treating parent-sourced `GB_*` as usable means every no-GitBucket test silently talks to — or authenticates as — your production GitBucket. The correct line: the test-env constants (`GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GITBUCKET_PORT`) are always the harness's own; only the `GB_TOKEN` credential is provisioned-scoped. This is the concrete instance of the SC13–SC16 general rule. |
| SC18 | A mutual-exclusion rule and opt-in capability that are not documented are rules a future test author will violate by accident. Undocumented behavior is not a rule — it is a trap set for the next person. |
| SC19 | A `GB_*` suite that reaches the executor incomplete is a suite that cannot authenticate. `gb` reads host, token, repo, and protocol together; an executor holding `GB_TOKEN` but no `GB_REPO`/`GB_PROTOCOL` still fails 'Not authenticated' against a host it cannot address. Every required variable must arrive together, or none of them means anything. |
| SC20 | A test home without a seeded `gb` config.toml forces the executor to attempt `gb auth login` interactively — a prompt the harness cannot answer — and the discovery call fails with 'Not authenticated'. A pre-fabricated config is the difference between a deterministic discovery and a stalled run. |

## 4. Requirements

- **R-1.** The harness SHALL provision `test-submodule-1` and `test-submodule-2` as local git repos inside the attempt workdir when `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1` is set, and SHALL NOT provision them when the flag is unset or absent.
- **R-2.** The harness SHALL wire the GitBucket instance as the test repo's `origin` remote in the attempt workdir when `BEHAVIOR_NEEDS_REMOTE=1` is set and GitBucket is provisioned.
- **R-3.** The harness SHALL reject configuration where both `BEHAVIOR_NEEDS_REMOTE=1` and `BEHAVIOR_SET_BARE_REMOTE=1` are set, with a `HARNESS_FAILURE` exit.
- **R-4.** The `env -i` allowlist in `with-test-home` SHALL pass through `BEHAVIOR_NEEDS_MULTI_SUBMODULES`, `BEHAVIOR_NEEDS_REMOTE`, and `BEHAVIOR_SET_BARE_REMOTE` as a strict superset, SHALL NOT remove any existing allowlisted variable, and SHALL NOT add any production-secret variable to the allowlist.
- **R-5.** The default provisioning (no opt-in flags set) SHALL remain a single `.opencode` submodule and `local` platform with no origin remote, byte-for-byte unchanged.
- **R-6.** `--clean-all` SHALL remove all provisioned submodule clones, the GitBucket process, and all stale `tmp/` state left by a full-env run, so a repeated run starts clean.
- **R-7.** `__kill_gitbucket()` SHALL terminate the GitBucket process without restarting it, and `__reset_gitbucket()` SHALL terminate and restart GitBucket fresh.
- **R-8.** When the full-env opt-in is set for `2242-sc6-cleanup-dispatch-no-task-card-read.sh`, the test SHALL enable the agent to discover the merged branch/PR state needed to execute cleanup (via any discovery mechanism the agent uses) and SHALL route the cleanup dispatch to the correct cleanup task card (`tasks/cleanup.md`), with the executor following its instructions to verify the merged PR and discover the merged branch, without halting for PR/branch context. The measure is correct routing + instruction-following, NOT terminal completion within a single timeout window.
- **R-9.** `tests-v2/AGENTS.md` SHALL document the `BEHAVIOR_NEEDS_MULTI_SUBMODULES` / `BEHAVIOR_SET_BARE_REMOTE` mutual-exclusion rule and the new opt-in capability.
- **R-10.** New fixture/remote flags MAY be added to `set-env.sh` for debugging aid, provided they are also present in the `env -i` allowlist.
- **R-11.** The test harness SHALL set every environment variable a test requires within the test environment setup (`do_setup`/`seed_model_config`/test-home provisioning), and SHALL NOT inherit any required value from the parent/production shell. The `env -i` allowlist in `with-test-home` SHALL contain ONLY the minimal, explicitly enumerated infrastructure set needed to locate tools and run the binary, namely exactly `PATH`, `SHELL`, `TERM`, `LANG`, `USER`, `LOGNAME`, `GIT_CONFIG_NOSYSTEM`, `XDG_*` into the test home, `SNAP_USER_DATA`/`SNAP_USER_COMMON`, and test-provisioned values. The allowlist SHALL NOT include any parent-sourced variable that carries secrets, credentials, platform tokens, or environment-specific configuration — namely none of `GB_*`, `GITHUB_*`, `GH_*`, `NODE_ENV`, `VIRTUAL_ENV`, `CONDA_DEFAULT_ENV`, `OPENCODE_CONFIG_CONTENT`, or API keys. Any value a test needs (GitBucket token/host, model, config) SHALL be generated/set by the test setup, never read through from the parent env.
- **R-12.** As the concrete instance of R-11, the test environment SHALL NOT inherit any `GB_*` or `GITBUCKET_PORT` value from the parent shell. The test-env constants (`GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GITBUCKET_PORT`) SHALL be ALWAYS set to the harness's test-env constant values in the isolated test env. Only `GB_TOKEN` (the credential secret) SHALL be set when and only when `BEHAVIOR_NEEDS_REMOTE=1` provisions a test GitBucket, to the test instance's own generated value; it SHALL be absent/empty otherwise. The `env -i` allowlist in `with-test-home` SHALL NOT pass through parent-sourced `GB_*`/`GITBUCKET_PORT` values.
- **R-13.** When the GitBucket origin is wired (R-2), the test SHALL be able to discover merged branches and open issues via `gh pr list` in the isolated test environment without GitHub auth, and the agent SHALL NOT halt for missing PR/branch context.
- **R-14.** When `BEHAVIOR_NEEDS_REMOTE=1` provisions a test GitBucket, the harness SHALL propagate the full `GB_*` env suite — `GB_TOKEN`, `GB_HOST`, `GITBUCKET_PORT`, `GB_REPO`, `GB_PROTOCOL` — into the isolated test environment via `GB_ENV_ARGS`. The test-env constants (`GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GITBUCKET_PORT`) SHALL be set to the harness's test-env constant values always; `GB_TOKEN` SHALL be set to the provisioned test instance's value only when `BEHAVIOR_NEEDS_REMOTE=1`, and SHALL be absent/empty otherwise. No value is ever sourced from the parent env.
- **R-15.** When `BEHAVIOR_NEEDS_REMOTE=1` provisions a test GitBucket, the test home SHALL seed a pre-fabricated `gb` config.toml at `$TEST_HOME/.config/gb/config.toml` with `default_host` and host token matching the provisioned test GitBucket instance, so `gb` authenticates deterministically without `gb auth login`. The `default_host` SHALL be the harness's test-env constant; the host token SHALL be present only when a test GitBucket was provisioned (`BEHAVIOR_NEEDS_REMOTE=1`).

## 5. Items

### Item 1 (SC1): Multi-submodule fixture provisioning

- RED: enforcement test asserts no `test-submodule-1`/`test-submodule-2` dirs appear when `BEHAVIOR_NEEDS_MULTI_SUBMODULES` is unset; with the flag set, asserts they do appear.
- GREEN: add the `BEHAVIOR_NEEDS_MULTI_SUBMODULES` branch to `behavior_run()` in `helpers.sh` that `git init`s the two fixture repos.
- verify: `ls` attempt workdir + `git submodule status`; confirm flag-on/flag-off behavior.
- commit: `helpers.sh` + new fixture templates under `behaviors/fixtures/`.

### Item 2 (SC2): GitBucket origin wiring

- RED: enforcement test with `BEHAVIOR_NEEDS_REMOTE=1` shows no `origin` remote attached in the attempt workdir.
- GREEN: ensure the origin-wiring block in `behavior_run()` attaches the GitBucket origin.
- verify: run with `BEHAVIOR_NEEDS_REMOTE=1`; confirm `git remote -v` shows the GitBucket `origin`.
- commit: `helpers.sh` origin-wiring logic.

### Item 3 (SC3): Merged-PR/issue discovery without GitHub auth

- RED: `opencode run` with `BEHAVIOR_NEEDS_REMOTE=1` fails to produce `gh pr list` output or halts for missing PR context.
- GREEN: no source change beyond SC2's origin wiring (discovery depends on the wired origin).
- verify: `opencode run` with `BEHAVIOR_NEEDS_REMOTE=1`; clean-room `session.yaml` evaluation confirms discovery.
- commit: verification evidence only (no source change unless SC2 is insufficient).

### Item 4 (SC4): Mutual-exclusion rejection

- RED: enforcement test with both `BEHAVIOR_NEEDS_REMOTE=1` and `BEHAVIOR_SET_BARE_REMOTE=1` fails to reject with `HARNESS_FAILURE`.
- GREEN: add mutual-exclusion rejection between `BEHAVIOR_NEEDS_REMOTE` and `BEHAVIOR_SET_BARE_REMOTE` in `behavior_run()`.
- verify: run `behavior_run()` with both flags set; assert the `HARNESS_FAILURE` exit.
- commit: `helpers.sh` mutual-exclusion logic.

### Item 5 (SC5): Env passthrough — strict superset

- RED: enforcement test asserts the three flags are absent from the `env -i` allowlist, or that an existing allowlisted variable is removed.
- GREEN: extend the `env -i` allowlist in `with-test-home` with the three flags (superset only, no removals).
- verify: inspect `with-test-home` allowlist; confirm all three flags present and no existing variable removed.
- commit: `with-test-home`.

### Item 6 (SC6): set-env.sh records new flags

- RED: enforcement test asserts the three flags are absent from `set-env.sh`.
- GREEN: add the three flags to `set-env.sh` in `with-test-home` (alongside the `env -i` allowlist addition).
- verify: inspect `set-env.sh` for the three variable names.
- commit: `with-test-home` (`set-env.sh`).

### Item 7 (SC7): Isolation check still passes after extension

- RED: isolation verification procedure fails (a production state leak is admitted) after the allowlist extension.
- GREEN: no source change beyond SC5/SC6 if the extension is a clean superset; correct any accidental admission.
- verify: run the isolation verification procedure against the extended allowlist; confirm no production state leaks.
- commit: verification evidence only (no source change unless a leak is found).

### Item 8 (SC8): No-regression default gate

- RED: enforcement test asserts default provisioning is unchanged (single `.opencode`, `local`).
- GREEN: no implementation change required beyond ensuring SC1/SC2/SC3/SC4/SC5/SC6 leave the default path intact.
- verify: run a representative non-opt-in behavioral test; clean-room `session.yaml` evaluation.
- commit: verification evidence only (no source change unless regression found).

### Item 9 (SC9): Cleanup

- RED: enforcement test leaves orphan GitBucket process / stale clones after a provisioned run.
- GREEN: extend `do_clean_all()` in `with-test-home` and `__kill_gitbucket()` / `__reset_gitbucket()` in `helpers.sh` to remove all provisioned submodule clones and remote state.
- verify: after a provisioned run, invoke `--clean-all` and `__kill_gitbucket()`; assert no orphans; rerun clean.
- commit: `with-test-home` + `helpers.sh` cleanup functions.

### Item 10 (SC10): Merged-branch discovery for 2242-sc6

- RED: `2242-sc6` test with full-env opt-in fails to enable the agent to discover the merged branch (by whatever discovery mechanism it uses) and does not proceed to cleanup.
- GREEN: extend `2242-sc6-cleanup-dispatch-no-task-card-read.sh` and its per-scenario fixture to set `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1` and `BEHAVIOR_NEEDS_REMOTE=1`.
- verify: clean-room `session.yaml` evaluation confirms merged-branch discovery enabled cleanup to proceed.
- commit: `2242-sc6` test + per-scenario fixture.

### Item 11 (SC11): Cleanup dispatch routed + instruction-following

- RED: `2242-sc6` run shows the cleanup dispatch is not routed to the correct task card (`tasks/cleanup.md`) or the executor does not follow its instructions to verify the merged PR and discover the merged branch.
- GREEN: verify the dispatch is routed to the correct task card (`tasks/cleanup.md`) and the executor follows its instructions to verify the merged PR and discover the merged branch.
- verify: clean-room `session.yaml` evaluation confirms the cleanup dispatch was routed to the correct task card and the executor followed its instructions to verify the merged PR and discover the merged branch. The measure is correct routing + instruction-following, NOT terminal completion within a single timeout window.
- commit: no source change unless the test needs assertion strengthening.

### Item 12 (SC12): No PR-context halt

- RED: `2242-sc6` run shows a question-tool call or PR/branch-context halt.
- GREEN: verify the run completes without asking the user for PR/branch context.
- verify: clean-room `session.yaml` evaluation confirms no PR/branch-context halt.
- commit: no source change unless the test needs assertion strengthening.

### Item 13 (SC13): General env-set rule — test-provisioned environment only

- RED: enforcement test asserts the `env -i` allowlist in `with-test-home` contains a variable not in the minimal infrastructure set, or that a required test value is inherited rather than set by the test setup.
- GREEN: ensure `do_setup`/`seed_model_config`/test-home provisioning in `with-test-home` sets every value a test requires (model, config, GitBucket token/host when provisioned) rather than inheriting from the parent shell.
- verify: confirm `with-test-home` (`do_setup`, `seed_model_config`) sets all required test values within the setup; run the isolation verification procedure.
- commit: `with-test-home` (`do_setup`, `seed_model_config`).

### Item 14 (SC14): env -i allowlist — minimal infrastructure set only

- RED: enforcement test asserts the `env -i` allowlist in `with-test-home` contains a variable outside the minimal infrastructure set (PATH, SHELL, TERM, LANG, USER, LOGNAME, GIT_CONFIG_NOSYSTEM, XDG_* into the test home, SNAP_USER_DATA/SNAP_USER_COMMON, and test-provisioned values).
- GREEN: refactor the `env -i` allowlist in `with-test-home` to contain ONLY the minimal, explicitly enumerated infrastructure set.
- verify: inspect the `env -i` allowlist; confirm it enumerates exactly the minimal infrastructure set and nothing more.
- commit: `with-test-home` (`env -i` allowlist).

### Item 15 (SC15): env -i allowlist — no parent-sourced secrets

- RED: enforcement test asserts the `env -i` allowlist admits a parent-sourced secret/credential/token/env-specific variable (GB_*, GITHUB_*, GH_*, NODE_ENV, VIRTUAL_ENV, CONDA_DEFAULT_ENV, OPENCODE_CONFIG_CONTENT, API keys).
- GREEN: remove any such variable from the `env -i` allowlist in `with-test-home`; ensure only test-provisioned values flow through.
- verify: run the isolation verification procedure with a parent env carrying representative secrets/tokens/credentials; confirm none propagate.
- commit: `with-test-home` (`env -i` allowlist).

### Item 16 (SC16): Required test values generated/set by setup

- RED: enforcement test asserts a required test value (model, config, GitBucket token/host) is inherited from the parent shell rather than set by the test setup.
- GREEN: ensure `do_setup`/`seed_model_config`/test-home provisioning in `with-test-home` generate or set model, config, and (when provisioned) GitBucket token/host.
- verify: with parent values present, confirm the test env uses test-provisioned values, not parent values.
- commit: `with-test-home` (`do_setup`, `seed_model_config`).

### Item 17 (SC17): GB_* test-env constants + token non-leakage from parent env (concrete instance of SC13–SC16)

- RED: enforcement test shows the test-env constants (`GB_HOST`/`GB_REPO`/`GB_PROTOCOL`/`GITBUCKET_PORT`) absent from the test env, or a parent-sourced `GB_*`/`GITBUCKET_PORT` value (including a parent `GB_TOKEN`) present in the test env.
- GREEN: in `with-test-home`, set the test-env constants (`GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GITBUCKET_PORT`) to the harness's test-env constant values in the `env -i` allowlist / `GB_ENV_ARGS` / `set-env.sh` always; scope `GB_TOKEN` to the test instance's generated value only when `BEHAVIOR_NEEDS_REMOTE=1` (via `__ensure_gitbucket()` in `helpers.sh`), absent/empty otherwise; ensure no parent-sourced `GB_*`/`GITBUCKET_PORT` value flows through.
- verify: inspect the `env -i` allowlist, `GB_ENV_ARGS`, and `set-env.sh` for `GB_*` sourcing; with a parent `GB_TOKEN`/`GB_HOST` set, confirm the test env has the harness's test-env constants and no parent-sourced value, with `GB_TOKEN` scoped only when provisioned.
- commit: `with-test-home` (`env -i` allowlist, `GB_ENV_ARGS`, `set-env.sh`) + `helpers.sh` (`__ensure_gitbucket()`).

### Item 18 (SC18): AGENTS.md documentation

- RED: enforcement test asserts `.opencode/tests-v2/AGENTS.md` does not document the mutual-exclusion rule or the new opt-in capability.
- GREEN: add a section to `.opencode/tests-v2/AGENTS.md` documenting the `BEHAVIOR_NEEDS_MULTI_SUBMODULES` / `BEHAVIOR_SET_BARE_REMOTE` mutual-exclusion rule and the new full-environment opt-in capability.
- verify: inspect `.opencode/tests-v2/AGENTS.md` for the documenting section.
- commit: `.opencode/tests-v2/AGENTS.md`.

### Item 19 (SC19): GB_* full env suite propagation

- RED: enforcement test asserts the `GB_ENV_ARGS` array in `with-test-home` carries fewer than the full `GB_*` suite (`GB_TOKEN`, `GB_HOST`, `GITBUCKET_PORT`, `GB_REPO`, `GB_PROTOCOL`) when `BEHAVIOR_NEEDS_REMOTE=1`, or that the test-env constants (`GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GITBUCKET_PORT`) are not always set.
- GREEN: set the test-env constants in `with-test-home` (`GB_ENV_ARGS`/`env -i` allowlist) to the harness's constant values always; extend `__ensure_gitbucket()` in `helpers.sh` to export `GB_REPO` and `GB_PROTOCOL` for the provisioned test instance, and scope `GB_TOKEN` to the test instance when `BEHAVIOR_NEEDS_REMOTE=1`; the `env -i` allowlist guard (no parent-sourced `GB_*`) must hold.
- verify: inspect the `GB_ENV_ARGS` array and `env -i` invocation in `with-test-home`; confirm the four test-env constants are always set to the harness's constants and `GB_TOKEN` is populated from the test instance only.
- commit: `with-test-home` (`GB_ENV_ARGS`) + `helpers.sh` (`__ensure_gitbucket()`).

### Item 20 (SC20): Pre-fabricated gb config.toml seeding

- RED: enforcement test asserts the test home has no `$TEST_HOME/.config/gb/config.toml` after `BEHAVIOR_NEEDS_REMOTE=1` setup.
- GREEN: add a `gb` config.toml seeding block to `do_setup`/test-home provisioning in `with-test-home` that writes `$TEST_HOME/.config/gb/config.toml` with the harness's `default_host` constant and the host token matching the provisioned test GitBucket instance (token present only when `BEHAVIOR_NEEDS_REMOTE=1`; mirroring the fixture in `.opencode/.issues/2059/spec.md`).
- verify: inspect `do_setup`/test-home provisioning for the seeding block; run with `BEHAVIOR_NEEDS_REMOTE=1` and confirm `$TEST_HOME/.config/gb/config.toml` exists with the harness's `default_host` and the test instance's token.
- commit: `with-test-home` (`do_setup`, test-home provisioning).

## 6. Dependencies

- **Reference:** `.opencode` issue #2242 (SC6/SC7) — **Relationship:** this spec's SC10/SC11/SC12 enable the #2242 cleanup-dispatch test to complete; must be coordinated so the #2242 test's opt-in flags match this spec's flag names. **Status:** Pending — #2242 is the consumer.
- **Reference:** `.opencode/tests-v2/behaviors/helpers.sh` (`behavior_run()`, `__ensure_gitbucket()`, `__reset_gitbucket()`, `__kill_gitbucket()`) — **Relationship:** must be read before implementation to match existing provisioning blocks. **Status:** Satisfied (exists in current code).
- **Reference:** `.opencode/tests-v2/with-test-home` (`do_clean()`, `do_clean_all()`, `env -i` allowlist, `set-env.sh`, `do_setup`, `seed_model_config`) — **Relationship:** must be read before extending the allowlist and cleanup; the allowlist must be refactored to the minimal infrastructure set (SC14/SC15/R-11) and the `GB_*`/`GITBUCKET_PORT` allowlist sourcing must be corrected so parent values never propagate (SC17/R-12); `do_setup`/`seed_model_config` must set all required test values (SC13/SC16/R-11). **Status:** Satisfied (exists in current code).
- **Reference:** `.opencode/tests-v2/behaviors/helpers.sh` (`__ensure_gitbucket()`) — **Relationship:** must be verified to scope `GB_TOKEN` to the test instance and to keep the test-env constants (`GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GITBUCKET_PORT`) as harness constants (SC17/R-12, SC19/R-14). **Status:** Satisfied (exists in current code).
- **Reference:** `.opencode/tests-v2/AGENTS.md` §5 (Infrastructure Details / Isolation Verification Procedure) and §12 (GitBucket) — **Relationship:** must be read and updated to document the new opt-in capability and mutual-exclusion rule (SC18/R-9). **Status:** Satisfied (exists in current code).
- **Reference:** GitBucket provisioner (JDK + GitBucket JAR under `.tools/`, `tmp/gitbucket-data`) — **Relationship:** must be provisionable in the environment for SC2/SC3/SC9/SC19/SC20 to execute. **Status:** Satisfied (`__ensure_gitbucket()` provisions it).
- **Reference:** `.opencode/tests-v2/with-test-home` (`GB_ENV_ARGS`, `env -i` invocation, `do_setup`, test-home provisioning) — **Relationship:** `GB_ENV_ARGS` must carry the full `GB_*` suite (SC19/R-14) — test-env constants always set, `GB_TOKEN` scoped to the test instance when provisioned — and `do_setup`/test-home provisioning must seed the pre-fabricated `gb` config.toml (SC20/R-15) before the 2242-sc6 executor can authenticate `gb`. **Status:** Satisfied (exists in current code).
- **Reference:** `.opencode/skills/issue-operations/platforms/gitbucket-api/` (`gb auth login`, `gb` config) — **Relationship:** `gb` authenticates via its config file (`$HOME/.config/gb/config.toml`), not environment variables; the pre-fabricated fixture (SC20) must mirror the `default_host` + host-token format validated in `.opencode/.issues/2059/spec.md`. **Status:** Satisfied (exists in current code).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC1 | 1 |
| R-2 | SC2 | 2 |
| R-3 | SC4 | 4 |
| R-4 | SC5, SC7 | 5, 7 |
| R-5 | SC8 | 8 |
| R-6 | SC9 | 9 |
| R-7 | SC9 | 9 |
| R-8 | SC10, SC11, SC12 | 10, 11, 12 |
| R-13 | SC3 | 3 |
| R-9 | SC18 | 18 |
| R-10 | SC6 | 6 |
| R-11 | SC13, SC14, SC15, SC16 | 13, 14, 15, 16 |
| R-12 | SC17 | 17 |
| R-14 | SC19 | 19 |
| R-15 | SC20 | 20 |

Dependency DAG: SC1 + SC5 + SC9 precede SC2; SC4 must be verified before SC2's wiring (mutual-exclusion rejection precedes origin wiring); SC2 precedes SC10; SC10 precedes SC11 and SC12; SC5 (env -i passthrough), SC14 (allowlist-only-minimal) and SC15 (allowlist-no-secrets) all concern the same `env -i` allowlist block and are verified together; SC13 (env-set rule) precedes SC17 (GB_* concrete instance) and is verified alongside SC2's GitBucket provisioning (test-env constants always set; `GB_TOKEN` scoped to the provisioned instance only) and alongside the default path (test-env constants still set; no `GB_TOKEN` when no GitBucket); SC16 (values-generated) is verified with SC13; SC18 (AGENTS.md documentation) is an independent string gate; SC19 (full GB_* suite propagation) and SC20 (pre-fabricated gb config.toml seeding) are prerequisites for SC10/SC11 — they precede the behavioral discovery SCs because the executor cannot authenticate `gb` to discover merged PRs until both the complete `GB_*` env suite reaches it (SC19) and the test home carries a seeded `gb` config (SC20); SC8 is the final regression gate.

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `helpers.sh` | code | `.opencode/tests-v2/behaviors/helpers.sh` | read — `behavior_run()`, `__ensure_gitbucket()`, `__reset_gitbucket()`, `__kill_gitbucket()`, `BEHAVIOR_SET_BARE_REMOTE` block, origin-wiring block |
| `with-test-home` | code | `.opencode/tests-v2/with-test-home` | read — `do_clean()`, `do_clean_all()`, `env -i` invocation + allowlist block, `set-env.sh` (minimal-infrastructure refactor for SC14/SC15, test-env constants + `GB_TOKEN` scoping for SC17, full GB_* suite `GB_ENV_ARGS` for SC19, gb config.toml seeding for SC20) |
| `helpers.sh` | code | `.opencode/tests-v2/behaviors/helpers.sh` | read — `__ensure_gitbucket()` (test-env constants for SC17/SC19; scopes `GB_TOKEN` to test instance; export GB_REPO/GB_PROTOCOL for SC19) |
| `with-test-home` | code | `.opencode/tests-v2/with-test-home` | read — `do_setup`, `seed_model_config`, test-home provisioning (sets required test values for SC13/SC16) |
| `AGENTS.md` | doc | `.opencode/tests-v2/AGENTS.md` | read — §5 Infrastructure Details, §12 GitBucket; write — mutual-exclusion rule + opt-in capability documentation (SC18) |
| `2242-sc6` test + fixture | code | `.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh` and `.opencode/tests-v2/behaviors/fixtures/setup/2242-sc6-cleanup-dispatch-no-task-card-read.sh` | read — merged-branch + open-issue fixture setup |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Edge Cases

- **Input boundary — flag unset/absent:** `BEHAVIOR_NEEDS_MULTI_SUBMODULES` and `BEHAVIOR_NEEDS_REMOTE` absent or set to a non-`1` value. **Expected behavior:** `behavior_run()` uses default single-`.opencode`/`local` provisioning; no sibling fixtures, no origin remote. **Resolution:** guard checks `${FLAG:-0} = "1"`; default path preserved.
- **State transition — flag set mid-run:** The flags are read once at `behavior_run()` start; changing them mid-run has no effect. **Expected behavior:** provisioning is fixed for the duration of the run. **Resolution:** flags are evaluated at the provisioning block, not dynamically re-read.
- **Failure mode — mutual exclusion violated:** Both `BEHAVIOR_NEEDS_REMOTE=1` and `BEHAVIOR_SET_BARE_REMOTE=1` set. **Expected behavior:** `behavior_run()` rejects the config with a `HARNESS_FAILURE` exit and does not attempt ambiguous origin wiring. **Resolution:** explicit rejection check before either wiring block.
- **Failure mode — GitBucket provisioning fails:** `__ensure_gitbucket()` cannot start GitBucket (JDK missing, download failure). **Expected behavior:** `behavior_run()` prints `HARNESS_FAILURE: GitBucket provisioning failed` and returns 1. **Resolution:** `__ensure_gitbucket() || { HARNESS_FAILURE; return 1; }`.
- **Concurrency — flock lock contention:** Two tests run concurrently and contend on `tmp/.behavior-run.lock`. **Expected behavior:** the losing test waits up to the flock timeout then exits with `HARNESS_FAILURE: lock contention`. **Resolution:** existing flock guard in `behavior_run()`; cleanup of stale lock files per `tests-v2/AGENTS.md` §10.1.
- **Concurrency — orphan GitBucket process:** A killed run leaves a GitBucket process holding `tmp/.gitbucket.pid`. **Expected behavior:** a subsequent `--clean-all` / `__kill_gitbucket()` terminates the stale process. **Resolution:** `do_clean_all()` and `__kill_gitbucket()` kill the PID and remove the pid/port files and data dir.
- **Failure mode — parent GB_* leak into test env:** A parent-sourced `GB_*`/`GITBUCKET_PORT` value is present in the parent shell and the isolated test env inherits it (instead of the harness's test-env constants / the test instance's scoped token). **Expected behavior:** the isolated test env has the harness's test-env constants (`GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GITBUCKET_PORT`) always set, and `GB_TOKEN` only from the provisioned test instance when `BEHAVIOR_NEEDS_REMOTE=1` — never any parent-sourced `GB_*`/`GITBUCKET_PORT` value (SC17). **Resolution:** `with-test-home` `env -i` allowlist, `GB_ENV_ARGS`, and `set-env.sh` MUST NOT pass through parent-sourced `GB_*`/`GITBUCKET_PORT`; the harness sets the test-env constants itself and `__ensure_gitbucket()` scopes `GB_TOKEN` to the test instance's value.
- **Failure mode — general parent env leak into test env:** A parent shell carries any secret, credential, platform token, or environment-specific configuration (GITHUB_*, GH_*, NODE_ENV, VIRTUAL_ENV, CONDA_DEFAULT_ENV, OPENCODE_CONFIG_CONTENT, API keys) and the `env -i` allowlist admits it. **Expected behavior:** the isolated test env inherits none of these; the allowlist contains only the minimal infrastructure set, and any value a test needs is set by the test setup (SC13–SC16). **Resolution:** `with-test-home` `env -i` allowlist enumerates only the minimal infrastructure set; `do_setup`/`seed_model_config`/test-home provisioning sets required test values.
- **Failure mode — executor cannot authenticate `gb`:** The executor calls `gb pr view` (or similar) against the provisioned GitBucket but fails with 'Not authenticated' because the full `GB_*` suite did not reach the isolated env (SC19) or the test home has no seeded `gb` config.toml (SC20). **Expected behavior:** the executor discovers the merged PR/issue and cleanup proceeds (SC10/SC11). **Resolution:** `GB_ENV_ARGS` in `with-test-home` propagates the full `GB_*` suite (`GB_TOKEN`, `GB_HOST`, `GITBUCKET_PORT`, `GB_REPO`, `GB_PROTOCOL`) — test-env constants always set, `GB_TOKEN` scoped to the test instance when provisioned; `do_setup`/test-home provisioning seeds `$TEST_HOME/.config/gb/config.toml` with `default_host` and the host token (token present only when GitBucket provisioned).
- **Recovery — repeated run after full-env run:** Provisioned clones/state remain from a prior run. **Expected behavior:** SC9 cleanup leaves a clean `tmp/` so the next run provisions fresh. **Resolution:** `--clean-all` removes submodule clones, GitBucket process, and stale state.

## Change Control

### 2026-08-05 — Revise (spec-creation revise pipeline, developer-directed GB_* scoping semantics)

- **What changed:** Corrected the GB_* scoping semantics across SC17, SC19, SC20, R-12, R-14, R-15, Item 17/19/20, cost-frames, Dependencies, the §7 Dependency DAG, Documentation Sources, and the §10 edge cases. The corrected model: the test-env-specific `GB_*` values (`GB_HOST`, `GB_REPO`, `GB_PROTOCOL`, `GITBUCKET_PORT`) are **test-env constants** that the harness ALWAYS sets in the isolated test environment — regardless of whether a test GitBucket is running. Only `GB_TOKEN` (the secret credential) is set when and only when the harness provisioned a test GitBucket (`BEHAVIOR_NEEDS_REMOTE=1`); it is absent/empty otherwise. No parent-sourced `GB_*`/`GITBUCKET_PORT` value ever leaks into the isolated test env. The `gb` config.toml fixture (SC20/R-15) seeds the harness's `default_host` constant always, with the host token present only when GitBucket is provisioned.
- **Why:** Developer-directed revision (revision_reason: clarify GB_* scoping semantics). The prior wording ("GB_* absent unless scoped to the provisioned test GitBucket") was incorrect: the test-env constants are always present as harness constants; only the `GB_TOKEN` credential is provisioned-scoped.
- **Who authorized the change:** Developer-directed revision (revision_reason: clarify GB_* scoping semantics).

### 2026-08-05 — Revise (spec-creation revise pipeline, developer-directed GB_* suite + gb config.toml SCs)

- **What changed:** Added SC19 (full `GB_*` env suite propagation) and SC20 (pre-fabricated `gb` config.toml seeding) as structural SCs, appended after SC18 (atomic decomposition — no renumbering of existing SCs 1–18). Added matching requirements R-14 and R-15, Items 19 and 20, cost-frames, an executor-authentication edge case, and Documentation Sources/Dependencies entries. Extended `GB_ENV_ARGS`/`__ensure_gitbucket()` to the full `GB_*` suite and added `do_setup` test-home `gb` config.toml seeding to Items/requirements. Updated §7 Traceability (R-14→SC19, R-15→SC20) and the Dependency DAG — SC19 and SC20 are prerequisites for SC10/SC11 (they precede the behavioral discovery SCs), encoded as a new `phase_10` in the dependency contract. SC17 invariant intact: `GB_*` still absent when no GitBucket is provisioned.
- **Why:** Developer-directed revision (revision_reason: the 2242-sc6 full-env behavioral test's cleanup executor cannot authenticate `gb` against the harness-provisioned GitBucket — `gb pr view` fails 'Not authenticated' because the executor's environment lacks the full `GB_*` suite and the test home has no `gb` config file). SC19 ensures the harness propagates `GB_TOKEN`, `GB_HOST`, `GITBUCKET_PORT`, `GB_REPO`, `GB_PROTOCOL` into the isolated env when `BEHAVIOR_NEEDS_REMOTE=1`; SC20 ensures the test home seeds a pre-fabricated `gb` config.toml (`default_host` + host token) so `gb` authenticates deterministically without `gb auth login`.
- **Who authorized the change:** Developer-directed revision (revision_reason: 2242-sc6 full-env cleanup executor `gb` authentication).

### 2026-08-05 — Revise (spec-creation revise pipeline, developer-directed correct-execution SCs)

- **What changed:** Revised SC10 and SC11 to measure correct task execution rather than literal tool-call mechanics. SC10 no longer measures the literal `gh pr list` command; it now measures whether the full-env opt-in enables the agent to discover the merged branch/PR state needed to execute cleanup (via any discovery mechanism the agent uses — git primitives, `gb pull-request list`, `gh pr list`, or any other) and that cleanup proceeds. SC11 no longer measures whether the orchestrator read or did not read `tasks/cleanup.md`; it now measures whether the git-workflow-cleanup dispatch followed the correct task card's instructions and completed correctly, producing a result contract. Updated the matching cost-frames, §1.6 User Intent, Item 10/Item 11, and R-8. SC12 (no PR-context halt) unchanged. Both evidence types remain behavioral.
- **Why:** Developer-directed revision (revision_reason: SC10 and SC11 defined success by literal tool-call mechanics rather than by correct task execution). The measure of success is whether the task was executed correctly — the correct task card's instructions were followed and the cleanup completed — not whether a specific command (`gh pr list`) or read/no-read pattern occurred.
- **Who authorized the change:** Developer-directed revision (revision_reason: correct-execution SC10/SC11).

### 2026-08-04 — Revise (spec-creation revise pipeline, Traceability)

- **What changed:** Completed the §7 Traceability table. Added SC3 (merged-PR/issue discovery, behavioral) mapping to a new requirement R-13, and added SC7 (isolation check passes after extension, structural) mapping to R-4. Added R-13 to §4 Requirements ("When the GitBucket origin is wired, the test SHALL be able to discover merged branches and open issues via `gh pr list` without GitHub auth, and SHALL NOT halt for missing PR/branch context"). Every SC now maps to ≥1 requirement and every requirement maps to ≥1 SC.
- **Why:** Validation (spec-creation validate) reported Traceability FAIL — SC3 and SC7 were orphan SCs: present in the SC table, Items, cost-frames, and Dependency DAG but absent from the §7 Traceability table. SC3 maps to the general discovery requirement R-13 (R-8 is narrowly scoped to the 2242 test); SC7 verifies R-4's "SHALL NOT add any production-secret variable" clause.
- **Who authorized the change:** Pipeline-initiated revision from the spec-creation validate→revise loop.

### 2026-08-04 — Revise (spec-creation revise pipeline, Atomicity/Determinism/Correctness/Traceability)

- **What changed:** (1) Decomposed compound SC2 into SC2 (origin wiring, structural) + SC3 (merged-PR/issue discovery, behavioral). Decomposed compound SC4 into SC5 (env -i passthrough superset), SC6 (set-env.sh records flags), SC7 (isolation check still passes). Decomposed compound SC10 into SC13 (test-provisioned environment), SC14 (allowlist minimal infra set), SC15 (allowlist no parent secrets), SC16 (required values generated by setup). (2) Replaced the `e.g.` escape hatches inside the SC14/SC15 and R-11 SHALL-clauses with exhaustive "namely exactly ..." / "namely none of ..." enumerations to make the allowlist bounds deterministic. (3) Fixed the Documentation Sources / Dependency attribution of `do_setup` and `seed_model_config` from `helpers.sh` to `.opencode/tests-v2/with-test-home` (they are defined there, ~lines 106/135, not in `helpers.sh`). (4) Added new SC18 (AGENTS.md documentation, string) and mapped R-9 to it (previously R-9 mapped to behavior-verifying SC1/SC2/SC3). Renumbered all downstream SCs, Items, cost-frames, requirements mapping, traceability, dependencies, and the Dependency DAG to the 18-SC atomic count. Refreshed `.opencode/.issues/2244/sc-summary.yaml` to the current 18-SC count.
- **Why:** Validation (spec-creation validate) reported four defects: Atomicity FAIL (SC2/SC4/SC10 compound), Determinism FAIL (SC10 `e.g.` escape hatch inside a "SHALL contain ONLY" clause), Correctness FAIL (`do_setup`/`seed_model_config` misattributed to `helpers.sh` instead of `with-test-home`), and Traceability FAIL (R-9 mapped to behavior-verifying SCs with no documentation SC). Each SC must be a single independently verifiable claim; SHALL clauses must be deterministic; documentation sources must match the real file; and every requirement must map to an SC that verifies it.
- **Who authorized the change:** Pipeline-initiated revision from the spec-creation validate→revise loop.

### 2026-08-04 — Revise (spec-creation revise pipeline, developer-directed general env-set hardening rule)

- **What changed:** Refactored SC10 from the GB_*-specific non-leakage criterion into a general, explicit env-set principle: the test harness MUST set all environment variables required by tests within the test environment setup (`do_setup`/`seed_model_config`/test-home provisioning), never inherit them from the parent/production shell; the `env -i` allowlist MUST contain ONLY the minimal, explicitly enumerated infrastructure set (PATH, SHELL, TERM, LANG, USER, LOGNAME, GIT_CONFIG_NOSYSTEM, XDG_* into the test home, SNAP_USER_DATA/SNAP_USER_COMMON, and test-provisioned values) and MUST NOT include any parent-sourced variable carrying secrets, credentials, platform tokens, or environment-specific configuration (GB_*, GITHUB_*, GH_*, NODE_ENV, VIRTUAL_ENV, CONDA_DEFAULT_ENV, OPENCODE_CONFIG_CONTENT, API keys). Added new SC11 as the concrete GB_* instance of the general rule (preserving the existing GB_* specificity). Renumbered R-11 to the general env-set SHALL and added R-12 for the GB_* instance. Added Item 10 (general env-set) and Item 11 (GB_* instance), cost-frames for both, a general parent-env edge case, and a Key Design Decision. Updated §2 Not Included (isolation wall relaxation), §6 Dependencies, §7 Traceability (R-11→SC10, R-12→SC11), §8 Documentation Sources, and the Dependency DAG. Refreshed `.opencode/.issues/2244/sc-summary.yaml` to the current 11-SC count.
- **Why:** Developer-directed correctness/security hardening: the env-set rule must be a general, explicit principle applying to ALL environment variables — not a GB_*-specific fix. Every required value must be test-provisioned; the `env -i` allowlist carries only the minimal infrastructure set so no parent-sourced secret, credential, or platform token leaks into the isolated test env.
- **Who authorized the change:** Developer-directed revision (revision_reason: general env-set hardening rule).

### 2026-08-04 — Revise (spec-creation revise pipeline, developer-directed GB_* non-leakage)

- **What changed:** Added SC10 (GB_* non-leakage) as a new success criterion. The `env -i` allowlist in `with-test-home` currently exports `GB_TOKEN="${GB_TOKEN:-}"` / `GB_HOST="${GB_HOST:-}"` and passes `GITBUCKET_PORT` through, which propagates any parent-shell `GB_*`/`GITBUCKET_PORT` values into the isolated test env. Added a corresponding Requirement R-11 (RFC 2119 SHALL), Item 10, cost-frame, edge case, and a Key Design Decision. Updated §6 Dependencies, §7 Traceability, and §8 Documentation Sources to reference SC10/R-11.
- **Why:** Developer-directed correctness/security fix: the harness must NOT leak production `GB_*` environment variables into the isolated test environment. When `BEHAVIOR_NEEDS_REMOTE=1` provisions GitBucket, `GB_TOKEN`/`GB_HOST`/`GITBUCKET_PORT` MUST be the test instance's generated values; when no GitBucket is provisioned they MUST be absent/empty.
- **Who authorized the change:** Developer-directed revision (revision_reason: GB_* passthrough non-leakage).

### 2026-08-03 — Revise (spec-creation revise pipeline, Atomicity/Compound-SC)

- **What changed:** Decomposed the compound SC2 into two atomic SCs: SC2 now covers only GitBucket origin wiring + merged-PR/branch discovery; new SC3 covers the mutual-exclusion rejection (`HARNESS_FAILURE` when both `BEHAVIOR_NEEDS_REMOTE` and `BEHAVIOR_SET_BARE_REMOTE` are set). Renumbered the downstream SCs (old SC3→SC4, SC4→SC5, SC5→SC6, SC6→SC7, SC7→SC8, SC8→SC9) and their corresponding Items (§5) and cost-frames. Updated §7 Traceability so R-3 maps to the new SC3 (not the wiring/discovery SC), and refreshed the Dependency DAG. Refreshed `.opencode/.issues/2244/sc-summary.yaml` to the current 9-SC atomic count.
- **Why:** Validation (spec-creation validate) reported Atomicity FAIL and Compound SC detection FAIL — SC2 bundled three independently verifiable claims (origin wiring, PR/branch discovery, and mutual-exclusion rejection) and both R-2 and R-3 mapped to it. Each SC must now be a single independently verifiable claim.
- **Who authorized the change:** Pipeline-initiated revision from the spec-creation validate→revise loop.

### 2026-08-03 — Revise (spec-creation revise pipeline)

- **What changed:** Added missing sections per the spec-structure-standards reference (Intent/Executive Summary with Alternatives Considered & Key Design Decisions, Not Included, Requirements R-1…R-10, Items per-SC, Dependencies, Documentation Sources, Enforcement Gate, Edge Cases). Replaced all `e.g.` escape hatches with exact deterministic flag names (`BEHAVIOR_NEEDS_MULTI_SUBMODULES=1`, `BEHAVIOR_NEEDS_REMOTE=1`, `BEHAVIOR_SET_BARE_REMOTE=1`) and an exact discovery target (`gh pr list` against the GitBucket origin). Split the compound SC6 into three atomic SCs (SC6 merged-PR discovery, SC7 cleanup dispatch without task-card read, SC8 no PR-context halt). Removed all line-number references (`~L429-464`, `~L505-511`, `~L491-496`, `~L421-443`, `~L382`, `~L66-104`) and replaced them with stable function/section anchors (`behavior_run()`, `__ensure_gitbucket()`, `__reset_gitbucket()`, `__kill_gitbucket()`, `do_clean()`, `do_clean_all()`, `env -i` allowlist, `set-env.sh`, `tests-v2/AGENTS.md` §5/§12). Added RFC 2119 SHALL/SHOULD/MAY Requirements section.
- **Why:** Validation (spec-creation validate) reported Completeness FAIL, Clarity FAIL, Atomicity FAIL, Determinism FAIL, and SHALL-language conformance FAIL. This revision addresses all five findings without changing the spec's scope, requirements, or success-criteria intent.
- **Who authorized the change:** Pipeline-initiated revision from the spec-creation validate→revise loop.

### 2026-08-03 — Initial spec (stacked into #2242 PR)

- **What changed:** Created this spec as new infrastructure for full-environment simulation in the `.opencode/tests-v2` harness, stacked into the #2242 PR (branch `feature/2242-git-workflow-workflows-format`). 6 SCs / 6 items with acyclic dependency DAG.
- **Design decisions:** test-submodule-1/2 wired as **local git repos** (not remote clones) to avoid GitHub auth in the isolated test env; GitBucket origin wiring reconciles with the existing `BEHAVIOR_SET_BARE_REMOTE` flag via mutual exclusion; all new capability is opt-in ("only when needed"), NOT universal replacement.
- **Why:** The 2242-sc6 cleanup-dispatch test dead-ended because `gh pr list` fails against a `local`-platform repo with no origin remote. This capability is prerequisite infrastructure for #2242 SC6/SC7.
