---
name: pr-creation-workflow
description: Use when asking about when to create a PR or whether PR creation is authorized. Triggers on: create PR, make PR, pull request, PR timing, when to PR, PR authorized. Feature branch PRs targeting dev only. Release PRs handled by git-workflow --task release-promotion.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# PR Creation Workflow

## Overview

PR creation is a DISTINCT phase requiring EXPLICIT instruction — NOT automatic after implementation. "Approved"/"go" authorize implementation only, not PR creation (unless `authorization_scope >= for_pr`).

Feature PRs target `dev` only. Release PRs (dev→main) handled by `git-workflow --task release-promotion`.

## Tasks

| Task | Words |
|------|-------|
| `pre-pr-checklist` | ≈500 |
| `sub-issue-collection` | ≈300 |
| `completion` | ≈200 |

## Invocation

`skill({name: "pr-creation-workflow"})` — load the skill, then dispatch a task:

| Task | Dispatch |
|------|----------|
| `pre-pr-checklist` | `task(..., prompt: "execute pre-pr-checklist task from pr-creation-workflow")` |
| `sub-issue-collection` | `task(..., prompt: "execute sub-issue-collection task from pr-creation-workflow")` |
| `completion` | `task(..., prompt: "execute completion task from pr-creation-workflow")` |

**CLI equivalent (for human TUI use):** `/skill pr-creation-workflow --task <task>`

## Operating Protocol

1. **Explicit instruction required** unless `authorization_scope >= for_pr`.
2. **Base branch = dev** for feature PRs.
3. **Squash verified** before PR (single commit for single-issue).
4. **Changelog generated** before PR.
5. **Adversarial-audit invocation:** after pre-pr-checklist, invoke `adversarial-audit --task spec-summary --pr <N>` with `audit_phase: pr_creation`.
6. **No agent merge** — human-only operation.
7. **Work branch guard:** no individual PRs during work execution (single stacked PR).
8. **Submodule-bump-only PR block (MANDATORY — parent repo context):** Before creating any PR, check whether the diff contains changes outside `.opencode/`. In a parent repo with `.gitmodules`, a PR that only changes `.opencode/` (submodule pointer bump) is BLOCKED by enforcement gate `pr-workflow-003`. The agent MUST NOT create, propose, or assist in creating a submodule-bump-only PR. This is a CRITICAL GUIDELINE VIOLATION — bypassing this gate results in a HALT.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ branch_name, worktree.path, github.owner, github.repo, authorization_scope, halt_at, pr_strategy, pipeline_phase }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo }`. No inline work.

### Authorization Context
```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|implementation_complete|review_prep|pr_created>
pr_strategy: <none|individual|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Dispatch Rules
- Missing `authorization_scope` in dispatch context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Cross-References

Skills: `git-workflow`, `changelog-generator`, `adversarial-audit --task spec-summary`. Guidelines: `000-critical-rules.md` (Step 0.5 enforcement gate).

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: pr-workflow-001
    title: "PR requires explicit instruction — approved does NOT authorize PR"
    conditions:
      all: ["pr_creation_attempted == true", "authorization_scope < for_pr"]
    actions: [HALT]
    source: "pr-creation-workflow/SKILL.md"

  - id: pr-workflow-002
    title: "Base branch must be dev for feature PRs"
    conditions:
      all: ["pr_type == 'feature'", "base_branch != 'dev'"]
    actions: [HALT]
    source: "pr-creation-workflow/SKILL.md"

  - id: pr-workflow-003
    title: "Submodule-bump-only PRs are BLOCKED — parent repo enforcement gate"
    conditions:
      all:
        - "github.identity_source == 'root'"
        - ".gitmodules exists"
        - "pr_creation_attempted == true"
        - "git diff shows only .opencode changed"
    actions: [BLOCK]
    source: "pr-creation-workflow/SKILL.md"
