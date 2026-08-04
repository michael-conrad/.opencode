## Problem

The git-workflow skill card family (6 skills: git-workflow, git-workflow-branch, git-workflow-cleanup, git-workflow-commit, git-workflow-conflict, git-workflow-pr) uses the deprecated Trigger Dispatch Table + DISPATCH_GATE + Tasks table format. This format lacks a canonical dispatch string column, forcing the orchestrator to read task card files to construct `task()` prompts — which violates the progressive disclosure architecture (Level 3 content leaks into Level 2).

Per `reference/skill-card-description-standards.md` §7, the Workflows section format replaces the old three-section structure with numbered steps containing sub-bullet dispatch contracts (Prompt, Context, Returns). The orchestrator never needs to read task cards because the exact prompt string is in the SKILL.md.

The SC-6 behavioral test (`2242-sc6-cleanup-dispatch-no-task-card-read.sh`) previously dead-ended in its cleanup-dispatch run: the model loaded git-workflow-cleanup, tried `gh pr list` (which fails because the isolated test env is `local` platform with no GitHub remote/auth), and asked the user for the PR/branch instead of dispatching cleanup. A full-environment simulation is required so merged-PR discovery and cleanup dispatch complete without the model halting for missing PR context.

## Success Criteria

- [ ] **SC1 (behavioral):** After remediation, when an agent loads any git-workflow skill card and dispatches a task, the orchestrator uses the canonical dispatch string from the Workflows section — no task card file reads by the orchestrator
- [ ] **SC2 (structural):** All 6 git-workflow SKILL.md files use the Workflows section format per reference §7
- [ ] **SC3 (structural):** All 6 git-workflow SKILL.md files have descriptions in the canonical agent-task format (no "Load via skill() when...", "User phrases:..." deprecated patterns)
- [ ] **SC4 (structural):** No git-workflow SKILL.md contains a Trigger Dispatch Table, DISPATCH_GATE section, or Tasks table
- [ ] **SC5 (structural):** Each Workflows step has sub-bullets: Prompt (with discovery directive), Context, Returns
- [ ] **SC6 (behavioral):** After remediation, dispatching "cleanup from git-workflow-cleanup" produces a sub-agent result contract without the orchestrator having read any task card file
- [ ] **SC7 (behavioral):** The SC-6 cleanup-dispatch behavioral test runs in a full-environment simulation — a provisioned GitBucket instance as the test repo's `origin` remote (via `BEHAVIOR_NEEDS_REMOTE=1`) and/or `test-submodule-1`/`test-submodule-2` repo fixtures — so merged-PR discovery and cleanup dispatch complete without the model halting for missing PR context. The test env is no longer `local`-platform with no GitHub; `gh pr list`/PR discovery succeeds.

## Approach

1. Convert each SKILL.md from TDT + DISPATCH_GATE + Tasks table to Workflows section format
2. Update descriptions to canonical agent-task format
3. Verify no orchestrator task card reads occur during dispatch
4. Run behavioral enforcement tests to confirm
5. Provision a full-environment simulation for the SC-6 cleanup-dispatch test: enable `BEHAVIOR_NEEDS_REMOTE=1` in the test script to provision a self-contained GitBucket instance wired as the test repo's `origin`, or add `test-submodule-1`/`test-submodule-2` fixtures as repo fixtures, so PR/branch discovery succeeds and cleanup dispatch completes without halting

## Affected Files

- `skills/git-workflow/SKILL.md`
- `skills/git-workflow-branch/SKILL.md`
- `skills/git-workflow-cleanup/SKILL.md`
- `skills/git-workflow-commit/SKILL.md`
- `skills/git-workflow-conflict/SKILL.md`
- `skills/git-workflow-pr/SKILL.md`
- `reference/skill-card-description-standards.md` (reference — no changes needed)
- `reference/task-card-structure-standards.md` (reference — no changes needed)
- `tests-v2/behaviors/helpers.sh` (GitBucket provisioning / remote-API support consumed by `BEHAVIOR_NEEDS_REMOTE=1`)
- `tests-v2/with-test-home` (test-home env isolation, `GB_HOST`/`GITBUCKET_PORT` passthrough, remote API test support)
- `tests-v2/behaviors/fixtures/setup/2242-sc6-cleanup-dispatch-no-task-card-read.sh` (per-scenario fixture for merged-branch + open-issue cleanup target; extend to provision full environment)
- `tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh` (set `BEHAVIOR_NEEDS_REMOTE=1` and/or reference test-submodule fixtures)
- New fixture/setup files under `tests-v2/behaviors/fixtures/` implementing full-environment provisioning (e.g., test-submodule repo fixtures)

## Change Control

### 2026-08-03 — Added SC7 and full-environment simulation for SC-6 cleanup test

- **What changed:** Added SC7 (behavioral) requiring the SC-6 cleanup-dispatch behavioral test to run in a full-environment simulation (provisioned GitBucket instance as the test repo's `origin` via `BEHAVIOR_NEEDS_REMOTE=1`, and/or `test-submodule-1`/`test-submodule-2` fixtures). Updated the Approach (step 5) and the Affected Files section to include the test framework files (`tests-v2/behaviors/helpers.sh`, `tests-v2/with-test-home`) and new fixture/setup files implementing full-environment provisioning.
- **Why:** The most recent SC-6 behavioral test run (-7 trial) failed scenario-completion: the model loaded git-workflow-cleanup, tried `gh pr list` (no GitHub auth in the `local`-platform isolated test repo), and asked the user for the PR/branch instead of dispatching cleanup. Correcting this failure mode requires a real test that provisions a full environment (test-submodule repos as fixtures and/or a GitBucket instance as the remote) so PR/branch discovery succeeds.
- **Authorized by:** Developer revision request (revision_reason for issue #2242).
