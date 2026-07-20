## Problem

The "one-step-at-a-time protocol" admonishment in `writing-plans/tasks/write.md` §Plan Format Requirements has three defects:

1. **"exactly one sub-agent dispatch" is wrong** — Steps with `(**inline**)` dispatch indicator (checkpoint commits, Z3 checks, VbC blocks) are not sub-agent dispatches. The text should say "exactly one unit of work (sub-agent dispatch or inline operation)."

2. **RED→GREEN-specific poisoning language is redundant** — The SAT solver already enforces RED-before-GREEN as a dependency constraint. The prose about "the phase is poisoned — all work in it MUST be discarded" duplicates what Z3 checks already guarantee. The self-remediation protocol in the bottom admonishment handles all step violations uniformly.

3. **No validation that dispatch indicators match step content** — A step labeled `(**inline**)` that dispatches a sub-agent, or a step labeled `(**sub-agent**)` that runs a simple inline check, is a plan defect. No validation rule catches this.

## Affected Files

| File | Change |
|------|--------|
| `writing-plans/tasks/write.md` | Fix one-step-at-a-time protocol admonishment (top copy) |
| `writing-plans/tasks/write.md` | Fix one-step-at-a-time protocol admonishment (bottom copy) |
| `writing-plans/tasks/write.md` §Validation Rules | Add rule 14: dispatch indicator matches step content |
| `writing-plans/tasks/validate.md` | Add dispatch indicator validation check |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Top one-step-at-a-time protocol admonishment says "exactly one unit of work (sub-agent dispatch or inline operation)" instead of "exactly one sub-agent dispatch" | `string` | grep for "unit of work" in top admonishment |
| SC-2 | Top admonishment has no RED→GREEN-specific poisoning language ("phase is poisoned", "MUST be discarded", "restarted from RED") | `string` | grep for absence of "poisoned" in top admonishment |
| SC-3 | Bottom self-remediation protocol admonishment is unchanged (already correct) | `string` | grep for "self-remediation protocol" in bottom admonishment |
| SC-4 | `write.md` §Validation Rules has rule 14: "Dispatch indicator matches step content — `(**inline**)` steps are orchestrator-executable operations; `(**sub-agent**)/(**clean-room**)` steps require independent discovery" | `string` | grep for rule 14 in Validation Rules |
| SC-5 | `validate.md` checks dispatch indicators against step content and returns FAIL on mismatch | `behavioral` | Run validate task on a plan with intentionally mismatched indicators; assert FAIL |

## Implementation Plan

### Phase 1: Fix top admonishment in `write.md`

1. Change "exactly one sub-agent dispatch" to "exactly one unit of work (sub-agent dispatch or inline operation)"
2. Remove the RED→GREEN-specific paragraph entirely (lines about "The RED→GREEN transition is a zero-tolerance gate... the phase is poisoned... MUST be discarded... restarted from RED")
3. Verify bottom admonishment (self-remediation protocol) is unchanged

### Phase 2: Add validation rule 14

1. Add to `write.md` §Validation Rules: "14. Dispatch indicator matches step content — `(**inline**)` steps are orchestrator-executable operations; `(**sub-agent**)/(**clean-room**)` steps require independent discovery"
2. Update `validate.md` to check this rule and return FAIL on mismatch

### Phase 3: Behavioral enforcement test

1. Write a test that creates a plan with intentionally mismatched dispatch indicators
2. Run validate task; assert FAIL

## Risks

| Risk | Mitigation |
|------|------------|
| Existing plans with the old admonishment text become stale | The admonishment is boilerplate in generated plans — old plans are superseded when re-generated through the pipeline |
| Dispatch indicator validation is too strict (e.g., a step that reads a file could be either inline or sub-agent) | Validation checks that the indicator is *plausible* for the step content, not that it's the *only* correct indicator. A step that says "run git commit" with `(**sub-agent**)` is clearly wrong; a step that says "read file and analyze" with either indicator is acceptable |

## Dependencies

None. Self-contained fix to `writing-plans` skill files.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
