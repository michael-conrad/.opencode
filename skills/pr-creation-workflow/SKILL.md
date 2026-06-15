---
name: pr-creation-workflow
description: "Use when asking about when to create a PR or whether PR creation is authorized. Every PR must be an authorized, intentional delivery."
type: discipline-enforcing
license: MIT
compatibility: opencode
---

# PR Creation Workflow

## Overview

PR creation is a DISTINCT phase requiring EXPLICIT instruction — NOT automatic after implementation. "Approved"/"go" authorize implementation only, not PR creation (unless `authorization_scope >= for_pr`).

Feature PRs target `dev` only. Release PRs (dev→main) handled by `git-workflow --task release-promotion`.



## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "pre-pr-checklist" / "PR checklist" | `pre-pr-checklist` | `sub-task` | {branch_name} |
| "sub-issue-collection" / "collect sub-issues" | `sub-issue-collection` | `sub-task` | {issue_number} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Tasks


| `pre-pr-checklist` |
| `sub-issue-collection` |
| `completion` |

## Invocation

`skill({name: "pr-creation-workflow"})` — call the skill, then call via task():

| Task | Call via task() |

| `pre-pr-checklist` | `task(..., prompt: "execute pre-pr-checklist task from pr-creation-workflow")` |
| `sub-issue-collection` | `task(..., prompt: "execute sub-issue-collection task from pr-creation-workflow")` |
| `completion` | `task(..., prompt: "execute completion task from pr-creation-workflow")` |

**CLI equivalent (for human TUI use):** `/skill pr-creation-workflow --task <task>`

## Operating Protocol

- [ ] 1. **Explicit instruction required** unless `authorization_scope >= for_pr`.
- [ ] 2. **Base branch = dev** for feature PRs.
- [ ] 3. **Squash verified** before PR (single commit for single-issue).
- [ ] 4. **Changelog generated** before PR.
- [ ] 5. **Adversarial-audit call:** after pre-pr-checklist, call `adversarial-audit --task spec-summary --pr <N>` with `audit_phase: pr_creation`.
- [ ] 6. **No agent merge** — human-only operation.
- [ ] 7. **Work branch guard:** no individual PRs during work execution (single stacked PR).
- [ ] 8. **Submodule-bump-only PR block (MANDATORY — parent repo context):** Before creating any PR, check whether the diff contains changes outside `.opencode/`. In a parent repo with `.gitmodules`, a PR that only changes `.opencode/` (submodule pointer bump) is BLOCKED by enforcement gate `pr-workflow-003`. The agent MUST NOT create, propose, or assist in creating a submodule-bump-only PR. This is a CRITICAL GUIDELINE VIOLATION — bypassing this gate results in a HALT.

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ branch_name, worktree.path, github.owner, github.repo, authorization_scope, halt_at, pr_strategy, pipeline_phase }`. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo }`. No inline work.

### Authorization Context
```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Routing Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** The orchestrator's context is the most expensive resource in the pipeline — sub-agents do the work, not the orchestrator. Every byte held by the orchestrator costs `byte × remaining_dispatches²`. See `020-go-prohibitions.md` §1.1.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read cleanup/branch-cleanup.md then execute step 1" | "execute cleanup task from git-workflow" |
| Preloaded step sequences | "Step 1: sync dev. Step 2: delete branch." | "execute cleanup task from git-workflow" |
| Preloaded expected outcomes | "Return { cleanup_status, branch_deleted }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The merge was just completed so we need to..." | Pure objective, no narrative |

#### Dispatch Context Contract

Every `task()` call MUST include only:

- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
- `pr_strategy`
- `pipeline_phase`

Plus skill-specific fields per the `## Sub-Agent Routing` section above.

Exclusions (MUST NOT be in prompt):
- `orchestrator_reasoning`
- `expected_outcomes`
- `inline_file_paths`
- `agent_memory`
- `cached_verification_results`

#### Sub-Agent Entry Criteria

A sub-agent receiving a `task()` prompt MUST reject it if the prompt contains:
- Inline file paths to task files
- Inline step or procedure definitions
- Expected outcome structures or schema constraints
- Pre-loaded evidence or orchestrator-derived conclusions

Return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

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
