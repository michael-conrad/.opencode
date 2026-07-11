# Cross-Cutting Matrix — Concerns Shared Across Sub-Skills

## Shared Completion Protocol

| Sub-Skill | Uses `completion-core`? | Notes |
|---|---|---|
| All 20 sub-skills | Yes | Every sub-skill needs a completion task that signals workflow end. Must share `completion-core` skill for push, URL generation, lifecycle events. |

**Resolution:** `completion-core` skill remains unchanged. Each sub-skill's completion task calls `completion-core` via `task()`.

## Shared Platform Dispatch

| Sub-Skill | Uses Platform Dispatch? | Notes |
|---|---|---|
| `issue-operations-core` | Yes | Core CRUD routes to github-mcp/gitbucket-api/local |
| `issue-operations-sub-issues` | Yes | Sub-issue operations route to platform |
| `issue-operations-sync` | Yes | Sync operations route to platform |
| `issue-operations-comments` | Yes | Comment operations route to platform |
| All other sub-skills | No | Do not interact with issue platforms |

**Resolution:** Platform sub-skills (`github-mcp`, `gitbucket-api`, `local`) remain unchanged. All 4 `issue-operations-*` sub-skills import the same platform routing logic. Consider extracting platform routing into a shared utility.

## Shared Authorization Verification

| Sub-Skill | Uses Authorization? | Notes |
|---|---|---|
| `approval-gate-scope` | Yes (primary) | Core authorization scope verification |
| `approval-gate-labels` | Yes | Label-based authorization state |
| `approval-gate-revision` | Yes | Revision revocation of authorization |
| `approval-gate-bug-discovery` | Yes | Bug discovery protocol (authorization boundary) |
| `implementation-pipeline` | Yes | References approval-gate for authorization checks |
| `git-workflow-pr` | Yes | PR creation requires authorization scope check |

**Resolution:** `approval-gate-scope` becomes the canonical authorization verifier. Other approval-gate sub-skills delegate scope checks to it. External skills (implementation-pipeline, git-workflow-pr) call `approval-gate-scope` directly.

## Shared Label Management

| Sub-Skill | Uses Labels? | Notes |
|---|---|---|
| `approval-gate-labels` | Yes (primary) | `approved-for-*` label management |
| `issue-operations-core` | Yes | CRUD operations read/update labels |
| `git-workflow-cleanup` | Yes | Removes `approved-for-*` labels on cleanup |

**Resolution:** `approval-gate-labels` owns the label policy. `issue-operations-core` and `git-workflow-cleanup` call it for label mutations. No label logic duplicated.

## Shared Submodule Management

| Sub-Skill | Uses Submodules? | Notes |
|---|---|---|
| `git-workflow-branch` | Yes | Pre-work syncs submodules |
| `git-workflow-cleanup` | Yes | Cleanup handles submodule pointers |
| `git-workflow-commit` | Yes | Pre-commit pointer check |

**Resolution:** Submodule sync logic stays in `git-workflow-cleanup` (primary). `git-workflow-branch` and `git-workflow-commit` delegate to cleanup for submodule operations.

## Shared Pair Mode

| Sub-Skill | Uses Pair Mode? | Notes |
|---|---|---|
| `git-workflow-branch` | Yes | `pair-pre-work`, `pair-mode-resume` |
| `git-workflow-commit` | Yes | `pair-commit` |
| `git-workflow-pr` | Yes | `pair-pr-creation` |
| `git-workflow-cleanup` | Yes | `pair-cleanup` |

**Resolution:** Pair mode tasks stay with their respective sub-skills. No shared pair-mode utility needed — each sub-skill has its own pair variant.

## Shared Audit Integration

| Sub-Skill | Uses Audit Skill? | Notes |
|---|---|---|
| `approval-gate-scope` | Yes | Authorization audit |
| `approval-gate-revision` | Yes | Revision audit |
| `writing-plans-holistic` | Yes | Plan fidelity/concern audits |
| `spec-creation-validation` | Yes | Spec quality audit |

**Resolution:** All sub-skills call `audit` skill via `skill({name: "audit"})`. No change needed — audit skill remains independent.

## Shared Verification Integration

| Sub-Skill | Uses Verification? | Notes |
|---|---|---|
| `approval-gate-scope` | Yes | Verify authorization state |
| `approval-gate-revision` | Yes | Verify revision completeness |
| `writing-plans-holistic` | Yes | Verify plan quality |
| `spec-creation-validation` | Yes | Verify spec quality |
| `git-workflow-cleanup` | Yes | Verify merge state |

**Resolution:** All sub-skills call `verification-before-completion` or `verification` skill. No change needed.

## Shared Analytical Artifact Format

| Sub-Skill | Produces/Consumes Artifacts? | Notes |
|---|---|---|
| `spec-creation-decomposition` | Produces | Creates blast-radius, concern-map, cross-cutting, etc. |
| `writing-plans-creation` | Consumes | Reads analytical artifacts for plan creation |
| `spec-creation-validation` | Consumes | Validates artifact completeness |

**Resolution:** Artifact format (YAML frontmatter + markdown body) is shared convention. `writing-plans-creation` validates artifact presence before plan creation. This cross-cutting concern is already documented in writing-plans SKILL.md §Mandatory Task Discipline item 8.

## Shared Dispatcher Pattern

| Original Skill | Sub-Skills | Dispatcher Needed? |
|---|---|---|
| `issue-operations` | 4 | Yes — routes to sub-skill based on trigger phrase |
| `approval-gate` | 4 | Yes — routes to sub-skill based on trigger phrase |
| `git-workflow` | 5 | Yes — routes to sub-skill based on trigger phrase |
| `writing-plans` | 3 | Yes — routes to sub-skill based on trigger phrase |
| `spec-creation` | 4 | Yes — routes to sub-skill based on trigger phrase |

**Resolution:** Each dispatcher SKILL.md contains a Trigger Dispatch Table mapping user phrases to sub-skills. Dispatchers are thin — they do NOT contain task files, only routing logic. This is a new pattern (no existing dispatcher skills in the codebase).
