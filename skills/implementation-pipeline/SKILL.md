---
name: implementation-pipeline
description: Use when orchestrating multi-item implementation through a serial 14-step pipeline with per-step dispatch routing, Z3-verified step transitions, and YAML contract artifact tracking. Triggers on: orchestrate, pipeline, multi-item, implementation pipeline, assemble work, dispatch table. Skipping pipeline steps produces undiscovered defects in every downstream consumer. Professional engineers route each step through clean-room sub-agents.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Implementation Pipeline

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Overview

Pure orchestrator routing table with 14 serial dispatch steps. The orchestrator holds only routing metadata — each step dispatches to an existing skill's task file via `task()`. Step transitions are validated by Z3 via `solve check` against `pipeline-state-machine.yaml`. YAML contract artifacts at `./tmp/{issue-N}/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`.

The orchestrator is a pure router — never reads task file content, never performs inline analysis. Sub-agents do the work.

## Dispatch Routing Table

| Step Label | Dispatches To | Artifact Produced |
|------------|---------------|-------------------|
| `sc-coherence-gate` | `adversarial-audit --task coherence-extraction` | coherence check results |
| `pre-red-baseline` | `implementation-pipeline --task pre-red-baseline` (simple bash) | solution state file |
| `red-phase` | `test-driven-development --task red` | test code + execution result |
| `red-doublecheck` | `verification-before-completion --task verify` | RED-side SC evidence |
| `green-phase` | `test-driven-development --task green` | implementation code + test pass |
| `checkpoint-commit` | `git-workflow --task commit-prep` | commit status |
| `structural-checks` | `finishing-a-development-branch --task checklist` | lint/typecheck/format results |
| `green-doublecheck` | `verification-before-completion --task verify` | GREEN-side SC evidence |
| `green-vbc` | `verification-before-completion --task completion` | VbC completion artifact |
| `adversarial-audit` | `adversarial-audit --task verification-audit` | dual-auditor YAML verdicts |
| `cross-validate` | `adversarial-audit --task cross-validate` | cross-validate findings YAML |
| `regression-check` | `test-driven-development --task patterns` (regression) | regression test results |
| `review-prep` | `git-workflow --task review-prep` | review-prep status |
| `exec-summary` | `completion-core --task completion` | push status + issue comment |

## Step Labels (for #932 naming convention)

`sc-coherence-gate`, `pre-red-baseline`, `red-phase`, `red-doublecheck`, `green-phase`, `checkpoint-commit`, `structural-checks`, `green-doublecheck`, `green-vbc`, `adversarial-audit`, `cross-validate`, `regression-check`, `review-prep`, `exec-summary`

## Invocation

`skill({name: "implementation-pipeline"})` — call the skill, then dispatch each step via task():

| Step | Call via task() |
|------|-----------------|
| Any dispatch step | `task(..., prompt: "execute <step_label> from implementation-pipeline")` |

Every task context MUST include the authorization context block:

```yaml
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

## Sub-Agent Routing

All substantive work runs via `task(subagent_type="general")`. The orchestrator is a pure router — no creative work, no file edits, no inline analysis. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include `audit_phase` in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`.

Exclusions: implementation context, agent memory, cached verification results.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** The orchestrator's context is the most expensive resource in the pipeline — sub-agents do the work, not the orchestrator. Every byte held by the orchestrator costs `byte × remaining_dispatches²`. See `020-go-prohibitions.md` §1.1.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read pipeline-executor.md then execute step 1" | "execute red-phase from implementation-pipeline" |
| Preloaded step sequences | "Step 1: red. Step 2: green." | "execute green-phase from implementation-pipeline" |
| Preloaded expected outcomes | "Return { test_count, pass_count }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The rename was just completed so we need to..." | Pure objective, no narrative |

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

## State Management

- `solve state init ./tmp/state/ISSUE_NUM/pipeline/` at `pre-red-baseline` step — creates state file with `current_step: pre-red-baseline`, `pipeline_state: init`
- `solve state update ./tmp/state/ISSUE_NUM/pipeline/ --var-name <name> --var-value <value> --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml` — 3 calls per step: previous_step, current_step, pipeline_state
- `solve check --state-path ./tmp/state/ISSUE_NUM/pipeline/ --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml` — validates step transitions

Step results go to YAML disk artifact — never into solve state. Solve state tracks pipeline **position** only.

## Remediation Routing

When a step returns FAIL, the orchestrator:
1. Reads the FAIL artifact's YAML frontmatter from disk
2. Dispatches the `researcher` skill to determine remediation scope
3. Routes to `remediation_steps[0].target_step` based on researcher findings
4. Re-runs the pipeline from the target remediation step

## Enforcement Reference

| Document | Purpose |
|----------|---------|
| Sub-agent context shape | Context shape and exclusions for task() routing |
| `enforcement/overflow-signal.md` | OVERFLOW contract and re-routing strategies |
| `enforcement/work-state-verification.md` | Verification table and work state format |

## Artifact Retention

### Rule 1: Permanent Artifacts Never Cleaned

Artifacts under `.issues/{issue-N}/spec-artifacts/` are permanent — they survive pipeline restarts, branch switches, and PR merges. Never delete or clean these files. They serve as the authoritative audit trail for spec lifecycle, SC coverage, verification consistency, and revision re-entry protocols.

### Rule 2: Ephemeral Artifacts Cleaned at PR Merge

Artifacts under `./tmp/{issue-N}/` are ephemeral — they are cleaned at PR merge cleanup (`git-workflow --task cleanup`). These include constraints contracts, decomposition validations, phase exit contracts, and phase-plan-validated files. Before PR merge, all permanent artifacts must be finalized and no unresolved references to ephemeral paths may remain in the lifecycle manifest.

### Rule 3: Step-Specific Pre-Cleanup

At the start of each pipeline step, clean previous-run artifacts for that step to prevent stale state contamination:

| Step Label | Pre-Cleanup Action |
|------------|-------------------|
| `pre-red-baseline` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-pre-red-baseline-*` |
| `red-phase` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-red-phase-*` |
| `green-phase` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-green-phase-*` |
| `checkpoint-commit` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-checkpoint-commit-*` |
| `structural-checks` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-structural-checks-*` |
| `green-doublecheck` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-green-doublecheck-*` |
| `green-vbc` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-green-vbc-*` |
| `adversarial-audit` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-adversarial-audit-*` |
| `cross-validate` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-cross-validate-*` |
| `regression-check` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-regression-check-*` |

## Lifecycle Manifest Event Emission

Each pipeline step SHOULD append an event to the lifecycle manifest at `.issues/{issue-N}/spec-artifacts/lifecycle.yaml` on completion. Events are appended, not overwritten:

```yaml
  - event: step_completed
    timestamp: <YYYY-MM-DDTHH:MM:SSZ>
    issuer: <AgentName> (<ModelId>)
    step: <step_label>
    status: <PASS|FAIL>
    description: "<brief summary>"
    severity: <info|warning|error>
```

Blocker events (on FAIL) MUST include:
```yaml
  - event: blocker
    timestamp: <YYYY-MM-DDTHH:MM:SSZ>
    issuer: <AgentName> (<ModelId>)
    step: <step_label>
    severity: error
    reason: "<root cause description>"
    resolution: "<applied remediation or UNRESOLVED>"
```

The lifecycle manifest is append-only. Never delete or edit existing entries — only append new ones. Validation: `grep -c "event:" lifecycle.yaml` MUST increase monotonically across pipeline steps.

## Cross-References

Skills: `approval-gate`, `git-workflow`, `test-driven-development`, `verification-before-completion`, `finishing-a-development-branch`, `adversarial-audit`, `completion-core`, `pre-analysis`, `completeness-gate`, `researcher`. Guidelines: `091-incremental-build.md`, `000-critical-rules.md`.

```yaml+symbolic
schema_version: "3.0"
last_updated: "2026-05-31T00:00:00Z"
rules:
  - id: implementation-pipeline-001
    title: "No direct implementation by orchestrator"
    conditions:
      all: ["is_orchestrator == true", "about_to_edit_implementation_file == true"]
    actions: [HALT, TASK(sub-agent)]
    source: "implementation-pipeline/SKILL.md"

  - id: implementation-pipeline-005
    title: "Implementation-first gate requires deliverable"
    conditions:
      all: ["pipeline_completed == true", "files_modified_count == 0", "authorization_scope >= for_implementation"]
    actions: [HALT, REPORT(zero_deliverables)]
    source: "implementation-pipeline/SKILL.md"

  - id: implementation-pipeline-007
    title: "PR merge boundary check before sub-agent routing"
    conditions:
      all: ["plan_has_pr_boundaries == true", "required_pr_not_merged == true"]
    actions: [HALT]
    source: "implementation-pipeline/SKILL.md"

  - id: implementation-pipeline-008
    title: "Tool-recipe prohibition — task context specifies WHAT, never HOW"
    conditions:
      any:
        - "task_context_contains_mcp_tool_names == true"
        - "task_context_contains_line_numbers == true"
        - "task_context_contains_step_by_step_script == true"
    actions: [HALT]
    source: "implementation-pipeline/SKILL.md"

  - id: implementation-pipeline-009
    title: "Poison recovery protocol — orchestrator inline work poisons pipeline"
    conditions:
      all: ["is_orchestrator == true", "performed_inline_work == true"]
    actions: [HALT, DISCARD_ALL_STATE, RESTART_FROM(verify-authorization)]
    source: "implementation-pipeline/SKILL.md"

  - id: implementation-pipeline-010
    title: "Discard on sub-agent failure — ALL files discarded before re-task"
    conditions:
      any:
        - "sub_agent_status == BLOCKED"
        - "sub_agent_status == ERROR"
    actions: [DISCARD(changed_files), RE_TASK(original_context)]
    source: "implementation-pipeline/SKILL.md"

  - id: implementation-pipeline-011
    title: "RED/GREEN push-prohibition — test sub-agents never commit or push"
    conditions:
      all: ["sub_agent_type IN ['RED', 'GREEN']", "attempting_to_commit_or_push == true"]
    actions: [HALT]
    source: "implementation-pipeline/SKILL.md"

  - id: implementation-pipeline-012
    title: "Coherence gate — verify spec/plan coherence before RED routing"
    conditions:
      all: ["red_routing_pending == true", "spec_plan_coherence_verified == false"]
    actions: [CALL(adversarial-audit --task coherence-maintenance), VERIFY_COHERENCE]
    source: "implementation-pipeline/SKILL.md"

  - id: implementation-pipeline-013
    title: "Execution-time coherence detection — RED/GREEN return BLOCKED on defect"
    conditions:
      any:
        - "red_sub_agent_detected_spec_codebase_contradiction == true"
        - "green_sub_agent_detected_plan_spec_mismatch == true"
    actions: [RETURN(status=BLOCKED)]
    source: "implementation-pipeline/SKILL.md"

  - id: implementation-pipeline-014
    title: "Audit-classified remediation — max 3 attempts before escalating"
    conditions:
      all: ["sub_agent_status == BLOCKED", "remediation_attempts >= 3"]
    actions: [ESCALATE_TO_DEVELOPER]
    source: "implementation-pipeline/SKILL.md"

  - id: implementation-pipeline-015
    title: "Gate non-waiver — 'continue' does not waive mandatory gates"
    conditions:
      all: ["user_input_type == 'continue'", "mandatory_gate_skipped == true"]
    actions: [HALT]
    source: "implementation-pipeline/SKILL.md"

  - id: implementation-pipeline-016
    title: "Cost-blind verification — never skip routing or verification to save resources"
    conditions:
      all: ["routing_or_verification_skipped_for_economy == true"]
    actions: [HALT]
    source: "implementation-pipeline/SKILL.md"

  - id: implementation-pipeline-017
    title: "Completeness gate required after RED/GREEN before adversarial audit"
    conditions:
      all: ["sub_agent_result_collected == true", "completeness_gate_run == false", "adversarial_audit_routing_pending == true"]
    actions: [CALL(completeness-gate --task check)]
    source: "implementation-pipeline/SKILL.md"
```
