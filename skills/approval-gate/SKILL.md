---
name: approval-gate
description: "Use when checking or enforcing authorization scope, approval cascade, and pipeline halt boundaries. Triggers on: approved, go, authorization, approve, approval-gate, spec-before-code. Implementing without authorization produces unreviewed, unapproved code — the fastest path to rework."
license: MIT
compatibility: opencode
---

Sub-Agent Task Context Audit

All tasks run via `task(subagent_type="general")`. Standard context: `{ issue_number, worktree.path, github.owner, github.repo, authorization_scope, halt_at, pr_strategy, pipeline_phase }`. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. `screen-issue` receives issue body + authorization context + pipeline_phase. `pre-implementation-analysis` receives all issue numbers + authorization context + pipeline_phase. `pre-analysis` receives only `{ issue_number, task_description, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo }` with zero file paths. No inline work — all tasks use sub-agents. If a sub-agent returns empty, re-task with original scoped context only (max 2 retries). Result contracts return `status` (DONE/BLOCKED/DONE_WITH_CONCERNS/OVERFLOW) + task-specific fields per `enforcement/` result contract schemas.

### Authorization Context Template
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
- The `pipeline_phase` field is NEW — it tracks which phase of a multi-phase plan is currently executing

### Column Validation Rules (Pre-Approval Gate Expansion)

The pre-approval gate validates the following columns in the spec's SC table. Each rule produces PASS or BLOCK with reason.

| Column | Validation Rule | Block On | Apply To |
|--------|----------------|----------|----------|
| Pipeline Step Binding | Every SC MUST have a valid pipeline step binding matching a step in `implementation-pipeline` dispatch table | Missing, invalid, or misspelled step name | All specs |
| Re-Entry Step | Every SC MUST declare a re-entry step. For single-task specs, may be `null`. For multi-phase, MUST reference a valid step within the bound phase | Missing for multi-phase, or references step outside phase scope | All specs |
| Verification Gate | Every SC's Verification Gate MUST be consistent with its Evidence Type per the Evidence Type Taxonomy: `behavioral` → pre-commit, `semantic` → pre-PR, `string` → CI, `structural` → none | EVIDENCE_TYPE_MISMATCH — behavioral SC with CI gate, etc. | All specs |
| Artifact Path | Every SC with a non-structural evidence type MUST declare an artifact path. Structural SCs MAY omit | Missing when evidence type is behavioral/semantic/string | All specs |
| Phase Binding | Every SC MUST declare a phase binding matching a phase in the spec's Phase section. Cross-cutting SCs use `common` | Phase name not found in spec phases, or `common` used for non-cross-cutting SC | Multi-phase specs only |

### Pre-Approval Gate Column Validation

When running the pre-approval gate for standard/complex specs, validate the following columns in the SC table:

| Column | Validation Rule | Error on Violation |
|--------|----------------|---------------------|
| Pipeline Step Binding | MUST specify which pipeline step validates this SC | BLOCK |
| Re-Entry Step | MUST specify re-entry point on verification failure | BLOCK |
| Verification Gate | MUST be one of: red-green, pre-commit, ci | BLOCK |
| Artifact Path | MUST use `./tmp/{issue-N}/` convention | BLOCK |
| Phase Binding | MUST annotate phase for multi-phase specs | FLAG (conditional) |

For `for_spec` scope, only minimal-tier requirements enforced (Pipeline Step Binding, Re-Entry Step).

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

Skills: `git-workflow`, `pr-creation-workflow`, `issue-review`, `implementation-pipeline`, `writing-plans`, `executing-plans`, `pre-analysis`. Guidelines: `010-approval-gate.md`, `000-critical-rules.md`, `065-verification-honesty.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: approval-gate-skill-001
    title: "Pre-implementation authorization verification required"
    conditions:
      all: ["spec_exists == true", "user_authorized == false"]
    actions: [HALT]
    triggers: [git-workflow]
    source: "approval-gate/SKILL.md"

  - id: approval-gate-skill-002
    title: "Multi-task cascade extends authorization from plan to all sub-issues"
    conditions:
      all: ["plan_has_sub_issues == true", "user_authorized == true"]
    actions: [PROCEED]
    triggers: [implementation-pipeline, executing-plans]
    source: "approval-gate/SKILL.md"

  - id: approval-gate-skill-005
    title: "Spec-to-plan approval cascade — spec approves existing plan"
    conditions:
      all: ["spec_approved == true", "spec_has_existing_plan == true"]
    actions: [APPLY_LABEL(approved-for-*, plan), ADD_COMMENT(cascade docs), PROCEED_TO(plan-approved run)]
    triggers: [writing-plans]
    source: "approval-gate/SKILL.md"

  - id: approval-gate-skill-006
    title: "PR merge boundary check — block if required PR not merged"
    conditions:
      all: ["plan_has_pr_boundaries == true", "required_pr_not_merged == true"]
    actions: [HALT, REPORT(CRITICAL: required PR not merged)]
    triggers: [implementation-pipeline, git-workflow]
    source: "approval-gate/SKILL.md"
