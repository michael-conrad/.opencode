> **Full spec and artifacts: [`.opencode/.issues/2219/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2219)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2219/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC-FIX] Submodule pointer discipline: pre-work ordering, dead-branch cleanup, PR guards, and pre-commit enforcement

## Intent and Executive Summary

**Problem Statement:** The submodule pointer lifecycle has four gaps that together produce dead branches, stale pointers, and submodule-only PRs:

1. **Pre-work ordering (#1686):** `pre-work.md` creates the parent feature branch before syncing submodules, so the parent branch captures a stale submodule pointer. When the submodule later advances, the parent's pointer is already outdated.
2. **Dead-branch cleanup (#2219):** When a submodule PR merges, the parent repo may have a corresponding feature branch whose only diff from main is submodule pointer changes. This branch is unmergeable (submodule-only PRs are forbidden per critical-rules-049). The `check-pr` task defers cleanup, leaving the repo on a dead branch.
3. **PR creation guards (#1812):** `implementation.md` and `pr-creation.md` instruct the agent to stage dirty submodule pointers without checking for non-submodule changes, creating submodule-only PRs. The prohibition in `020-go-prohibitions.md` is scoped to "during cleanup" only.
4. **Pre-commit enforcement (#1710):** No enforcement mechanism verifies that submodule pointer commits reference the remote trunk tip SHA. Agents commit stale SHAs without detection.

**Root Cause / Motivation:** The submodule pointer workflow has no end-to-end discipline. Each gap is a separate pipeline stage (pre-work → cleanup → PR creation → commit), and each stage lacks the guard it needs.

**Approach Chosen:** Fix all four gaps in a single stacked PR:
1. Reorder `pre-work.md` steps so submodule sync precedes feature branch creation
2. Add dead-branch detection to `check-pr.md` Phase 5
3. Add guards to `implementation.md` and `pr-creation.md` to prevent submodule-only staging; widen the prohibition in `020-go-prohibitions.md`
4. Add pre-commit enforcement for stale submodule pointer SHAs

**Alternatives Considered & Why Discarded:**
- *Separate PRs for each gap* — The gaps are interdependent: fixing pre-work without fixing cleanup leaves dead branches. Fixing cleanup without fixing PR guards recreates them. A single stacked PR ensures all gates are in place.
- *Modify only the pre-push hook* — The hook already blocks submodule-only pushes, but the agent creates PRs locally without pushing. Task file guards are needed at the source.

**Key Design Decisions:**
1. Pre-work reorder: submodule sync → tag → feature branch creation (parent + submodule)
2. Dead-branch detection: `git diff --stat origin/$DEFAULT_BRANCH...HEAD` to identify pointer-only branches
3. PR guards: verify non-submodule changes exist before staging submodule pointer
4. Pre-commit enforcement: block commits where submodule SHA != remote trunk tip
5. All four fixes in one stacked PR with a single feature branch

**User Intent / Original Prompt:** Fix the submodule pointer lifecycle end-to-end: pre-work ordering, dead-branch cleanup, PR guards, and pre-commit enforcement.

## Not Included

- Changes to the pre-push hook (already blocks submodule-only pushes)
- CI workflows (no CI infrastructure exists)
- Changes to how existing hooks work for non-submodule commits
- Changes to `branch-cleanup.md` — its patterns are reused, not changed

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|-------------------|
| SC-1 | Submodule sync appears BEFORE feature branch creation in pre-work.md | `string` | grep for step ordering — submodule steps precede branch creation |
| SC-2 | Submodule feature branch creation step references the tagged commit, not trunk tip | `string` | grep for submodule branch creation using the tag |
| SC-3 | Behavioral test verifies agent syncs submodules before creating main repo feature branch | `behavioral` | `opencode run` with pre-work scenario → assert_semantic for ordering |
| SC-4 | All step numbers in pre-work.md are internally consistent | `string` | grep for orphan references to old step numbers |
| SC-5 | Submodule feature branch creation handles the "already exists" edge case | `string` | grep for existence check before branch creation |
| SC-6 | Agent detects that a branch's only diff from trunk is submodule pointer changes | `behavioral` | `opencode run` with test repo → assert_semantic for detection decision |
| SC-7 | Agent verifies submodule PR merge status via platform API before deleting parent branch | `behavioral` | `opencode run` with merged vs unmerged submodule PR → assert_semantic for decision logic |
| SC-8 | Agent deletes the dead branch (local + remote) and parks at trunk tip | `behavioral` | `opencode run` → assert_semantic for deletion + parking actions, with assert_stderr_pattern as secondary corroboration |
| SC-9 | Agent leaves submodule pointer dirty after trunk parking (does NOT commit it) | `behavioral` | `opencode run` → assert_semantic for dirty pointer preservation, with assert_stderr_pattern_absent as secondary corroboration |
| SC-10 | Agent does NOT delete branches with real code changes (non-submodule files in diff) | `behavioral` | `opencode run` with mixed-content branch → assert_semantic for preservation decision |
| SC-11 | Existing merged-branch cleanup (Phase 5) continues to work unchanged | `behavioral` + `string` | Existing cleanup behavioral tests pass + grep confirms Phase 5 logic unmodified |
| SC-12 | `implementation.md` guards against submodule-only staging — before staging submodule pointer, verifies non-submodule changes exist | `string` | grep for guard logic in implementation.md |
| SC-13 | `pr-creation.md` guards against submodule-only staging — before staging submodule pointer, verifies non-submodule changes exist | `string` | grep for guard logic in pr-creation.md |
| SC-14 | Universal prohibition in `020-go-prohibitions.md` says "in ANY context, for ANY reason" (not scoped to cleanup only) | `string` | grep for universal scope in prohibition text |
| SC-15 | Behavioral test verifies agent declines submodule-only PR creation | `behavioral` | `opencode run` with submodule-only prompt → assert_semantic for decline behavior |
| SC-16 | Pre-commit hook blocks submodule-pointer commits where local SHA != remote trunk tip SHA | `behavioral` | bash test creating stale pointer, attempting commit, verifying block |
| SC-17 | git-workflow SKILL.md has a release-pr trigger dispatch entry in the Trigger Dispatch Table | `string` | grep for release-pr in SKILL.md |
| SC-18 | create-pr task has a --release mode section with submodule SHA verification step | `string` | grep for --release or release mode in create-pr.md |
| SC-19 | Agent tasked with release PR dispatches pre-work before any submodule operations | `behavioral` | `opencode run` with release PR prompt → assert_semantic for pre-work dispatch |

## Requirements

1. pre-work.md SHALL reorder steps so submodule sync precedes feature branch creation
2. pre-work.md SHALL create submodule feature branches from the tagged commit
3. pre-work.md SHALL handle the "already exists" edge case for submodule branches
4. check-pr.md SHALL detect pointer-only branches at end of Phase 5
5. check-pr.md SHALL verify submodule PR merge status via platform API before deletion
6. check-pr.md SHALL delete dead branches (local + remote) and park at trunk tip
7. check-pr.md SHALL leave submodule pointer dirty after trunk parking
8. check-pr.md SHALL NOT delete branches with non-submodule changes
9. check-pr.md SHALL preserve existing merged-branch cleanup logic
10. implementation.md SHALL guard against submodule-only staging
11. pr-creation.md SHALL guard against submodule-only staging
12. 020-go-prohibitions.md SHALL have universal submodule-only PR prohibition
13. Pre-commit hook SHALL block submodule-pointer commits where SHA != remote trunk tip
14. git-workflow SKILL.md SHALL have a release-pr trigger dispatch entry
15. create-pr task SHALL have a --release mode with submodule SHA verification

## Items

| Item | SCs | Description |
|------|-----|-------------|
| 1 | SC-1, SC-2, SC-3, SC-4, SC-5 | Reorder pre-work.md: submodule sync before feature branch creation |
| 2 | SC-6, SC-7, SC-8, SC-9, SC-10, SC-11 | Add dead-branch detection to check-pr.md Phase 5 |
| 3 | SC-12, SC-13, SC-14, SC-15 | Add guards to implementation.md, pr-creation.md, 020-go-prohibitions.md |
| 4 | SC-16, SC-17, SC-18, SC-19 | Add pre-commit enforcement for stale submodule pointers |

## Dependencies

- **Prerequisite specs:** None — all four gaps are independent and can be implemented in any order
- **Skills:** `git-workflow-branch` (pre-work.md), `git-workflow-cleanup` (check-pr.md), `git-workflow-commit` (implementation.md), `git-workflow-pr` (pr-creation.md)
- **Guidelines:** `000-critical-rules.md` §critical-rules-049 (submodule-only PR prohibition), `020-go-prohibitions.md` (prohibition scope)
- **Reference files:** `branch-cleanup.md` Step 1.7 (dirty pointer), Step 3.4 (branch deletion), `pre-work.md` (current step ordering)

## Traceability

| Requirement | SC(s) | Phase |
|-------------|-------|-------|
| R1 (pre-work reorder) | SC-1, SC-3, SC-4 | Pre-work |
| R2 (submodule branch from tag) | SC-2 | Pre-work |
| R3 (already exists edge case) | SC-5 | Pre-work |
| R4 (dead-branch detection) | SC-6 | Cleanup |
| R5 (submodule PR verification) | SC-7 | Cleanup |
| R6 (branch deletion + parking) | SC-8 | Cleanup |
| R7 (dirty pointer) | SC-9 | Cleanup |
| R8 (non-pointer guard) | SC-10 | Cleanup |
| R9 (existing cleanup) | SC-11 | Cleanup |
| R10 (implementation guard) | SC-12 | PR guards |
| R11 (pr-creation guard) | SC-13 | PR guards |
| R12 (universal prohibition) | SC-14 | PR guards |
| R13 (pre-commit hook) | SC-16 | Pre-commit |
| R14 (release-pr dispatch) | SC-17 | Pre-commit |
| R15 (--release mode) | SC-18 | Pre-commit |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| pre-work.md | Task file | `.opencode/skills/git-workflow-branch/tasks/pre-work.md` | Read file |
| check-pr.md | Task file | `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md` | Read file |
| implementation.md | Task file | `.opencode/skills/git-workflow-commit/tasks/implementation.md` | Read file |
| pr-creation.md | Task file | `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` | Read file |
| branch-cleanup.md | Task file | `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` | Read file |
| 020-go-prohibitions.md | Guideline | `.opencode/guidelines/020-go-prohibitions.md` | Read file |
| critical-rules-049 | Guideline | `.opencode/guidelines/000-critical-rules.md` | Read file |
| git-workflow SKILL.md | Skill card | `.opencode/skills/git-workflow/SKILL.md` | Read file |
| pre-push hook | Hook | `.opencode/hooks/pre-push` | Read file |

## Enforcement Gate

ALL 19 success criteria MUST pass before this spec is considered complete. No partial delivery is permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1 through SC-5: Verifying pre-work step ordering costs one grep search. Skipping means the parent branch captures a stale submodule pointer, causing the "stale commit" problem on every feature branch.
- SC-6 through SC-11: Verifying dead-branch detection costs one behavioral test run per SC. Skipping means dead branches accumulate in the repo indefinitely.
- SC-12 through SC-15: Verifying PR guards costs one grep + one behavioral test. Skipping means the agent continues creating submodule-only PRs.
- SC-16 through SC-19: Verifying pre-commit enforcement costs one behavioral test. Skipping means stale submodule pointer SHAs are committed without detection.

## Edge Cases

- **Submodule feature branch already exists:** pre-work.md must check `git branch --list` before creation and skip if exists
- **Submodule tag push fails:** Verify tag exists locally before creating branch from it
- **Branch with only submodule changes + no real code:** PR guard catches this — HALT before staging
- **Branch with real code changes + dirty submodule:** PR guard passes — submodule pointer is staged alongside real changes
- **Cleanup workflow:** The existing cleanup prohibition already handles this. The task file guards are an additional safety net
- **Pre-push hook still fires:** The hook remains as a last-resort block. The task file guards prevent the agent from ever reaching the hook with a submodule-only PR
- **External cross-references to old step numbers:** Grep all `.opencode/` files before renumbering pre-work.md steps

## Affected Files

- **MODIFY:** `.opencode/skills/git-workflow-branch/tasks/pre-work.md` — reorder steps, add submodule branch creation
- **MODIFY:** `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md` — add dead-branch detection at end of Phase 5
- **MODIFY:** `.opencode/skills/git-workflow-commit/tasks/implementation.md` — add submodule-only staging guard
- **MODIFY:** `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` — add submodule-only staging guard
- **MODIFY:** `.opencode/guidelines/020-go-prohibitions.md` — widen prohibition to universal scope
- **MODIFY:** `.opencode/skills/git-workflow/SKILL.md` — add release-pr trigger dispatch entry
- **MODIFY:** `.opencode/skills/git-workflow/tasks/pr-creation/create-pr.md` — add --release mode with submodule SHA verification
- **MODIFY:** `.opencode/hooks/pre-push` — add pre-commit gate for stale submodule pointers
- **CREATE:** `.opencode/tests-v2/behaviors/` — new behavioral enforcement tests
