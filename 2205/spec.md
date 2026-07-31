---
remote_issue: 2205
remote_url: https://github.com/michael-conrad/.opencode/issues/2205
labels: [spec]
---

> **Full spec and artifacts: [`.opencode/.issues/2205/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2205)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2205/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Intent and Executive Summary

Remove all references to the deleted `implementation-pipeline` skill and its vestigial forwarding layer `executing-plans`. The `implementation-pipeline` skill was deleted and its content preserved as a static reference card at `writing-plans/reference/implementation-workflow.md`, but 40+ files still reference the old skill as a live dispatch target, document path, or cross-reference. The `executing-plans` skill was a thin routing layer that forwarded to `implementation-pipeline` — with the target gone, it is dead code. The orchestrator reads the plan directly and dispatches steps per each step's dispatch indicator — no intermediate skill is needed.

## Problem Statement

40 files across `.opencode/` contain stale references to `implementation-pipeline` and `executing-plans`. These fall into categories:

1. **Live dispatch targets** — files that tell the agent to `task()` to or route to `implementation-pipeline` as a loadable skill. The skill doesn't exist, so any agent following these instructions hits a hard failure.

2. **Document references** — files that reference `implementation-pipeline/SKILL.md` or `implementation-pipeline per the SKILL.md Trigger Dispatch Table` as a document path. The path doesn't exist.

3. **Cross-reference lists** — SKILL.md files that list `implementation-pipeline` in their `Skills:` cross-reference sections.

4. **Behavioral tests** — test scripts that grep for `implementation-pipeline` patterns or check files that no longer exist.

5. **Non-skill files** — `dispatch-table.yaml`, `prompts/default.txt`, `README.md`, `session_context_triggers.py`, `065-verification-honesty.md` that reference the deleted skill.

## Root Cause / Motivation

The `implementation-pipeline` skill was deleted and replaced with a static reference card at `writing-plans/reference/implementation-workflow.md`. The migration was incomplete — references across the codebase were never updated. The `executing-plans` skill was a forwarding layer to `implementation-pipeline` and is now vestigial.

## Approach Chosen

Delete `executing-plans/` skill directory. Remove or update all stale `implementation-pipeline` references. Update behavioral tests to reference the reference card or remove obsolete tests. The orchestrator reads the plan directly — no intermediate routing skill.

## Scope

- Delete `executing-plans/` skill directory entirely
- Remove 5 `dispatch-table.yaml` entries routing to `implementation-pipeline`
- Remove `implementation-pipeline` from `README.md` skill listing
- Remove `implementation-pipeline` from cross-reference lists in 4 SKILL.md files
- Remove `rationalization-check-remediation.sh` behavioral test (checks non-existent file)
- Update 30+ files with stale references (live dispatch targets, document references, behavioral tests, non-skill files)
- Preserve `CHANGELOG.md` historical entries as-is

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `executing-plans/` skill directory deleted | structural | `ls .opencode/skills/executing-plans/` returns error |
| SC-2 | No `dispatch-table.yaml` entries reference `implementation-pipeline` | string | `grep -c "implementation-pipeline" .opencode/dispatch-table.yaml` returns 0 |
| SC-3 | No `implementation-pipeline` references in `.md` files outside CHANGELOG.md, `.issues/` historical specs, and `implementation-workflow.md` self-description | string | `grep -r "implementation-pipeline" .opencode/ --include="*.md" | grep -v CHANGELOG.md | grep -v ".opencode/.issues/" | grep -v "implementation-workflow.md" | wc -l` returns 0 |
| SC-4 | No `implementation-pipeline` references in non-md files (yaml, py, txt, sh) outside `.issues/` historical specs, `tmp/` artifacts, and intentional test file comments | string | `grep -r "implementation-pipeline" .opencode/ --include="*.yaml" --include="*.py" --include="*.txt" --include="*.sh" | grep -v ".opencode/.issues/" | grep -v ".opencode/tmp/" | grep -v "2203-" | grep -v "2205-sc3-implementation-pipeline-references.sh" | wc -l` returns 0 |
| SC-5 | `rationalization-check-remediation.sh` behavioral test removed | structural | `ls .opencode/tests-v2/behaviors/rationalization-check-remediation.sh` returns error |
| SC-6 | `rationalization-check-pipeline.sh` updated to check reference card | string | grep for `implementation-workflow.md` in the test file |
| SC-7 | `writing-plans-create.sh` grep patterns updated to `implementation-workflow` | string | grep for `implementation-workflow` in the test file |
| SC-8 | `writing-plans-structure.sh` grep patterns updated to `implementation-workflow` | string | grep for `implementation-workflow` in the test file |
| SC-9 | `1246-sc3-resolve-models-preflight.sh` prompt updated to real-domain task | string | No `implementation-pipeline` in prompt text |
| SC-10 | `2009-sc4-plan-fidelity-pipeline.sh` prompt updated to real-domain task | string | No `implementation-pipeline` in prompt text |
| SC-11 | `prompts/default.txt` no longer references `implementation-pipeline` | string | `grep "implementation-pipeline" .opencode/prompts/default.txt` returns empty |
| SC-12 | `README.md` no longer lists `implementation-pipeline` | string | `grep "implementation-pipeline" .opencode/README.md` returns empty |
| SC-13 | `session_context_triggers.py` no longer references `implementation-pipeline` | string | `grep "implementation-pipeline" .opencode/scripts/session_context_triggers.py` returns empty |
| SC-14 | `065-verification-honesty.md` no longer references `implementation-pipeline` | string | `grep "implementation-pipeline" .opencode/guidelines/065-verification-honesty.md` returns empty |
| SC-15 | `plan-artifact-format.md` no longer lists `implementation-pipeline` as consumer | string | `grep "implementation-pipeline" .opencode/skills/writing-plans/reference/plan-artifact-format.md` returns empty |
| SC-16 | `implementation-workflow.md` reference card no longer references `skill({name: "implementation-pipeline"})` | string | `grep "skill.*implementation-pipeline" .opencode/skills/writing-plans/reference/implementation-workflow.md` returns empty |
| SC-17 | `implementation-workflow.md` reference card no longer has Trigger Dispatch Table | string | No `## Trigger Dispatch Table` heading in the reference card |
| SC-18 | `implementation-workflow.md` reference card no longer references `implementation-pipeline` in OVERFLOW section | string | `grep "implementation-pipeline" .opencode/skills/writing-plans/reference/implementation-workflow.md` returns only lines 3 and 14 (self-description) |

## Files Affected

### Delete
- `.opencode/skills/executing-plans/` (entire directory)
- `.opencode/tests-v2/behaviors/rationalization-check-remediation.sh`

### Remove entries
- `.opencode/dispatch-table.yaml` — 5 entries routing to `implementation-pipeline`
- `.opencode/README.md` — remove `implementation-pipeline` from Planning skills table
- `.opencode/skills/approval-gate/SKILL.md` — remove from cross-reference list
- `.opencode/skills/approval-gate-scope/SKILL.md` — remove from cross-reference list
- `.opencode/skills/writing-plans/SKILL.md` — remove from cross-reference list and update task descriptions
- `.opencode/skills/writing-plans/reference/plan-artifact-format.md` — remove from consumer list

### Update references
- `.opencode/skills/approval-gate-scope/tasks/verify-authorization/auto-dispatch.md`
- `.opencode/skills/approval-gate-scope/enforcement/auto-dispatch-table.md`
- `.opencode/skills/approval-gate-scope/tasks/pre-implementation-analysis.md`
- `.opencode/skills/approval-gate-scope/tasks/pre-impl/yield-to-assemble-work.md`
- `.opencode/skills/approval-gate-scope/tasks/pre-impl/write-work-state.md`
- `.opencode/skills/approval-gate-scope/tasks/pre-impl/build-dependency-graph.md`
- `.opencode/skills/approval-gate-scope/tasks/screen/screen-issue-gate2.md`
- `.opencode/skills/approval-gate-scope/tasks/gap-fill-cascade/for-pr.md`
- `.opencode/skills/approval-gate-scope/tasks/gap-fill-cascade/for-implementation.md`
- `.opencode/skills/approval-gate-scope/tasks/column-validation.md`
- `.opencode/skills/writing-plans/SKILL.md`
- `.opencode/skills/writing-plans/tasks/create.md`
- `.opencode/skills/writing-plans/reference/implementation-workflow.md`
- `.opencode/skills/git-workflow-branch/tasks/operating-protocol.md`
- `.opencode/skills/git-workflow-branch/tasks/pre-work.md`
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`
- `.opencode/skills/git-workflow-pr/tasks/review-prep/push-and-cleanup.md`
- `.opencode/skills/pr-creation-workflow/tasks/create.md`
- `.opencode/skills/pr-creation-workflow/tasks/pre-pr-checklist.md`
- `.opencode/skills/pr-creation-workflow/tasks/sub-issue-collection.md`
- `.opencode/skills/finishing-a-development-branch/tasks/checklist.md`
- `.opencode/skills/using-git-worktrees/tasks/create-worktree.md`
- `.opencode/skills/using-git-worktrees/tasks/reference.md`
- `.opencode/skills/pre-analysis/tasks/analyze.md`
- `.opencode/skills/verification-enforcement/tasks/enforce.md`
- `.opencode/skills/issue-operations-core/tasks/single-task-check.md`
- `.opencode/prompts/default.txt`
- `.opencode/guidelines/065-verification-honesty.md`
- `.opencode/scripts/session_context_triggers.py`

### Update behavioral tests
- `.opencode/tests-v2/behaviors/rationalization-check-pipeline.sh`
- `.opencode/tests-v2/behaviors/writing-plans-create.sh`
- `.opencode/tests-v2/behaviors/writing-plans-structure.sh`
- `.opencode/tests-v2/behaviors/1246-sc3-resolve-models-preflight.sh`
- `.opencode/tests-v2/behaviors/2009-sc4-plan-fidelity-pipeline.sh`

### Preserve as-is
- `.opencode/CHANGELOG.md` — historical entries

## Dependencies

- None.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
