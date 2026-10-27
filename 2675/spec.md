# Spec — .opencode#2675: fix three red regression tests (test env lacks pyyaml)

## Problem

The regression suite at the current tip (`99c3b2410`, post-#2667 merge) carries
3 red failures in `tests/test_local_issues/test_update_reopen_clears_closed_state.py`
(observed 2026-10-27 by triage, reproducing the originally filed report):

- `test_update_status_open_clears_closed_state`
- `test_update_status_open_clears_duplicate_of`
- `test_update_other_fields_does_not_resurrect_closed_state`

Each fails with `ModuleNotFoundError: No module named 'yaml'` from the direct
`import yaml` in the tests' `_load_yaml` helper (line 108). The dev dependency
group in `pyproject.toml` (`[dependency-groups] dev`) contains only
`pytest` and `pytest-cov`; the sibling tests run the tool in subprocesses with
`uv run --with pyyaml`, so their environments get pyyaml, but this module-path
test never does. Suite redness from an environment gap (not a product
regression) masks real regressions and blocks clean PR baselines.

## Root cause

- Direct: pyyaml is absent from the dev dependency group that `uv run`
  materializes for the test process, while the test imports it directly.
- The test file predates or sidesteps the sibling tests' subprocess pattern,
  leaving an unmet implicit dependency.

## Requirements

- R-1: The dev dependency group SHALL include pyyaml so `uv run` (with the
  dev group) provides `import yaml` to the test process.
- R-2: The three failing tests SHALL pass under the standard dev-group run
  (`uv run pytest tests/test_local_issues/test_update_reopen_clears_closed_state.py`).

## Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | `pyproject.toml` `[dependency-groups]` dev includes a pyyaml entry | Structural | Fact check: `rg -n "pyyaml" pyproject.toml` under `[dependency-groups]` returns an entry |
| SC-2 | The dev-group environment resolves `import yaml` (no ModuleNotFoundError) | Behavioral | `uv run python -c "import yaml; print(yaml.__version__)"` exits 0 |
| SC-3 | All three named tests pass | Behavioral | `uv run pytest tests/test_local_issues/test_update_reopen_clears_closed_state.py -q` reports 0 failed |
| SC-4 | No new test failures introduced in surrounding local-issues suites | Behavioral | `uv run pytest tests/test_local_issues -q` reports 0 failed |

## Approach

Add `pyyaml` to the `dev` dependency group in `pyproject.toml` (one-line
change), per triage recommendation — lower-risk than rewriting `_load_yaml`
through the sibling tests' `uv run --with pyyaml` subprocess pattern.

## Out of scope

- Refactoring the failing test module to the subprocess pattern.
- Changes to `local-issues` tool code.
- Any change to sibling tests' subprocess invocations.

## Traceability

| Requirement | SCs | Source |
|-------------|-----|--------|
| R-1 | SC-1, SC-2 | Observed failure: ModuleNotFoundError at test line 108 (triage + original filing) |
| R-2 | SC-3, SC-4 | Developer instruction: implement for PR (#2675); observed 3-failure evidence |

---
🤖 OpenCode (huggingface/zai-org/GLM-5.3-Flash)