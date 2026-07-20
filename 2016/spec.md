## Bug Description

The `with-test-home` isolation check (line 240-251) compares sha256 of the production SQLite DB before and after test setup. If any other opencode process (desktop app, another CLI session) modifies the production DB during the ~30-second test setup window, the sha256 check fails with:

```
[isolation] FAIL: production DB was modified during test setup!
```

This is a false positive — the production DB was not modified by the test setup, it was modified by a legitimate concurrent process.

## Root Cause

The check assumes the production DB is static during test setup. In practice, the desktop app and other CLI sessions actively write to the production DB.

## Suggested Fix

Replace the sha256 comparison with a bidirectional isolation verification:

### Check 1: Test DB points to test project

Query the test DB's `project.worktree` — it MUST contain the test project path (under `tmp/test-home-*`), not the production project path:

```bash
sqlite3 $TEST_HOME/.local/share/opencode/opencode.db "SELECT worktree FROM project;"
# Expected: /path/to/tmp/test-home-<timestamp>/project
# NOT:      /home/user/git/production-project
```

### Check 2: Production DB does NOT point to test project

Query the production DB's `project.worktree` — it MUST NOT contain the test project path. If the production DB was somehow contaminated by the test setup, its worktree would point to the test project:

```bash
sqlite3 $HOME/.local/share/opencode/opencode.db "SELECT worktree FROM project;"
# Expected: /home/user/git/production-project
# NOT:      /path/to/tmp/test-home-<timestamp>/project
```

Both checks must pass for isolation to be confirmed. This is more reliable than the sha256 comparison because:

1.  It directly verifies the test DB is isolated (points to test project)
2.  It directly verifies the production DB was not contaminated (does not point to test project)
3.  It does not depend on the production DB being static
4.  It is already partially documented as the correct verification method in `tests-v2/AGENTS.md` §5
