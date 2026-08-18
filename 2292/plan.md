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
| 2 — Structural enforcement | `test-driven-development` | `red` | `test-enforcement.sh`, new test, `create-pr.md` | SC-4, SC-5 | 1 |

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

**Procedure** (`(**clean-room**)` — dispatch via `test-driven-development` task `red`/`green`; commit via orchestrator `commit-inline`):

- [ ] 1. **Item 1 — SC-1 RED (`(**clean-room**)`).** Dispatch the `red` task to write a behavioral enforcement test (`2292-sc1-live-root-fallback.sh`) asserting that a `BEHAVIOR_NEEDS_REMOTE=1` run currently mutates the live repo's `origin` remote and `main` ref (fallback present). The test FAILs because the fallback still resolves to the live repo.
- [ ] 2. **Item 1 — SC-1 GREEN (`(**clean-room**)`).** Dispatch the `green` task to remove the `${TEST_PROJECT:-$project_root}` fallback in `__ensure_gitbucket()` and emit a BLOCKED diagnostic when `$TEST_PROJECT` is unset. What must be true: an unset `$TEST_PROJECT` never resolves to `$project_root` for a git-mutating operation.
- [ ] 3. **Item 1 — SC-1 COMMIT (`(**inline**)`).** Stage the `helpers.sh` fallback-removal change and the `2292-sc1-live-root-fallback.sh` enforcement test and commit them as one atomic slice.
- [ ] 4. **Item 2 — SC-2 RED (`(**clean-room**)`).** Dispatch the `red` task to write a behavioral enforcement test (`2292-sc2-live-root-guard.sh`) asserting that an unguarded git-mutating target resolving to the live repo currently mutates it (guard absent). The test FAILs because the guard does not yet exist.
- [ ] 5. **Item 2 — SC-2 GREEN (`(**clean-room**)`).** Dispatch the `green` task to add a guard that aborts any git-mutating operation whose resolved target equals the live repo, emitting a clear BLOCK diagnostic before mutating. What must be true: a live-repo target is blocked with a diagnostic and no mutation occurs; a legitimate isolated target is not blocked.
- [ ] 6. **Item 2 — SC-2 COMMIT (`(**inline**)`).** Stage the guard logic and the `2292-sc2-live-root-guard.sh` enforcement test and commit them as one atomic slice.
- [ ] 7. **Item 3 — SC-3 RED (`(**clean-room**)`).** Dispatch the `red` task to write a behavioral enforcement test (`2292-sc3-remote-wiring-ordering.sh`) asserting that `__ensure_gitbucket()` currently wires the remote before an isolated target exists and hits the live repo. The test FAILs because the ordering defect is present.
- [ ] 8. **Item 3 — SC-3 GREEN (`(**clean-room**)`).** Dispatch the `green` task so the `__ensure_gitbucket()` remote-wiring block runs against a validated isolated repo established before remote wiring, or is relocated/guarded so it cannot hit the live repo. What must be true: GitBucket origin is wired on the isolated `$attempt_workdir` and the live repo origin is untouched.
- [ ] 9. **Item 3 — SC-3 COMMIT (`(**inline**)`).** Stage the ordering/guard fix and the `2292-sc3-remote-wiring-ordering.sh` enforcement test and commit them as one atomic slice.

### Phase 2 — Structural enforcement

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/test-enforcement.sh`, new standalone test, `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md` |
| SCs | SC-4, SC-5 |
| Depends On | 1 |

**Context:**
```yaml
files_to_modify:
  - .opencode/tests-v2/test-enforcement.sh
  - .opencode/tests-v2/test-2292-sc4-live-root-mutation.sh
  - .opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md
sc_ids: [SC-4, SC-5]
forbidden_patterns:
  - "-C \"$PROJECT_DIR\""
  - "${TEST_PROJECT:-$project_root}"
  - unguarded bare git mutation against live root
phantom_artifact_pattern: "verification-*.md"
create_pr_gate_area: "the verification-evidence gate in create-pr.md Step 4.75"
```

**Procedure** (`(**clean-room**)` — dispatch via `test-driven-development` task `red`/`green`; commit via orchestrator `commit-inline`):

- [ ] 1. **Item 4 — SC-4 RED (`(**clean-room**)`).** Dispatch the `red` task to add the content-verification enforcement test (`test-2292-sc4-live-root-mutation.sh`) asserting zero grep matches for live-root git-mutation patterns in the harness. The test FAILs because the live-root mutation patterns are still present in the source.
- [ ] 2. **Item 4 — SC-4 GREEN (`(**clean-room**)`).** Dispatch the `green` task to register the standalone test in `test-enforcement.sh` so it runs via the `--changed`/`--tag` or standalone path. What must be true: the enforcement test runs and PASSes with zero matches for the forbidden live-root patterns.
- [ ] 3. **Item 4 — SC-4 COMMIT (`(**inline**)`).** Stage the enforcement-test registration and the new standalone test file and commit them as one atomic slice.
- [ ] 4. **Item 5 — SC-5 RED (`(**clean-room**)`).** Dispatch the `red` task to write a structural content-verification test or grep assertion that the verification-evidence gate in `create-pr.md` Step 4.75 still references `verification-*.md` as a required PR-blocking artifact. The test FAILs because the reference is present.
- [ ] 5. **Item 5 — SC-5 GREEN (`(**clean-room**)`).** Dispatch the `green` task to remove the `verification-*.md` check line from the verification-evidence gate in `create-pr.md` Step 4.75, so the gate requires only `vbc-table-*.md` and `judgment.yaml`. What must be true: the gate no longer references `verification-*.md` and both remaining artifact checks (vbc-table, judgment) are intact.
- [ ] 6. **Item 5 — SC-5 COMMIT (`(**inline**)`).** Stage the `create-pr.md` gate change and the structural test and commit them as one atomic slice.

---

## Exit Criteria

- [ ] C1. `__ensure_gitbucket()` no longer falls back to `$project_root` when `$TEST_PROJECT` is unset; it emits a BLOCKED diagnostic instead (SC-1)
- [ ] C2. The harness detects when a git-mutating target resolves to the live repo and BLOCKs with a clear diagnostic before mutating (SC-2)
- [ ] C3. The `__ensure_gitbucket()` remote-wiring block runs against a validated isolated repo established before remote wiring, or is relocated/guarded so it cannot hit the live repo (SC-3)
- [ ] C4. A content-verification enforcement test asserts the harness contains no git-mutating operation that can target the live project root (SC-4)
- [ ] C5. The verification-evidence gate in `create-pr.md` Step 4.75 no longer references `verification-*.md`; it requires only `vbc-table-*.md` and `judgment.yaml` (SC-5)
- [ ] C6. All 18 existing `BEHAVIOR_NEEDS_REMOTE=1` tests remain functional (GitBucket origin still wired on the isolated repo)
- [ ] C7. The isolation contract (`env -i`, test home, `TEST_PROJECT`/`attempt_workdir`) is preserved
- [ ] C8. The artifact-only generator paradigm is preserved (scripts exit 0, no evaluation logic)

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-17T03:44:16Z | `plan_created` | Plan file: `.opencode/.issues/2292/plan.md`; phase count: 2 |
