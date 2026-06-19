# Task: create

## Purpose

Create an implementation plan from an approved spec. Plans are stored at `.issues/{N}/plan.md`.

## Prerequisites

- [ ] 1. Approved spec (verified by approval-gate)
- [ ] 2. Spec stored in `.issues/{N}/spec.md`
- [ ] 3. Spec has explicit approval (`approved` or `go`)
- [ ] 4. (Optional) `authorization_scope` from verify-authorization — if scope >= `for_plan`, plan auto-approval triggers

## Operating Protocol

- [ ] 1. **Verification first** — **orchestrator routes to**: `verification-enforcement --task verify` via sub-agent — Must run verification-enforcement --task verify before reading spec content
- [ ] 2. **Combined or separate decision** — Procedure: early evaluation whether plan content references spec content inline (combined) or stands alone with separate phase sections (separate)
- [ ] 3. **Item decomposition mandatory** — Procedure: plan must enumerate items, order dependencies, specify acceptance criteria
- [ ] 4. **RED checkpoint mandatory** — Procedure: every TDD task must include explicit Step 2 checkpoint
- [ ] 5. **Approval cascade auto-approve** — Procedure: pipeline scope (`for_plan+`) auto-approves plan
- [ ] 6. **Handoff verification pre-PASS** — **orchestrator routes to**: `handoffs/spec-to-plan` via sub-agent — Before any plan content is written, spec-to-plan handoff MUST return PASS. This is a non-waivable hard gate — no exceptions, no "proceed anyway."
- [ ] 7. **Checklist format mandatory** — Procedure: all plan phases MUST use the numbered checklist format with dispatch indicators. Steps are `- [ ] N.` with `(**clean-room**)` or `(**inline**)` dispatch mode indicators. The gate labels, step sequence, and dispatch targets MUST reference the canonical source at `implementation-pipeline/SKILL.md` §Dispatch Routing Table. This is the default format for every phase — no exceptions, no simplified alternatives.

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

- [ ] 8. **Plan Structure Definition** — **orchestrator routes to**: `create/plan-structure` via sub-agent — Runs verification gate, makes combined/separate decision, checks for duplicate plans, maps file structure, defines phase structure, and creates TDD tasks with mandatory RED checkpoints.

- [ ] 9. **Plan Creation and Approval Cascade** — **orchestrator routes to**: `create/create-and-validate` via sub-agent — Writes plan header, stores at `.issues/{N}/plan.md`, runs self-review and validation, revisits verification, cross-references skills, runs handoff-consistency check against the spec-to-plan manifest, and applies approval cascade with scope-aware auto-approval.

## Sub-Task Files

| Sub-Task | Purpose | Words |
| -- | -- | -- |
| `create/plan-structure` | Verification, combined/separate decision, file mapping, TDD definition | ≈750 |
| `create/create-and-validate` | Document writing, local storage, validation, approval cascade | ≈650 |

## Orchestrator Execution Protocol

- [ ] 1. Read the numbered checklist steps in the plan to determine the gate sequence for the current phase
- [ ] 2. Execute every step in every phase in numeric order (1, 2, 3, ...)
- [ ] 3. Do NOT skip any step — every entry is mandatory
- [ ] 4. Do NOT reorder steps — the sequence is defined by the plan
- [ ] 5. For `(**clean-room**)` steps: dispatch a clean-room sub-agent via `task()` with scoped context
- [ ] 6. For `(**inline**)` steps: execute the described operation directly (no sub-agent)
- [ ] 7. After each step completes, verify the SCs referenced in that step's `→ SC-N` annotation
- [ ] 8. Report progress via chat output only — zero GitHub Issue comments during implementation unless absolutely warranted
- [ ] 9. After each phase completes, run the Inter-Phase Handoff steps before advancing to the next phase
- [ ] 10. Do NOT modify the plan — it is a static definitional artifact. Only mutate for remediation or scope revision

## Checklist Format Specification

Every plan phase MUST use the numbered checklist format with dispatch indicators. No deviations.

### Dispatch Mode Mapping

- `sub-task` → `(**clean-room**)`
- Everything else (orchestrator, inline) → `(**inline**)`

### Discovery Directive

Read `implementation-pipeline/SKILL.md` §Dispatch Routing Table for the canonical gate sequence and dispatch types. Do NOT hardcode gate names — reference the canonical source at plan-creation time.

### Sub-Step Expansion Directive

Gates with sub-steps (e.g., `adversarial-audit` with resolve-models → auditor_1 → remediate → auditor_2 → cross-validate) MUST be expanded into multiple `- [ ] N.` entries. Prohibit collapsing sub-steps into prose.

### Output Format

```
- [ ] 1. <gate-label> (**<dispatch-mode>**) — <unit-specific exit criterion>
  - <sub-step description> (**<dispatch-mode>**)
  - <sub-step description> (**<dispatch-mode>**)
- [ ] 2. <gate-label> (**<dispatch-mode>**) — <unit-specific exit criterion>
...
```

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