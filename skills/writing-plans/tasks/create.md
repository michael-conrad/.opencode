# Task: create

## Purpose

Create an implementation plan from an approved spec. Plans are stored at `.issues/{N}/spec-artifacts/plan.md`.

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

- Plan stored at `.issues/{N}/spec-artifacts/plan.md`
- All validation passed
- Plan reported in chat with `.issues/{N}/spec-artifacts/plan.md` path
- Approval cascade applied (auto-approval for pipeline scope)

## Procedure

### Steps 0-5: Plan Structure Definition

**Route to:** `create/plan-structure`

Runs verification gate, makes combined/separate decision, checks for duplicate plans, maps file structure, defines phase structure, and creates TDD tasks with mandatory RED checkpoints.

### Steps 6-13: Plan Creation and Approval Cascade

**Route to:** `create/create-and-validate`

Writes plan header, stores at `.issues/{N}/spec-artifacts/plan.md`, runs self-review and validation, revisits verification, cross-references skills, runs handoff-consistency check against the spec-to-plan manifest, and applies approval cascade with scope-aware auto-approval.

## Sub-Task Files

| Sub-Task | Purpose | Words |
| -- | -- | -- |
| `create/plan-structure` | Verification, combined/separate decision, file mapping, TDD definition | ≈750 |
| `create/create-and-validate` | Document writing, local storage, validation, approval cascade | ≈650 |

## Plan Phase Structure Requirements — Mandatory Enumerated Checklist with Routing Annotations

Every plan phase MUST use EXACTLY the following 14-item enumerated checklist with routing annotations. No free-form prose outside the Concern/Files/SCs header block. No deviations.

Each checklist item MUST include a routing annotation specifying which agent role executes it:
- **orchestrator routes to [sub-agent-type]** — orchestrator tasks a clean-room sub-agent
- **orchestrator inline** — orchestrator performs the action directly (only for git commits, file reads, artifact verification)

The 14 gates with routing annotations:

- [ ] 1. SC-COHERENCE-GATE — **orchestrator routes to pre-analysis**: verify spec SCs are internally consistent and complete for this phase
- [ ] 2. PRE-RED-BASELINE — **orchestrator routes to exploration**: run full test suite, confirm all existing tests PASS before any changes
- [ ] 3. RED-PHASE — **orchestrator routes to RED sub-agent**: write enforcement test at permanent path → run → capture output to `./tmp/{issue-N}/artifacts/{phase}-test-output.log` → expected FAIL (exit non-zero)
- [ ] 4. RED-DOUBLECHECK — **orchestrator inline**: confirm RED evidence artifact exists and shows non-zero exit
- [ ] 5. GREEN-PHASE — **orchestrator routes to GREEN sub-agent (clean-room, receives spec + test path only)**: implement change → run test → capture output → expected PASS (exit 0)
- [ ] 6. CHECKPOINT-COMMIT — **orchestrator inline**: git commit -m "phase N checkpoint" with test + change
- [ ] 7. STRUCTURAL-CHECKS — **orchestrator routes to structural sub-agent**: lint, format, typecheck on changed files
- [ ] 8. GREEN-DOUBLECHECK — **orchestrator inline**: confirm GREEN evidence artifact exists and shows exit 0
- [ ] 9. GREEN-VBC — **orchestrator routes to VbC sub-agent**: verification-before-completion against this phase's SCs
- [ ] 10. ADVERSARIAL-AUDIT — **orchestrator routes to resolve-models**: dispatches 2 auditors for plan-fidelity + concern-separation
- [ ] 11. CROSS-VALIDATE — **orchestrator inline**: verify dual-auditor consensus on all phase SCs
- [ ] 12. REGRESSION-CHECK — **orchestrator routes to regression sub-agent**: full test suite, confirm nothing previously passing is now broken
- [ ] 13. REVIEW-PREP — **orchestrator routes to review-prep sub-agent**: compare URL (verified from session-init), PR body draft for the phase
- [ ] 14. EXEC-SUMMARY — **orchestrator inline**: read all sub-agent result contracts, produce phase completion report with SC status, artifact paths, byline

### Inter-Phase Handoff

Between gate 14 of phase N and gate 1 of phase N+1:

- Update Z3 state file: `solve state update` with phase N's gate states
- Run `solve check`: confirm phase N dependency contract still SAT
- Verify checkpoint tag exists for phase N
- Append lifecycle manifest event for phase N completion

### Post-All-Phases Sweep

After the last phase's gate 14:

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

Plan is stored at `.issues/{N}/spec-artifacts/plan.md`. Combined and separate affect which sections the plan document includes but not where it is stored.

**Combined (single-task):**
- Write to `.issues/{N}/spec-artifacts/plan.md`, reference spec content inline
- Retain `[SPEC]` title prefix on spec

**Separate (multi-task):**
- Write to `.issues/{N}/spec-artifacts/plan.md` with separate phase sections
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