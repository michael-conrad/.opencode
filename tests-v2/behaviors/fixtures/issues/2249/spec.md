# Bug: analyze-and-spec crashes when issue has no reproduction steps

## Description

When the issue-review `analyze-and-spec` task processes a bug report that lacks a
"steps to reproduce" section, it crashes with a traceback instead of proceeding with
root cause analysis.

## Steps to Reproduce

1. Open any bug report whose body does not include a "steps to reproduce" heading
2. Run the `analyze-and-spec` task on it
3. Observe the crash

## Expected vs Actual

- **Expected:** Root cause analysis proceeds and a fix spec is created.
- **Actual:** The agent raises an unhandled exception and the fix spec is never created.

## Environment

- Repo: .opencode
- Task: issue-review -> analyze-and-spec
