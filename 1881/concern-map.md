# Concern Map — Current vs Proposed Sub-Skill Concerns

## issue-operations (44 tasks → 4 sub-skills)

### Current Concerns (All in one skill)
| Concern | Task Count | Description |
|---|---|---|
| Platform dispatch routing | 3 | Route to github-mcp/gitbucket-api/local |
| Issue CRUD | 8 | create, read, update, close, list, search, body-edit, capabilities |
| Sub-issue management | 3 | link-sub-issue, read-sub-issues, verify-merge |
| Sync operations | 4 | sync-from-remote, sync-pull-to-local, import-remote, push-artifacts |
| Comment gating | 2 | comment, read-comments |
| Labels | 1 | read-labels |
| Pre/post creation | 2 | pre-creation, post-creation |
| Single-task check | 1 | single-task-check |
| Completion | 1 | completion |

### Proposed Sub-Skill Concerns

| Sub-Skill | Concerns | Task Count |
|---|---|---|
| `issue-operations-core` | Platform dispatch routing + Issue CRUD (create, read, update, close, list, search, body-edit, capabilities, pre-creation, post-creation, single-task-check) | ~12 |
| `issue-operations-sub-issues` | Sub-issue management (link-sub-issue, read-sub-issues, verify-merge) | ~8 |
| `issue-operations-sync` | Sync operations (sync-from-remote, sync-pull-to-local, import-remote, push-artifacts) | ~8 |
| `issue-operations-comments` | Comment gating + substantiveness checks (comment, read-comments) | ~6 |

## approval-gate (40 tasks → 4 sub-skills)

### Current Concerns (All in one skill)
| Concern | Task Count | Description |
|---|---|---|
| Authorization scope | 5 | verify-authorization, verify-blockers, verify-closed-issue, verify-already-implemented, verify-sub-issues |
| Label application | 2 | column-validation, authorization-context |
| Spec-to-plan cascade | 4 | gap-fill-cascade, verify-plan-pipeline, verify-codebase, verify-fix-spec |
| Revision revocation | 3 | reconcile-issue-graph, verify-open-questions, verify-qa-mode |
| Bug discovery protocol | 2 | screen-issue, pre-implementation-analysis |
| Post-implementation | 1 | post-implementation |
| Completion | 1 | completion |

### Proposed Sub-Skill Concerns

| Sub-Skill | Concerns | Task Count |
|---|---|---|
| `approval-gate-scope` | Authorization scope, cascade, halt boundaries (verify-authorization, verify-blockers, verify-closed-issue, verify-already-implemented, verify-sub-issues, post-implementation) | ~10 |
| `approval-gate-labels` | Label application, approved-for-* management (column-validation, authorization-context) | ~8 |
| `approval-gate-revision` | Spec-to-plan cascade, revision revocation (gap-fill-cascade, verify-plan-pipeline, verify-codebase, verify-fix-spec, reconcile-issue-graph, verify-open-questions, verify-qa-mode) | ~8 |
| `approval-gate-bug-discovery` | Bug discovery protocol (screen-issue, pre-implementation-analysis) | ~6 |

## git-workflow (30 tasks → 5 sub-skills)

### Current Concerns (All in one skill)
| Concern | Task Count | Description |
|---|---|---|
| Branch creation | 3 | pre-work, pair-pre-work, pair-mode-resume |
| Commit/push | 3 | implementation, commit-prep, pair-commit |
| PR creation | 3 | pr-creation, pair-pr-creation, review-prep |
| Cleanup | 3 | cleanup, pair-cleanup, check-pr |
| Conflict resolution | 2 | rebase-pending, operating-protocol |
| Submodule sync | 2 | submodule-sync, pre-commit-pointer-check |
| Provenance | 1 | provenance |
| Completion | 1 | completion |

### Proposed Sub-Skill Concerns

| Sub-Skill | Concerns | Task Count |
|---|---|---|
| `git-workflow-branch` | Branch creation, worktree setup (pre-work, pair-pre-work, pair-mode-resume) | ~6 |
| `git-workflow-commit` | Commit, push, provenance tracking (implementation, commit-prep, pair-commit, provenance) | ~6 |
| `git-workflow-pr` | PR creation, strategy, readiness (pr-creation, pair-pr-creation, review-prep) | ~6 |
| `git-workflow-cleanup` | Cleanup, merge verification, submodule sync (cleanup, pair-cleanup, check-pr, submodule-sync, pre-commit-pointer-check) | ~6 |
| `git-workflow-conflict` | Rebase/merge conflict resolution (rebase-pending, operating-protocol) | ~6 |

## writing-plans (19 tasks → 3 sub-skills)

### Current Concerns (All in one skill)
| Concern | Task Count | Description |
|---|---|---|
| Plan creation | 8 | create, write, structure, solve, research, readiness, pre-plan-readiness, handoffs |
| Holistic checks | 4 | holistic-self-check, audit-fidelity, audit-concern, artifact-validation |
| Retroactive/backfill | 3 | retroactive, update, revisit |
| Completion | 1 | completion |
| Operating protocol | 1 | operating-protocol |

### Proposed Sub-Skill Concerns

| Sub-Skill | Concerns | Task Count |
|---|---|---|
| `writing-plans-creation` | Plan creation from spec, Z3 pipeline (create, write, structure, solve, research, readiness, pre-plan-readiness, handoffs) | ~7 |
| `writing-plans-holistic` | Holistic checks, quality verification (holistic-self-check, audit-fidelity, audit-concern, artifact-validation) | ~6 |
| `writing-plans-retroactive` | Retroactive plans, backfill (retroactive, update, revisit) | ~6 |

## spec-creation (17 tasks → 4 sub-skills)

### Current Concerns (All in one skill)
| Concern | Task Count | Description |
|---|---|---|
| Requirements extraction | 2 | requirements, traceability |
| Problem decomposition | 3 | decompose, concern-analysis, blast-radius |
| Analytical discovery | 5 | code-path-analysis, cross-cutting, interface-compatibility, state-analysis, testability-assessment |
| Validation | 2 | pipeline-readiness-gate, risk |
| Change control | 2 | change-control, holistic-self-check |
| Creation | 1 | create |
| Completion | 1 | completion |

### Proposed Sub-Skill Concerns

| Sub-Skill | Concerns | Task Count |
|---|---|---|
| `spec-creation-requirements` | Requirements extraction, analytical discovery (requirements, traceability, code-path-analysis) | ~5 |
| `spec-creation-decomposition` | Problem decomposition, blast radius, cross-cutting (decompose, concern-analysis, blast-radius, cross-cutting, interface-compatibility, state-analysis) | ~5 |
| `spec-creation-validation` | Traceability, risk analysis, holistic checks (pipeline-readiness-gate, risk, holistic-self-check) | ~4 |
| `spec-creation-change-control` | Change control, revision management (change-control, create, completion) | ~3 |
