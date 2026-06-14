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

## Plan Phase Structure Requirements — Dispatch Table Mandate

Every plan phase MUST include a dispatch table. The table is the executable checklist for the orchestrator. Each row is one gate. The orchestrator executes rows in numeric order.

**No separate checklist file.** The dispatch tables ARE the checklist. A separate `implementation-checklist.md` that mirrors the same rows is duplication and creates a sync hazard.

### Orchestrator Execution Protocol (MANDATORY — top of every plan)

Every plan MUST begin with an execution protocol that the orchestrator follows:

1. Read the dispatch tables in this plan to determine the gate sequence
2. Execute every gate in every phase in numeric order (G1, G2, G3, ...)
3. NOT skip any gate — every row is mandatory
4. NOT reorder gates — the sequence is the plan
5. For `sub-task` gates: call `task()` with the exact `Receives Context` JSON object as the prompt, using the specified `Sub-Agent Type`
6. For `inline` gates: execute the described operation directly (no sub-agent)
7. After each gate completes, verify the SCs listed in that gate's SCs column
8. Report progress via chat output only — zero GitHub Issue comments during implementation unless absolutely warranted (blocker requiring developer input, spec revision changing scope). Issue bodies and plan files are revised directly and synced as needed — comments are not a revision mechanism
9. After each phase completes, run the Inter-Phase Handoff steps before advancing to the next phase
10. Do NOT modify this plan — it is a static definitional artifact. Only mutate for remediation or scope revision

### Dispatch Table (MANDATORY per phase — this IS the plan)

Every phase MUST include a dispatch table. The table is the executable checklist for the orchestrator. Each row is one gate. The orchestrator executes rows in order.

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|

**Column definitions:**
- **Gate**: Gate identifier (e.g., `G1: SC-Coherence-Gate`, `G5: GREEN-Phase`). The orchestrator executes gates in numeric order.
- **Dispatch Type**: `sub-task` (via task()) or `inline` (orchestrator does it directly without a sub-agent)
- **Blind?**: `yes (blind)` for clean-room sub-agents (no context beyond what's in Receives Context), `no` for context-aware, `N/A` for inline
- **Sub-Agent Type**: The subagent_type parameter (e.g., `general`, `pre-analysis`, `resolve-models`). Only meaningful when Dispatch Type is `sub-task`.
- **Receives Context**: The exact context object to pass in the task() prompt. Must be a valid JSON object — not prose description. The orchestrator passes this verbatim.
- **SCs**: Which success criteria this gate verifies. The orchestrator checks these SCs after the gate completes.

**Rules:**
- All sub-task dispatches MUST be blind (clean-room) by default unless explicitly justified
- Inline gates are limited to: RED-doublecheck, GREEN-doublecheck, Checkpoint-Commit, Cross-Validate, Exec-Summary
- Every SC must appear in at least one gate's SCs column
- The Receives Context column must be a valid JSON object (not prose description)
- Gates are executed in numeric order — the orchestrator does NOT reorder
- The orchestrator MUST NOT skip a gate — every row is mandatory
- No separate checklist file — the dispatch table IS the checklist

### Inter-Phase Handoff

Between the last gate of phase N and gate G1 of phase N+1:

- Update Z3 state file: `solve state update` with phase N's gate states
- Run `solve check`: confirm phase N dependency contract still SAT
- Verify checkpoint tag exists for phase N
- Append lifecycle manifest event for phase N completion

### Post-All-Phases Sweep

After the last phase's final gate:

- [ ] FINISHING CHECKLIST — **orchestrator routes to finishing sub-agent**: git status clean, lint/typecheck from scratch, coverage sweep
- [ ] PR CREATION — **orchestrator routes to git-workflow pr-creation**: via `github_create_pull_request`, extract `html_url` from response
- [ ] POST-MERGE CLEANUP — **orchestrator routes to git-workflow cleanup**: delete merged branches, close issues, sync dev

### Solve and Plan Mandatory

- `solve check` on dependency contract: MUST return SAT. If UNSAT, HALT.
- `plan plan` on phase problem: MUST return SOLVED_SATISFICING or SOLVED_OPTIMALLY. If UNSOLVABLE, HALT.
- No fallback paths. No "If utility unavailable, validate manually." HALT on unavailability.

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