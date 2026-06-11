# [SPEC] solve tool — model precondition fix + skill card + behavioral test coverage

## Summary

The `solve` tool has three gaps: (1) `solve model` ignores contract preconditions + invariants, (2) no dedicated skill card exists, (3) `solve prove` has zero behavioral test coverage. Scope covers `.opencode/tools/solve` (tool source) and `.opencode/skills/solve/` (new skill card).

## All-or-Nothing Gate

All SC-1 through SC-11 must PASS for this spec to be complete.

## Phase Dependencies

| Phase | Name | Depends On |
|-------|------|------------|
| 1 | Fix `solve model` precondition assertion | — |
| 2 | Create solve skill card | — |
| 3 | Behavioral test for `solve prove` | — |
| 4 | Integration | Phase 2, Phase 3 |

## Success Criteria

| ID | Criterion | Evidence Type | Depends On | Verification Method |
|----|-----------|---------------|------------|---------------------|
| SC-1 | Contradictory contract → `solve model` returns UNSAT | `behavioral` | — | `opencode-cli run` with test contract |
| SC-2 | Valid contract + consistent query → `solve model` returns SAT | `behavioral` | — | `opencode-cli run` with test contract |
| SC-3 | Existing inline-constraint queries continue to work | `behavioral` | SC-1 | Re-run existing behavioral tests |
| SC-4 | Skill dispatch gate routes to `solve` skill | `behavioral` | — | `opencode-cli run` + stderr assertion |
| SC-5 | Each task file has entry criteria, procedure, exit criteria | `structural` | — | File verification |
| SC-6 | Contract task references Z3 expression syntax | `string` | — | grep for key patterns |
| SC-7 | Fallback task documents acyclic graph check | `string` | — | grep for fallback patterns |
| SC-8 | Valid theorem → `solve prove` returns VALID | `behavioral` | — | `opencode-cli run` |
| SC-9 | Invalid theorem → `solve prove` returns INVALID | `behavioral` | — | `opencode-cli run` |
| SC-10 | `solve` skill registered in AGENTS.md | `string` | SC-5 | grep |
| SC-11 | Referencing task files route through solve skill | `string + behavioral` | SC-5 | grep + behavioral test |

## Files Changed

- `.opencode/tools/solve` — modified (Phase 1)
- `.opencode/skills/solve/SKILL.md` — created (Phase 2)
- `.opencode/skills/solve/tasks/{contract,state,check,model,prove,fallback}.md` — created (Phase 2)
- `.opencode/tests/behaviors/` — created (Phase 3)
- `.opencode/AGENTS.md` — modified (Phase 4)
- Referencing task files — modified (Phase 4)

## Dependencies

None — independent from the `plan` spec.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)