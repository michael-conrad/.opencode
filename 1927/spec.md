## Problem

The `opencode-cli` test framework has two fundamental defects that require a from-scratch rewrite:

1. **Wrong binary name**: The framework references `opencode-cli` throughout, but the current CLI tool is `opencode` (v1.17.18 at `/snap/bin/opencode`). The `opencode-cli` binary (v1.14.33 at `/usr/bin/opencode-cli`) is the outdated predecessor. All test infrastructure must use `opencode`.

2. **Incorrect test environment setup**: The current `with-test-home` script does not produce a fully isolated test environment. It sets XDG vars and HOME but does not:
   - Create a test sub-folder for the project inside the test home
   - `git init` the test project
   - `cd` into the test project
   - Clone `.opencode/` as a submodule
   - Verify `opencode models` runs successfully
   - Verify `opencode run "hello world"` produces valid output

   The current setup runs commands inside `$TEST_HOME` directly (a flat temp directory), not inside a git project with `.opencode/` properly configured. This means tests that depend on `.opencode/` tools, skills, or guidelines fail or behave unpredictably.

## Approach: Parallel New Framework

The new test framework is created **alongside** the defective framework, not as an in-place replacement. The existing `.opencode/tests/` directory is left completely untouched until the new framework is verified working.

| Phase | Action | Directory |
|-------|--------|-----------|
| Phase 1 | Create new framework | `.opencode/tests-v2/` |
| Phase 2 | Verify new framework passes all SCs | `.opencode/tests-v2/` |
| Phase 3 | Update references in skills/guidelines to point to `tests-v2/` | `.opencode/skills/`, `.opencode/guidelines/` |
| Phase 4 | Deprecate old framework | `.opencode/tests/` → marked deprecated |
| Phase 5 | Remove old framework (separate spec) | `.opencode/tests/` deleted |

**The old framework is NOT modified, deleted, or degraded during Phase 1-2.** It remains fully functional so any in-progress work that depends on it is not disrupted.

## Scope

This is a **from-scratch write** into a new directory. The existing code in `.opencode/tests/` is NOT read, referenced, or used as implementation source. The new implementation is written independently based on the requirements below.

### New Directory Structure

```
.opencode/tests-v2/
├── with-test-home              # Core env setup (rewritten from scratch)
├── AGENTS.md                   # Test harness spec (rewritten from scratch)
├── default-model.sh            # Default model config (rewritten from scratch)
├── behaviors/
│   ├── helpers.sh              # behavior_run() and helpers (rewritten from scratch)
│   ├── template.sh             # Script template (rewritten from scratch)
│   ├── fixtures/               # Copied from tests/ (test data, not code)
│   └── *.sh                    # Behavioral test scripts (updated references)
├── test-enforcement.sh         # Content-verification runner (rewritten from scratch)
└── test-verification-honesty.sh # Verification honesty runner (rewritten from scratch)
```

### Old Directory — NOT TOUCHED

```
.opencode/tests/                # UNCHANGED during Phase 1-2
```

## Requirements

### REQ-1: Binary Rename — `opencode-cli` → `opencode`

Every reference to `opencode-cli` in the new framework must use `opencode`:

- `opencode-cli run` → `opencode run`
- `opencode-cli models` → `opencode models`
- Comments, error messages, documentation — all updated
- The `--log-level INFO --print-logs` flags must be verified to work with `opencode` (not just `opencode-cli`)

### REQ-2: Test Environment Setup (with-test-home rewrite)

The `with-test-home` script MUST produce a **fully isolated test environment** with the following steps in order:

| Step | Action | Purpose |
|------|--------|---------|
| 1 | Create test home directory at `{project_root}/tmp/test-home-{timestamp}` | Isolated XDG state |
| 2 | Set `HOME`, `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, `XDG_RUNTIME_DIR`, `XDG_DATA_HOME`, `XDG_STATE_HOME` to test home paths | Full env isolation |
| 3 | Set `PATH` to parent env PATH only (no other parent env vars leak) | Minimal inheritance |
| 4 | Create test sub-folder inside test home: `{test_home}/project/` | Git project root |
| 5 | `git init` the test sub-folder | Clean git state |
| 6 | `cd` into the test sub-folder | CWD = test project |
| 7 | Clone `.opencode/` submodule from remote into the test project | Agent tools/skills available |
| 8 | Seed `opencode.jsonc` config with available models | Model configuration |
| 9 | Run `opencode models` to verify CLI works | Smoke test |
| 10 | Run `opencode run "hello world"` to verify model works | End-to-end validation |

**Environment variable isolation** — the `env -i` call MUST include ONLY:

| Variable | Source | Purpose |
|----------|--------|---------|
| `HOME` | Test home | Isolated home |
| `PWD` | Test project dir | Working directory |
| `XDG_*` | Test home subdirs | Isolated XDG state |
| `PATH` | Parent env | Tool access |
| `SHELL` | Parent env | Shell preference |
| `USER` | Parent env | Identity |
| `LOGNAME` | Parent env | Identity |
| `LANG` | Parent env | Locale |
| `TERM` | Parent env | Terminal type |
| `GB_TOKEN` | Parent env (if set) | GitBucket CLI |

**FORBIDDEN** — no other parent env vars. Particularly:
- No `GITHUB_TOKEN`, `GH_TOKEN` — tests must not depend on GitHub credentials by default; tests that need GitHub access must explicitly pass these vars
- No `OPENCODE_CONFIG_CONTENT` (use seeded `opencode.jsonc` instead)
- No `NODE_ENV`, `VIRTUAL_ENV`, `CONDA_DEFAULT_ENV` or other tool env vars
- No shell-specific vars (`BASH_VERSION`, `BASHOPTS`, etc.)

### REQ-3: helpers.sh Rewrite

The `behavior_run()` function must:

1. Use `opencode` instead of `opencode-cli` for all invocations
2. Use `opencode models` instead of `opencode-cli models` for model discovery
3. Call `with-test-home --setup` to create the isolated environment
4. Run `opencode run` inside the isolated test project (not flat test home)
5. Preserve the artifact-only generator paradigm (exit 0, no inline evaluation)
6. Preserve the flock concurrency lock
7. Preserve the retry logic for transient errors
8. Preserve SQLite session export to YAML

### REQ-4: Smoke Test in with-test-home

The `--setup` mode must include a verification phase:

```bash
# After env setup and git init:
opencode models                    # Must succeed (exit 0, stdout non-empty)
opencode run "hello world"         # Must succeed (exit 0, stdout non-empty)
```

If either verification fails, `--setup` must exit non-zero with a descriptive error message. This prevents tests from running against a broken environment.

### REQ-5: Documentation Update

`AGENTS.md` must be written to reflect:
- The binary is `opencode`, not `opencode-cli`
- The test environment setup steps (REQ-2)
- The smoke test requirements (REQ-4)
- Updated invocation examples
- Directory structure is `.opencode/tests-v2/` (not `.opencode/tests/`)

### REQ-6: Behavioral Test Script Migration

Existing behavioral test scripts in `.opencode/tests/behaviors/*.sh` that reference `opencode-cli` in comments or prompts need updated copies in `.opencode/tests-v2/behaviors/`. The actual invocation logic goes through `helpers.sh behavior_run()`, so only comment/prompt strings need updating.

Fixtures (test data, setup scripts) in `.opencode/tests/behaviors/fixtures/` should be copied as-is to `.opencode/tests-v2/behaviors/fixtures/` — these are data, not code.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Zero references to `opencode-cli` in `.opencode/tests-v2/` | `string` | `grep -r 'opencode-cli' .opencode/tests-v2/` returns empty |
| SC-2 | `.opencode/tests/` directory is UNCHANGED during Phase 1-2 | `structural` | `git diff .opencode/tests/` shows no changes |
| SC-3 | `with-test-home --setup` creates git project inside test home | `behavioral` | Run `with-test-home --setup`, verify `git status` works inside test home |
| SC-4 | `.opencode/` submodule exists inside test project after setup | `behavioral` | Run `with-test-home --setup`, verify `.opencode/` is a git submodule |
| SC-5 | `opencode models` succeeds inside test environment | `behavioral` | Run `with-test-home opencode models`, verify exit 0 and stdout |
| SC-6 | `opencode run "hello world"` produces non-empty output inside test environment | `behavioral` | Run `with-test-home opencode run "hello world"`, verify stdout non-empty |
| SC-7 | No parent env vars leak except the allowlist (REQ-2 table) | `behavioral` | Run `with-test-home env` and verify only allowed vars present |
| SC-8 | `behavior_run()` invokes `opencode run` (not `opencode-cli run`) | `string` | `grep 'opencode run' helpers.sh` matches, `grep 'opencode-cli' helpers.sh` returns empty |
| SC-9 | `AGENTS.md` documentation uses `opencode` throughout | `string` | `grep 'opencode-cli' AGENTS.md` returns empty |
| SC-10 | Behavioral test scripts' comment references updated in tests-v2 | `string` | `grep -r 'opencode-cli' .opencode/tests-v2/behaviors/*.sh` returns empty |
| SC-11 | Existing behavioral test scripts still work against old framework | `behavioral` | Run one test from `.opencode/tests/behaviors/`, verify artifacts produced |
| SC-12 | New behavioral test scripts produce artifacts against new framework | `behavioral` | Run one test from `.opencode/tests-v2/behaviors/`, verify artifact directory with manifest.yaml, stdout.log, stderr.log, exit_code, session.yaml |

## Non-Goals

- Changing the artifact-only generator paradigm
- Changing the flock concurrency mechanism
- Changing the SQLite-to-YAML export logic
- Modifying the content-verification test structure (`test-enforcement.sh` scenario format)
- Updating `opencode run` CLI flags (verify `--log-level INFO --print-logs` work with `opencode`, but don't change the flag names)
- Removing the old `.opencode/tests/` directory (separate spec, Phase 5)
- Updating skills/guidelines to reference `tests-v2/` (Phase 3, separate task)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| `opencode` CLI has different flags than `opencode-cli` | Medium | High | SC-5/SC-6 verify both `models` and `run` subcommands work |
| `opencode.jsonc` config format changed between versions | Low | Medium | SC-5 verifies model discovery works with seeded config |
| Behavioral test scripts have hardcoded `opencode-cli` in prompts (not just comments) | Medium | Low | SC-10 catches all references; prompts can keep the string as domain context |
| Submodule clone URL format changed | Low | Medium | SC-4 verifies submodule exists; clone URL comes from `.gitmodules` |
| Old framework breaks while new one is under construction | Low | High | SC-2 verifies old framework is untouched; parallel directories are independent |

## Change Control

- **Status**: DRAFT
- **Author**: AI agent
- **Date**: 2026-07-14
- **Supersedes**: None (this is a fresh write, not a modification of existing code)
- **Previously filed as**: opencode-config#292 (closed — wrong repo)

---

> **Full spec and artifacts: [`.opencode/.issues/1927/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1927)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1927/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

*Co-authored with AI: OpenCode (opencode/mimo-v2.5-free)*