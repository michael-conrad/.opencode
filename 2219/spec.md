> **Full spec and artifacts: [`.opencode/.issues/2219/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2219)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2219/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC-FIX] Cleanup workflow must detect and delete submodule-pointer-only dead branches

## Intent and Executive Summary

**Problem Statement:** When a submodule PR merges, the parent repo may have a corresponding feature branch whose only diff from main is submodule pointer changes (gitlink updates in `.opencode/`). This branch is unmergeable — submodule-only PRs are forbidden per critical-rules-049. The `check-pr` task currently defers cleanup when the current branch is unmerged (Phase 6, line 131), leaving the repo on a dead branch with no path to resolution.

**Root Cause / Motivation:** The cleanup workflow has no mechanism to detect branches that are unmergeable by design. The existing merged-branch cleanup (Phase 5) only handles branches whose PRs have merged. The dead-branch detection fills this gap: branches whose only diff from trunk is submodule pointer changes are unmergeable artifacts that must be deleted, not deferred.

**Approach Chosen:** Add a dead-branch detection step at the end of Phase 5 (Parent Branch Cleanup) in `check-pr.md`. The step checks if the current branch is unmerged and its only diff from trunk is submodule pointer changes. If so, it verifies the submodule PR merge status via API, deletes the dead branch (local + remote), parks at trunk tip, and acknowledges the dirty submodule pointer.

**Alternatives Considered & Why Discarded:**
- *Defer to Phase 6 branch-aware parking* — Phase 6 currently defers unmerged branches. Adding dead-branch detection there would mix concerns (parking vs. deletion). Detection belongs in Phase 5 where deletion happens.
- *Add a new Phase 5.5* — A separate phase adds structural complexity. The dead-branch detection is a conditional branch within Phase 5's cleanup scope.
- *Modify the pre-work guard to prevent dead branches* — The pre-work No-Op Branch Guard (pre-work.md Step 4) already prevents submodule-only PR creation. The cleanup-side fix is complementary, not a replacement.

**Key Design Decisions:**
1. Dead-branch detection runs at the end of Phase 5, after merged-branch deletion and checkpoint tag cleanup
2. Detection uses `git diff --stat origin/$DEFAULT_BRANCH...HEAD` to check if all changed files are submodule paths
3. Submodule PR merge verification uses the platform API targeting the submodule repo
4. Branch deletion reuses the existing pattern from branch-cleanup.md Step 3.4
5. Dirty submodule pointer handling reuses the pattern from branch-cleanup.md Step 1.7 (acknowledge, do NOT commit)
6. Branches with real code changes (non-submodule files in diff) are NOT deleted — they fall through to Phase 6's existing branch-aware parking

**User Intent / Original Prompt:** Fix the cleanup workflow to handle the case where a submodule PR merges but the parent repo's feature branch is stuck as an unmergeable dead branch.

## Not Included

- Modifying the pre-work No-Op Branch Guard (pre-work.md Step 4) — it already works correctly
- Modifying branch-cleanup.md — its patterns are reused, not changed
- Adding new critical violation entries to SKILL.md — cross-references only
- Creating new task files — the fix is contained within check-pr.md
- Behavioral enforcement tests — these are scoped to the implementation plan, not the spec

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|-------------------|
| SC-1 | Agent detects that a branch's only diff from trunk is submodule pointer changes | `behavioral` | `opencode run` with test repo → assert_semantic for detection decision |
| SC-2 | Agent verifies submodule PR merge status via platform API before deleting parent branch | `behavioral` | `opencode run` with merged vs unmerged submodule PR → assert_semantic for decision logic |
| SC-3 | Agent deletes the dead branch (local + remote) and parks at trunk tip | `behavioral` | `opencode run` → assert_semantic for deletion + parking actions, with assert_stderr_pattern as secondary corroboration |
| SC-4 | Agent leaves submodule pointer dirty after trunk parking (does NOT commit it) | `behavioral` | `opencode run` → assert_semantic for dirty pointer preservation, with assert_stderr_pattern_absent as secondary corroboration |
| SC-5 | Agent does NOT delete branches with real code changes (non-submodule files in diff) | `behavioral` | `opencode run` with mixed-content branch → assert_semantic for preservation decision |
| SC-6 | Existing merged-branch cleanup (Phase 5) continues to work unchanged | `behavioral` + `string` | Existing cleanup behavioral tests pass + grep confirms Phase 5 logic unmodified |

## Requirements

1. The check-pr task SHALL detect when the current branch's only diff from trunk is submodule pointer changes
2. The check-pr task SHALL verify submodule PR merge status via platform API before deleting the parent branch
3. The check-pr task SHALL delete the dead branch (local and remote) when submodule PR merge is confirmed
4. The check-pr task SHALL park the repo at trunk tip after dead-branch deletion
5. The check-pr task SHALL leave the submodule pointer dirty after trunk parking (MUST NOT commit it)
6. The check-pr task SHALL NOT delete branches whose diff contains non-submodule files
7. The check-pr task SHALL preserve the existing merged-branch cleanup logic unchanged

## Items

| Item | SC | Description |
|------|-----|-------------|
| 1 | SC-1 | Add dead-branch detection step at end of Phase 5: check if current branch is unmerged and pointer-only |
| 2 | SC-2 | Add submodule PR merge verification: identify submodule repo, query merge status via API |
| 3 | SC-3 | Add dead-branch deletion: delete local + remote branch, park at trunk tip |
| 4 | SC-4 | Add dirty pointer acknowledgment: reuse branch-cleanup.md Step 1.7 pattern |
| 5 | SC-5 | Add non-pointer branch guard: skip deletion if diff contains non-submodule files |
| 6 | SC-6 | Verify existing Phase 5 logic is unmodified; run existing cleanup tests |

## Dependencies

- **Prerequisite specs:** None
- **Skills:** `git-workflow-cleanup` — the check-pr task is part of this skill
- **Guidelines:** `000-critical-rules.md` §critical-rules-049 (submodule-only PR prohibition), `080-code-standards.md` (evidence type taxonomy, behavioral test mandate)
- **Reference files:** `branch-cleanup.md` Step 1.7 (dirty pointer pattern), Step 3.4 (branch deletion pattern), `pre-work.md` Step 4 (No-Op Branch Guard)

## Traceability

| Requirement | SC(s) | Phase |
|-------------|-------|-------|
| R1 (detection) | SC-1 | Detection |
| R2 (submodule PR verification) | SC-2 | Detection |
| R3 (branch deletion) | SC-3 | Deletion |
| R4 (trunk parking) | SC-3 | Deletion |
| R5 (dirty pointer) | SC-4 | Deletion |
| R6 (non-pointer guard) | SC-5 | Detection |
| R7 (existing cleanup) | SC-6 | Verification |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| check-pr.md | Task file | `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md` | Read file |
| branch-cleanup.md | Task file | `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` | Read file |
| pre-work.md | Task file | `.opencode/skills/git-workflow-branch/tasks/pre-work.md` | Read file |
| critical-rules-049 | Guideline | `.opencode/guidelines/000-critical-rules.md` | Read file |
| Analysis artifacts | YAML | `tmp/spec-fix-submodule-dead-branch/artifacts/` | Read directory |

## Enforcement Gate

ALL success criteria MUST pass before this spec-fix is considered complete. Partial implementation is not acceptable — the dead-branch detection, submodule PR verification, deletion, dirty pointer handling, non-pointer guard, and existing cleanup preservation must all be verified.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Running the behavioral detection test costs minutes of execution time. Skipping means a dead branch is left in the repo, blocking future cleanup runs and confusing the agent.
- SC-2: Verifying submodule PR merge status via API costs one API call. Skipping means the agent deletes a branch whose submodule changes haven't been incorporated — data loss.
- SC-3: Running the deletion behavioral test costs minutes. Skipping means the deletion logic silently fails and the dead branch persists.
- SC-4: Verifying dirty pointer preservation costs minutes. Skipping means the agent commits the dirty pointer, violating the submodule-only PR prohibition.
- SC-5: Running the non-pointer guard test costs minutes. Skipping means the agent deletes a branch with real code changes — data loss.
- SC-6: Running existing cleanup tests costs minutes. Skipping means the fix breaks existing cleanup behavior without detection.

## Edge Cases

- **Submodule PR not merged:** The agent MUST NOT delete the parent branch. It falls through to Phase 6's existing branch-aware parking (defer cleanup).
- **Multiple submodules with pointer changes:** The diff check (`git diff --stat`) shows all changed paths. If ALL are submodule paths, the branch is dead. If ANY non-submodule path exists, the branch is NOT dead.
- **No submodule PR found:** The agent cannot verify merge status. The branch is NOT deleted — it falls through to Phase 6 deferral.
- **Branch has both pointer changes and real code changes:** The diff check catches non-submodule files. The branch is NOT dead — it falls through to Phase 6.
- **Remote branch already deleted:** `git push origin --delete` fails gracefully. The agent continues with local deletion and trunk parking.
- **Trunk pull fails (non-ff):** The agent reports the failure and halts. The dirty pointer is preserved.
- **Submodule repo inaccessible (network error):** The agent cannot verify merge status. The branch is NOT deleted — it falls through to Phase 6 deferral.

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-01 | SC-3 and SC-4 verification methods changed from assert_stderr_pattern/assert_stderr_pattern_absent to assert_semantic (primary) with stderr assertions as secondary corroboration | Validation FAIL on dimension 9 (Evidence type correctness): behavioral evidence type requires assert_semantic, not string-level stderr assertions, as primary verification method | Validation gate (dimension 9) |
