---
type: LESSON
session: 2026-07-02
consumed: false
severity: systemic
---

# Lesson: Behavioral test harness bootstrap timeout — `--setup` dead code and cumulative test home creation

## Root Cause

The `behavior_run()` function in `tests/behaviors/helpers.sh` has two bugs that together cause multi-scenario behavioral tests to time out:

### Bug 1: `--setup` is dead code

Lines 282-289 call `with-test-home --setup "$workdir"` to create a test home, capture the path, then **never use it**. The actual `opencode-cli run` on line 296 creates a **brand new test home** via the default path (no `--setup` flag). The `--setup` call burns ~30s on `ollama list` + `seed_model_config` + directory creation for nothing.

### Bug 2: Each `behavior_run` creates a fresh test home

Every `behavior_run` invocation creates a new test home via `with-test-home` default path. Each new test home runs a full SQLite DB migration and plugin bootstrap (~240s). With 3 scenarios × 2 retries = up to 6 test homes, cumulative bootstrap time exceeds the 600s bash tool timeout. The script gets killed mid-bootstrap, producing empty log files.

## Impact

- Multi-scenario behavioral tests (3+ scenarios) consistently time out
- Empty stdout/stderr logs because the model never dispatches
- The `--setup` flag exists but is never used — it was designed to create a test home once and reuse it across sequential dispatches, but the code never implemented the reuse path
- The #492 test (stale, clean, conflict scenarios) never completed all 3 scenarios in a single run

## Remediation

1. **Remove `--setup` dead code** from `behavior_run()` — the `--setup` call and test_home capture are unused
2. **Each scenario must be a separate run** — multi-scenario tests MUST be split into individual scripts (one `behavior_run` call per script). Cumulative bootstrap time of N scenarios × ~240s exceeds the 600s timeout.
3. **Test home reuse pattern:** `with-test-home --setup` creates a test home and prints `TEST_HOME=<path>`. Subsequent `behavior_run` calls can pass `TEST_HOME=<path>` to reuse the same home, avoiding repeated bootstrap. The test home retains SQLite state across dispatches.
4. **Test homes persist after runs** — verified: 21 test homes accumulated during a single session. They are never auto-deleted. This is intentional for investigatory purposes and reuse. Cleanup is manual via `with-test-home --clean` or `--clean-all`.

## Evidence

- `tests/behaviors/helpers.sh` lines 282-289: `--setup` output captured but never used
- `tests/behaviors/helpers.sh` line 296: `opencode-cli run` creates new test home via default path
- `tests/with-test-home` lines 134-155: `--setup` creates test home and exits
- `tests/with-test-home` lines 186-244: default path creates a *different* test home
- Successful single-scenario runs (e.g., stale scenario from `behavior-test-20260701-221643`) completed within timeout
- Multi-scenario runs consistently killed at 600s with empty logs

## Files Affected

| File | Change |
|------|--------|
| `tests/behaviors/helpers.sh` | Remove `--setup` dead code; document test home reuse pattern |
| `tests/AGENTS.md` | Document that each scenario needs a separate run; document test home reuse |
