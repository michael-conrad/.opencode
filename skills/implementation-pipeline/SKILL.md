---
name: implementation-pipeline
description: "Use when executing an approved plan through the implementation pipeline. Also use when dispatching pipeline stages to clean-room sub-agents, managing pipeline state, or handling remediation routing. Invoke for: pipeline execution, stage dispatch, state management, checkpoint creation, remediation routing, post-green enforcement, post-red enforcement. MUST dispatch here after plan approval, before any file modification. Trigger phrases: execute pipeline, run pipeline, dispatch stage, pipeline state, checkpoint, remediation, green phase, red phase."
license: MIT
compatibility: opencode
---

# Implementation Pipeline

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->


## Overview

Orchestrator-facing dispatch router for the implementation pipeline. The orchestrator holds only routing metadata — each step dispatches to an existing skill's task file via `task()`. The orchestrator is a pure router — never reads task file content, never performs inline analysis. Sub-agents do the work.

## Persona

Pipeline router. Routes each pipeline stage to a clean-room sub-agent via `task()`. The orchestrator holds routing metadata only — never reads task file content, never performs inline analysis. An orchestrator that performs inline work has stopped being a router and started being a contaminant — every inline analysis artifact carries the orchestrator's preloaded bias through every downstream sub-agent, and the pipeline is poisoned from the first byte. Professional pipeline routers dispatch to sub-agents. Inlining means the pipeline was never clean.

**MUST dispatch here after plan approval, before any file modification.** This is the mandatory entry point for all implementation work.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "execute plan" / "implement spec" / "run pipeline" / "assemble work" | `assemble-work` | `orchestrator` | {issue_number, plan_path, authorization_scope, halt_at, pr_strategy} |
| "sc-coherence-gate" / "coherence gate" | `sc-coherence-gate` | `sub-task` | {issue_number} |
| "pre-red-baseline" / "baseline check" | `pre-red-baseline` | `sub-task` | {issue_number} |
| "red-phase" / "write failing test" | `red-phase` | `sub-task` | {issue_number} |
| "z3-check-red" / "solve check RED" | `z3-check-red` | `inline` | {issue_number, contract_path} |
| "red-doublecheck" / "verify RED" | `red-doublecheck` | `sub-task` | {issue_number} |
| "z3-check-red-doublecheck" / "solve check RED doublecheck" | `z3-check-red-doublecheck` | `inline` | {issue_number, contract_path} |
| "post-red-enforcement" / "RED gate" | `post-red-enforcement` | `sub-task` | {issue_number} |
| "z3-check-post-red" / "solve check post-RED" | `z3-check-post-red` | `inline` | {issue_number, contract_path} |
| "green-phase" / "implement" | `green-phase` | `sub-task` | {issue_number} |
| "z3-check-green" / "solve check GREEN" | `z3-check-green` | `inline` | {issue_number, contract_path} |
| "post-green-enforcement" / "GREEN gate" | `post-green-enforcement` | `sub-task` | {issue_number} |
| "z3-check-post-green" / "solve check post-GREEN" | `z3-check-post-green` | `inline` | {issue_number, contract_path} |
| "checkpoint-tag-create" / "create checkpoint tag" | `checkpoint-tag-create` | `sub-task` | {issue_number} |
| "checkpoint-commit" / "save checkpoint" | `checkpoint-commit` | `sub-task` | {issue_number} |
| "structural-checks" / "lint/typecheck" | `structural-checks` | `sub-task` | {issue_number} |
| "green-doublecheck" / "verify GREEN" | `green-doublecheck` | `sub-task` | {issue_number} |
| "green-vbc" / "verification before completion" | `green-vbc` | `sub-task` | {issue_number} |
| "adversarial-audit" / "audit step" | `adversarial-audit` | `orchestrator` | {issue_number} |
| "cross-validate" / "consensus check" | `cross-validate` | `sub-task` | {issue_number} |
| "regression-check" / "regression tests" | `regression-check` | `sub-task` | {issue_number} |
| "review-prep" / "prepare review" | `review-prep` | `sub-task` | {issue_number} |
| "exec-summary" / "completion" | `exec-summary` | `sub-task` | {issue_number} |

## Dispatch Routing Table

| Step Label | Dispatches To | Artifact Produced |
|------------|---------------|-------------------|
| `sc-coherence-gate` | `adversarial-audit --task coherence-extraction` (evidence-type uplift + substrate classification) | coherence check results + uplift verdict |
| `pre-red-baseline` | `implementation-pipeline --task pre-red-baseline` (doc-source-currency + SC-ID cross-ref traceability) | solution state file + source currency report |
| `red-phase` | `test-driven-development --task red` | test code + execution result |
| `z3-check-red` | `solve check` against red-phase output contract (`contracts/red-phase-output-template.yaml`) | SAT/UNSAT result |
| `red-doublecheck` | `verification-before-completion --task verify` | RED-side SC evidence |
| `z3-check-red-doublecheck` | `solve check` against red-doublecheck output contract (`contracts/red-doublecheck-output-template.yaml`) | SAT/UNSAT result |
| `post-red-enforcement` | `implementation-pipeline --task post-red-enforcement` (git diff --name-only -- src/ \| wc -l) | git diff structural gate result |
| `z3-check-post-red` | `solve check` against post-red-enforcement output contract (`contracts/post-red-enforcement-output-template.yaml`) | SAT/UNSAT result |
| `green-phase` | `test-driven-development --task green` | implementation code + test pass |
| `z3-check-green` | `solve check` against green-phase output contract (`contracts/green-phase-output-template.yaml`) | SAT/UNSAT result |
| `post-green-enforcement` | `implementation-pipeline --task post-green-enforcement` (git diff --name-only -- test/ \| wc -l) | git diff structural gate result |
| `z3-check-post-green` | `solve check` against post-green-enforcement output contract (`contracts/post-green-enforcement-output-template.yaml`) | SAT/UNSAT result |
| `checkpoint-tag-create` | `implementation-pipeline --task checkpoint-tag-create` (creates git tag per `000-critical-rules.md` §Checkpoint Rollback Exception) | checkpoint tag created |
| `checkpoint-commit` | `git-workflow --task commit-prep` | commit status |
| `structural-checks` | `finishing-a-development-branch --task checklist` | lint/typecheck/format results |
| `green-doublecheck` | `verification-before-completion --task verify` (semantic-intent verification) | GREEN-side SC evidence + intent verdict |
| `green-vbc` | `verification-before-completion --task completion` | VbC completion artifact |
| `adversarial-audit` | **Orchestrator multi-dispatch:** resolve-models → dispatch audit task (phase-appropriate: verification-audit/spec-audit/plan-fidelity/etc.) with auditor_1 (remediate + restart on non-clean-pass) → same audit task with auditor_2 (remediate + restart on non-clean-pass) | dual-auditor YAML verdicts per auditor |
| `cross-validate` | `adversarial-audit --task cross-validate` (receives `auditor_artifact_paths` from adversarial-audit step) | cross-validate findings YAML |
| `regression-check` | `test-driven-development --task patterns` (regression) | regression test results |
| `review-prep` | `git-workflow --task review-prep` | review-prep status |
| `exec-summary` | `completion-core --task completion` | append lifecycle event + chat exec summary |

**Note:** The `adversarial-audit` step is a multi-dispatch sequence with remediation loop-back. The audit task dispatched depends on pipeline phase (e.g., `verification-audit` for post-implementation, `spec-audit` for pre-implementation, `plan-fidelity` for plan validation):
- [ ] 1. Run `.opencode/tools/resolve-models` to select cross-family auditors
- [ ] 2. Dispatch the appropriate audit task with `subagent_type` from `auditor_1`
- [ ] 3. If auditor 1 returned non-clean-pass (FAIL): remediate the root cause, then restart from step 1 (re-run resolve-models). Do NOT dispatch auditor 2. `DONE_WITH_CONCERNS` is coerced to FAIL per the bright-line coercion rule in `pipeline-executor.md`.
- [ ] 4. Dispatch the same audit task with `subagent_type` from `auditor_2`
- [ ] 5. If auditor 2 returned non-clean-pass: remediate the root cause, then restart from step 1 (re-run resolve-models).
- [ ] 6. Both auditors clean PASS. Collect both `artifact_path` values and pass as `auditor_artifact_paths` context to `cross-validate`.

## Pre-Flight

Before the pipeline dispatches to `sc-coherence-gate`, the orchestrator MUST run plan-to-pipeline handoff verification:

- [ ] 1. **Plan-to-pipeline handoff:** Execute `implementation-pipeline --task pre-flight-handoff` — validates RED checkpoints, SC-ID traceability, approval cascade state, verification gate preservation, and manifest writes at `./tmp/{issue-N}/artifacts/plan-to-pipeline-handoff-*.yaml`
- [ ] 2. **Handoff-consistency check:** Reads both `spec-to-plan-handoff-*.yaml` and `plan-to-pipeline-handoff-*.yaml` manifests and compares shared variables (SC coverage total, decomposition classification, phase count). BLOCKs on mismatch.
- [ ] 3. **Pre-flight PASS required:** The pipeline MUST NOT proceed to `sc-coherence-gate` (step 1) if pre-flight returns BLOCKED. This is a hard gate — no bypass path.

## Step Labels (for #932 naming convention)

`sc-coherence-gate`, `pre-red-baseline`, `red-phase`, `z3-check-red`, `red-doublecheck`, `z3-check-red-doublecheck`, `post-red-enforcement`, `z3-check-post-red`, `green-phase`, `z3-check-green`, `post-green-enforcement`, `z3-check-post-green`, `checkpoint-tag-create`, `checkpoint-commit`, `structural-checks`, `green-doublecheck`, `green-vbc`, `resolve-models`, `adversarial-audit`, `cross-validate`, `regression-check`, `review-prep`, `exec-summary`

## Invocation

`skill({name: "implementation-pipeline"})` — call the skill, then:

### Orchestrator-Level Tasks (read and execute directly, no task() call)

| Task | Action |
|------|--------|
| `assemble-work` (orchestrator entry) | Orchestrator reads `implementation-pipeline/tasks/assemble-work.md` directly and executes its steps |
| `pipeline-executor` (step dispatch loop) | Orchestrator reads `implementation-pipeline/tasks/pipeline-executor.md` directly and dispatches each step's sub-agent via task() |

### Sub-Agent Tasks (dispatch via task())

All other steps in the Trigger Dispatch Table with `sub-task` dispatch are called via:

`task(..., prompt: "execute <step_label> from implementation-pipeline. Read \`implementation-pipeline/tasks/<step_label>.md\` first")`

**Exception — adversarial-audit sequence:** The adversarial audit is a multi-step sequence, not a single dispatch. Each step is a separate numbered item:
1. `resolve-models` (inline) — run `.opencode/tools/resolve-models`
2. `auditor-1 dispatch` (sub-agent) — dispatch audit task with auditor_1
3. `auditor-1 remediate` (inline) — if non-clean-pass, remediate and restart
4. `auditor-2 dispatch` (sub-agent) — dispatch audit task with auditor_2
5. `auditor-2 remediate` (inline) — if non-clean-pass, remediate and restart
6. `cross-validate` (clean-room) — produce cross-validate findings

Every task context MUST include the authorization context block:

```yaml
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

## Sub-Agent Routing

**Orchestrator entry point:** `assemble-work` is the mandatory entry point. The orchestrator reads `implementation-pipeline/tasks/assemble-work.md` directly and executes its steps after plan approval. `assemble-work` reads the plan, creates branches, dispatches sub-agents, and routes to `pipeline-executor` for the internal step dispatch sequence. The orchestrator reads `pipeline-executor.md` directly and dispatches each step's sub-agent via task() — `pipeline-executor` is NOT dispatched as a sub-agent.

All substantive work runs via `task(subagent_type="general")`. The orchestrator is a pure router — no creative work, no file edits, no inline analysis. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include `audit_phase` in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`.

**Exception — adversarial-audit sequence:** The adversarial audit is a multi-step sequence, not a single dispatch. Each step is a separate numbered item (resolve-models inline, auditor-1 sub-agent, auditor-1 remediate inline, auditor-2 sub-agent, auditor-2 remediate inline, cross-validate clean-room). See Invocation section for the complete sequence.

Exclusions: implementation context, agent memory, cached verification results.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.
> This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read pipeline-executor.md then execute step 1" | "execute red-phase from implementation-pipeline" |
| Preloaded step sequences | "Step 1: red. Step 2: green." | "execute green-phase from implementation-pipeline" |
| Preloaded expected outcomes | "Return { test_count, pass_count }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The rename was just completed so we need to..." | Pure objective, no narrative |
| Missing task file discovery directive | "execute green-phase from implementation-pipeline" without task file path | "execute green-phase from implementation-pipeline. Read `implementation-pipeline/tasks/green-phase.md` first" |

## Required: Sub-agent Task File Discovery Directive

Every `task()` prompt that dispatches a named task MUST include a discovery directive in the format:

```
execute <task> from <skill>. Read `<skill>/tasks/<task>.md` first
```

This directive tells the sub-agent which task file to load independently — it is NOT preloading the file content. The sub-agent opens and reads the task file in its own clean-room context, discovers the procedure, and executes autonomously. Without this directive, the sub-agent must search for the correct task file, which is wasted context and routing ambiguity.

This is NOT a violation of the preloading prohibition. The task file path is routing metadata (which file to load), not execution context (what the file contains). The sub-agent still reads the file independently and discovers scope on its own.

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

#### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)

## State Management

- `solve state init ./tmp/{issue-N}/state/` at `pre-red-baseline` step — creates state file with `current_step: pre-red-baseline`, `pipeline_state: init`
- `solve state update ./tmp/{issue-N}/state/ --var-name <name> --var-value <value> --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml` — 3 calls per step: previous_step, current_step, pipeline_state
- `solve check --state-path ./tmp/{issue-N}/state/ --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml` — validates step transitions

Step results go to YAML disk artifact — never into solve state. Solve state tracks pipeline **position** only.

Step results go to YAML disk artifact — never into solve state. Solve state tracks pipeline **position** only.

## Remediation Routing

When a step returns FAIL, the orchestrator:
- [ ] 1. Reads the FAIL artifact's YAML frontmatter from disk
- [ ] 2. Dispatches the `research` skill to determine remediation scope
- [ ] 3. Routes to `remediation_steps[0].target_step` based on research findings
- [ ] 4. Re-runs the pipeline from the target remediation step

## Enforcement Reference

| Document | Purpose |

| Sub-agent context shape | Context shape and exclusions for task() routing |
| `enforcement/overflow-signal.md` | OVERFLOW contract and re-routing strategies |
| `enforcement/work-state-verification.md` | Verification table and work state format |

## Artifact Retention

### Rule 1: Permanent Artifacts Never Cleaned

Artifacts under `.issues/{issue-N}/` (root repo) or `*/.issues/{issue-N}/` (submodule/sub-repo) are permanent — they survive pipeline restarts, branch switches, and PR merges. Never delete or clean these files. They serve as the authoritative audit trail for spec lifecycle, SC coverage, verification consistency, and revision re-entry protocols.

### Rule 2: Ephemeral Artifacts Cleaned at PR Merge

Artifacts under `./tmp/{issue-N}/` are ephemeral — they are cleaned at PR merge cleanup (`git-workflow --task cleanup`). These include constraints contracts, decomposition validations, phase exit contracts, and phase-plan-validated files. Before PR merge, all permanent artifacts must be finalized and no unresolved references to ephemeral paths may remain in the lifecycle manifest.

### Rule 3: Step-Specific Pre-Cleanup

At the start of each pipeline step, clean previous-run artifacts for that step to prevent stale state contamination:

| Step Label | Pre-Cleanup Action |

| `pre-red-baseline` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-pre-red-baseline-*` |
| `post-red-enforcement` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-post-red-enforcement-*` |
| `red-phase` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-red-phase-*` |
| `z3-check-red` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-z3-check-red-*` |
| `green-phase` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-green-phase-*` |
| `z3-check-green` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-z3-check-green-*` |
| `post-green-enforcement` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-post-green-enforcement-*` |
| `checkpoint-tag-create` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-checkpoint-tag-create-*` |
| `checkpoint-commit` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-checkpoint-commit-*` |
| `structural-checks` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-structural-checks-*` |
| `green-doublecheck` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-green-doublecheck-*` |
| `green-vbc` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-green-vbc-*` |
| `adversarial-audit` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-adversarial-audit-*` |
| `cross-validate` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-cross-validate-*` |
| `regression-check` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-regression-check-*` |

## Lifecycle Manifest Event Emission

Each pipeline step SHOULD append an event to the lifecycle manifest at `./tmp/{issue-N}/lifecycle.yaml` on completion. Events are appended, not overwritten:

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

Skills: `approval-gate`, `git-workflow`, `test-driven-development`, `verification-before-completion`, `finishing-a-development-branch`, `adversarial-audit`, `completion-core`, `pre-analysis`, `completeness-gate`, `research`. Guidelines: `091-incremental-build.md`, `000-critical-rules.md`.

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
