# Interface Compatibility — Dispatcher Backward Compatibility

## Dispatcher Pattern

Each original skill name becomes a **dispatcher skill** that:
1. Preserves the original `name:` in frontmatter (e.g., `name: issue-operations`)
2. Preserves all original trigger phrases in its description
3. Routes to the appropriate sub-skill via `skill({name: "<sub-skill>"})` + `task()`
4. Contains NO task files — only routing logic

## Backward Compatibility Guarantees

### 1. `skill({name: "issue-operations"})` Still Works

| Before | After |
|---|---|
| `skill({name: "issue-operations"})` loads SKILL.md with all 44 tasks | `skill({name: "issue-operations"})` loads dispatcher SKILL.md that routes to sub-skills |
| `task(..., prompt: "execute creation task from issue-operations")` | `task(..., prompt: "execute creation task from issue-operations-core")` |
| Trigger phrases: "create issue", "comment", "close issue", etc. | Same trigger phrases — dispatcher maps to correct sub-skill |

**Migration path for callers:**
- Old callers using `skill({name: "issue-operations"})` + `task(..., prompt: "execute <task> from issue-operations")` continue to work
- New callers can call sub-skills directly: `skill({name: "issue-operations-core"})` + `task(..., prompt: "execute creation task from issue-operations-core")`
- Dispatcher translates old-style prompts to new-style sub-skill calls

### 2. `skill({name: "approval-gate"})` Still Works

| Before | After |
|---|---|
| `skill({name: "approval-gate"})` loads SKILL.md with all 40 tasks | `skill({name: "approval-gate"})` loads dispatcher SKILL.md that routes to sub-skills |
| `task(..., prompt: "execute verify-authorization from approval-gate")` | `task(..., prompt: "execute verify-authorization from approval-gate-scope")` |
| Trigger phrases: "check authorization", "verify scope", "apply label", etc. | Same trigger phrases — dispatcher maps to correct sub-skill |

### 3. `skill({name: "git-workflow"})` Still Works

| Before | After |
|---|---|
| `skill({name: "git-workflow"})` loads SKILL.md with all 30 tasks | `skill({name: "git-workflow"})` loads dispatcher SKILL.md that routes to sub-skills |
| `task(..., prompt: "execute pre-work task from git-workflow")` | `task(..., prompt: "execute pre-work task from git-workflow-branch")` |
| Trigger phrases: "create branch", "commit", "create PR", "cleanup", etc. | Same trigger phrases — dispatcher maps to correct sub-skill |

### 4. `skill({name: "writing-plans"})` Still Works

| Before | After |
|---|---|
| `skill({name: "writing-plans"})` loads SKILL.md with all 19 tasks | `skill({name: "writing-plans"})` loads dispatcher SKILL.md that routes to sub-skills |
| `task(..., prompt: "execute create task from writing-plans")` | `task(..., prompt: "execute create task from writing-plans-creation")` |
| Trigger phrases: "create plan", "write plan", "holistic check", "retroactive", etc. | Same trigger phrases — dispatcher maps to correct sub-skill |

### 5. `skill({name: "spec-creation"})` Still Works

| Before | After |
|---|---|
| `skill({name: "spec-creation"})` loads SKILL.md with all 17 tasks | `skill({name: "spec-creation"})` loads dispatcher SKILL.md that routes to sub-skills |
| `task(..., prompt: "execute requirements task from spec-creation")` | `task(..., prompt: "execute requirements task from spec-creation-requirements")` |
| Trigger phrases: "create spec", "extract requirements", "blast radius", "change control", etc. | Same trigger phrases — dispatcher maps to correct sub-skill |

## Dispatcher SKILL.md Structure

```yaml
---
name: issue-operations  # Original name preserved
description: "Issue operations dispatcher that routes to sub-skills based on trigger phrases. [Original description preserved for backward compatibility]. User phrases: [all original trigger phrases]."
license: MIT
compatibility: opencode
---

# Skill: issue-operations (Dispatcher)

## Trigger Dispatch Table

| User says / Context | Route to Sub-Skill | Task |
|---|---|---|
| "create issue" / "new issue" | `issue-operations-core` | `creation` |
| "comment" / "add comment" | `issue-operations-comments` | `comment` |
| "link sub-issue" / "add sub-issue" | `issue-operations-sub-issues` | `link-sub-issue` |
| "sync-from-remote" / "reconcile" | `issue-operations-sync` | `sync-from-remote` |
| ... | ... | ... |

## Invocation

`skill({name: "issue-operations"})` — dispatcher routes to sub-skills.
For direct sub-skill access: `skill({name: "issue-operations-core"})`.
```

## External Caller Compatibility

| Caller | Current Call Pattern | After Migration | Compatible? |
|---|---|---|---|
| `implementation-pipeline` SKILL.md | `skill({name: "approval-gate"})`, `skill({name: "git-workflow"})` | Same call — dispatcher routes | Yes |
| `audit` SKILL.md | References `approval-gate` tasks | Same reference — dispatcher routes | Yes |
| `finishing-a-development-branch` | References `git-workflow` | Same reference — dispatcher routes | Yes |
| `AGENTS.md` (root) | Lists skill descriptions | Must update descriptions to reference dispatchers | Update needed |
| `AGENTS.md` (.opencode) | Lists skill descriptions | Must update descriptions to reference dispatchers | Update needed |
| Enforcement tests | `skill({name: "issue-operations"})` | Same call — dispatcher routes | Yes |
| Behavioral tests | `skill({name: "approval-gate"})` | Same call — dispatcher routes | Yes |

## Breaking Changes (Must Update)

| Component | Change Required | Risk |
|---|---|---|
| `implementation-pipeline` SKILL.md Trigger Dispatch Table | Update task references from `approval-gate/tasks/X` to `approval-gate-scope/tasks/X` | Medium — task file paths changed |
| `audit` SKILL.md | Update task references from `approval-gate/tasks/X` to sub-skill paths | Medium |
| `AGENTS.md` files | Update skill descriptions to reference dispatchers | Low — cosmetic |
| `INDEX.md` | Update skill index entries | Low — cosmetic |
| Enforcement test scenarios | Update skill name references in test assertions | Low — test infrastructure |
| `skill-creator/tasks/validate.md` REQ-2 | Must accept Agent-Intent Pattern as valid format | **High — prerequisite fix** |

## Delegation Preservation

| Delegation | Preserved? | Notes |
|---|---|---|
| `git-workflow` → `using-git-worktrees` | Yes | `git-workflow-branch` calls `using-git-worktrees` |
| `git-workflow` → `pr-creation-workflow` | Yes | `git-workflow-pr` calls `pr-creation-workflow` |
| `git-workflow` → `conflict-resolution` | Yes | `git-workflow-conflict` calls `conflict-resolution` |
| `issue-operations` → `github-mcp` | Yes | `issue-operations-core` routes to platform sub-skills |
| `issue-operations` → `gitbucket-api` | Yes | Same — platform routing preserved |
| `issue-operations` → `local` | Yes | Same — platform routing preserved |
