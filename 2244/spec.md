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

Add an opt-in capability to the harness: a `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1` flag provisions `test-submodule-1` and `test-submodule-2` as local git repos in the attempt workdir, and the existing `BEHAVIOR_NEEDS_REMOTE=1` flag wires a GitBucket instance as the test repo's `origin` remote. Both capabilities are opt-in and mutually exclusive with the existing `BEHAVIOR_SET_BARE_REMOTE=1` bare-remote flag. The env `env -i` allowlist in `with-test-home` is extended (superset only) to pass the new flags through, and `GB_*`/`GITBUCKET_PORT` are scoped so they never leak from the parent shell (SC10). Cleanup is extended so `--clean-all` removes all newly provisioned state.

### 1.4 Alternatives Considered & Why Discarded

- **Wire real GitHub as the origin remote** — Discarded: the isolated test env has no GitHub credentials (`GITHUB_TOKEN`/`GH_TOKEN` are in the FORBIDDEN set of `with-test-home`), so pushing/discovering against real GitHub would require leaking production auth into the test environment, violating the isolation contract. GitBucket provides a local, credentialed origin without leaking production state.
- **Provision sibling submodules as remote `git clone`s of the private GitHub repos** — Discarded: the private fixture repos require GitHub auth to clone, which is unavailable in the isolated env. Local `git init` from fixture templates is deterministic and requires no auth.
- **Make full-environment simulation the universal default** — Discarded: the ~80 existing tests provision a single `.opencode` submodule and `local` platform; changing the default would alter their behavior and require re-verification of every existing test. Opt-in preserves the no-regression guarantee.

### 1.5 Key Design Decisions

- **Multi-submodule fixtures as local git repos, not remote clones:** `test-submodule-1` and `test-submodule-2` are created via local `git init` from fixture templates inside the attempt workdir. Tradeoff: no GitHub auth needed (deterministic), but the fixtures do not reflect the real remote state (acceptable — the test only needs the sibling repos to exist as discoverable `.gitmodules` entries).
- **GitBucket origin wiring reuses the existing `BEHAVIOR_NEEDS_REMOTE` provisioner:** The `__ensure_gitbucket()` function already provisions GitBucket; the origin-wiring block in `behavior_run()` attaches it as `origin`. Tradeoff: reuses proven provisioning machinery, but couples this feature to GitBucket's availability in the environment.
- **Mutual exclusion between `BEHAVIOR_NEEDS_REMOTE` and `BEHAVIOR_SET_BARE_REMOTE`:** A test MUST NOT set both because both try to configure the `origin` remote and would conflict. Contradictory config is rejected with `HARNESS_FAILURE`. Tradeoff: forces test authors to pick exactly one remote strategy, preventing ambiguous origin state.
- **Env passthrough as a strict superset:** New fixture/remote flags are added to the `env -i` allowlist in `with-test-home`; no existing variable is removed or reordered. Tradeoff: keeps the isolation wall intact while extending reach.
- **GB_* scoped to the test instance only:** Parent-sourced `GB_TOKEN`/`GB_HOST`/`GITBUCKET_PORT` are NOT passed through the `env -i` allowlist; `__ensure_gitbucket()` sets them to the provisioned test instance's generated values only when `BEHAVIOR_NEEDS_REMOTE=1`, and they are absent/empty otherwise. Tradeoff: tests that need GitBucket must opt in to provisioning, but the default path never leaks a production GitBucket credential or host into the isolated test env.

### 1.6 User Intent / Original Prompt

The `.opencode` #2242 SC6/SC7 cleanup-dispatch behavioral test (`.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh`) requires the agent to discover a merged PR and dispatch cleanup without reading a task card or halting for PR/branch context. The user's intent is that this test be able to complete against a full-environment simulation (sibling submodules and/or a GitBucket origin) so the skill-card migration is verifiable.

## 2. Not Included

- **Real GitHub / GitBucket as the default remote** — The full-environment simulation is opt-in only; the default single-`.opencode`/`local` provisioning is preserved. Rationale: SC4 no-regression gate.
- **Modification of the ~80 existing test scripts** — Only `2242-sc6-cleanup-dispatch-no-task-card-read.sh` is extended to set the opt-in. Rationale: existing tests are regression fixtures and must remain byte-for-byte unchanged.
- **Provisioning more than two sibling submodules** — Only `test-submodule-1` and `test-submodule-2` are in scope. Rationale: the motivating test needs exactly two sibling repos; more would be speculative.
- **GitHub Actions / CI integration** — The capability is scoped to the local behavioral harness only. Rationale: CI is out of scope for this spec.

## 3. Success Criteria

### SC Table

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC1 | When `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1` is set in the environment, `behavior_run()` in `helpers.sh` provisions `test-submodule-1` and `test-submodule-2` as local git repos (created via `git init` from fixture templates) inside the attempt workdir, in addition to the existing `.opencode` clone. When the flag is unset or absent, `behavior_run()` provisions only the existing single `.opencode` clone. | structural | `ls` the attempt workdir for `test-submodule-1` and `test-submodule-2` directories and confirm `git submodule status` lists them when the flag is set; confirm their absence when the flag is unset. | `.opencode/tests-v2/behaviors/helpers.sh` (`behavior_run()` submodule provisioning block); `.opencode/tests-v2/behaviors/fixtures/` |
| SC2 | When `BEHAVIOR_NEEDS_REMOTE=1` is set in the environment and GitBucket is provisioned, `behavior_run()` wires the GitBucket instance as the test repo's `origin` remote, and the agent's `gh pr list` call in the isolated test env discovers merged branches and open issues without GitHub auth. | behavioral | `opencode run` with `BEHAVIOR_NEEDS_REMOTE=1`; clean-room evaluation of `session.yaml` confirms `gh pr list` returns merged-branch/issue results and the agent does not halt for missing PR context. | `.opencode/tests-v2/behaviors/helpers.sh` (`__ensure_gitbucket()`, origin-wiring block); `.opencode/tests-v2/AGENTS.md` §12 |
| SC3 | When both `BEHAVIOR_NEEDS_REMOTE=1` and `BEHAVIOR_SET_BARE_REMOTE=1` are set, `behavior_run()` rejects the configuration with a `HARNESS_FAILURE` exit and does not attempt ambiguous origin wiring. | behavioral | Run `behavior_run()` with both flags set; assert the `HARNESS_FAILURE` exit and that no origin-wiring is attempted. | `.opencode/tests-v2/behaviors/helpers.sh` (`BEHAVIOR_SET_BARE_REMOTE` block, mutual-exclusion rejection check) |
| SC4 | The `env -i` allowlist in `with-test-home` passes through `BEHAVIOR_NEEDS_MULTI_SUBMODULES`, `BEHAVIOR_NEEDS_REMOTE`, and `BEHAVIOR_SET_BARE_REMOTE` as a strict superset (no existing allowlisted variable is removed), and `set-env.sh` records the new flags. The isolation check (no production state leaked) still passes after the extension. | structural | Inspect the `env -i` invocation and the allowlist block in `with-test-home` and `set-env.sh` for the three new variable names; run the isolation verification procedure. | `.opencode/tests-v2/with-test-home` (`env -i` invocation + allowlist block, `set-env.sh`); `.opencode/tests-v2/AGENTS.md` §5 (Isolation Verification Procedure) |
| SC5 | With no opt-in flags set, a representative non-opt-in behavioral test provisions exactly one `.opencode` submodule and the `local` platform (no origin remote) — byte-for-byte identical to the current default provisioning of the ~80 existing tests. | behavioral | Run a representative non-opt-in behavioral test; clean-room evaluation of `session.yaml` confirms single-`.opencode` provisioning and no origin remote. | `.opencode/tests-v2/behaviors/helpers.sh`; `.opencode/tests-v2/with-test-home` |
| SC6 | After a full-env provisioned run, `--clean-all` in `with-test-home` (via `do_clean_all()`) and `__kill_gitbucket()` / `__reset_gitbucket()` in `helpers.sh` remove the provisioned `test-submodule-1`/`test-submodule-2` clones, the GitBucket process, and all stale `tmp/` state, leaving no orphan clones or processes; a repeated run starts clean. | behavioral | After a provisioned run, invoke `--clean-all` and `__kill_gitbucket()`; assert no orphan GitBucket process is running and no stale `tmp/` submodule clones/state remain; then run again and confirm a clean start. | `.opencode/tests-v2/with-test-home` (`do_clean()`, `do_clean_all()`); `.opencode/tests-v2/behaviors/helpers.sh` (`__reset_gitbucket()`, `__kill_gitbucket()`) |
| SC7 | When the full-env opt-in (`BEHAVIOR_NEEDS_MULTI_SUBMODULES=1` and `BEHAVIOR_NEEDS_REMOTE=1`) is set for `2242-sc6-cleanup-dispatch-no-task-card-read.sh`, the test's `session.yaml` shows that merged-PR discovery (`gh pr list`) returned a merged branch and an open issue during the run. | behavioral | Run `2242-sc6-cleanup-dispatch-no-task-card-read.sh` with the full-env opt-in; clean-room evaluation of `session.yaml` confirms `gh pr list` returned the merged branch and open issue. | `.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh`; `.opencode/tests-v2/behaviors/fixtures/setup/2242-sc6-cleanup-dispatch-no-task-card-read.sh` |
| SC8 | In the SC7 run, the git-workflow-cleanup dispatch completes and produces a result contract, and `session.yaml` shows the orchestrator never read the cleanup task card (`tasks/cleanup.md`) — no file-read tool call targets that path. | behavioral | Clean-room evaluation of the SC7 `session.yaml` confirms the cleanup dispatch produced a result contract and no task-card read of `tasks/cleanup.md` appears in the tool timeline. | `.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh` |
| SC9 | In the SC7 run, `session.yaml` shows the agent never halted to ask the user for PR/branch context (no question-tool call or "provide PR" style halt). | behavioral | Clean-room evaluation of the SC7 `session.yaml` confirms no PR/branch-context halt or question-tool invocation. | `.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh` |
| SC10 | `GB_*` environment variables MUST be ABSENT from the isolated test environment unless they are scoped to the provisioned test GitBucket instance. (a) When `BEHAVIOR_NEEDS_REMOTE=1` provisions GitBucket, `GB_TOKEN` and `GB_HOST` MUST be set to the test instance's own generated values (root/generated token, `http://localhost:<port>`) — never inherited from the parent env. (b) When GitBucket is NOT provisioned, `GB_TOKEN`, `GB_HOST`, and `GITBUCKET_PORT` MUST be absent/empty in the test env — the harness MUST NOT pass through parent-sourced `GB_*`/`GITBUCKET_PORT` values via the `env -i` allowlist or `set-env.sh` in `with-test-home`. | string | Inspect the `env -i` allowlist and `set-env.sh` in `with-test-home` for `GB_*` sourcing; confirm no parent-sourced `GB_*`/`GITBUCKET_PORT` values propagate when no GitBucket is provisioned, and confirm `__ensure_gitbucket()` in `helpers.sh` scopes `GB_TOKEN`/`GB_HOST`/`GITBUCKET_PORT` to the test instance when provisioned. | `.opencode/tests-v2/with-test-home` (`env -i` allowlist, `set-env.sh`); `.opencode/tests-v2/behaviors/helpers.sh` (`__ensure_gitbucket()`); `.opencode/tests-v2/AGENTS.md` §5 (Isolation Verification Procedure) |

### Per-SC Cost-Frame (dark-prose-007)

| ID | Cost-Frame |
|----|------------|
| SC1 | Failing to provision fixture submodules means every remote-sensitive test inherits the dead-end halt. A test that cannot see its merged branch and open issue cannot exercise cleanup — it burns a model run to end in a question. You will accept that cost every single time you skip this. |
| SC2 | Wiring GitBucket as origin is the difference between a workflow that completes and one that stalls at `gh pr list`. A cleanup test that halts for PR context is not a test of cleanup — it is a test of the model's willingness to ask questions. That is not the behavior under test. |
| SC3 | Allowing both remote flags to be set simultaneously produces an ambiguous `origin` — a harness that silently picks one strategy corrupts the isolation contract. Contradictory config rejected early is a harness that fails loudly instead of failing silently. |
| SC4 | Leaking production state through a careless allowlist extension silently corrupts every test that follows. The isolation contract is the wall between your test and your real repo. A breach here is not a flaky test — it is a data-integrity event in your working tree. |
| SC5 | A regression in the default single-`.opencode` path breaks all ~80 existing tests at once. The opt-in design is the shield; SC5 is the proof the shield holds. Without it, you ship a change whose blast radius you have not measured. |
| SC6 | Orphan GitBucket processes and stale clones poison every subsequent run and hold the flock. A harness that cannot clean itself is a harness that eventually stops working for reasons nobody can reproduce. Cleanup is not housekeeping — it is the precondition for a reliable next run. |
| SC7 | The motivating test exists to prove the git-workflow cleanup dispatch completes. If merged-PR discovery still fails, the #2242 SC6/SC7 evidence is unobtainable and the whole skill-card migration is unverifiable. This SC is not optional scope — it is the point of the capability. |
| SC8 | A cleanup dispatch that silently reads the task card defeats the entire no-task-card-read purpose of the test. If the orchestrator reads `tasks/cleanup.md`, the behavioral evidence is invalid and the migration claim is unsupported. |
| SC9 | A run that halts to ask the user for PR/branch context is not a completed cleanup dispatch — it is a deferred question. If the agent asks instead of acting, the SC7/SC8 evidence is unobtainable and the capability has not delivered. |
| SC10 | Passing a parent-sourced `GB_TOKEN`/`GB_HOST`/`GITBUCKET_PORT` into the isolated test env means every no-GitBucket test silently talks to — or authenticates as — your production GitBucket. That is not an isolation breach you can reproduce; it is a production-credential leak into a test you believed was sandboxed. When no GitBucket is provisioned the `GB_*` vars must be empty; when it is, they must belong to the test instance alone. |

## 4. Requirements

- **R-1.** The harness SHALL provision `test-submodule-1` and `test-submodule-2` as local git repos inside the attempt workdir when `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1` is set, and SHALL NOT provision them when the flag is unset or absent.
- **R-2.** The harness SHALL wire the GitBucket instance as the test repo's `origin` remote in the attempt workdir when `BEHAVIOR_NEEDS_REMOTE=1` is set and GitBucket is provisioned.
- **R-3.** The harness SHALL reject configuration where both `BEHAVIOR_NEEDS_REMOTE=1` and `BEHAVIOR_SET_BARE_REMOTE=1` are set, with a `HARNESS_FAILURE` exit.
- **R-4.** The `env -i` allowlist in `with-test-home` SHALL pass through `BEHAVIOR_NEEDS_MULTI_SUBMODULES`, `BEHAVIOR_NEEDS_REMOTE`, and `BEHAVIOR_SET_BARE_REMOTE` as a strict superset, SHALL NOT remove any existing allowlisted variable, and SHALL NOT add any production-secret variable to the allowlist.
- **R-5.** The default provisioning (no opt-in flags set) SHALL remain a single `.opencode` submodule and `local` platform with no origin remote, byte-for-byte unchanged.
- **R-6.** `--clean-all` SHALL remove all provisioned submodule clones, the GitBucket process, and all stale `tmp/` state left by a full-env run, so a repeated run starts clean.
- **R-7.** `__kill_gitbucket()` SHALL terminate the GitBucket process without restarting it, and `__reset_gitbucket()` SHALL terminate and restart GitBucket fresh.
- **R-8.** When the full-env opt-in is set for `2242-sc6-cleanup-dispatch-no-task-card-read.sh`, the test SHALL complete merged-PR discovery and cleanup dispatch without the orchestrator reading any cleanup task card and without halting for PR/branch context.
- **R-9.** `tests-v2/AGENTS.md` SHALL document the `BEHAVIOR_NEEDS_MULTI_SUBMODULES` / `BEHAVIOR_SET_BARE_REMOTE` mutual-exclusion rule and the new opt-in capability.
- **R-10.** New fixture/remote flags MAY be added to `set-env.sh` for debugging aid, provided they are also present in the `env -i` allowlist.
- **R-11.** The test environment SHALL NOT inherit any `GB_*` or `GITBUCKET_PORT` value from the parent shell. When `BEHAVIOR_NEEDS_REMOTE=1` provisions GitBucket, `GB_TOKEN`, `GB_HOST`, and `GITBUCKET_PORT` SHALL be set to the test instance's own generated values; when GitBucket is NOT provisioned, these variables SHALL be absent/empty in the test env. The `env -i` allowlist in `with-test-home` SHALL NOT pass through parent-sourced `GB_*`/`GITBUCKET_PORT` values.

## 5. Items

### Item 1 (SC1): Multi-submodule fixture provisioning

- RED: enforcement test asserts no `test-submodule-1`/`test-submodule-2` dirs appear when `BEHAVIOR_NEEDS_MULTI_SUBMODULES` is unset; with the flag set, asserts they do appear.
- GREEN: add the `BEHAVIOR_NEEDS_MULTI_SUBMODULES` branch to `behavior_run()` in `helpers.sh` that `git init`s the two fixture repos.
- verify: `ls` attempt workdir + `git submodule status`; confirm flag-on/flag-off behavior.
- commit: `helpers.sh` + new fixture templates under `behaviors/fixtures/`.

### Item 2 (SC2): GitBucket origin wiring and merged-PR discovery

- RED: enforcement test with `BEHAVIOR_NEEDS_REMOTE=1` fails to produce `gh pr list` output.
- GREEN: ensure the origin-wiring block in `behavior_run()` attaches the GitBucket origin.
- verify: `opencode run` with `BEHAVIOR_NEEDS_REMOTE=1`; clean-room `session.yaml` evaluation confirms discovery.
- commit: `helpers.sh` origin-wiring logic.

### Item 3 (SC3): Mutual-exclusion rejection

- RED: enforcement test with both `BEHAVIOR_NEEDS_REMOTE=1` and `BEHAVIOR_SET_BARE_REMOTE=1` fails to reject with `HARNESS_FAILURE`.
- GREEN: add mutual-exclusion rejection between `BEHAVIOR_NEEDS_REMOTE` and `BEHAVIOR_SET_BARE_REMOTE` in `behavior_run()`.
- verify: run `behavior_run()` with both flags set; assert the `HARNESS_FAILURE` exit.
- commit: `helpers.sh` mutual-exclusion logic.

### Item 4 (SC4): Env passthrough

- RED: enforcement test asserts the three flags are absent from the `env -i` allowlist.
- GREEN: extend the `env -i` allowlist in `with-test-home` and `set-env.sh` with the three flags (superset only).
- verify: inspect `with-test-home` allowlist + `set-env.sh`; run the isolation verification procedure.
- commit: `with-test-home` + `set-env.sh`.

### Item 5 (SC5): No-regression default gate

- RED: enforcement test asserts default provisioning is unchanged (single `.opencode`, `local`).
- GREEN: no implementation change required beyond ensuring SC1/SC2/SC3/SC4 leave the default path intact.
- verify: run a representative non-opt-in behavioral test; clean-room `session.yaml` evaluation.
- commit: verification evidence only (no source change unless regression found).

### Item 6 (SC6): Cleanup

- RED: enforcement test leaves orphan GitBucket process / stale clones after a provisioned run.
- GREEN: extend `do_clean_all()` in `with-test-home` and `__kill_gitbucket()` / `__reset_gitbucket()` in `helpers.sh` to remove all provisioned submodule clones and remote state.
- verify: after a provisioned run, invoke `--clean-all` and `__kill_gitbucket()`; assert no orphans; rerun clean.
- commit: `with-test-home` + `helpers.sh` cleanup functions.

### Item 7 (SC7): Merged-PR discovery for 2242-sc6

- RED: `2242-sc6` test with full-env opt-in fails to show `gh pr list` discovering merged branch + open issue.
- GREEN: extend `2242-sc6-cleanup-dispatch-no-task-card-read.sh` and its per-scenario fixture to set `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1` and `BEHAVIOR_NEEDS_REMOTE=1`.
- verify: clean-room `session.yaml` evaluation confirms merged-PR discovery.
- commit: `2242-sc6` test + per-scenario fixture.

### Item 8 (SC8): Cleanup dispatch without task-card read

- RED: `2242-sc6` run shows a read of `tasks/cleanup.md` in the tool timeline, or no result contract.
- GREEN: verify the dispatch completes without the orchestrator reading the cleanup task card.
- verify: clean-room `session.yaml` evaluation confirms no `tasks/cleanup.md` read and a result contract produced.
- commit: no source change unless the test needs assertion strengthening.

### Item 9 (SC9): No PR-context halt

- RED: `2242-sc6` run shows a question-tool call or PR/branch-context halt.
- GREEN: verify the run completes without asking the user for PR/branch context.
- verify: clean-room `session.yaml` evaluation confirms no PR/branch-context halt.
- commit: no source change unless the test needs assertion strengthening.

### Item 10 (SC10): GB_* non-leakage from parent env

- RED: enforcement test shows `GB_TOKEN`/`GB_HOST`/`GITBUCKET_PORT` values present in the test env from the parent shell when no GitBucket is provisioned (or inherited values when GitBucket IS provisioned).
- GREEN: remove parent-sourced `GB_*`/`GITBUCKET_PORT` from the `env -i` allowlist and `set-env.sh` in `with-test-home`; ensure only `__ensure_gitbucket()` in `helpers.sh` sets these variables to the test instance's generated values when `BEHAVIOR_NEEDS_REMOTE=1`, and they are absent/empty otherwise.
- verify: inspect the `env -i` allowlist + `set-env.sh` for parent-sourced `GB_*`; with a parent `GB_TOKEN`/`GB_HOST` set, confirm the test env has no `GB_*` when no GitBucket is provisioned and the scoped test-instance values when provisioned.
- commit: `with-test-home` (`env -i` allowlist, `set-env.sh`) + `helpers.sh` (`__ensure_gitbucket()`).

## 6. Dependencies

- **Reference:** `.opencode` issue #2242 (SC6/SC7) — **Relationship:** this spec's SC7/SC8/SC9 enable the #2242 cleanup-dispatch test to complete; must be coordinated so the #2242 test's opt-in flags match this spec's flag names. **Status:** Pending — #2242 is the consumer.
- **Reference:** `.opencode/tests-v2/behaviors/helpers.sh` (`behavior_run()`, `__ensure_gitbucket()`, `__reset_gitbucket()`, `__kill_gitbucket()`) — **Relationship:** must be read before implementation to match existing provisioning blocks. **Status:** Satisfied (exists in current code).
- **Reference:** `.opencode/tests-v2/with-test-home` (`do_clean()`, `do_clean_all()`, `env -i` allowlist, `set-env.sh`) — **Relationship:** must be read before extending the allowlist and cleanup; the `GB_*`/`GITBUCKET_PORT` allowlist sourcing must be corrected so parent values never propagate (SC10). **Status:** Satisfied (exists in current code).
- **Reference:** `.opencode/tests-v2/behaviors/helpers.sh` (`__ensure_gitbucket()`) — **Relationship:** must be verified to scope `GB_TOKEN`/`GB_HOST`/`GITBUCKET_PORT` to the test instance (SC10). **Status:** Satisfied (exists in current code).
- **Reference:** `.opencode/tests-v2/AGENTS.md` §5 (Infrastructure Details / Isolation Verification Procedure) and §12 (GitBucket) — **Relationship:** must be read and updated to document the new opt-in capability and mutual-exclusion rule. **Status:** Satisfied (exists in current code).
- **Reference:** GitBucket provisioner (JDK + GitBucket JAR under `.tools/`, `tmp/gitbucket-data`) — **Relationship:** must be provisionable in the environment for SC2/SC6 to execute. **Status:** Satisfied (`__ensure_gitbucket()` provisions it).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC1 | 1 |
| R-2 | SC2 | 2 |
| R-3 | SC3 | 3 |
| R-4 | SC4 | 4 |
| R-5 | SC5 | 5 |
| R-6 | SC6 | 6 |
| R-7 | SC6 | 6 |
| R-8 | SC7, SC8, SC9 | 7, 8, 9 |
| R-9 | SC1, SC2, SC3 | 1, 2, 3 |
| R-10 | SC4 | 4 |
| R-11 | SC10 | 10 |

Dependency DAG: SC1 + SC4 + SC6 precede SC2; SC3 must be verified before SC2's wiring (mutual-exclusion rejection precedes origin wiring); SC2 precedes SC7; SC7 precedes SC8 and SC9; SC10 is verified alongside SC2's GitBucket provisioning (scoped GB_* values) and alongside the default path (absent GB_* when no GitBucket); SC5 is the final regression gate.

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `helpers.sh` | code | `.opencode/tests-v2/behaviors/helpers.sh` | read — `behavior_run()`, `__ensure_gitbucket()`, `__reset_gitbucket()`, `__kill_gitbucket()`, `BEHAVIOR_SET_BARE_REMOTE` block, origin-wiring block |
| `with-test-home` | code | `.opencode/tests-v2/with-test-home` | read — `do_clean()`, `do_clean_all()`, `env -i` invocation + allowlist block, `set-env.sh` (GB_* sourcing for SC10) |
| `AGENTS.md` | doc | `.opencode/tests-v2/AGENTS.md` | read — §5 Infrastructure Details, §12 GitBucket |
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
- **Failure mode — parent GB_* leak into test env:** A `GB_TOKEN`/`GB_HOST`/`GITBUCKET_PORT` value is present in the parent shell and no GitBucket is provisioned (or the test inherits the parent value instead of the test instance's value). **Expected behavior:** the isolated test env has no `GB_*`/`GITBUCKET_PORT` from the parent; when GitBucket is provisioned, only the test instance's generated values are present (SC10). **Resolution:** `with-test-home` `env -i` allowlist and `set-env.sh` MUST NOT pass through parent-sourced `GB_*`/`GITBUCKET_PORT`; `__ensure_gitbucket()` sets them to the test instance's values only.
- **Recovery — repeated run after full-env run:** Provisioned clones/state remain from a prior run. **Expected behavior:** SC5 cleanup leaves a clean `tmp/` so the next run provisions fresh. **Resolution:** `--clean-all` removes submodule clones, GitBucket process, and stale state.

## Change Control

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
