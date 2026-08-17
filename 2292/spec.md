# [SPEC] Test framework must never use project root as a git-mutating target

> **Full spec and artifacts: [`.opencode/.issues/2292/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2292)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2292/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

The test harness `__ensure_gitbucket()` falls back to the live `.opencode` git repo as a git-mutating target when `$TEST_PROJECT` is unset. Because `$TEST_PROJECT` is only set inside `with-test-home`'s subprocess and `__ensure_gitbucket()` runs before that in the parent shell, every `BEHAVIOR_NEEDS_REMOTE=1` test (21 scripts) executes `git remote remove/add/push` against the live repo, silently mutating its `origin` remote and `main` ref. This corrupts the live repository state that the harness is meant to protect.

## Root Cause / Motivation

`tests-v2/behaviors/helpers.sh` line 267 declares `local test_project="${TEST_PROJECT:-$project_root}"`, where `$project_root` equals `$PARENT_REPO_DIR` — the live `.opencode` repository. `__ensure_gitbucket()` runs at line 488, before `with-test-home` establishes `TEST_PROJECT` at line 620, so the fallback is always taken during remote-provisioning. This is a defect-discovery-latency hazard: the harness is designed to isolate git operations, yet its own fallback targets the live repo, shipping undetected mutations that surface only as confusing branch/rebase failures downstream.

## Approach Chosen

Fix at the harness level (not per-script): (1) eliminate the `$project_root` fallback so an unset `$TEST_PROJECT` yields a BLOCKED diagnostic instead of a live-repo target, (2) add a guard that aborts any git-mutating op whose resolved target equals the live repo, and (3) relocate the remote-wiring out of `__ensure_gitbucket()` (making it a pure provisioner) into `behavior_run()`, where it runs against the established `$attempt_workdir` and cannot hit the live repo. A structural content-verification enforcement test asserts the absence of live-root git-mutation patterns to prevent regression.

## Alternatives Considered & Why Discarded

- **Per-script `TEST_PROJECT` export:** Requires editing all 18 affected test scripts and leaves the fallback in place for future scripts. Discarded because it is non-structural, fragile, and does not protect against reintroduction.
- **Only removing the fallback (no guard):** Removes the immediate live-repo target but leaves any future unguarded git-mutating op exposed. Discarded because the guard is the defensive layer that prevents regression.
- **Only adding the guard (no fallback removal):** The guard would catch the current defect but the fallback would still resolve to the live repo before the guard fires, and a partially-mutated state could occur. Discarded because fallback elimination is the primary fix.

## Key Design Decisions

- **Fallback elimination over fallback-to-error:** Removing `${TEST_PROJECT:-$project_root}` means an unset `$TEST_PROJECT` in a remote-provisioning path must halt with a clear diagnostic, not silently skip or target the live repo. Tradeoff: requires a strict ordering contract that `TEST_PROJECT` is always set before remote provisioning.
- **Guard blocks only live-repo targets:** The guard MUST only BLOCK when the resolved target equals the live repo; it MUST NOT block legitimate isolated-target operations. Tradeoff: requires reliable live-repo path detection to avoid false positives.
- **Structural enforcement over behavioral-only:** Phase 2 uses a structural grep-based content-verification test because the regression is a static pattern (unguarded live-root mutation). Tradeoff: structural evidence is the correct substrate for a source-pattern prohibition, and it complements the behavioral verification of Phase 1.

## User Intent / Original Prompt

The original request motivating this spec: eliminate the live-project-root git-mutation hazard in the behavioral test harness so no `BEHAVIOR_NEEDS_REMOTE=1` test can silently mutate the live `.opencode` repo's `origin` remote or `main` ref, add a structural enforcement test preventing regression, and remove the phantom `verification-*.md` requirement from the create-pr gate.

## Not Included

- **Per-script `TEST_PROJECT` exports** — The fix is structural (harness-level), not per-script. Editing individual test scripts is non-structural, fragile, and leaves the fallback in place for future scripts.
- **Changes to the 21 existing behavioral test scripts** — The fix is harness-level; the existing `BEHAVIOR_NEEDS_REMOTE=1` scripts are not modified.
- **Changes to the isolation contract (`env -i`, test home, `TEST_PROJECT`)** — The fix preserves the existing isolation contract; it does not alter how isolation is established.
- **Behavioral testing of the new SC-5 gate change beyond the structural grep assertion** — SC-5 is a static source-pattern change; structural evidence is the correct substrate for a source-pattern prohibition.
- **Any change to the artifact-only generator paradigm** — The fix maintains the artifact-only generator paradigm: scripts exit 0 and contain no evaluation logic.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `__ensure_gitbucket()` in `tests-v2/behaviors/helpers.sh` SHALL NOT fall back to `$project_root` for git-mutating remote operations when `$TEST_PROJECT` is unset | behavioral | Run a `BEHAVIOR_NEEDS_REMOTE=1` test; assert the live `.opencode` repo `origin` remote and `main` ref are unchanged (`git remote -v`, `git rev-parse main` before/after) via clean-room session.yaml evaluation |
| SC-2 | The test harness SHALL detect when a git-mutating target resolves to the live repo (`$PARENT_REPO_DIR` / `$PROJECT_DIR`) and BLOCK with a clear diagnostic before mutating | behavioral | Invoke the guard (or a harness path) with target == live repo; assert BLOCK + diagnostic with no mutation (`git remote -v` unchanged, no push) |
| SC-3 | The remote-wiring SHALL be relocated out of `__ensure_gitbucket()` (which becomes a pure provisioner) and run in `behavior_run()` against the established `$attempt_workdir`, so it cannot hit the live repo | behavioral | Run a `BEHAVIOR_NEEDS_REMOTE=1` test; assert GitBucket origin is wired on the isolated `$attempt_workdir` and the live repo origin is untouched via clean-room session.yaml evaluation |
| SC-4 | A content-verification enforcement test SHALL assert the harness contains no git-mutating operation that can target the live project root (no `-C "$PROJECT_DIR"` mutation, no `${TEST_PROJECT:-$project_root}` fallback, no unguarded bare git mutation) | structural | Run the enforcement test (`test-enforcement.sh --changed`/`--tag` or the standalone test); assert zero grep matches for live-root mutation patterns |
| SC-5 | The `create-pr.md` verification-evidence gate SHALL NOT reference `verification-*.md` as a required PR-blocking artifact; the gate SHALL require only `vbc-table-*.md` and `judgment.yaml` | structural | Grep `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md` for a `verification-*.md` gate requirement; assert zero matches (the `verification-*.md` check in the verification-evidence gate is removed) |

## Requirements

- R-1. The test framework SHALL NOT run git-mutating operations (add, commit, push, reset, checkout, branch, merge, rebase, rm, clean, restore, switch, tag, remote add/remove, stash) against the live project root (`$PROJECT_DIR` / `$PARENT_REPO_DIR` / `$project_root`).
- R-2. All git-mutating operations in the test harness SHALL target the isolated test project (`$TEST_PROJECT` / `$attempt_workdir` inside the test home), never the live repo.
- R-3. When `$TEST_PROJECT` is unset, the harness SHALL NOT default to `$project_root` for git-mutating operations; it SHALL fail/halt (BLOCKED) instead of mutating the live repo.
- R-4. The remote-wiring SHALL be relocated out of `__ensure_gitbucket()` into `behavior_run()`, running against the established `$attempt_workdir`; it SHALL NOT run against the live repo.
- R-5. The harness SHALL detect when a resolved git target equals the live repo and BLOCK with a clear diagnostic before mutating.
- R-6. The fix SHALL be structural (harness-level), not per-script, so all 18 `BEHAVIOR_NEEDS_REMOTE=1` tests are protected without individual edits.
- R-7. The fix SHALL preserve the existing isolation contract (`env -i`, test home, `TEST_PROJECT` / `attempt_workdir`).
- R-8. The fix SHALL NOT break the GitBucket provisioning flow (`BEHAVIOR_NEEDS_REMOTE=1`); the test GitBucket SHALL still be wired as `origin` on a valid isolated repo.
- R-9. The fix SHALL maintain the artifact-only generator paradigm: scripts exit 0 and contain no evaluation logic.
- R-10. A content-verification enforcement test SHALL assert the harness contains no live-root git-mutation pattern to prevent regression.
- R-11. The `create-pr.md` verification-evidence gate SHALL NOT require a `verification-*.md` artifact for PR creation; it SHALL require only `vbc-table-*.md` (PASS for all SCs) and `judgment.yaml` (`overall_verdict: PASS`).

## Items

### Item 1 (SC-1): Live-root fallback elimination

- RED: Behavioral test asserts a `BEHAVIOR_NEEDS_REMOTE=1` run mutates the live repo origin/main (fallback present).
- GREEN: Remove `${TEST_PROJECT:-$project_root}` fallback in `__ensure_gitbucket()`; emit a BLOCKED diagnostic when `$TEST_PROJECT` is unset.
- verify: Run a `BEHAVIOR_NEEDS_REMOTE=1` test; assert live repo origin/main unchanged via clean-room session.yaml evaluation.
- commit: helpers.sh fallback removal + behavioral enforcement test in one atomic slice.

### Item 2 (SC-2): Live-root mutation guard

- RED: Behavioral test asserts an unguarded live-repo target mutates the repo (guard absent).
- GREEN: Add a guard that aborts any git-mutating op whose resolved target equals the live repo, with a clear diagnostic.
- verify: Invoke the guard with target == live repo; assert BLOCK + diagnostic, no mutation occurs.
- commit: guard logic + behavioral test in one atomic slice.

### Item 3 (SC-3): Remote-wiring ordering dependency

- RED: Behavioral test asserts remote wiring runs before an isolated target exists and hits the live repo.
- GREEN: Relocate remote wiring out of `__ensure_gitbucket()` (making it a pure provisioner) into `behavior_run()`, where it runs against the established `$attempt_workdir` and cannot hit the live repo.
- verify: Run a `BEHAVIOR_NEEDS_REMOTE=1` test; assert GitBucket origin wired on isolated `$attempt_workdir`, live repo origin untouched.
- commit: ordering/guard fix + behavioral test in one atomic slice.

### Item 4 (SC-4): Structural regression enforcement test

- RED: Enforcement test fails because the live-root mutation pattern is present.
- GREEN: Add the content-verification enforcement test asserting zero grep matches for live-root mutation patterns.
- verify: Run the enforcement test (`test-enforcement.sh --changed`/`--tag` or standalone); assert PASS.
- commit: enforcement test file in one atomic slice.

### Item 5 (SC-5): Remove phantom `verification-*.md` gate requirement

- RED: Structural test asserts `create-pr.md` Step 4.75 references `verification-*.md` as a PR-blocking artifact (gate requires an artifact no pipeline stage produces).
- GREEN: Edit `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md` Step 4.75 to remove the `verification-*.md` check; the gate requires only `vbc-table-*.md` and `judgment.yaml`.
- verify: Grep `create-pr.md` for `verification-*.md` gate references; assert zero matches and that both remaining artifact checks (vbc-table, judgment) are intact.
- commit: create-pr.md gate fix + structural test in one atomic slice.

## Dependencies

- **Reference:** `.opencode/tests-v2/behaviors/helpers.sh` (`__ensure_gitbucket()`, `behavior_run()`)
- **Relationship:** Must be read before implementation to modify the remote-wiring block and ordering.
- **Status:** Satisfied (verified live in analysis).

- **Reference:** `.opencode/tests-v2/with-test-home`
- **Relationship:** Must be read to confirm `TEST_PROJECT` establishment points and preserve the isolation contract.
- **Status:** Satisfied (verified live in analysis).

- **Reference:** `.opencode/tests-v2/test-enforcement.sh`
- **Relationship:** Must be used to register/run the new structural enforcement test (Phase 2).
- **Status:** Satisfied (existing enforcement runner).

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1, SC-2, SC-4 | Phase 1, Phase 2 |
| R-2 | SC-1, SC-3 | Phase 1 |
| R-3 | SC-1 | Phase 1 |
| R-4 | SC-3 | Phase 1 |
| R-5 | SC-2 | Phase 1 |
| R-6 | SC-1 | Phase 1 |
| R-7 | SC-1, SC-3 | Phase 1 |
| R-8 | SC-3 | Phase 1 |
| R-9 | SC-1, SC-2, SC-3 | Phase 1 |
| R-10 | SC-4 | Phase 2 |
| R-11 | SC-5 | Phase 2 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `tests-v2/behaviors/helpers.sh` | code | `.opencode/tests-v2/behaviors/helpers.sh` | live read; line 267 fallback confirmed, lines 488/612 ordering confirmed |
| `tests-v2/with-test-home` | code | `.opencode/tests-v2/with-test-home` | live read; `TEST_PROJECT` set at lines 229, 389-395 (subprocess only) |
| `tests-v2/test-enforcement.sh` | code | `.opencode/tests-v2/test-enforcement.sh` | existing enforcement runner for Phase 2 test registration |
| `git-workflow-pr/tasks/pr-creation/create-pr.md` | code | `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md` | live read; line 78 `verification-*.md` gate check confirmed, vbc-table/judgment.yaml checks intact |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the fallback is removed and the live repo is untouched costs running one remote-provisioning test plus a live-repo `origin`/`main` snapshot check. Skipping means every `BEHAVIOR_NEEDS_REMOTE=1` test silently mutates the live repo, surfacing as confusing branch/rebase failures that cost exponentially more to trace.
- SC-2: Verifying the guard blocks a live-repo target costs one harness invocation with a diagnostic assertion. Skipping means any future unguarded git-mutating op ships a live-repo mutation with no safeguard, discovered only after the damage is done.
- SC-3: Verifying remote wiring targets the isolated repo costs one remote-provisioning run with an isolated-origin assertion. Skipping means GitBucket wiring silently targets the live repo, breaking isolation for the 21 remote tests and corrupting `origin`.
- SC-4: Running the structural enforcement test costs one content-verification gate run. Skipping means the live-root mutation pattern can be reintroduced and pass review, shipping the same defect in a future cycle — a structural death-spiral start.
- SC-5: Verifying the gate no longer requires `verification-*.md` costs one grep of `create-pr.md` Step 4.75. Skipping means every PR creation BLOCKs on a phantom artifact no pipeline stage produces — a guaranteed dead end at the finish line.

## Edge Cases

- **`$TEST_PROJECT` unset in a remote-provisioning path:** Condition — a `BEHAVIOR_NEEDS_REMOTE=1` test runs with `TEST_PROJECT` unset. Expected — harness emits a BLOCKED diagnostic and halts; no git-mutating op targets the live repo. Resolution — fallback elimination (Item 1) + ordering contract (Item 3) guarantee no live-repo fallback.
- **Target resolves to live repo via `-C` or CWD:** Condition — a git-mutating op uses `-C "$PROJECT_DIR"` or runs with CWD in the live repo. Expected — guard fires with a clear diagnostic; no mutation. Resolution — live-root guard (Item 2).
- **Legitimate isolated target:** Condition — a git-mutating op targets `$attempt_workdir` or a validated isolated repo. Expected — guard must NOT block. Resolution — guard only BLOCKS when target == live repo.
- **GitBucket provisioning ordering:** Condition — `__ensure_gitbucket()` would run before an isolated target exists. Expected — remote wiring is relocated into `behavior_run()` and runs against the established `$attempt_workdir`, never the live repo. Resolution — ordering/relocation fix (Item 3).
- **Reintroduction of the fallback pattern:** Condition — a future edit reintroduces `${TEST_PROJECT:-$project_root}` or unguarded live-root mutation. Expected — content-verification enforcement test fails. Resolution — structural regression test (Item 4).
- **Phantom `verification-*.md` gate requirement:** Condition — `create-pr.md` Step 4.75 references `verification-*.md` as a PR-blocking artifact that no pipeline stage produces. Expected — PR creation BLOCKED on a nonexistent artifact. Resolution — remove the `verification-*.md` check from the gate (Item 5); the gate requires only `vbc-table-*.md` and `judgment.yaml`.

---

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-17 | Added SC-5, R-11, Item 5, traceability row, documentation source, and edge case to remove the phantom `verification-*.md` requirement from the create-pr verification-evidence gate | Revision request #2292: the gate at `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md:78` requires `verification-*.md`, an artifact no pipeline stage produces (verify.md writes only `vbc-table-*.md`; audit tasks write `evidence`/`reasoning`/`verdict`/`judgment.yaml`), blocking PR creation | Michael Conrad |
| 2026-08-17 | Rewrote SC-3 (and its Approach, R-4, Item 3, and edge case) to state the deterministic relocation approach — remote-wiring removed from `__ensure_gitbucket()` (now a pure provisioner) and moved into `behavior_run()` against the established `$attempt_workdir` — removing the either/or ambiguity; corrected the `BEHAVIOR_NEEDS_REMOTE=1` script count from 18 to 21 in the Problem and Cost Frame sections | Validation findings: SC-3 used either/or ambiguity ('run against a validated isolated repo established before remote wiring, or be relocated/guarded so it cannot hit the live repo') — a determinism defect; the '18 scripts' claim was inaccurate (21 scripts have `BEHAVIOR_NEEDS_REMOTE=1`) | Michael Conrad |
| 2026-08-17 | Added the 'User Intent / Original Prompt' preamble field and the 'Not Included' section per spec-structure-standards.md | Validation findings: two required template sections were missing — the preamble lacked the 'User Intent / Original Prompt' field, and the spec had no 'Not Included' section | Michael Conrad |
| 2026-08-17 | Rewrote SC-5 criterion and Item 5 GREEN to use the stable file-area reference 'the verification-evidence gate in create-pr.md Step 4.75' instead of the exact line number (line 78); preserved the Problem/Root Cause, Documentation Sources, and prior Change Control line-number citations as documented historical facts | Validation finding: prescriptive line-number references violate spec-structure-standards.md, which requires SCs and Items to use stable file-area references, not exact line numbers | Michael Conrad |

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
