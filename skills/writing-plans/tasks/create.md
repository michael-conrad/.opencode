# Task: create

## Purpose

Create an implementation plan from an approved spec. Plans are stored at `.issues/{N}/plan.md`.

## Prerequisites

1. Approved spec (verified by approval-gate)
2. Spec stored in `.issues/{N}/spec.md`
3. Spec has explicit approval (`approved` or `go`)
4. (Optional) `authorization_scope` from verify-authorization — if scope >= `for_plan`, plan auto-approval triggers

## Operating Protocol

1. **Verification first:** Must run verification-enforcement --task verify before reading spec
2. **Combined or separate decision:** Early evaluation whether plan content references spec content inline (combined) or stands alone with separate phase sections (separate)
3. **Item decomposition mandatory:** Plan must enumerate items, order dependencies, specify acceptance criteria
4. **RED checkpoint mandatory:** Every TDD task must include explicit Step 2 checkpoint
5. **Approval cascade auto-approve:** Pipeline scope (`for_plan+`) auto-approves plan
6. **Handoff verification pre-PASS:** Before any plan content is written, spec-to-plan handoff MUST return PASS. This is a non-waivable hard gate — no exceptions, no "proceed anyway."

## Entry Criteria

- Spec is approved and stored in `.issues/{N}/spec.md`
- `authorization_scope` received from approval-gate (for cascade)
- Spec-to-plan handoff PASS (verified by handoffs/spec-to-plan task artifact at `./tmp/{issue-N}/artifacts/spec-to-plan-handoff-*.yaml` with `status: PASS`)

## Exit Criteria

- Plan stored at `.issues/{N}/plan.md`
- All validation passed
- Plan reported in chat with `.issues/{N}/plan.md` path
- Approval cascade applied (auto-approval for pipeline scope)

## Procedure

### Steps 0-5: Plan Structure Definition

**Route to:** `create/plan-structure`

Runs verification gate, makes combined/separate decision, checks for duplicate plans, maps file structure, defines phase structure, and creates TDD tasks with mandatory RED checkpoints.

### Steps 6-13: Plan Creation and Approval Cascade

**Route to:** `create/create-and-validate`

Writes plan header, stores at `.issues/{N}/plan.md`, runs self-review and validation, revisits verification, cross-references skills, runs handoff-consistency check against the spec-to-plan manifest, and applies approval cascade with scope-aware auto-approval.

## Sub-Task Files

| Sub-Task | Purpose | Words |
| -- | -- | -- |
| `create/plan-structure` | Verification, combined/separate decision, file mapping, TDD definition | ≈750 |
| `create/create-and-validate` | Document writing, local storage, validation, approval cascade | ≈650 |

## Orchestrator Execution Protocol

1. Read the dispatch tables in the plan to determine the gate sequence for the current phase
2. Execute every gate in every phase in numeric order (G1, G2, G3, ...)
3. Do NOT skip any gate — every row is mandatory
4. Do NOT reorder gates — the sequence is defined by the plan
5. For `sub-task` gates: call `task()` with the exact `Receives Context` JSON object as the prompt, using the specified `Sub-Agent Type`
6. For `inline` gates: execute the described operation directly (no sub-agent)
7. After each gate completes, verify the SCs listed in that gate's SCs column
8. Report progress via chat output only — zero GitHub Issue comments during implementation unless absolutely warranted
9. After each phase completes, run the Inter-Phase Handoff steps before advancing to the next phase
10. Do NOT modify the plan — it is a static definitional artifact. Only mutate for remediation or scope revision

## Dispatch Table

Every plan phase MUST include a dispatch table using EXACTLY the following 6-column format. No deviations.

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G{N}: {step-label} | sub-task or inline | yes (blind) or N/A | general or N/A | JSON context or — | SC-N |

### Dispatch Table Rules

1. **One row per gate.** Every gate in the sequence must have exactly one row. No merged cells, no multi-step rows.
2. **Dispatch Type is binary:** `sub-task` (orchestrator tasks a clean-room sub-agent) or `inline` (orchestrator executes directly — restricted to CHECKPOINT-COMMIT only).
3. **Blind? column:** `yes (blind)` means the sub-agent receives only the Receives Context JSON — no other context from prior gates. `N/A` for inline gates.
4. **Sub-Agent Type:** Use `general` for sub-task gates. Use `N/A` for inline gates.
5. **Receives Context:** A JSON object with task instruction, issue number, phase number. For sub-task gates this is the EXACT prompt passed to `task()`. For inline gates this is `—` (em dash, no context).
6. **SCs column:** Lists the SCs this gate verifies (e.g., `SC-1, SC-2`). Must match SC IDs from the spec.
7. **Standard gate set is dynamic.** The gate labels and step sequence MUST be pulled from `implementation-pipeline/SKILL.md` §Dispatch Routing Table at the time of plan creation. Do NOT hardcode gate names — reference the canonical source. The current standard set is: `sc-coherence-gate`, `pre-red-baseline`, `red-phase`, `red-doublecheck`, `post-red-enforcement`, `green-phase`, `post-green-enforcement`, `checkpoint-commit`, `structural-checks`, `green-doublecheck`, `green-vbc`, `adversarial-audit`, `cross-validate`, `regression-check`, `review-prep`, `exec-summary`. Any deviation from this set must be justified.

### Dynamic Standard Gate Set Mandate

The dispatch table for every phase MUST pull the list of gate step labels from `implementation-pipeline/SKILL.md` §Dispatch Routing Table. This is a MANDATORY dynamic reference — gate names are NOT hardcoded in `create.md`. The gate labels, their dispatch targets, and artifact requirements are defined in the implementation-pipeline skill and may evolve independently. If a gate is added or removed from the implementation-pipeline Dispatch Routing Table, plans follow automatically without updating `create.md`.

### Inline Gates Restriction

Only `checkpoint-commit` may be an inline gate. All other gates MUST be `sub-task`. This restriction ensures every pipeline step is executed by a clean-room sub-agent except the git commit, which is a mechanical operation.

### Inter-Phase Handoff

Between the last gate of phase N and gate 1 of phase N+1:

- Update Z3 state file: `solve state update` with phase N's gate states
- Run `solve check`: confirm phase N dependency contract still SAT
- Verify checkpoint tag exists for phase N
- Append lifecycle manifest event for phase N completion

### Post-All-Phases Sweep

After the last phase's final gate:

- [ ] FINISHING CHECKLIST — **orchestrator routes to finishing sub-agent**: git status clean, lint/typecheck from scratch, coverage sweep
- [ ] PR CREATION — **orchestrator routes to git-workflow pr-creation**: via `github_create_pull_request`, extract `html_url` from response
- [ ] POST-MERGE CLEANUP — **orchestrator routes to git-workflow cleanup**: delete merged branches, close issues, sync dev

### Concern Boundary Annotations

When transitioning between architectural concerns, describe:
- What concern being left (prior scope)
- What concern being entered (new scope)
- What information the new concern needs from prior (handoff point)

## Plan Format

Plan is stored at `.issues/{N}/plan.md`. Combined and separate affect which sections the plan document includes but not where it is stored.

**Combined (single-task):**
- Write to `.issues/{N}/plan.md`, reference spec content inline
- Retain `[SPEC]` title prefix on spec

**Separate (multi-task):**
- Write to `.issues/{N}/plan.md` with separate phase sections
- Phases are sections in the local plan file — no sub-issues

## Approval Cascade Matrix

| Scope | Plan Approval | Implementation |
| -- | -- | -- |
| `for_review_prep` | Separate approval required | Separate approval required |
| `for_spec` | N/A | N/A |
| `for_analysis` | N/A (analysis-only) | N/A |
| `for_plan` | Auto-approved | Separate approval required |
| `for_implementation` | Auto-approved | Auto-approved |
| `for_pr` | Auto-approved | Auto-approved |
| `for_pr_only` | N/A (skip) | N/A |

## Authorization Context

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Task() Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Context Required

- Related skills: `verification-enforcement`, `issue-operations`, `spec-creation`
- Related tasks: `create/plan-structure`, `create/create-and-validate`