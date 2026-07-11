# Code Path Inventory — Task Files per Overloaded Skill

## issue-operations (21 task files)

| Task File | Proposed Sub-Skill | Purpose |
|---|---|---|
| `pre-creation.md` | `issue-operations-core` | Prepare issue creation context |
| `single-task-check.md` | `issue-operations-core` | Verify single-task exemption |
| `creation.md` | `issue-operations-core` | Create new issue via dispatcher |
| `post-creation.md` | `issue-operations-core` | Post-creation setup |
| `read-issue.md` | `issue-operations-core` | Read single issue via dispatcher |
| `read-labels.md` | `issue-operations-core` | Read issue labels |
| `list-issues.md` | `issue-operations-core` | List issues with filters |
| `search-issues.md` | `issue-operations-core` | Search issues |
| `update-issue.md` | `issue-operations-core` | Update issue body/labels/state |
| `body-edit.md` | `issue-operations-core` | Edit remote body via 4-agent dispatch |
| `capabilities.md` | `issue-operations-core` | List platform capabilities |
| `close.md` | `issue-operations-core` | Close issue via dispatcher |
| `link-sub-issue.md` | `issue-operations-sub-issues` | Add sub-issue to parent |
| `read-sub-issues.md` | `issue-operations-sub-issues` | Read sub-issues |
| `verify-merge.md` | `issue-operations-sub-issues` | Verify PR merge before closure |
| `sync-from-remote.md` | `issue-operations-sync` | Reconcile remote vs local issues |
| `sync-pull-to-local.md` | `issue-operations-sync` | Mirror remote issue to local |
| `import-remote.md` | `issue-operations-sync` | Retroactively import remote issue |
| `push-artifacts.md` | `issue-operations-sync` | Push spec artifacts to issues-data |
| `comment.md` | `issue-operations-comments` | Post comment with substantiveness gate |
| `read-comments.md` | `issue-operations-comments` | Read issue comments |
| `completion.md` | `issue-operations-core` | Workflow completion signal |

## approval-gate (16 task files + 3 directories)

| Task File | Proposed Sub-Skill | Purpose |
|---|---|---|
| `verify-authorization.md` | `approval-gate-scope` | Verify authorization scope |
| `verify-authorization/` (dir) | `approval-gate-scope` | Sub-tasks for authorization verification |
| `verify-blockers.md` | `approval-gate-scope` | Check for blocking conditions |
| `verify-closed-issue.md` | `approval-gate-scope` | Verify closed issue state |
| `verify-already-implemented.md` | `approval-gate-scope` | Check if already implemented |
| `verify-sub-issues.md` | `approval-gate-scope` | Verify sub-issue structure |
| `post-implementation.md` | `approval-gate-scope` | Post-implementation verification |
| `column-validation.md` | `approval-gate-labels` | Pre-approval column validation |
| `authorization-context.md` | `approval-gate-labels` | Authorization context template |
| `gap-fill-cascade.md` | `approval-gate-revision` | Spec-to-plan gap fill cascade |
| `gap-fill-cascade/` (dir) | `approval-gate-revision` | Sub-tasks for gap fill |
| `verify-plan-pipeline.md` | `approval-gate-revision` | Verify plan pipeline readiness |
| `verify-codebase.md` | `approval-gate-revision` | Verify codebase state |
| `verify-fix-spec.md` | `approval-gate-revision` | Verify fix spec completeness |
| `reconcile-issue-graph.md` | `approval-gate-revision` | Reconcile issue dependency graph |
| `verify-open-questions.md` | `approval-gate-revision` | Verify open questions resolved |
| `verify-qa-mode.md` | `approval-gate-revision` | Verify QA mode state |
| `screen-issue.md` | `approval-gate-bug-discovery` | Screen issue for bug discovery |
| `screen/` (dir) | `approval-gate-bug-discovery` | Sub-tasks for issue screening |
| `pre-implementation-analysis.md` | `approval-gate-bug-discovery` | Pre-implementation analysis |
| `pre-impl/` (dir) | `approval-gate-bug-discovery` | Sub-tasks for pre-implementation |
| `completion.md` | `approval-gate-scope` | Workflow completion signal |

## git-workflow (16 task files + 4 directories)

| Task File | Proposed Sub-Skill | Purpose |
|---|---|---|
| `pre-work.md` | `git-workflow-branch` | Branch creation and setup |
| `pair-pre-work.md` | `git-workflow-branch` | Pair mode branch setup |
| `pair-mode-resume.md` | `git-workflow-branch` | Resume pair mode session |
| `implementation.md` | `git-workflow-commit` | Commit and save work |
| `commit-prep.md` | `git-workflow-commit` | Prepare commit |
| `pair-commit.md` | `git-workflow-commit` | Pair mode commit |
| `provenance.md` | `git-workflow-commit` | Provenance tracking |
| `provenance/` (dir) | `git-workflow-commit` | Sub-tasks for provenance |
| `pr-creation.md` | `git-workflow-pr` | Create PR |
| `pr-creation/` (dir) | `git-workflow-pr` | Sub-tasks for PR creation |
| `review-prep.md` | `git-workflow-pr` | Prepare for review |
| `review-prep/` (dir) | `git-workflow-pr` | Sub-tasks for review prep |
| `pair-pr-creation.md` | `git-workflow-pr` | Pair mode PR creation |
| `cleanup.md` | `git-workflow-cleanup` | Post-merge cleanup |
| `cleanup/` (dir) | `git-workflow-cleanup` | Sub-tasks for cleanup |
| `pair-cleanup.md` | `git-workflow-cleanup` | Pair mode cleanup |
| `check-pr.md` | `git-workflow-cleanup` | Check PR state |
| `submodule-sync.md` | `git-workflow-cleanup` | Sync submodules |
| `pre-commit-pointer-check.md` | `git-workflow-cleanup` | Check submodule pointers |
| `rebase-pending.md` | `git-workflow-conflict` | Handle rebase conflicts |
| `operating-protocol.md` | `git-workflow-conflict` | Operating protocol |
| `completion.md` | `git-workflow-cleanup` | Workflow completion signal |

## writing-plans (18 task files + 1 directory)

| Task File | Proposed Sub-Skill | Purpose |
|---|---|---|
| `create.md` | `writing-plans-creation` | Create plan from spec |
| `write.md` | `writing-plans-creation` | Write plan content |
| `structure.md` | `writing-plans-creation` | Structure plan phases |
| `solve.md` | `writing-plans-creation` | Z3 solve for plan |
| `research.md` | `writing-plans-creation` | Research for plan |
| `readiness.md` | `writing-plans-creation` | Plan readiness check |
| `pre-plan-readiness.md` | `writing-plans-creation` | Pre-plan readiness |
| `handoffs/` (dir) | `writing-plans-creation` | Spec-to-plan handoff |
| `holistic-self-check.md` | `writing-plans-holistic` | Holistic quality check |
| `audit-fidelity.md` | `writing-plans-holistic` | Plan fidelity audit |
| `audit-concern.md` | `writing-plans-holistic` | Concern separation audit |
| `artifact-validation.md` | `writing-plans-holistic` | Artifact validation |
| `retroactive.md` | `writing-plans-retroactive` | Retroactive plan creation |
| `update.md` | `writing-plans-retroactive` | Update existing plan |
| `revisit.md` | `writing-plans-retroactive` | Revisit and revise plan |
| `operating-protocol.md` | `writing-plans-creation` | Operating protocol |
| `completion.md` | `writing-plans-creation` | Workflow completion signal |
| `clean-room.md` | `writing-plans-creation` | Clean-room execution |
| `validate.md` | `writing-plans-creation` | Plan validation |

## spec-creation (17 task files)

| Task File | Proposed Sub-Skill | Purpose |
|---|---|---|
| `requirements.md` | `spec-creation-requirements` | Extract requirements |
| `traceability.md` | `spec-creation-requirements` | Trace requirements |
| `code-path-analysis.md` | `spec-creation-requirements` | Analyze code paths |
| `decompose.md` | `spec-creation-decomposition` | Decompose problem |
| `concern-analysis.md` | `spec-creation-decomposition` | Analyze concern boundaries |
| `blast-radius.md` | `spec-creation-decomposition` | Analyze blast radius |
| `cross-cutting.md` | `spec-creation-decomposition` | Analyze cross-cutting concerns |
| `interface-compatibility.md` | `spec-creation-decomposition` | Check interface compatibility |
| `state-analysis.md` | `spec-creation-decomposition` | Analyze state transitions |
| `testability-assessment.md` | `spec-creation-decomposition` | Assess testability |
| `pipeline-readiness-gate.md` | `spec-creation-validation` | Pipeline readiness gate |
| `risk.md` | `spec-creation-validation` | Risk analysis |
| `holistic-self-check.md` | `spec-creation-validation` | Holistic quality check |
| `change-control.md` | `spec-creation-change-control` | Change control |
| `create.md` | `spec-creation-change-control` | Create spec |
| `completion.md` | `spec-creation-change-control` | Workflow completion signal |
| `operating-protocol.md` | `spec-creation-change-control` | Operating protocol |
