# Plan: Test Framework Isolation, Documentation, and Change Control

**Issue:** #1979
**Spec:** `.opencode/.issues/1979/spec.md`
**Authorization Scope:** `for_pr`
**Halt At:** `pr_created`
**Pipeline Phase:** `plan-creation`

## Phase 1: Documentation and Behavioral Test Creation

Single phase — all items build on each other. Documentation updates must precede behavioral test creation since the tests verify the documented contract.

### SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | AGENTS.md documents complete isolation contract | 1 | 1.1 |
| SC-2 | AGENTS.md documents default model change control | 1 | 1.2 |
| SC-3 | AGENTS.md documents PATH-based binary resolution | 1 | 1.3 |
| SC-4 | with-test-home uses `env -i` with explicit allowlist | 1 | 1.4 (verify existing) |
| SC-5 | with-test-home runs from TEST_PROJECT directory (behavioral) | 1 | 1.5 |
| SC-6 | seed_model_config() generates from Ollama API | 1 | 1.6 (verify existing) |
| SC-7 | helpers.sh resolves opencode from PATH | 1 | 1.7 (verify existing) |
| SC-8 | default-model.sh has DO NOT CHANGE comment | 1 | 1.8 (verify existing) |
| SC-9 | Behavioral test for isolation verification exists and passes | 1 | 1.9 |
| SC-10 | Behavioral test for `env -i` allowlist exists and passes | 1 | 1.10 |
| SC-11 | Stale test home cleanup before each test run | 1 | 1.11 (verify existing) |

### Safety/Rollback

**Phase 1 — Safety/Rollback:**
- Destructive operations: None. All changes are documentation updates and new behavioral test scripts. No existing code is modified — only `tests-v2/AGENTS.md` is updated (documentation only).
- Rollback plan: `git checkout -- .opencode/tests-v2/AGENTS.md` to revert documentation changes. New test scripts can be deleted with `rm`.
- Data loss risk: None

### Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `tests-v2/AGENTS.md` | ✅ | `read` |
| 1.2 | `tests-v2/AGENTS.md` | ✅ | `read` |
| 1.3 | `tests-v2/AGENTS.md` | ✅ | `read` |
| 1.4 | `tests-v2/with-test-home` | ✅ | `read` — `env -i` at line 126 with 14 vars |
| 1.5 | `tests-v2/with-test-home` `_run_isolated` | ✅ | `read` — `cd "$TEST_PROJECT"` at line 126 |
| 1.6 | `tests-v2/with-test-home` `seed_model_config` | ✅ | `read` — `curl.*api/tags` at line 88, no `cp.*opencode.jsonc` |
| 1.7 | `tests-v2/behaviors/helpers.sh` | ✅ | `read` — `command -v opencode` at line 45, no `snap run` |
| 1.8 | `tests-v2/default-model.sh` | ✅ | `read` — "DO NOT CHANGE" at line 4 |
| 1.9 | `tests-v2/behaviors/` | ✅ | `ls` — existing test scripts |
| 1.10 | `tests-v2/behaviors/` | ✅ | `ls` — existing test scripts |
| 1.11 | `tests-v2/with-test-home` `--clean-all` | ✅ | `read` — `do_clean_all` at line 62 |

### Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| `env -i` allowlist has 14 vars | `read(with-test-home:126-143)` | ✅ |
| `_run_isolated` uses `cd "$TEST_PROJECT"` | `read(with-test-home:126)` | ✅ |
| `seed_model_config` uses `curl` for Ollama API | `read(with-test-home:88)` | ✅ |
| No `cp.*opencode.jsonc` in `seed_model_config` | `grep(with-test-home)` | ✅ |
| `helpers.sh` uses `command -v opencode` | `read(helpers.sh:45)` | ✅ |
| No `snap run` in `helpers.sh` | `grep(helpers.sh)` | ✅ |
| `default-model.sh` has "DO NOT CHANGE" | `read(default-model.sh:4)` | ✅ |

## Step-by-Step Execution

### Step 1.1 — Update AGENTS.md: Isolation Contract (SC-1)

**Task:** Update `tests-v2/AGENTS.md` §5 (Infrastructure Details) to document the complete isolation contract.

**Details:**
- Document the `env -i` allowlist with all 14 variables: `HOME`, `PATH`, `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, `XDG_RUNTIME_DIR`, `XDG_DATA_HOME`, `XDG_STATE_HOME`, `SNAP_USER_DATA`, `SNAP_USER_COMMON`, `GIT_CONFIG_NOSYSTEM`, `SHELL`, `USER`, `LOGNAME`, `LANG`, `TERM`, `GB_TOKEN`
- Document that `.opencode` is checked out locally (not cloned from remote) — `cp -a` from parent repo
- Document that model config is generated from Ollama API (`curl localhost:11434/api/tags`)
- Document the isolation verification procedure (SQLite DB `project.worktree` check)
- Add a subsection documenting the local submodule checkout pattern

**Verification:** `grep` for each documented section heading and variable name in AGENTS.md

**Evidence type:** structural

### Step 1.2 — Update AGENTS.md: Default Model Change Control (SC-2)

**Task:** Add documentation in `tests-v2/AGENTS.md` that `DEFAULT_TEST_MODEL` in `default-model.sh` MUST NOT be changed without an approved spec.

**Details:**
- Add a subsection in §5 or a new §10 documenting the change control requirement
- Reference `default-model.sh` as the single source of truth
- State: "DO NOT CHANGE the default model unless explicitly directed to do so by an approved spec"

**Verification:** `grep` for "DO NOT CHANGE" or equivalent language referencing spec requirement in AGENTS.md

**Evidence type:** structural

### Step 1.3 — Update AGENTS.md: PATH-Based Binary Resolution (SC-3)

**Task:** Update `tests-v2/AGENTS.md` §5.1 (Binary) to document that `opencode` is resolved from PATH, not hardcoded to `/snap/bin/opencode`.

**Details:**
- Change the binary documentation from "`opencode` at `/snap/bin/opencode` — the ONLY binary used" to document that `helpers.sh` resolves `opencode` via `command -v opencode` from PATH
- Explain why: snap's `SNAP_USER_DATA` hardcoding breaks `HOME` isolation; PATH resolution allows the test harness to use any opencode installation
- Update the invocation examples in §5 to use `opencode` (not `/snap/bin/opencode`)

**Verification:** `grep` for PATH-based binary resolution documentation in AGENTS.md

**Evidence type:** structural

### Step 1.4 — Verify with-test-home `env -i` Allowlist (SC-4)

**Task:** Verify that `with-test-home` uses `env -i` with the complete allowlist.

**Details:**
- Read `with-test-home` `_run_isolated()` function
- Confirm all 14 variables are present: `HOME`, `PATH`, `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, `XDG_RUNTIME_DIR`, `XDG_DATA_HOME`, `XDG_STATE_HOME`, `SNAP_USER_DATA`, `SNAP_USER_COMMON`, `GIT_CONFIG_NOSYSTEM`, `SHELL`, `USER`, `LOGNAME`, `LANG`, `TERM`, `GB_TOKEN`
- This is already implemented — verification only

**Verification:** `grep` for `env -i` in `with-test-home` and verify each variable

**Evidence type:** structural

### Step 1.5 — Verify with-test-home CWD Isolation (SC-5)

**Task:** Verify that `with-test-home` runs commands from `TEST_PROJECT` directory.

**Details:**
- Read `with-test-home` `_run_isolated()` function
- Confirm `cd "$TEST_PROJECT"` is used before `env -i`
- This is already implemented — verification only

**Verification:** `grep` for `cd.*TEST_PROJECT` in `with-test-home`

**Evidence type:** structural (spec says behavioral but the code is already in place; behavioral verification via SQLite is covered by SC-9)

### Step 1.6 — Verify seed_model_config() Uses Ollama API (SC-6)

**Task:** Verify that `seed_model_config()` generates config from Ollama API, not by copying production config.

**Details:**
- Read `with-test-home` `seed_model_config()` function
- Confirm `curl.*api/tags` is used
- Confirm no `cp.*opencode.jsonc` pattern exists
- This is already implemented — verification only

**Verification:** `grep` for `curl.*api/tags` in `seed_model_config`, verify no `cp.*opencode.jsonc`

**Evidence type:** structural

### Step 1.7 — Verify helpers.sh PATH Resolution (SC-7)

**Task:** Verify that `helpers.sh` resolves `opencode` from PATH, not `snap run`.

**Details:**
- Read `helpers.sh`
- Confirm `command -v opencode` is used
- Confirm no `snap run` pattern exists
- This is already implemented — verification only

**Verification:** `grep` for `command -v opencode` in `helpers.sh`, verify no `snap run`

**Evidence type:** structural

### Step 1.8 — Verify default-model.sh DO NOT CHANGE Comment (SC-8)

**Task:** Verify that `default-model.sh` contains a "DO NOT CHANGE" comment.

**Details:**
- Read `default-model.sh`
- Confirm "DO NOT CHANGE" comment exists referencing spec requirement
- This is already implemented — verification only

**Verification:** `grep` for "DO NOT CHANGE" in `default-model.sh`

**Evidence type:** structural

### Step 1.9 — Create Behavioral Test: Isolation Verification (SC-9)

**Task:** Create a behavioral enforcement test that verifies test home isolation.

**Details:**
- Create `tests-v2/behaviors/test-home-isolation.sh`
- The test should:
  1. Run `with-test-home --setup`
  2. Run `opencode run` with a simple prompt inside the isolated environment
  3. Export the SQLite DB to YAML via `__export_sqlite_to_yaml`
  4. Verify `project.worktree` contains `tmp/test-home-` and does NOT contain the production project path
- Follow the artifact-only generator paradigm (exit 0, no evaluation)
- Include cross-reference header per AGENTS.md §1

**Verification:** Test script exists and can be executed (behavioral — requires model run)

**Evidence type:** behavioral

### Step 1.10 — Create Behavioral Test: `env -i` Allowlist (SC-10)

**Task:** Create a behavioral enforcement test that verifies `with-test-home` uses `env -i` with correct allowlist.

**Details:**
- Create `tests-v2/behaviors/env-i-allowlist.sh`
- The test should:
  1. Run `with-test-home --setup`
  2. Run a command inside the isolated environment that prints all environment variables
  3. Verify that only the allowlisted variables are present
  4. Verify that `GITHUB_TOKEN`, `GH_TOKEN`, `NODE_ENV`, `VIRTUAL_ENV`, `CONDA_DEFAULT_ENV` are NOT present
- Follow the artifact-only generator paradigm (exit 0, no evaluation)
- Include cross-reference header per AGENTS.md §1

**Verification:** Test script exists and can be executed (behavioral — requires model run)

**Evidence type:** behavioral

### Step 1.11 — Verify Stale Test Home Cleanup (SC-11)

**Task:** Verify that stale test home directories are cleaned before each test run.

**Details:**
- Read `with-test-home` `do_clean_all()` function
- Confirm `--clean-all` flag exists and removes all `test-home-*` directories
- This is already implemented — verification only

**Verification:** `grep` for `--clean-all` or equivalent in test setup

**Evidence type:** structural

### Step 1.12 — Commit and Create PR

**Task:** Commit all changes and create a PR.

**Details:**
- Commit message: `docs(tests-v2): document isolation contract, add behavioral enforcement tests`
- Create PR with body documenting all SCs and their verification methods
- PR targets `main` branch of `.opencode` repo

**Verification:** PR created successfully

**Evidence type:** structural

## Exit Criteria

- [ ] `tests-v2/AGENTS.md` updated with complete isolation contract (SC-1)
- [ ] `tests-v2/AGENTS.md` documents default model change control (SC-2)
- [ ] `tests-v2/AGENTS.md` documents PATH-based binary resolution (SC-3)
- [ ] `with-test-home` `env -i` allowlist verified (SC-4)
- [ ] `with-test-home` CWD isolation verified (SC-5)
- [ ] `seed_model_config()` Ollama API usage verified (SC-6)
- [ ] `helpers.sh` PATH resolution verified (SC-7)
- [ ] `default-model.sh` DO NOT CHANGE comment verified (SC-8)
- [ ] Behavioral test for isolation verification created (SC-9)
- [ ] Behavioral test for `env -i` allowlist created (SC-10)
- [ ] Stale test home cleanup verified (SC-11)
- [ ] All changes committed and PR created
