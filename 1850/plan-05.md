# Phase 5: Behavioral Enforcement Tests

**SCs:** SC-5, SC-6, SC-7, SC-8, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24, SC-25
**Dependencies:** Phases 2, 3, 4 (gates must exist before tests can verify them)

## Steps

1. Create `.opencode/tests/behaviors/spec-audit-holistic-gate.sh` — covers SC-3, SC-5, SC-6, SC-7, SC-8, SC-19, SC-21, SC-22, SC-23, SC-24, SC-25:
   - Test: ambiguous spec with "Design Options" → holistic gate FAILs Implementability, DRAFT status
   - Test: clean spec with "Alternatives Considered & Why Discarded" → holistic gate PASSes all 11
   - Test: contradictory spec (preamble says X, body does Y) → FAIL on Internal Consistency
   - Test: untestable SC ("must be intuitive") → FAIL on Testability
   - Test: escape hatch language ("use best judgment") → FAIL on Escape Hatches
   - Test: unsupported claims → FAIL on Provenance
   - Test: infeasible spec (references non-existent function) → FAIL on Feasibility
   - Test: unsafe spec (destructive op without rollback) → FAIL on Safety
   - Test: untraceable spec (orphan SCs) → FAIL on Traceability
   - Test: incorrect spec (solves wrong problem) → FAIL on Correctness

2. Create `.opencode/tests/behaviors/plan-writer-holistic-gate.sh` — covers SC-11:
   - Test: ambiguous spec → plan writer hard-fails with escalation message listing failed dimensions

3. Create `.opencode/tests/behaviors/plan-fidelity-holistic-gate.sh` — covers SC-14, SC-20:
   - Test: broken plan → plan-fidelity hard-fails with escalation
   - Test: escape hatch plan → plan-fidelity FAILs on Escape Hatches

4. Create `.opencode/tests/behaviors/plan-revision-holistic-gate.sh` — covers SC-16:
   - Test: ambiguous revised spec → revision hard-fails with escalation

5. Create `.opencode/tests/behaviors/implementation-holistic-gate.sh` — covers SC-18:
   - Test: broken plan → implementation hard-fails with escalation

## Verification

- All 11 behavioral SCs verified via `opencode-cli run` with appropriate test prompts
- Each test uses `assert_semantic` for behavioral evidence (clean-room AI inspector)
- `assert_stderr_pattern_present` used as secondary corroboration for tool dispatch strings only
