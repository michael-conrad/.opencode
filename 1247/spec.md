---
issue: 1247
title: "[SPEC-FIX] Add behavioral test fixtures for SC-5/SC-6 label advisory authorization"
state: open
author: michael-conrad
---

## SPEC-FIX: Add behavioral test fixtures for SC-5/SC-6

### Problem

SC-5 and SC-6 (from #1244) require behavioral evidence: agent reads auth from `./tmp/{N}/work.md` not labels, and agent does not halt on `needs-approval` label. The behavioral test script `tests/behaviors/labels-advisory-only.sh` exists but the isolated test environment lacks the `./tmp/1244/work.md` fixture, so the agent correctly blocks on missing work state.

### Root Cause

`behavior_run` in `helpers.sh` creates an isolated test repo with fixture setup via `tests/behaviors/fixtures/setup-fixture-issues.sh`, but no fixture exists for issue #1244&#39;s work state file. The test prompt references `./tmp/1244/work.md` with `authorization_scope: for_pr` but the file doesn&#39;t exist in the test environment.

### Fix

1. Add `./tmp/1244/work.md` fixture creation with:
   ```yaml
   authorization_scope: for_pr
   halt_at: pr_created
   pr_strategy: stacked
   authorization_source: "User approved for pr on 2026-06-16"
   ```
2. Ensure `BEHAVIOR_FIXTURE_ISSUES=1` picks up issue #1244 fixture data

### Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `labels-advisory-only.sh` exits 0 with behavioral evidence showing agent proceeds when `work.md` has authorization despite `needs-approval` label | behavioral |
| SC-2 | `assert_semantic` clean-room inspector verifies agent reads auth from work state, not label | behavioral |

### Labels

- `spec-fix`
- `needs-approval`