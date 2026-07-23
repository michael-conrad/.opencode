# Phase 6: Behavioral tests

**Skill:** `test-driven-development`
**Task:** `red-green-cycle`
**Target:** `.opencode/tests-v2/behaviors/`
**SCs:** SC-4, SC-16
**Depends On:** Phase 5

## Context

- Replace existing `dispatch-boundary-writing-plans.sh` with new flat pipeline tests
- Remove tests for removed functionality (clean-room, handoffs, etc.)
- Add behavioral tests for:
  - Create workflow produces routing-table plan (SC-4)
  - Revise loop (max 3 iterations)
  - Spec-not-found blocks with SPEC_NOT_FOUND
  - Skill+task validation returns FAIL on invalid reference
  - Retroactive backfill
  - Plan artifact format compliance (SC-4)
- Old tests must FAIL, new tests must PASS
- Use `with-test-home` wrapper for all opencode run calls

## Entry Criteria

- [ ] Phase 5 complete (old directories removed)
- [ ] New writing-plans fully implemented

## Procedure

1. Identify existing behavioral tests for old architecture
2. Remove/replace old dispatch-boundary-writing-plans.sh
3. Write new behavioral tests for flat pipeline
4. Run new tests → verify PASS
5. Verify old tests → FAIL

## Exit Criteria

- [ ] Old dispatch-boundary-writing-plans.sh removed or replaced
- [ ] New flat pipeline tests pass
- [ ] SC-4 verified: plan artifact uses routing-table format
- [ ] SC-16 verified: old tests FAIL, new tests PASS
