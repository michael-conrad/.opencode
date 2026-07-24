## Problem

### Bug: `--no-interactive` flag regression

Issue #2012 was fixed in commit `a013d368` (remove `--no-interactive` from `gh auth status`). The squash merge in commit `aafeeaa4` (PR #2061) re-introduced the broken flag. Current HEAD (`732463cc`) has the regression at `tools/session-init:204`:

```python
["gh", "auth", "status", "--no-interactive"],
```

`gh auth status` has no `--no-interactive` flag — that is a `gh auth login` flag. The command fails with exit code 1, producing `gh: not_logged_in` on every session regardless of actual auth state.

### No Unit Tests

Zero Python tools in `.opencode/tools/` have unit tests. The `check_cli_auth_status()` function has never been tested. The `CACHE_TTL_MS` constant in `session-enforcement.ts` is dead code (defined but never referenced). There is no `pyproject.toml`, no `tests/` directory, no `pytest.ini` in `.opencode/`.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `gh auth status` is called WITHOUT `--no-interactive` flag | `string` | grep for `--no-interactive` in `tools/session-init` — must return no matches |
| SC-2 | `check_cli_auth_status()` is importable as a Python module for testing | `structural` | `python -c "from session_init.auth import check_cli_auth_status"` succeeds |
| SC-3 | Unit tests exist for `check_cli_auth_status()` covering: correct command invocation, "Logged in to" parsing, non-zero exit → `not_logged_in`, timeout → `timeout`, `gb` auth parsing | `behavioral` | `uv run pytest .opencode/tests/` passes with ≥90% coverage on the auth module |
| SC-4 | Test infrastructure exists: `pyproject.toml` with pytest dep, `tests/` directory, `conftest.py` | `structural` | Files exist at `.opencode/pyproject.toml`, `.opencode/tests/test_session_init.py`, `.opencode/tests/conftest.py` |
| SC-5 | Test command is documented in `.opencode/AGENTS.md` Build/Lint/Test Commands table | `string` | grep for `pytest` in `.opencode/AGENTS.md` returns the test command |
| SC-6 | `CACHE_TTL_MS` dead code is removed from `session-enforcement.ts` | `string` | grep for `CACHE_TTL_MS` in `.opencode/plugins/session-enforcement.ts` returns no matches |
| SC-7 | Regression test: running `gh auth status` directly produces exit code 0 when authenticated | `behavioral` | `gh auth status` exits 0 (verified at test time) |

## Approach

### Phase 1: Refactor session-init for testability

Extract `check_cli_auth_status()` and its helper functions into an importable module:

```
.opencode/tools/session_init/
  __init__.py          # empty
  auth.py              # check_cli_auth_status(), helper functions
  cli.py               # thin CLI wrapper (the PEP 723 entry point)
```

The `cli.py` script retains the `#!/usr/bin/env -S uv run --script` header and `if __name__ == "__main__"` guard, importing from `auth.py`. The `auth.py` module is a plain `.py` file importable by pytest.

### Phase 2: Fix the bug

Remove `--no-interactive` from the `gh auth status` call in `auth.py`.

### Phase 3: Create test infrastructure

```
.opencode/
  pyproject.toml        # [tool.pytest.ini_options], [dependency-groups] dev
  tests/
    __init__.py
    conftest.py          # shared fixtures (mock subprocess, mock shutil.which)
    test_session_init/
      __init__.py
      test_auth.py       # tests for check_cli_auth_status()
```

### Phase 4: Write unit tests

Test cases for `check_cli_auth_status()`:

| Test | Scenario | Expected |
|------|----------|----------|
| `test_gh_auth_command_no_no_interactive` | Verify the command list does not contain `--no-interactive` | Command is `["gh", "auth", "status"]` |
| `test_gh_auth_logged_in_parsing` | Mock `gh auth status` returning "Logged in to github.com account user" | Returns `["gh: ✓ Logged in to github.com account user"]` |
| `test_gh_auth_not_logged_in` | Mock non-zero exit code | Returns `["gh: not_logged_in"]` |
| `test_gh_auth_timeout` | Mock subprocess.TimeoutExpired | Returns `["gh: timeout"]` |
| `test_gh_auth_no_gh_installed` | Mock `shutil.which("gh")` returns None | No gh status lines added |
| `test_gb_auth_logged_in` | Mock `gb auth status` returning "Logged in to gitbucket.example.com as user" | Returns `["gb: ✓ Logged in to gitbucket.example.com account user"]` |
| `test_gb_auth_not_logged_in` | Mock `gb auth status` returning "Not logged in" with exit code 0 | Returns `["gb: not_logged_in"]` |
| `test_gb_auth_timeout` | Mock subprocess.TimeoutExpired for gb | Returns `["gb: timeout"]` |

### Phase 5: Remove dead code

Delete the unused `CACHE_TTL_MS` constant from `session-enforcement.ts`.

### Phase 6: Document test command

Add to `.opencode/AGENTS.md` Build/Lint/Test Commands table:

```
| Run tool unit tests | `uv run pytest .opencode/tests/` | Python (.opencode/tools/) |
```

## Affected Files

| File | Change |
|------|--------|
| `.opencode/tools/session-init` | Refactor: extract auth functions into `session_init/auth.py`, keep thin CLI wrapper |
| `.opencode/tools/session_init/__init__.py` | **New** — empty package init |
| `.opencode/tools/session_init/auth.py` | **New** — `check_cli_auth_status()` and helpers |
| `.opencode/tools/session_init/cli.py` | **New** — thin PEP 723 CLI wrapper |
| `.opencode/pyproject.toml` | **New** — pytest config, dev deps |
| `.opencode/tests/__init__.py` | **New** — empty |
| `.opencode/tests/conftest.py` | **New** — shared fixtures |
| `.opencode/tests/test_session_init/__init__.py` | **New** — empty |
| `.opencode/tests/test_session_init/test_auth.py` | **New** — unit tests |
| `.opencode/plugins/session-enforcement.ts` | Remove dead `CACHE_TTL_MS` constant |
| `.opencode/AGENTS.md` | Add pytest command to Build/Lint/Test Commands table |

## Non-Goals

- Not refactoring other `.opencode/tools/` scripts (only session-init)
- Not adding CI pipeline for `.opencode/` tests (manual `uv run pytest` for now)
- Not adding behavioral tests for session-init (unit tests are the primary gate)
- Not changing the `gb` auth check behavior (only fixing the `gh` flag)

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
