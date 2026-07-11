# Blast Radius Analysis — Skill Split for Issue #1881

## Affected Skills (5 overloaded → 20 sub-skills + 5 dispatchers)

| Original Skill | Sub-Skills Created | Blast Radius |
|---|---|---|
| `issue-operations` | `issue-operations-core`, `issue-operations-sub-issues`, `issue-operations-sync`, `issue-operations-comments` | 4 new SKILL.md + ~34 task files migrated |
| `approval-gate` | `approval-gate-scope`, `approval-gate-labels`, `approval-gate-revision`, `approval-gate-bug-discovery` | 4 new SKILL.md + ~20 task files migrated |
| `git-workflow` | `git-workflow-branch`, `git-workflow-commit`, `git-workflow-pr`, `git-workflow-cleanup`, `git-workflow-conflict` | 5 new SKILL.md + ~16 task files migrated |
| `writing-plans` | `writing-plans-creation`, `writing-plans-holistic`, `writing-plans-retroactive` | 3 new SKILL.md + ~12 task files migrated |
| `spec-creation` | `spec-creation-requirements`, `spec-creation-decomposition`, `spec-creation-validation`, `spec-creation-change-control` | 4 new SKILL.md + ~12 task files migrated |

## Cross-Referencing Skills (Must Update Dispatch Tables)

| Skill | Reason for Impact |
|---|---|
| `implementation-pipeline` | Trigger Dispatch Table references `approval-gate`, `git-workflow`, `writing-plans`, `spec-creation` by name — must update to reference dispatchers |
| `audit` | References `approval-gate` tasks for spec-audit pipeline — must update routing |
| `completion-core` | Shared completion operations referenced by all 5 overloaded skills — must ensure sub-skills can still call completion |
| `skill-creator` | Validation task (`validate.md`) must accept Agent-Intent Pattern (not just Farmage) — prerequisite fix |
| `pr-creation-workflow` | `git-workflow` delegates PR creation here — no change needed (delegation preserved) |
| `conflict-resolution` | `git-workflow` delegates conflict resolution here — no change needed |
| `using-git-worktrees` | `git-workflow-branch` delegates worktree setup here — no change needed |

## Task Files Affected (Direct Migration)

| Original Location | Migrated To |
|---|---|
| `issue-operations/tasks/*` (21 files) | Split across 4 sub-skills |
| `approval-gate/tasks/*` (16 files + 3 dirs) | Split across 4 sub-skills |
| `git-workflow/tasks/*` (16 files + 4 dirs) | Split across 5 sub-skills |
| `writing-plans/tasks/*` (18 files + 1 dir) | Split across 3 sub-skills |
| `spec-creation/tasks/*` (17 files) | Split across 4 sub-skills |

## Enforcement Tests Affected

| Test File | Impact |
|---|---|
| `.opencode/tests/test-enforcement.sh` | Content-verification scenarios reference skill names — must update to reference dispatchers |
| `.opencode/tests/behaviors/*.sh` | Behavioral tests that `skill({name: "issue-operations"})` etc. — must still work via dispatcher |
| Any test with `--tag skill-issue-operations` etc. | Tag-based filtering must be updated or aliased |

## Guidelines Affected

| Guideline | Impact |
|---|---|
| `000-critical-rules.md` | References `approval-gate` skill by name in multiple rules — must update references |
| `010-approval-gate.md` | References `approval-gate` skill — must update |
| `080-code-stdards.md` | References `writing-plans`, `spec-creation` — must update |
| `INDEX.md` | Skill descriptions in index reference overloaded skills — must update |

## AGENTS.md Files Affected

| File | Impact |
|---|---|
| Root `AGENTS.md` | References `issue-operations`, `approval-gate`, `git-workflow`, `writing-plans`, `spec-creation` in skill descriptions — must update |
| `.opencode/AGENTS.md` | Same references — must update |
| Each overloaded skill's `AGENTS.md` | Must be updated or replaced with dispatcher AGENTS.md |

## No Impact (Out of Scope)

| Component | Reason |
|---|---|
| `issue-operations/platforms/github-mcp` | Already focused, not split |
| `issue-operations/platforms/gitbucket-api` | Already focused, not split |
| `issue-operations/platforms/local` | Already focused, not split |
| `brainstorming` | Not in scope of split |
| `verification-before-completion` | Not in scope of split |
| `finishing-a-development-branch` | Not in scope of split |
| `opencode.jsonc` | Skill registration — may need update if sub-skills need explicit registration |
