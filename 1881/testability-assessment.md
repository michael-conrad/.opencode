# Testability Assessment — Behavioral Testing per Sub-Skill

## Testing Strategy

Each sub-skill is tested via:
1. **Behavioral tests** (`opencode-cli run` with stderr assertions) — PRIMARY
2. **Content-verification tests** (grep for SKILL.md structure) — SECONDARY
3. **Dispatcher integration tests** (verify routing from original skill name to sub-skill)

## Per Sub-Skill Test Plan

### issue-operations-core (~12 tasks)

| SC | Test Prompt | Expected Behavior | Assertion |
|---|---|---|---|
| Platform dispatch routing | "create issue for .opencode#1881" | Routes to github-mcp/gitbucket-api/local based on platform | `assert_stderr_pattern_present 'Skill "issue-operations-core"'` |
| Issue CRUD | "read issue .opencode#1881" | Calls read-issue task via dispatcher | `assert_stderr_pattern_present 'execute read-issue task from issue-operations-core'` |
| Backward compat | "create issue for .opencode#1881" via `skill({name: "issue-operations"})` | Dispatches to issue-operations-core | `assert_stderr_pattern_present 'Skill "issue-operations-core"'` |

**Test file:** `.opencode/tests/behaviors/issue-operations-core.sh`

### issue-operations-sub-issues (~8 tasks)

| SC | Test Prompt | Expected Behavior | Assertion |
|---|---|---|---|
| Sub-issue linking | "link sub-issue #1882 to parent #1881" | Calls link-sub-issue task | `assert_stderr_pattern_present 'execute link-sub-issue task from issue-operations-sub-issues'` |
| Sub-issue reading | "read sub-issues for .opencode#1881" | Calls read-sub-issues task | `assert_stderr_pattern_present 'execute read-sub-issues task from issue-operations-sub-issues'` |
| Merge verification | "verify merge for .opencode#1881" | Calls verify-merge task | `assert_stderr_pattern_present 'execute verify-merge task from issue-operations-sub-issues'` |

**Test file:** `.opencode/tests/behaviors/issue-operations-sub-issues.sh`

### issue-operations-sync (~8 tasks)

| SC | Test Prompt | Expected Behavior | Assertion |
|---|---|---|---|
| Sync from remote | "sync from remote" | Calls sync-from-remote task | `assert_stderr_pattern_present 'execute sync-from-remote task from issue-operations-sync'` |
| Pull to local | "mirror .opencode#1881 to local" | Calls sync-pull-to-local task | `assert_stderr_pattern_present 'execute sync-pull-to-local task from issue-operations-sync'` |
| Import remote | "import remote issue .opencode#1881" | Calls import-remote task | `assert_stderr_pattern_present 'execute import-remote task from issue-operations-sync'` |

**Test file:** `.opencode/tests/behaviors/issue-operations-sync.sh`

### issue-operations-comments (~6 tasks)

| SC | Test Prompt | Expected Behavior | Assertion |
|---|---|---|---|
| Comment posting | "add comment to .opencode#1881: test comment" | Calls comment task with substantiveness gate | `assert_stderr_pattern_present 'execute comment task from issue-operations-comments'` |
| Comment reading | "read comments for .opencode#1881" | Calls read-comments task | `assert_stderr_pattern_present 'execute read-comments task from issue-operations-comments'` |

**Test file:** `.opencode/tests/behaviors/issue-operations-comments.sh`

### approval-gate-scope (~10 tasks)

| SC | Test Prompt | Expected Behavior | Assertion |
|---|---|---|---|
| Authorization verification | "check authorization for .opencode#1881" | Calls verify-authorization task | `assert_stderr_pattern_present 'execute verify-authorization task from approval-gate-scope'` |
| Scope enforcement | "verify scope for .opencode#1881" | Calls verify-blockers task | `assert_stderr_pattern_present 'execute verify-blockers task from approval-gate-scope'` |
| Backward compat | "check authorization for .opencode#1881" via `skill({name: "approval-gate"})` | Dispatches to approval-gate-scope | `assert_stderr_pattern_present 'Skill "approval-gate-scope"'` |

**Test file:** `.opencode/tests/behaviors/approval-gate-scope.sh`

### approval-gate-labels (~8 tasks)

| SC | Test Prompt | Expected Behavior | Assertion |
|---|---|---|---|
| Label application | "apply approved-for-pr label to .opencode#1881" | Calls column-validation or authorization-context task | `assert_stderr_pattern_present 'execute column-validation task from approval-gate-labels'` |

**Test file:** `.opencode/tests/behaviors/approval-gate-labels.sh`

### approval-gate-revision (~8 tasks)

| SC | Test Prompt | Expected Behavior | Assertion |
|---|---|---|---|
| Revision revocation | "spec .opencode#1881 was revised, check cascade" | Calls gap-fill-cascade or reconcile-issue-graph task | `assert_stderr_pattern_present 'execute gap-fill-cascade task from approval-gate-revision'` |
| Plan pipeline verification | "verify plan pipeline for .opencode#1881" | Calls verify-plan-pipeline task | `assert_stderr_pattern_present 'execute verify-plan-pipeline task from approval-gate-revision'` |

**Test file:** `.opencode/tests/behaviors/approval-gate-revision.sh`

### approval-gate-bug-discovery (~6 tasks)

| SC | Test Prompt | Expected Behavior | Assertion |
|---|---|---|---|
| Bug discovery | "screen issue .opencode#1881 for bugs" | Calls screen-issue task | `assert_stderr_pattern_present 'execute screen-issue task from approval-gate-bug-discovery'` |
| Pre-implementation analysis | "analyze before implementing .opencode#1881" | Calls pre-implementation-analysis task | `assert_stderr_pattern_present 'execute pre-implementation-analysis task from approval-gate-bug-discovery'` |

**Test file:** `.opencode/tests/behaviors/approval-gate-bug-discovery.sh`

### git-workflow-branch (~6 tasks)

| SC | Test Prompt | Expected Behavior | Assertion |
|---|---|---|---|
| Branch creation | "create branch feature/test-split" | Calls pre-work task | `assert_stderr_pattern_present 'execute pre-work task from git-workflow-branch'` |
| Backward compat | "create branch feature/test-split" via `skill({name: "git-workflow"})` | Dispatches to git-workflow-branch | `assert_stderr_pattern_present 'Skill "git-workflow-branch"'` |

**Test file:** `.opencode/tests/behaviors/git-workflow-branch.sh`

### git-workflow-commit (~6 tasks)

| SC | Test Prompt | Expected Behavior | Assertion |
|---|---|---|---|
| Commit | "commit current work" | Calls implementation or commit-prep task | `assert_stderr_pattern_present 'execute implementation task from git-workflow-commit'` |
| Provenance | "check provenance" | Calls provenance task | `assert_stderr_pattern_present 'execute provenance task from git-workflow-commit'` |

**Test file:** `.opencode/tests/behaviors/git-workflow-commit.sh`

### git-workflow-pr (~6 tasks)

| SC | Test Prompt | Expected Behavior | Assertion |
|---|---|---|---|
| PR creation | "create PR for current branch" | Calls pr-creation task | `assert_stderr_pattern_present 'execute pr-creation task from git-workflow-pr'` |
| Review prep | "prepare review" | Calls review-prep task | `assert_stderr_pattern_present 'execute review-prep task from git-workflow-pr'` |

**Test file:** `.opencode/tests/behaviors/git-workflow-pr.sh`

### git-workflow-cleanup (~6 tasks)

| SC | Test Prompt | Expected Behavior | Assertion |
|---|---|---|---|
| Cleanup | "cleanup after merge" | Calls cleanup task | `assert_stderr_pattern_present 'execute cleanup task from git-workflow-cleanup'` |
| Check PR | "check merged PRs" | Calls check-pr task | `assert_stderr_pattern_present 'execute check-pr task from git-workflow-cleanup'` |
| Submodule sync | "sync submodules" | Calls submodule-sync task | `assert_stderr_pattern_present 'execute submodule-sync task from git-workflow-cleanup'` |

**Test file:** `.opencode/tests/behaviors/git-workflow-cleanup.sh`

### git-workflow-conflict (~6 tasks)

| SC | Test Prompt | Expected Behavior | Assertion |
|---|---|---|---|
| Conflict resolution | "resolve rebase conflict" | Calls rebase-pending task | `assert_stderr_pattern_present 'execute rebase-pending task from git-workflow-conflict'` |

**Test file:** `.opencode/tests/behaviors/git-workflow-conflict.sh`

### writing-plans-creation (~7 tasks)

| SC | Test Prompt | Expected Behavior | Assertion |
|---|---|---|---|
| Plan creation | "create plan for .opencode#1881" | Calls create task | `assert_stderr_pattern_present 'execute create task from writing-plans-creation'` |
| Backward compat | "create plan for .opencode#1881" via `skill({name: "writing-plans"})` | Dispatches to writing-plans-creation | `assert_stderr_pattern_present 'Skill "writing-plans-creation"'` |

**Test file:** `.opencode/tests/behaviors/writing-plans-creation.sh`

### writing-plans-holistic (~6 tasks)

| SC | Test Prompt | Expected Behavior | Assertion |
|---|---|---|---|
| Holistic check | "run holistic check on plan for .opencode#1881" | Calls holistic-self-check task | `assert_stderr_pattern_present 'execute holistic-self-check task from writing-plans-holistic'` |

**Test file:** `.opencode/tests/behaviors/writing-plans-holistic.sh`

### writing-plans-retroactive (~6 tasks)

| SC | Test Prompt | Expected Behavior | Assertion |
|---|---|---|---|
| Retroactive plan | "create retroactive plan for .opencode#1881" | Calls retroactive task | `assert_stderr_pattern_present 'execute retroactive task from writing-plans-retroactive'` |
| Plan update | "update plan for .opencode#1881" | Calls update task | `assert_stderr_pattern_present 'execute update task from writing-plans-retroactive'` |

**Test file:** `.opencode/tests/behaviors/writing-plans-retroactive.sh`

### spec-creation-requirements (~5 tasks)

| SC | Test Prompt | Expected Behavior | Assertion |
|---|---|---|---|
| Requirements extraction | "extract requirements for .opencode#1881" | Calls requirements task | `assert_stderr_pattern_present 'execute requirements task from spec-creation-requirements'` |
| Backward compat | "extract requirements for .opencode#1881" via `skill({name: "spec-creation"})` | Dispatches to spec-creation-requirements | `assert_stderr_pattern_present 'Skill "spec-creation-requirements"'` |

**Test file:** `.opencode/tests/behaviors/spec-creation-requirements.sh`

### spec-creation-decomposition (~5 tasks)

| SC | Test Prompt | Expected Behavior | Assertion |
|---|---|---|---|
| Problem decomposition | "decompose problem for .opencode#1881" | Calls decompose task | `assert_stderr_pattern_present 'execute decompose task from spec-creation-decomposition'` |
| Blast radius | "analyze blast radius for .opencode#1881" | Calls blast-radius task | `assert_stderr_pattern_present 'execute blast-radius task from spec-creation-decomposition'` |

**Test file:** `.opencode/tests/behaviors/spec-creation-decomposition.sh`

### spec-creation-validation (~4 tasks)

| SC | Test Prompt | Expected Behavior | Assertion |
|---|---|---|---|
| Pipeline readiness | "check pipeline readiness for .opencode#1881" | Calls pipeline-readiness-gate task | `assert_stderr_pattern_present 'execute pipeline-readiness-gate task from spec-creation-validation'` |
| Risk analysis | "analyze risk for .opencode#1881" | Calls risk task | `assert_stderr_pattern_present 'execute risk task from spec-creation-validation'` |

**Test file:** `.opencode/tests/behaviors/spec-creation-validation.sh`

### spec-creation-change-control (~3 tasks)

| SC | Test Prompt | Expected Behavior | Assertion |
|---|---|---|---|
| Change control | "update change control for .opencode#1881" | Calls change-control task | `assert_stderr_pattern_present 'execute change-control task from spec-creation-change-control'` |

**Test file:** `.opencode/tests/behaviors/spec-creation-change-control.sh`

## Dispatcher Integration Tests

Beyond individual sub-skill tests, integration tests verify that dispatchers correctly route:

| Test | Prompt | Expected Sub-Skill Dispatch |
|---|---|---|
| issue-operations dispatcher | "create issue" | `issue-operations-core` |
| issue-operations dispatcher | "add comment" | `issue-operations-comments` |
| issue-operations dispatcher | "link sub-issue" | `issue-operations-sub-issues` |
| issue-operations dispatcher | "sync from remote" | `issue-operations-sync` |
| approval-gate dispatcher | "check authorization" | `approval-gate-scope` |
| approval-gate dispatcher | "apply label" | `approval-gate-labels` |
| approval-gate dispatcher | "spec revised" | `approval-gate-revision` |
| approval-gate dispatcher | "screen issue" | `approval-gate-bug-discovery` |
| git-workflow dispatcher | "create branch" | `git-workflow-branch` |
| git-workflow dispatcher | "commit" | `git-workflow-commit` |
| git-workflow dispatcher | "create PR" | `git-workflow-pr` |
| git-workflow dispatcher | "cleanup" | `git-workflow-cleanup` |
| git-workflow dispatcher | "rebase conflict" | `git-workflow-conflict` |
| writing-plans dispatcher | "create plan" | `writing-plans-creation` |
| writing-plans dispatcher | "holistic check" | `writing-plans-holistic` |
| writing-plans dispatcher | "retroactive plan" | `writing-plans-retroactive` |
| spec-creation dispatcher | "extract requirements" | `spec-creation-requirements` |
| spec-creation dispatcher | "decompose problem" | `spec-creation-decomposition` |
| spec-creation dispatcher | "pipeline readiness" | `spec-creation-validation` |
| spec-creation dispatcher | "change control" | `spec-creation-change-control` |

**Integration test file:** `.opencode/tests/behaviors/skill-split-dispatcher-integration.sh`

## Content-Verification Tests

| SC | Assertion |
|---|---|
| All 20 sub-skills have SKILL.md with valid frontmatter | `grep -r "^name:" .opencode/skills/*/SKILL.md` |
| All 5 dispatchers have routing table | `grep -r "Trigger Dispatch Table" .opencode/skills/{issue-operations,approval-gate,git-workflow,writing-plans,spec-creation}/SKILL.md` |
| All sub-skill descriptions ≤1024 chars | `wc -c` on each description field |
| All sub-skill descriptions follow Agent-Intent Pattern | `grep -c "Dispatch when"` per description |
| No sub-skill has >15 tasks | Count task files per sub-skill directory |

**Content-verification scenario:** `.opencode/tests/scenarios/skill-split-structure.yaml`

## Test Execution Order

```
1. Content-verification tests (fast, structural)
2. Behavioral tests per sub-skill (parallelizable)
3. Dispatcher integration tests (sequential — each tests routing)
4. Full regression: existing behavioral tests still pass with dispatchers
```
