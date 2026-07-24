---
remote_issue: 2043
remote_url: "https://github.com/michael-conrad/.opencode/issues/2043"
last_sync: "2026-07-21T14:36:53Z"
source: github
---

## Problem

The `with-test-home` isolation check has a pre-existing bug: `.cache/uv/` files leak into the test home. The allowlist patterns in the isolation check do not match top-level directories, so uv cache files created during test execution are not caught by the isolation verification.

## Root Cause

The allowlist patterns in the isolation check use directory names without `*` glob prefixes (e.g., `.config` instead of `.config/*`). This means top-level directories are matched but their contents are not recursively checked. When uv creates `.cache/uv/` files inside the test home, the isolation check's `find` command does not flag them because the pattern only matches the directory entry itself, not its children.

## Affected File

`.opencode/tests-v2/with-test-home` — the isolation check at line 216

## Acceptance Criteria

- [ ] Allowlist patterns use `*` globs: `.config/*`, `.local/*`, `.cache/*`, `.runtime/*`, `snap/*`, `project/*`, `.git/*`
- [ ] `-mindepth 1` added to the `find` command to skip the test home root directory from the allowlist match
- [ ] Isolation verification passes when `.cache/uv/` files exist in the test home