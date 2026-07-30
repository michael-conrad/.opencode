---
name: implementation-workflow
description: "Static reference card containing all implementation-pipeline workflow content — dispatch strings, enforcement rules, coercion rule, artifact retention, remediation routing, sub-agent routing, and state management guidance. Read by plan-writer tasks instead of loading the live implementation-pipeline skill."
license: MIT
provenance: AI-generated
---

# Implementation Workflow Reference Card

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

> **Purpose:** This is a static reference card containing ALL content from the former `skills/implementation-pipeline/SKILL.md` and its enforcement directory. Plan-writer tasks (`create.md`, `research.md`, `validate.md`) read this card instead of loading the live skill. The orchestrator reads the plan (which contains baked-in dispatch strings) at execution time — no `skill()` call needed at plan-writing or execution time.

## Overview

Orchestrator-facing dispatch router for the implementation pipeline. The orchestrator holds only routing metadata — each step dispatches to an existing skill's task file via `task()`. The orchestrator is a pure router — never reads task file content, never performs inline analysis. Sub-agents do the work.

**Step-level dispatch is the ONLY valid dispatch mode.** The orchestrator processes the plan INLINE, step by step. For each step, the orchestrator reads the step's dispatch indicator:
- `(**inline**)` — orchestrator executes directly
- `(**sub-agent**)` — orchestrator dispatches to a sub-agent with context via `task()`
- `(**clean-room**)` — orchestrator dispatches to a sub-agent with routing metadata only via `task()`

The orchestrator MUST NOT dispatch entire phases or batches to a single sub-agent. Every step with a `(**sub-agent**)` or `(**clean-room**)` indicator receives its own clean-room sub-agent. No phase-level batching. No batched dispatch. Each step's sub-agent is independent, receives only the step's SCs, and produces its own result contract.

## Persona

Pipeline router. Routes each pipeline stage to a clean-room sub-agent via `task()`. The orchestrator holds routing metadata only — never reads task file content, never performs inline analysis. An orchestrator that performs inline work has stopped being a router and started being a contaminant — every inline analysis artifact carries the orchestrator's preloaded bias through every downstream sub-agent, and the pipeline is poisoned from the first byte. Professional pipeline routers dispatch to sub-agents. Inlining means the pipeline was never clean.

**Step-level dispatch only.** The orchestrator reads the plan's steps sequentially and checks each step's dispatch indicator. Steps marked `(**inline**)` are executed directly by the orchestrator. Steps marked `(**sub-agent**)` or `(**clean-room**)` are dispatched individually to clean-room sub-agents. The orchestrator MUST NOT dispatch entire phases or batches to a single sub-agent. There is no default dispatch mode — every step declares its indicator explicitly.

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
| "pre-regression" / "baseline check" | `pre-regression` | `test-driven-development --task patterns` | `sub-task` | {issue_number} |
| "pre-regression-verify" / "verify baseline" | `pre-regression-verify` | `verification-before-completion --task verify` | `sub-task` | {issue_number} |
| "red-phase" / "write failing test" | `red` | `test-driven-development --task red` | `sub-task` | {issue_number} |
| "green-phase" / "implement" | `green` | `test-driven-development --task green` | `sub-task` | {issue_number} |
| "post-regression" / "re-run tests" | `post-regression` | `test-driven-development --task patterns` | `sub-task` | {issue_number} |
| "verify" / "verify implementation" | `verify` | `verification-before-completion --task verify` | `sub-task` | {issue_number} |
| "commit inline" / "inline commit" | `commit-inline` | Orchestrator runs git add + git commit directly | `inline` | {issue_number} |
| "audit" / "audit step" | `audit` | Orchestrator dispatch — dispatch audit task (phase-appropriate: verification-audit/spec-audit/plan-fidelity/etc.) via `task(subagent_type="general")` | `orchestrator` | {issue_number} |
| "z3-check" / "solve check" | `z3-check` | `solve --task check` | `inline` | {issue_number, contract_path} |
| "structural-checks" / "lint/typecheck" | `structural-checks` | `finishing-a-development-branch --task checklist` | `sub-task` | {issue_number} |
| "pre-pr-gate" / "pre-PR gate" | `pre-pr-gate` | `verification-before-completion --task verify` — reads all SC verdicts, BLOCKs if any FAIL | `sub-task` | {issue_number} |
| "rationalization-check" / "check for rationalization" | `rationalization-check` | `verification-before-completion --task verify` — dispatches clean-room sub-agent to evaluate whether proposed action is a rationalization. Sub-agent receives ONLY proposed action + rule text. Returns BLOCKED with REMEDIATION_MANDATORY if rationalization detected. | `sub-task` | {issue_number, proposed_action, rule_text} |
| "regression-check" / "regression tests" | `regression-check` | `test-driven-development --task patterns` | `sub-task` | {issue_number} |
| "review-prep" / "prepare review" | `review-prep` | `git-workflow --task review-prep` | `sub-task` | {issue_number} |
| "create-pr" / "create pull request" | `create-pr` | `pr-creation-workflow --task create` | `sub-task` | {issue_number, authorization_scope, halt_at} |
| "exec-summary" / "completion" | `exec-summary` | `completion-core --task completion` | `sub-task` | {issue_number} |
| "execute step" / "dispatch step" / "step dispatch" | `step-dispatch` | Orchestrator reads step's dispatch indicator: `(**inline**)` executes directly, `(**sub-agent**)` dispatches with context, `(**clean-room**)` dispatches with routing metadata only | `orchestrator` | {issue_number, plan_path, step_number} |

**Note:** The `audit` step dispatches the appropriate audit task (e.g., `verification-audit` for post-implementation, `spec-audit` for pre-implementation, `plan-fidelity` for plan validation) via `task(subagent_type="general")`:
- [ ] 1. Dispatch the audit task from audit skill with {spec_local_dir, artifact_evidence_dir}
- [ ] 2. If the audit returns non-clean-pass (FAIL): remediate the root cause, then restart from step 1. `DONE_WITH_CONCERNS` is coerced to FAIL per the bright-line coercion rule in this reference card §Trigger Dispatch Table.
- [ ] 3. On clean PASS: run inline Z3 check via `.opencode/tools/solve check --state-path ... --contract-path ...`

## Step Labels (for #932 naming convention)

`pre-regression`, `pre-regression-verify`, `red`, `green`, `post-regression`, `verify`, `commit-inline`, `audit`, `z3-check`, `structural-checks`, `pre-pr-gate`, `rationalization-check`, `regression-check`, `review-prep`, `create-pr`, `exec-summary`, `step-dispatch`

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
| `pre-regression` | `task(..., prompt: "execute patterns from test-driven-development. Read \`test-driven-development/tasks/patterns.md\` first")` |
| `pre-regression-verify` | `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")` |
| `red` | `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")` |
| `green` | `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")` |
| `post-regression` | `task(..., prompt: "execute patterns from test-driven-development. Read \`test-driven-development/tasks/patterns.md\` first")` |
| `verify` | `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")` |
| `commit-inline` | Orchestrator runs `git add <files> && git commit -m "<message>"` directly — no sub-agent dispatch |
| `audit` | `task(..., prompt: "execute audit from audit. Read \`audit/tasks/verification-audit.md\` first")` |
| `z3-check` | Orchestrator runs `.opencode/tools/solve check --state-path ... --contract-path ...` directly — no sub-agent dispatch |
| `structural-checks` | `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")` |
| `pre-pr-gate` | `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")` — reads all SC verdicts, BLOCKs if any FAIL |
| `regression-check` | `task(..., prompt: "execute patterns from test-driven-development. Read \`test-driven-development/tasks/patterns.md\` first")` |
| `review-prep` | `task(..., prompt: "execute review-prep from git-workflow. Read \`git-workflow-pr/tasks/review-prep.md\` first")` |
| `create-pr` | `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")` |
| `exec-summary` | `task(..., prompt: "execute completion from completion-core. Read \`completion-core/tasks/completion.md\` first")` |

**Exception — audit sequence:** The audit is a multi-step sequence, not a single dispatch. Each step is a separate numbered item:
1. Dispatch audit task (sub-agent) — dispatch the appropriate audit task via `task(subagent_type="general")`
2. `remediate` (inline) — if non-clean-pass, remediate and restart from step 1
3. `z3-check` (inline) — orchestrator runs Z3 check after AUDIT per phase

## Sub-Agent Routing

**Orchestrator entry point:** The orchestrator reads the plan and dispatches each step per the Trigger Dispatch Table using step-level dispatch. The orchestrator reads each step's dispatch indicator: `(**inline**)` for direct execution, `(**sub-agent**)` or `(**clean-room**)` for individual `task()` dispatch. No phase-level batching. The Trigger Dispatch Table IS the single source of truth — the orchestrator dispatches each step using the canonical dispatch string from the table. No task files are read by the orchestrator.

All substantive work runs via `task(subagent_type="general")`. The orchestrator is a pure router — no creative work, no file edits, no inline analysis. Auditor tasks also use `subagent_type="general"` — the task file provides all role-specific behavior. Dispatch contracts carry exactly 2 fields: `spec_local_dir` and `artifact_evidence_dir`. No `audit_phase` field. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`.

**Exception — audit sequence:** The audit is a multi-step sequence, not a single dispatch. Each step is a separate numbered item (dispatch audit task, remediate inline, z3-check inline). See Invocation section for the complete sequence.

Exclusions: implementation context, agent memory, cached verification results.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.
> This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read the task file then execute step 1" | "execute red from test-driven-development" |
| Preloaded step sequences | "Step 1: red. Step 2: green." | "execute green from test-driven-development" |
| Preloaded expected outcomes | "Return { test_count, pass_count }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The rename was just completed so we need to..." | Pure objective, no narrative |
| Missing task file discovery directive | "execute green from test-driven-development" without task file path | "execute green from test-driven-development. Read `test-driven-development/tasks/green.md` first" |

## Required: Sub-agent Task File Discovery Directive

Every `task()` prompt that dispatches a named task MUST include a discovery directive in the format:

```
execute <task> from <skill>. Read `<skill>/tasks/<task>.md` first
```

This directive tells the sub-agent which task file to load independently — it is NOT preloading the file content. The sub-agent opens and reads the task file in its own clean-room context, discovers the procedure, and executes autonomously. Without this directive, the sub-agent must search for the correct task file, which is wasted context and routing ambiguity.

This is NOT a violation of the preloading prohibition. The task file path is routing metadata (which file to load), not execution context (what the file contains). The sub-agent still reads the file independently and discovers scope on its own.

### Dispatch Context Contract

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

### Pipeline Re-Priming Enforcement Block

At every pipeline stage transition (pre-work → execute-plan → verification-before-completion → finishing-checklist → review-prep), the orchestrator re-encounters this enforcement block restating procedural discipline:

- Sub-agents execute — orchestrators route
- No inline work — all file modifications, analysis, and decisions go through clean-room sub-agents
- The orchestrator holds routing metadata only — task file contents, analysis artifacts, and verification results go to sub-agents or disk
- Every stage transition is a re-encounter of this discipline — context degrades between gates, and re-priming prevents drift

### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)

## State Management

> **Note:** Plan step order IS the state machine. The former `pipeline-state-machine.yaml` and Z3-based solve state tracking have been removed. The pipeline's step sequence in the plan defines the valid state transitions. No separate state machine contract is needed.

## Remediation Routing

When a step returns FAIL, the orchestrator:
- [ ] 1. Reads the FAIL artifact's YAML frontmatter from disk
- [ ] 2. Dispatches the `research` skill to determine remediation scope
- [ ] 3. Routes to `remediation_steps[0].target_step` based on research findings
- [ ] 4. Re-runs the pipeline from the target remediation step

## DONE_WITH_CONCERNS Coercion Rule

`DONE_WITH_CONCERNS` is a coercion trigger at the verification honesty gate. When a sub-agent returns `DONE_WITH_CONCERNS`, the orchestrator MUST coerce it to FAIL per the bright-line coercion rule. Caveats are defects, not completions — a `DONE` status with a non-empty `caveat_summary` is also coerced to FAIL.

This rule is referenced by:
- `approval-gate-scope/SKILL.md` — Trigger Dispatch Table
- `guidelines/065-verification-honesty.md` — Hard Failure Discipline section

## Artifact Retention

### Rule 1: Permanent Artifacts Never Cleaned

Artifacts under `.issues/{issue-N}/` (root repo) or `{project_root}/{path}/.issues/{issue-N}/` (submodule/sub-repo) are permanent — they survive pipeline restarts, branch switches, and PR merges. Never delete or clean these files. They serve as the authoritative audit trail for spec lifecycle, SC coverage, verification consistency, and revision re-entry protocols.

### Rule 2: Ephemeral Artifacts Cleaned at PR Merge

Artifacts under `{project_root}/tmp/{issue-N}/` are ephemeral — they are cleaned at PR merge cleanup (`git-workflow --task cleanup`). These include constraints contracts, decomposition validations, phase exit contracts, and phase-plan-validated files. Before PR merge, all permanent artifacts must be finalized and no unresolved references to ephemeral paths may remain in the lifecycle manifest.

### Rule 3: Step-Specific Pre-Cleanup

At the start of each pipeline step, clean previous-run artifacts for that step to prevent stale state contamination:

| Step Label | Pre-Cleanup Action |
|------------|-------------------|
| `pre-regression` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-pre-regression-*` |
| `pre-regression-verify` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-pre-regression-verify-*` |
| `red` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-red-*` |
| `green` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-green-*` |
| `post-regression` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-post-regression-*` |
| `verify` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-verify-*` |
| `commit-inline` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-commit-inline-*` |
| `audit` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-audit-*` |
| `z3-check` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-z3-check-*` |
| `structural-checks` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-structural-checks-*` |
| `pre-pr-gate` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-pre-pr-gate-*` |
| `regression-check` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-regression-check-*` |

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

## Sub-agent Context Shape

### Context shape and exclusions for task() routing

The sub-agent receives only routing metadata and task-specific context. Exclusions:
- Orchestrator reasoning
- Expected outcomes
- Inline file paths
- Agent memory
- Cached verification results

### Work State File Format

Work state files are stored at `{project_root}/tmp/{issue-N}/work.md` and contain:

```markdown
# Work State: <branch-name>

Authorization: "<authorization-text>"
Authorization scope: <scope>
PR strategy: <strategy>
Branch: <branch-name>
Worktree: <worktree-path>

## Issues

- [x|#] <issue-number> — <issue-title>

## Progress

### <issue-number> — <title>
- Status: PENDING | IN_PROGRESS | DONE | BLOCKED
- Sub-branch: <sub-branch-name>
- Result: <result-contract-summary>
```

### Evidence Artifacts

Every claim about work state MUST have a corresponding tool-call artifact:
- Work state file read → verify branch/status entries
- Git commands → verify branch/worktree state
- GitHub API calls → verify issue/PR state

Claims without artifacts are verification honesty violations.

## Context Passing

### What Pre-Work Needs FROM Authorization

```yaml
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
issue_number: int
```

**`must_receive` validation:** The task context `must_receive` array MUST include `authorization_scope`. If missing, HALT and report a context-contamination violation.

### What Implementation Needs FROM Pre-Work

```yaml
branch: string
working_tree_clean: bool
```

### What Review-Prep Needs FROM Implementation

```yaml
files_changed: list
commit_summary: string
implementation_status: success | failure
```

### What Verification Gate Needs FROM Implementation

```yaml
issue_number: int
phase: string
success_criteria: list
files_changed: list
```

### What Finishing Checklist Needs FROM Verification

```yaml
branch: string
verification_passed: true
```

### What Chat Needs FROM Review-Prep

```yaml
compare_url: string (actionable link)
exec_summary: string (markdown, human-readable)
```

### Phase Progress — What Travels at Phase Boundaries

When the orchestrator task()s a sub-agent for a phase that follows a prior phase, the task context MUST carry phase progress information composed from prior sub-agent results and the work state file at `{project_root}/tmp/{N}/work.md`. This information ensures each phase knows what has already been accomplished and can act accordingly.

The orchestrator builds phase_progress incrementally. Before each sub-agent task():
- [ ] 1. Read the work state file (`{project_root}/tmp/{N}/work.md`) to identify which phases are already complete
- [ ] 2. Accumulate `completed_phases`, `concern_boundaries_crossed`, and `verification_evidence` from each prior sub-agent's result
- [ ] 3. If this sub-agent's work crosses a concern boundary, note the transition in `concern_boundaries_crossed`

**How it is NOT composed:** There is no fixed template, no rigid YAML schema, no mandatory section headers. The orchestrator describes progress in natural prose that communicates what the next sub-agent needs to know. The information requirement is the rule; the encoding is up to the agent.

### Decision Log for Full Context History

`prior_context` in the task context carries the most recent intent summary — it is designed for immediate consumption by the next sub-agent. For the full history of design decisions across ALL phases, the orchestrator and sub-agents should reference the **Decision Log** persisted on the Plan issue.

The Decision Log is an append-only sequence stored in `.issues/` local storage. Each entry captures one sub-agent's `decision_log_entry` — the design decisions made during that phase. It survives session restarts because it lives in the `.issues/` directory, not in transient agent context.

When `prior_context` references a decision that may need fuller explanation, the orchestrator should note "see Decision Log in `.issues/N/comments.md`" so the sub-agent can retrieve the full context history if needed.

To append a decision log entry:
```bash
./.opencode/tools/local-issues comment N --body "decision_log_entry: <content>"
```

Decision log entries are classified as `internal` content per the content classification gate. They are written to `.issues/N/comments.md` only — they are NOT posted to GitHub Issue comments.

### Edge Cases

#### Context Lost Between Steps
If a yield-back produces empty or missing fields:
- [ ] 1. HALT orchestration
- [ ] 2. Report which context field is missing
- [ ] 3. Wait for manual intervention

#### Phase Progress with No Prior Phases
For the first sub-agent task()ed (no prior phases completed), `phase_progress` should still be present but note that no prior phases exist. For example: "No phases completed yet. This is the first phase." This ensures the field is never absent — it is either populated with prior progress or explicitly states that no progress has been made.

#### Pre-Work Asks for Auth Again
Pre-work receives context from orchestrator — no re-authorization check needed. If pre-work prompts for auth, it received stale context. Re-invoke with fresh context from approval-gate.

### Live Verification: Context Accuracy (MANDATORY)

**Verify task context accuracy before sending to sub-agents.**

| Claim | Verification Action | Tool Call | Problem Class |
|-------|-------------------|-----------|---------------|
| "worktree.path correct" | Verify path exists | `ls -d <path>` | STRUCTURE-VIOLATION |
| "Session vars current" | Verify vars match session init | Check against session values | VERIFICATION-GAP |
| "Prior results accurate" | Verify result contracts from prior sub-agents | Read work state file | VERIFICATION-GAP |

## Dispatch Mode Verification Gate

Pre-execution verification gate that runs after `assemble-work` creates the dispatch plan but before `pipeline-executor` begins execution. Rejects any plan containing `per-phase` or `batched` dispatch modes, or steps without explicit dispatch indicators.

### Entry Criteria

- [ ] 1. Work state file exists at `{project_root}/tmp/{issue-N}/work.md`
- [ ] 2. Plan is available at `{plan_path}`
- [ ] 3. All plan steps are identified with step numbers

### Procedure

#### 1. Scan for Prohibited Modes
Check the entire plan for any occurrence of:
- `per-phase` — forbidden
- `batched` — forbidden
- `batch` — forbidden
- `Dispatch: sub-agent-with-context` — forbidden
- `Dispatch: sub-agent-clean-room` — forbidden
- Phase-level dispatch without per-step indicators — forbidden

**If any prohibited mode found:**
1. Record the exact location (file, line, step)
2. Return `status: BLOCKED` with `reason: PROHIBITED_DISPATCH_MODE`
3. Include `artifact_path` pointing to the scan output

#### 2. Verify Every Step Has an Explicit Indicator
Check every step in the plan for an explicit dispatch indicator:
- `(**inline**)` — valid
- `(**sub-agent**)` — valid
- `(**clean-room**)` — valid

**If any step lacks an indicator:**
1. Record the step number and name
2. Return `status: BLOCKED` with `reason: MISSING_DISPATCH_INDICATOR`
3. Include the list of steps missing indicators in `blocker_reason`

#### 3. Verify No Default Mode
Confirm that the plan does not document any "default dispatch mode" or "fallback dispatch" — every step must be explicit.

**If any default/fallback dispatch documentation found:**
1. Return `status: BLOCKED` with `reason: DEFAULT_DISPATCH_FOUND`

#### 4. Return PASS
If all checks pass:
- `status: DONE`
- `finding_summary: "All steps have valid dispatch indicators. No prohibited modes found. {N} steps verified."`
- `artifact_path: {project_root}/tmp/{issue-N}/verify/dispatch-mode-verification.yaml`

### Verification

- [ ] grep for `per-phase` in plan → absent
- [ ] grep for `batched` in plan → absent
- [ ] grep for `batch` in plan → absent
- [ ] Every step matches `\(\*\*(inline|sub-agent|clean-room)\*\*\)` pattern
- [ ] No step matches `\(\*\*(per-phase|batched)\*\*\)` pattern

## Overflow Signal

### OVERFLOW Contract Format

When a sub-agent's context window exceeds capacity during execution, it MUST emit an OVERFLOW result contract:

```yaml
status: OVERFLOW
task: <task-name>
completed_items: [<item-ids-or-names>]
remaining_items: [<item-ids-or-names>]
context_usage: <estimated-percentage>
suggested_split: <proposed-split-strategy>
```

### Re-Dispatch Protocol

When the implementation-pipeline per the Trigger Dispatch Table receives an OVERFLOW result:

- [ ] 1. Record completed items in work state file
- [ ] 2. Create new sub-agent task(s) for remaining items using suggested split strategy
- [ ] 3. Re-dispatch new sub-agent(s) with reduced scope
- [ ] 4. Continue orchestration with accumulated results

### Split Strategies

| Strategy | When | Action |
|----------|------|--------|
| Per-item | Single large item causing overflow | Split into one sub-agent per remaining item |
| Per-phase | Multi-phase task with phase boundary | Split at phase boundaries |
| Chunked | Many small items | Split remaining items into 2-3 equal chunks |
| Fallback | No clear split point | HALT and report context overflow to developer |

### Context Allocation Awareness

Signal OVERFLOW only on concrete, observable signs:
- Tool output is truncated mid-result with content missing
- Required spec, plan, or file content cannot be included in task context because earlier content fills the window
- Previously read content is no longer accessible due to context displacement

Sub-process dispatch (opencode run, task()) spawns independent processes — they do not affect orchestrator context allocation.

## Cross-References

Skills: `approval-gate`, `git-workflow`, `test-driven-development`, `verification-before-completion`, `finishing-a-development-branch`, `audit`, `completion-core`, `pre-analysis`, `completeness-gate`, `research`. Guidelines: `091-incremental-build.md`, `000-critical-rules.md`.

Co-authored with AI: OpenCode (deepseek-v4-flash)
