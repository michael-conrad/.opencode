---
name: implementation-pipeline
description: "Use when executing an approved plan through the implementation pipeline. Also use when dispatching pipeline stages to clean-room sub-agents, managing pipeline state, or handling remediation routing. Invoke for: pipeline execution, stage dispatch, state management, checkpoint creation, remediation routing, pre-flight handoff, submodule verification. MUST dispatch here after plan approval, before any file modification. Trigger phrases: execute pipeline, run pipeline, dispatch stage, pipeline state, checkpoint, remediation, pre-flight, handoff."
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
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatches To | Dispatch | Context passed |
|---------------------|------|---------------|----------|----------------|
| "execute plan" / "implement spec" / "run pipeline" / "assemble work" | `assemble-work` | Orchestrator entry — reads plan, creates branches, dispatches sub-agents | `orchestrator` | {issue_number, plan_path, authorization_scope, halt_at} |
| "sc-coherence-gate" / "coherence gate" | `sc-coherence-gate` | `audit --task coherence-extraction` | `sub-task` | {issue_number} |
| "pre-red-baseline" / "baseline check" | `pre-red-baseline` | `implementation-pipeline --task pre-red-baseline` | `sub-task` | {issue_number} |
| "red-phase" / "write failing test" | `red-phase` | `test-driven-development --task red` | `sub-task` | {issue_number} |
| "z3-check-red" / "solve check RED" | `z3-check-red` | `solve --task check` | `inline` | {issue_number, contract_path} |
| "red-doublecheck" / "verify RED" | `red-doublecheck` | `verification-before-completion --task verify` | `sub-task` | {issue_number} |
| "z3-check-red-doublecheck" / "solve check RED doublecheck" | `z3-check-red-doublecheck` | `solve --task check` | `inline` | {issue_number, contract_path} |
| "post-red-enforcement" / "RED gate" | `post-red-enforcement` | `implementation-pipeline --task post-red-enforcement` | `sub-task` | {issue_number} |
| "z3-check-post-red" / "solve check post-RED" | `z3-check-post-red` | `solve --task check` | `inline` | {issue_number, contract_path} |
| "green-phase" / "implement" | `green-phase` | `test-driven-development --task green` | `sub-task` | {issue_number} |
| "z3-check-green" / "solve check GREEN" | `z3-check-green` | `solve --task check` | `inline` | {issue_number, contract_path} |
| "post-green-enforcement" / "GREEN gate" | `post-green-enforcement` | `implementation-pipeline --task post-green-enforcement` | `sub-task` | {issue_number} |
| "z3-check-post-green" / "solve check post-GREEN" | `z3-check-post-green` | `solve --task check` | `inline` | {issue_number, contract_path} |
| "checkpoint-tag-create" / "create checkpoint tag" | `checkpoint-tag-create` | `implementation-pipeline --task checkpoint-tag-create` | `sub-task` | {issue_number} |
| "checkpoint-commit" / "save checkpoint" | `checkpoint-commit` | `git-workflow --task commit-prep` | `sub-task` | {issue_number} |
| "structural-checks" / "lint/typecheck" | `structural-checks` | `finishing-a-development-branch --task checklist` | `sub-task` | {issue_number} |
| "green-doublecheck" / "verify GREEN" | `green-doublecheck` | `verification-before-completion --task verify` | `sub-task` | {issue_number} |
| "green-vbc" / "verification before completion" | `green-vbc` | `verification-before-completion --task completion` | `sub-task` | {issue_number} |
| "pre-pr-gate" / "pre-PR gate" | `pre-pr-gate` | `verification-before-completion --task verify` — reads all SC verdicts, BLOCKs if any FAIL | `sub-task` | {issue_number} |
| "audit" / "audit step" | `audit` | Orchestrator dispatch — dispatch audit task (phase-appropriate: verification-audit/spec-audit/plan-fidelity/etc.) via `task(subagent_type="general")` | `orchestrator` | {issue_number} |
| "cross-validate" / "consensus check" | `cross-validate` | `audit --task cross-validate` | `sub-task` | {issue_number} |
| "regression-check" / "regression tests" | `regression-check` | `test-driven-development --task patterns` | `sub-task` | {issue_number} |
| "behavioral-test-remediation" / "remediate behavioral test" | `behavioral-test-remediation` | `implementation-pipeline --task behavioral-test-remediation` | `sub-task` | {issue_number, test_artifact_path, sc_list} |
| "review-prep" / "prepare review" | `review-prep` | `git-workflow --task review-prep` | `sub-task` | {issue_number} |
| "create-pr" / "create pull request" | `create-pr` | `pr-creation-workflow --task create` | `sub-task` | {issue_number, authorization_scope, halt_at} |
| "exec-summary" / "completion" | `exec-summary` | `completion-core --task completion` | `sub-task` | {issue_number} |

**Note:** The `audit` step dispatches the appropriate audit task (e.g., `verification-audit` for post-implementation, `spec-audit` for pre-implementation, `plan-fidelity` for plan validation) via `task(subagent_type="general")`:
- [ ] 1. Dispatch the audit task from audit skill with {spec_local_dir, artifact_evidence_dir}
- [ ] 2. If the audit returns non-clean-pass (FAIL): remediate the root cause, then restart from step 1. `DONE_WITH_CONCERNS` is coerced to FAIL per the bright-line coercion rule in this SKILL.md §Trigger Dispatch Table.
- [ ] 3. On clean PASS: collect the `artifact_path` and pass as `auditor_artifact_paths` context to `cross-validate`.

## Pre-Flight

See `implementation-pipeline/tasks/pre-flight.md` for pre-flight verification and authorization context requirements.

## Step Labels (for #932 naming convention)

`assemble-work`, `sc-coherence-gate`, `pre-red-baseline`, `red-phase`, `z3-check-red`, `red-doublecheck`, `z3-check-red-doublecheck`, `post-red-enforcement`, `z3-check-post-red`, `green-phase`, `z3-check-green`, `post-green-enforcement`, `z3-check-post-green`, `checkpoint-tag-create`, `checkpoint-commit`, `structural-checks`, `green-doublecheck`, `green-vbc`, `pre-pr-gate`, `audit`, `cross-validate`, `regression-check`, `behavioral-test-remediation`, `review-prep`, `create-pr`, `exec-summary`

## Invocation

`skill({name: "implementation-pipeline"})` — call the skill, then:

### Orchestrator-Level Tasks (read and execute directly, no task() call)

| Task | Action |
|------|--------|
| Orchestrator entry | Orchestrator reads the plan, creates branches, dispatches sub-agents per the Trigger Dispatch Table. The orchestrator does NOT read any task file — the Trigger Dispatch Table IS the single source of truth for all pipeline steps. |

### Sub-Agent Tasks (dispatch via task())

Steps that route to owning skills use the owning skill's canonical dispatch string from the Trigger Dispatch Table's "Dispatches To" column:

| Step | Canonical Dispatch String |
|------|--------------------------|
| `sc-coherence-gate` | `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")` |
| `pre-red-baseline` | `task(..., prompt: "execute pre-red-baseline from implementation-pipeline. Read \`implementation-pipeline/tasks/pre-red-baseline.md\` first")` |
| `red-phase` | `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")` |
| `red-doublecheck` | `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")` |
| `post-red-enforcement` | `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")` |
| `green-phase` | `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")` |
| `post-green-enforcement` | `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")` |
| `checkpoint-tag-create` | `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")` |
| `checkpoint-commit` | `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")` |
| `structural-checks` | `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")` |
| `green-doublecheck` | `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")` |
| `green-vbc` | `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")` |
| `pre-pr-gate` | `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")` — reads all SC verdicts, BLOCKs if any FAIL |
| `cross-validate` | `task(..., prompt: "execute cross-validate from audit. Read \`audit/tasks/cross-validate.md\` first")` |
| `regression-check` | `task(..., prompt: "execute patterns from test-driven-development. Read \`test-driven-development/tasks/patterns.md\` first")` |
| `behavioral-test-remediation` | `task(..., prompt: "execute behavioral-test-remediation from implementation-pipeline. Read \`implementation-pipeline/tasks/behavioral-test-remediation.md\` first")` |
| `review-prep` | `task(..., prompt: "execute review-prep from git-workflow. Read \`git-workflow/tasks/review-prep.md\` first")` |
| `create-pr` | `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")` |
| `exec-summary` | `task(..., prompt: "execute completion from completion-core. Read \`completion-core/tasks/completion.md\` first")` |

**Exception — audit sequence:** The audit is a multi-step sequence, not a single dispatch. Each step is a separate numbered item:
1. Dispatch audit task (sub-agent) — dispatch the appropriate audit task via `task(subagent_type="general")`
2. `remediate` (inline) — if non-clean-pass, remediate and restart from step 1
3. `cross-validate` (clean-room) — produce cross-validate findings

## Sub-Agent Routing

**Orchestrator entry point:** The orchestrator reads the plan, creates branches, and dispatches sub-agents per the Trigger Dispatch Table. The Trigger Dispatch Table IS the single source of truth — the orchestrator dispatches each step using the canonical dispatch string from the table. No task files are read by the orchestrator.

All substantive work runs via `task(subagent_type="general")`. The orchestrator is a pure router — no creative work, no file edits, no inline analysis. Auditor tasks also use `subagent_type="general"` — the task file provides all role-specific behavior. Dispatch contracts carry exactly 2 fields: `spec_local_dir` and `artifact_evidence_dir`. No `audit_phase` field. See audit SKILL.md §DISPATCH_GATE. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`.

**Exception — audit sequence:** The audit is a multi-step sequence, not a single dispatch. Each step is a separate numbered item (dispatch audit task, remediate inline, cross-validate clean-room). See Invocation section for the complete sequence.

Exclusions: implementation context, agent memory, cached verification results.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.
> This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read the task file then execute step 1" | "execute red-phase from implementation-pipeline" |
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

**Behavioral enforcement test:** `dispatch-gate-rejection.sh` verifies sub-agents reject preloaded context with `PRELOADED_CONTEXT_REJECTED`.

#### Pipeline Re-Priming Enforcement Block

At every pipeline stage transition (pre-work → implementation-pipeline → verification-before-completion → finishing-checklist → review-prep), the orchestrator re-encounters this enforcement block restating procedural discipline:

- Sub-agents execute — orchestrators route
- No inline work — all file modifications, analysis, and decisions go through clean-room sub-agents
- The orchestrator holds routing metadata only — task file contents, analysis artifacts, and verification results go to sub-agents or disk
- Every stage transition is a re-encounter of this discipline — context degrades between gates, and re-priming prevents drift

#### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)

## State Management

- `solve state init {project_root}/tmp/{issue-N}/state/` at `pre-red-baseline` step — creates state file with `current_step: pre-red-baseline`, `pipeline_state: init`
- `solve state update {project_root}/tmp/{issue-N}/state/ --var-name <name> --var-value <value> --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml` — 3 calls per step: previous_step, current_step, pipeline_state
- `solve check --state-path {project_root}/tmp/{issue-N}/state/ --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml` — validates step transitions

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

Artifacts under `.issues/{issue-N}/` (root repo) or `{project_root}/{path}/.issues/{issue-N}/` (submodule/sub-repo) are permanent — they survive pipeline restarts, branch switches, and PR merges. Never delete or clean these files. They serve as the authoritative audit trail for spec lifecycle, SC coverage, verification consistency, and revision re-entry protocols.

### Rule 2: Ephemeral Artifacts Cleaned at PR Merge

Artifacts under `{project_root}/tmp/{issue-N}/` are ephemeral — they are cleaned at PR merge cleanup (`git-workflow --task cleanup`). These include constraints contracts, decomposition validations, phase exit contracts, and phase-plan-validated files. Before PR merge, all permanent artifacts must be finalized and no unresolved references to ephemeral paths may remain in the lifecycle manifest.

### Rule 3: Step-Specific Pre-Cleanup

At the start of each pipeline step, clean previous-run artifacts for that step to prevent stale state contamination:

| Step Label | Pre-Cleanup Action |

| `pre-red-baseline` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-pre-red-baseline-*` |
| `post-red-enforcement` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-post-red-enforcement-*` |
| `red-phase` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-red-phase-*` |
| `z3-check-red` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-z3-check-red-*` |
| `green-phase` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-green-phase-*` |
| `z3-check-green` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-z3-check-green-*` |
| `post-green-enforcement` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-post-green-enforcement-*` |
| `checkpoint-tag-create` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-checkpoint-tag-create-*` |
| `checkpoint-commit` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-checkpoint-commit-*` |
| `structural-checks` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-structural-checks-*` |
| `green-doublecheck` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-green-doublecheck-*` |
| `green-vbc` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-green-vbc-*` |
| `pre-pr-gate` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-pre-pr-gate-*` |
| `audit` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-audit-*` |
| `cross-validate` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-cross-validate-*` |
| `regression-check` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-regression-check-*` |
| `behavioral-test-remediation` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-behavioral-test-remediation-*` |

## Lifecycle Manifest Event Emission

Each pipeline step SHOULD append an event to the lifecycle manifest at `{project_root}/tmp/{issue-N}/lifecycle.yaml` on completion. Events are appended, not overwritten:

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

## Pipeline Enforcement Rules

- [ ] 1. **No direct implementation by orchestrator:** Orchestrator MUST NOT edit implementation files — dispatch to sub-agents
- [ ] 2. **Implementation-first gate:** Pipeline with `authorization_scope >= for_implementation` MUST produce at least one file modification
- [ ] 3. **PR merge boundary check:** HALT if plan has PR boundaries and required PR is not merged
- [ ] 4. **Tool-recipe prohibition:** Task context specifies WHAT, never HOW — no MCP tool names, line numbers, or step-by-step scripts
- [ ] 5. **Poison recovery:** Orchestrator inline work poisons the pipeline — discard ALL state and restart from `verify-authorization`
- [ ] 6. **Discard on sub-agent failure:** ALL files from a BLOCKED/ERROR sub-agent MUST be discarded before re-task
- [ ] 7. **RED/GREEN push-prohibition:** Test sub-agents (RED/GREEN) MUST NOT commit or push
- [ ] 8. **Coherence gate:** Verify spec/plan coherence before RED routing via `audit --task coherence-maintenance`
- [ ] 9. **Execution-time coherence detection:** RED/GREEN sub-agents MUST return BLOCKED on spec/codebase contradiction
- [ ] 10. **Remediation limit:** Max 3 remediation attempts before escalating to developer
- [ ] 11. **Gate non-waiver:** "Continue" does NOT waive mandatory gates
- [ ] 12. **Cost-blind verification:** Never skip routing or verification to save resources
- [ ] 13. **Completeness gate required:** Run `completeness-gate --task check` after RED/GREEN before audit

## Cross-References

Skills: `approval-gate`, `git-workflow`, `test-driven-development`, `verification-before-completion`, `finishing-a-development-branch`, `audit`, `completion-core`, `pre-analysis`, `completeness-gate`, `research`. Guidelines: `091-incremental-build.md`, `000-critical-rules.md`.


```
