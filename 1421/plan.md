# Implementation Plan — [.opencode#1421](https://github.com/michael-conrad/.opencode/issues/1421) — Gap-Fill Cascade Restructuring

**Goal:** Replace the gap-fill cascade with a state-verification checklist model. The cascade becomes a routing-only dispatcher that loads per-scope checklist files. Each checklist item verifies a state and, if missing, reports which action to take next.

**Architecture:** Three-phase sequential plan. Phase 1 creates checklist files and rewrites the dispatcher. Phase 2 removes obsolete scopes and updates guidelines. Phase 3 writes behavioral enforcement tests.

**Files:**
- `skills/approval-gate/tasks/gap-fill-cascade.md` — rewrite as routing dispatcher
- `skills/approval-gate/tasks/gap-fill-cascade/for-pr.md` — create
- `skills/approval-gate/tasks/gap-fill-cascade/for-implementation.md` — create
- `skills/approval-gate/tasks/gap-fill-cascade/for-plan.md` — create
- `skills/approval-gate/enforcement/scope-parsing.md` — remove for_pr_only/for_review_only
- `skills/approval-gate/enforcement/auto-dispatch-table.md` — remove for_pr_only/for_review_only
- `skills/approval-gate/SKILL.md` — remove for_pr_only/for_review_only
- `skills/approval-gate/tasks/verify-authorization.md` — remove for_pr_only/for_review_only
- `skills/approval-gate/tasks/verify-authorization/gap-fill-cascade.md` — remove for_pr_only/for_review_only
- `skills/approval-gate/tasks/verify-authorization/auto-dispatch.md` — remove for_pr_only/for_review_only
- `guidelines/010-approval-gate.md` — remove gap-fill column, remove for_pr_only/for_review_only
- `guidelines/000-critical-rules.md` — remove for_pr_only/for_review_only
- `guidelines/020-go-prohibitions.md` — remove for_review_only
- `guidelines/080-code-standards.md` — add YAML-only rule
- ~71 skill task files — remove pr_strategy from template blocks
- `.opencode/tests/behaviors/gap-fill-cascade-for-pr.sh` — create
- `.opencode/tests/behaviors/gap-fill-cascade-missing-plan.sh` — create

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Execute steps sequentially. Do NOT skip ahead. Do NOT batch steps. Do NOT parallelize. Each step depends on the previous step's output. If a step fails, HALT and remediate before proceeding. The orchestrator dispatches each step to a clean-room sub-agent via `task()`. The orchestrator does NOT execute steps inline.

> **Step Status:** Before each step, the orchestrator MUST update the step's status to `in_progress`. After completion, update to `completed`. If blocked, update to `blocked` with reason. This is tracked via `todowrite` lifecycle.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range |
|-------|------|---------|-----|--------------|------------|
| 1 | Checklist Files and Dispatcher | Create per-scope checklist files and rewrite gap-fill-cascade.md as routing dispatcher | SC-1, SC-2, SC-3, SC-4, SC-5 | None | 1-10 |
| 2 | Scope Removal and Guideline Updates | Remove for_pr_only/for_review_only, remove gap-fill column, add YAML-only rule, remove pr_strategy | SC-6, SC-7, SC-10, SC-11 | Phase 1 | 11-20 |
| 3 | Behavioral Tests | Write behavioral enforcement tests for SC-8 and SC-9 | SC-8, SC-9 | Phase 2 | 21-30 |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **Self-remediation protocol:** When a step fails, the orchestrator MUST NOT proceed to the next step. The orchestrator MUST diagnose the failure, remediate the root cause, and re-run the failed step. If remediation fails after 2 attempts, the orchestrator MUST HALT and report the blocker. The orchestrator MUST NOT skip the failed step or reorder steps to work around the failure.

## Exit Criteria

- [ ] C1. Plan index exists at `.opencode/.issues/1421/plan.md` with phase table
- [ ] C2. Phase files exist at `.opencode/.issues/1421/plan-01.md`, `plan-02.md`, `plan-03.md`
- [ ] C3. All validation checks PASS (no placeholders, all steps actionable)
- [ ] C4. Audit-fidelity PASS (plan faithfully reflects spec)
- [ ] C5. Audit-concern PASS (concerns properly separated)
- [ ] C6. Approval cascade applied (auto-approved for for_pr scope)
- [ ] C7. Plan reported in chat with path
- [ ] C8. All implementation-pipeline gate steps enumerated in phase structure
- [ ] C9. Step numbering is globally sequential across all phases
- [ ] C10. Dispatch indicators match step content

## Self-Review Evidence

- Spec coverage: All 11 SCs mapped to phases (SC-1 through SC-5 → Phase 1, SC-6/SC-7/SC-10/SC-11 → Phase 2, SC-8/SC-9 → Phase 3)
- Placeholders: None — all steps have concrete actions
- Type consistency: All dispatch indicators use valid types (`(**sub-agent**)`, `(**inline**)`)
- Global sequential numbering: Steps 1-10 (Phase 1), 11-20 (Phase 2), 21-30 (Phase 3)
- Three-tier structure: Global pre-phase (coherence gate), per-phase RED/GREEN chains, global post-phase (VbC, audit, review-prep)
