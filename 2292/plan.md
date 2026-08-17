---
plan_schema_version: "1.0"
issue: 2292
title: "Test framework must never use project root as a git-mutating target"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 2
---

# Implementation Plan — #2292 — Test framework must never use project root as a git-mutating target

**Goal:** Eliminate the live-project-root git-mutation hazard in the behavioral test harness so no `BEHAVIOR_NEEDS_REMOTE=1` test can silently mutate the live `.opencode` repo's `origin` remote or `main` ref, and add a structural enforcement test that prevents regression.

**Architecture:** Fix at the harness level (not per-script). Phase 1 modifies `helpers.sh` and `with-test-home` to (a) remove the `${TEST_PROJECT:-$project_root}` fallback so an unset `$TEST_PROJECT` yields a BLOCKED diagnostic, (b) add a live-root mutation guard that aborts any git-mutating op whose resolved target equals the live repo, and (c) ensure the `__ensure_gitbucket()` remote-wiring block runs against a validated isolated repo established before remote wiring. Phase 2 adds a structural content-verification enforcement test asserting the absence of live-root git-mutation patterns.

**Files:**
- `.opencode/tests-v2/behaviors/helpers.sh`
- `.opencode/tests-v2/with-test-home`
- `.opencode/tests-v2/test-enforcement.sh`
- `.opencode/tests-v2/test-2292-sc4-live-root-mutation.sh` (new)
- `.opencode/tests-v2/behaviors/2292-sc1-live-root-fallback.sh` (new)
- `.opencode/tests-v2/behaviors/2292-sc2-live-root-guard.sh` (new)
- `.opencode/tests-v2/behaviors/2292-sc3-remote-wiring-ordering.sh` (new)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Harness fix | `test-driven-development` | `red` | `helpers.sh`, `with-test-home` | SC-1, SC-2, SC-3 | — |
| 2 — Structural enforcement | `test-driven-development` | `red` | `test-enforcement.sh`, new test | SC-4 | 1 |

---

## Phase Details

### Phase 1 — Harness fix

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/helpers.sh`, `.opencode/tests-v2/with-test-home` |
| SCs | SC-1, SC-2, SC-3 |
| Depends On | — |

**Context:**
```yaml
files_to_modify:
  - .opencode/tests-v2/behaviors/helpers.sh
  - .opencode/tests-v2/with-test-home
sc_ids: [SC-1, SC-2, SC-3]
fallback_pattern: "${TEST_PROJECT:-$project_root}"
live_repo_vars: ["$PARENT_REPO_DIR", "$PROJECT_DIR", "$project_root"]
remote_wiring_call_site: "__ensure_gitbucket() remote-wiring block (helpers.sh lines 266-273)"
isolated_target_var: "$attempt_workdir"
```

### Phase 2 — Structural enforcement

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/test-enforcement.sh`, new standalone test |
| SCs | SC-4 |
| Depends On | 1 |

**Context:**
```yaml
files_to_modify:
  - .opencode/tests-v2/test-enforcement.sh
  - .opencode/tests-v2/test-2292-sc4-live-root-mutation.sh
sc_ids: [SC-4]
forbidden_patterns:
  - "-C \"$PROJECT_DIR\""
  - "${TEST_PROJECT:-$project_root}"
  - unguarded bare git mutation against live root
```

---

## Exit Criteria

- [ ] C1. `__ensure_gitbucket()` no longer falls back to `$project_root` when `$TEST_PROJECT` is unset; it emits a BLOCKED diagnostic instead (SC-1)
- [ ] C2. The harness detects when a git-mutating target resolves to the live repo and BLOCKs with a clear diagnostic before mutating (SC-2)
- [ ] C3. The `__ensure_gitbucket()` remote-wiring block runs against a validated isolated repo established before remote wiring, or is relocated/guarded so it cannot hit the live repo (SC-3)
- [ ] C4. A content-verification enforcement test asserts the harness contains no git-mutating operation that can target the live project root (SC-4)
- [ ] C5. All 18 existing `BEHAVIOR_NEEDS_REMOTE=1` tests remain functional (GitBucket origin still wired on the isolated repo)
- [ ] C6. The isolation contract (`env -i`, test home, `TEST_PROJECT`/`attempt_workdir`) is preserved
- [ ] C7. The artifact-only generator paradigm is preserved (scripts exit 0, no evaluation logic)
