---
title: "Plan: Authorization Scope ≠ Implementation Trigger"
number: 1799
status: draft
---

## Goal

Prevent the agent from conflating authorization scope with implementation trigger. Two failure modes: (1) question-as-authorization leading to file deletion, (2) "approved for pr" skipping the plan pipeline.

## Architecture

Three phases, each producing one SC:

1. **Phase 1** — Add the Authorization Scope ≠ Implementation Trigger block to `010-approval-gate.md` (SC-1, string evidence)
2. **Phase 2** — Create behavioral test file `authorization-scope-not-trigger.sh` (SC-2, structural evidence)
3. **Phase 3** — Verify behavioral tests pass (SC-3, SC-4, behavioral evidence, depends on Phase 2)

## Files

| File | Phase | Action |
|------|-------|--------|
| `.opencode/guidelines/010-approval-gate.md` | 1 | Insert authorization scope block |
| `.opencode/tests/behaviors/authorization-scope-not-trigger.sh` | 2 | Create behavioral test |
| `.opencode/tests/behaviors/helpers.sh` | 2 | Reference (read-only) |

## Phase Table

| Phase | SCs | Depends On | Concern |
|-------|-----|------------|---------|
| 1 | SC-1 | None | Guideline text |
| 2 | SC-2 | None | Test infrastructure |
| 3 | SC-3, SC-4 | Phase 2 | Behavioral verification |

## Exit Criteria

- Plan index stored at `.opencode/.issues/1799/plan.md`
- Phase files stored at `.opencode/.issues/1799/plan-01.md`, `plan-02.md`, `plan-03.md`
- All validation passed
- Plan reported in chat with path
- Approval cascade applied (auto-approved for `for_pr` scope)
- All implementation-pipeline gate steps enumerated in phase structure
- Step numbering globally sequential across all phases
- Phase exit criteria for behavioral SCs include both `behavior_run` artifact generation AND `behavioral-test-evaluation` clean-room dispatch steps
- Each SC in exit criteria carries `evidence_type` metadata annotation
- VbC section for behavioral SCs includes mandatory gate: after artifact generation, dispatch `behavioral-test-evaluation` before allowing PASS verdict

## Self-Review Evidence

- Spec #1799 approved with `for_pr` scope
- 4 SCs identified with evidence types: string, structural, behavioral, behavioral
- Phase dependency: Phase 3 depends on Phase 2 (test file must exist before test can run)
- Implementation-pipeline steps enumerated in each phase
