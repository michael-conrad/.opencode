---
plan_schema_version: "1.0"
issue: 2088
title: "session-init: fix --no-interactive regression + mandatory unit tests"
authorization_scope: for_implementation
pr_strategy: stacked
phase_count: 6
---

# Implementation Plan — #2088 — Fix --no-interactive regression + unit tests

**Goal:** Fix the `--no-interactive` flag regression in `session-init`, add unit test infrastructure for `.opencode/tools/`, write comprehensive unit tests for `check_cli_auth_status()`, remove dead `CACHE_TTL_MS` code, and document the test command.

**Architecture:** Refactor `session-init` into an importable package (`session_init/` with `auth.py` + `cli.py`), create pytest infrastructure under `.opencode/tests/`, write unit tests with mocked subprocess, remove dead code from `session-enforcement.ts`, and document in `AGENTS.md`.

**Files:**
- `.opencode/tools/session-init`
- `.opencode/tools/session_init/__init__.py` (new)
- `.opencode/tools/session_init/auth.py` (new)
- `.opencode/tools/session_init/cli.py` (new)
- `.opencode/pyproject.toml` (new)
- `.opencode/tests/__init__.py` (new)
- `.opencode/tests/conftest.py` (new)
- `.opencode/tests/test_session_init/__init__.py` (new)
- `.opencode/tests/test_session_init/test_auth.py` (new)
- `.opencode/plugins/session-enforcement.ts`
- `.opencode/AGENTS.md`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Refactor session-init | `test-driven-development` | `green` | `.opencode/tools/session-init` → `session_init/` | SC-2 | — |
| 2 — Fix the bug | `test-driven-development` | `green` | `.opencode/tools/session_init/auth.py` | SC-1 | 1 |
| 3 — Create test infrastructure | `test-driven-development` | `green` | `.opencode/pyproject.toml`, `.opencode/tests/` | SC-4 | — |
| 4 — Write unit tests | `test-driven-development` | `green` | `.opencode/tests/test_session_init/test_auth.py` | SC-3 | 1, 2, 3 |
| 5 — Remove dead code | `test-driven-development` | `green` | `.opencode/plugins/session-enforcement.ts` | SC-6 | — |
| 6 — Document test command | `test-driven-development` | `green` | `.opencode/AGENTS.md` | SC-5 | 3 |

---

## Phase Details

### Phase 1 — Refactor session-init

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/tools/session-init` → `session_init/` package |
| SCs | SC-2 |
| Depends On | — |

**Context:**
```yaml
refactor:
  source: .opencode/tools/session-init
  target_package: .opencode/tools/session_init/
  files:
    - __init__.py: empty
    - auth.py: check_cli_auth_status() and helper functions
    - cli.py: thin PEP 723 CLI wrapper with #!/usr/bin/env -S uv run --script header
  cli_wrapper:
    - imports from auth.py
    - retains if __name__ == "__main__" guard
sc_ids:
  - SC-2: "check_cli_auth_status() is importable as a Python module"
```

### Phase 2 — Fix the bug

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/tools/session_init/auth.py` |
| SCs | SC-1 |
| Depends On | 1 |

**Context:**
```yaml
bug: "gh auth status --no-interactive" has no --no-interactive flag
fix: Remove --no-interactive from the gh auth status command list
expected_command: ["gh", "auth", "status"]
sc_ids:
  - SC-1: "gh auth status called WITHOUT --no-interactive flag"
```

### Phase 3 — Create test infrastructure

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/pyproject.toml`, `.opencode/tests/` |
| SCs | SC-4 |
| Depends On | — |

**Context:**
```yaml
files:
  - .opencode/pyproject.toml: [tool.pytest.ini_options], [dependency-groups] dev with pytest
  - .opencode/tests/__init__.py: empty
  - .opencode/tests/conftest.py: shared fixtures (mock subprocess, mock shutil.which)
  - .opencode/tests/test_session_init/__init__.py: empty
sc_ids:
  - SC-4: "Test infrastructure files exist"
```

### Phase 4 — Write unit tests

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/tests/test_session_init/test_auth.py` |
| SCs | SC-3 |
| Depends On | 1, 2, 3 |

**Context:**
```yaml
test_cases:
  - test_gh_auth_command_no_no_interactive: command is ["gh", "auth", "status"]
  - test_gh_auth_logged_in_parsing: mock returns "Logged in to github.com account user"
  - test_gh_auth_not_logged_in: mock non-zero exit code
  - test_gh_auth_timeout: mock subprocess.TimeoutExpired
  - test_gh_auth_no_gh_installed: mock shutil.which("gh") returns None
  - test_gb_auth_logged_in: mock gb auth status returns "Logged in to gitbucket.example.com as user"
  - test_gb_auth_not_logged_in: mock gb returns "Not logged in" with exit code 0
  - test_gb_auth_timeout: mock subprocess.TimeoutExpired for gb
coverage_target: "≥90% on auth module"
sc_ids:
  - SC-3: "Unit tests pass with ≥90% coverage"
```

### Phase 5 — Remove dead code

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/plugins/session-enforcement.ts` |
| SCs | SC-6 |
| Depends On | — |

**Context:**
```yaml
removal: CACHE_TTL_MS constant from session-enforcement.ts
sc_ids:
  - SC-6: "CACHE_TTL_MS removed from session-enforcement.ts"
```

### Phase 6 — Document test command

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/AGENTS.md` |
| SCs | SC-5 |
| Depends On | 3 |

**Context:**
```yaml
addition: "| Run tool unit tests | `uv run pytest .opencode/tests/` | Python (.opencode/tools/) |"
table: Build/Lint/Test Commands
sc_ids:
  - SC-5: "pytest command documented in AGENTS.md"
```

---

## Pre-Implementation

- [ ] 1. **Coherence gate (**clean-room**).** Verify spec #2088 is approved. Read the current `session-init` file to confirm the `--no-interactive` regression at line 204. **→ pre-flight**
- [ ] 2. **Baseline check (**clean-room**).** Run `grep --no-interactive .opencode/tools/session-init` to confirm the regression exists. Check that `.opencode/pyproject.toml` and `.opencode/tests/` do not exist. **→ pre-flight**

---

## Phase 1 — Refactor session-init

**Concern:** Extract auth functions into an importable Python package.

**Files:**
- `.opencode/tools/session-init` (refactored to thin CLI wrapper)
- `.opencode/tools/session_init/__init__.py` (new)
- `.opencode/tools/session_init/auth.py` (new)
- `.opencode/tools/session_init/cli.py` (new)

**SCs:** SC-2

**Dependencies:** None

**Entry Conditions:**
- Coherence gate passed
- Baseline check confirmed current state

**Exit Conditions:**
- `check_cli_auth_status()` is importable via `from session_init.auth import check_cli_auth_status`
- `cli.py` is the PEP 723 entry point with `#!/usr/bin/env -S uv run --script` header
- Original `session-init` file is replaced by `cli.py`

---

- [ ] 3. **GREEN (**sub-agent**).** Create `.opencode/tools/session_init/` package: `__init__.py` (empty), `auth.py` with `check_cli_auth_status()` and helpers extracted from `session-init`, `cli.py` with PEP 723 header and thin wrapper importing from `auth.py`. Replace original `session-init` with `cli.py`. **→ SC-2**
- [ ] 4. **GREEN doublecheck (**clean-room**).** Run `python -c "from session_init.auth import check_cli_auth_status"` from `.opencode/tools/` to verify importability. **→ SC-2**
- [ ] 5. **Checkpoint commit (**inline**).** Commit session-init refactor.

#### Phase 1 VbC

- [ ] 6. **VbC (**clean-room**).** Verify SC-2: import test passes. **→ SC-2**

---

## Phase 2 — Fix the bug

**Concern:** Remove the `--no-interactive` flag from the `gh auth status` command.

**Files:**
- `.opencode/tools/session_init/auth.py`

**SCs:** SC-1

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `auth.py` exists with `check_cli_auth_status()`

**Exit Conditions:**
- `gh auth status` command list does not contain `--no-interactive`

---

- [ ] 7. **GREEN (**sub-agent**).** Remove `--no-interactive` from the `gh auth status` command list in `auth.py`. **→ SC-1**
- [ ] 8. **GREEN doublecheck (**clean-room**).** Run `grep --no-interactive .opencode/tools/session_init/auth.py` → 0 matches. **→ SC-1**
- [ ] 9. **Checkpoint commit (**inline**).** Commit the bug fix.

#### Phase 2 VbC

- [ ] 10. **VbC (**clean-room**).** Verify SC-1: grep for `--no-interactive` returns no matches. **→ SC-1**

---

## Phase 3 — Create test infrastructure

**Concern:** Create pytest infrastructure for `.opencode/tools/` unit tests.

**Files:**
- `.opencode/pyproject.toml` (new)
- `.opencode/tests/__init__.py` (new)
- `.opencode/tests/conftest.py` (new)
- `.opencode/tests/test_session_init/__init__.py` (new)

**SCs:** SC-4

**Dependencies:** None

**Entry Conditions:**
- Baseline confirmed no existing test infrastructure

**Exit Conditions:**
- `pyproject.toml` exists with pytest config
- `tests/` directory exists with `__init__.py` and `conftest.py`
- `tests/test_session_init/` exists with `__init__.py`

---

- [ ] 11. **GREEN (**sub-agent**).** Create `.opencode/pyproject.toml` with `[tool.pytest.ini_options]` and `[dependency-groups] dev` with pytest. Create `.opencode/tests/__init__.py`, `.opencode/tests/conftest.py` with shared fixtures (mock subprocess, mock shutil.which). Create `.opencode/tests/test_session_init/__init__.py`. **→ SC-4**
- [ ] 12. **GREEN doublecheck (**clean-room**).** Verify all 4 files exist. **→ SC-4**
- [ ] 13. **Checkpoint commit (**inline**).** Commit test infrastructure.

#### Phase 3 VbC

- [ ] 14. **VbC (**clean-room**).** Verify SC-4: all 4 infrastructure files exist. **→ SC-4**

---

## Phase 4 — Write unit tests

**Concern:** Write comprehensive unit tests for `check_cli_auth_status()`.

**Files:**
- `.opencode/tests/test_session_init/test_auth.py` (new)

**SCs:** SC-3

**Dependencies:** Phase 1, Phase 2, Phase 3

**Entry Conditions:**
- `auth.py` exists with `check_cli_auth_status()`
- Test infrastructure exists

**Exit Conditions:**
- All 8 test cases pass
- ≥90% coverage on the auth module

---

- [ ] 15. **GREEN (**sub-agent**).** Write `.opencode/tests/test_session_init/test_auth.py` with all 8 test cases covering: correct command invocation, "Logged in to" parsing, non-zero exit → `not_logged_in`, timeout → `timeout`, no gh installed, gb auth parsing, gb not logged in, gb timeout. **→ SC-3**
- [ ] 16. **GREEN doublecheck (**clean-room**).** Run `uv run pytest .opencode/tests/ -v` and verify all tests pass. Run `uv run pytest .opencode/tests/ --cov=.opencode/tools/session_init/ --cov-report=term-missing` and verify ≥90% coverage. **→ SC-3**
- [ ] 17. **Checkpoint commit (**inline**).** Commit unit tests.

#### Phase 4 VbC

- [ ] 18. **VbC (**clean-room**).** Verify SC-3: all tests pass, coverage ≥90%. **→ SC-3**

---

## Phase 5 — Remove dead code

**Concern:** Remove unused `CACHE_TTL_MS` constant from `session-enforcement.ts`.

**Files:**
- `.opencode/plugins/session-enforcement.ts`

**SCs:** SC-6

**Dependencies:** None

**Entry Conditions:**
- Baseline confirmed `CACHE_TTL_MS` exists

**Exit Conditions:**
- `CACHE_TTL_MS` removed from `session-enforcement.ts`

---

- [ ] 19. **GREEN (**sub-agent**).** Remove the `CACHE_TTL_MS` constant definition from `session-enforcement.ts`. **→ SC-6**
- [ ] 20. **GREEN doublecheck (**clean-room**).** Run `grep CACHE_TTL_MS .opencode/plugins/session-enforcement.ts` → 0 matches. **→ SC-6**
- [ ] 21. **Checkpoint commit (**inline**).** Commit dead code removal.

#### Phase 5 VbC

- [ ] 22. **VbC (**clean-room**).** Verify SC-6: grep for `CACHE_TTL_MS` returns no matches. **→ SC-6**

---

## Phase 6 — Document test command

**Concern:** Add pytest command to AGENTS.md Build/Lint/Test Commands table.

**Files:**
- `.opencode/AGENTS.md`

**SCs:** SC-5

**Dependencies:** Phase 3

**Entry Conditions:**
- Test infrastructure exists

**Exit Conditions:**
- AGENTS.md contains the pytest command in the Build/Lint/Test Commands table

---

- [ ] 23. **GREEN (**sub-agent**).** Add `| Run tool unit tests | \`uv run pytest .opencode/tests/\` | Python (.opencode/tools/) |` to the Build/Lint/Test Commands table in `.opencode/AGENTS.md`. **→ SC-5**
- [ ] 24. **GREEN doublecheck (**clean-room**).** Run `grep pytest .opencode/AGENTS.md` and verify the test command is present. **→ SC-5**
- [ ] 25. **Checkpoint commit (**inline**).** Commit AGENTS.md update.

#### Phase 6 VbC

- [ ] 26. **VbC (**clean-room**).** Verify SC-5: grep for `pytest` in AGENTS.md returns the test command. **→ SC-5**

---

## Post-Implementation

- [ ] 27. **Structural checks (**sub-agent**).** Run lint/format checks on modified files. **→ post-flight**
- [ ] 28. **Audit (**sub-agent**).** Dispatch verification-audit for the refactor and tests. **→ post-flight**
- [ ] 29. **Cross-validate (**clean-room**).** Verify audit findings against evidence artifacts. **→ post-flight**
- [ ] 30. **Review prep (**sub-agent**).** Prepare PR with summary of all changes. **→ post-flight**
- [ ] 31. **Create PR (**sub-agent**).** Create pull request for the feature branch. **→ post-flight**
- [ ] 32. **Completion (**sub-agent**).** Report summary with PR URL. **→ post-flight**

---

## Exit Criteria

- [ ] C1. `gh auth status` is called WITHOUT `--no-interactive` flag
- [ ] C2. `check_cli_auth_status()` is importable as a Python module
- [ ] C3. Unit tests pass with ≥90% coverage on the auth module
- [ ] C4. Test infrastructure files exist
- [ ] C5. Test command is documented in AGENTS.md
- [ ] C6. `CACHE_TTL_MS` dead code is removed from `session-enforcement.ts`
- [ ] C7. `gh auth status` exits 0 when authenticated
