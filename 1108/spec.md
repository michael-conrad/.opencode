# [SPEC] plan tool — skill card + behavioral test coverage + integration

## Summary

The `plan` tool has six gaps: `plan state update` missing `--contract-path`, `plan discover` prints to stderr, no skill card, no standalone problem YAML schema reference, no documented fallback, and no behavioral test for `discover`. Scope covers `.opencode/tools/plan` (tool source) and `.opencode/skills/plan/` (new skill card).

## All-or-Nothing Gate

All SC-1 through SC-13 must PASS for this spec to be complete.

## Phase Dependencies

| Phase | Name | Depends On |
|-------|------|------------|
| 1 | Fix `plan state update` (`--contract-path`) | — |
| 1b | Fix `plan discover` stdout output | — |
| 2 | Create plan skill card | Phase 1, Phase 1b |
| 3 | Behavioral tests | Phase 1, Phase 1b |
| 4 | Integration | Phase 2, Phase 3 |

## Success Criteria

| ID | Criterion | Evidence Type | Depends On | Verification Method |
|----|-----------|---------------|------------|---------------------|
| SC-1 | `plan state update --contract-path` rejects out-of-domain values | `behavioral` | — | Test with domain-limited contract |
| SC-2 | `plan state update --contract-path` accepts in-domain values | `behavioral` | — | Test with domain-limited contract |
| SC-3 | `plan state update` without `--contract-path` works as before (regression guard) | `structural` | — | Re-run basic state update without --contract-path |
| SC-4 | `plan discover` output can be piped | `behavioral` | — | Bash pipe test |
| SC-5 | Skill dispatch gate routes to `plan` skill | `behavioral` | — | `opencode-cli run` + `assert_semantic` |
| SC-6 | Each task file has entry criteria, procedure, exit criteria | `structural` | — | File existence |
| SC-7 | Problem task includes full YAML schema sections | `string` | — | grep for section keywords |
| SC-8 | Fallback task documents acyclic check | `string` | — | grep for fallback patterns |
| SC-9 | PDDL task documents both directions | `string` | — | grep for to-pddl and from-pddl |
| SC-10 | `plan discover` exits 0 and prints to stdout | `behavioral` | SC-4 | Bash pipe capture |
| SC-11 | `plan state init` + `--contract-path` enforces domain | `behavioral` | SC-1, SC-2 | Bash script |
| SC-12 | `plan` skill registered in AGENTS.md | `string` | SC-6 | grep |
| SC-13 | Referencing task files route through plan skill | `string + behavioral` | SC-6 | grep + semantic check |

## Files Changed

- `.opencode/tools/plan` — modified (Phase 1 + Phase 1b)
- `.opencode/skills/plan/SKILL.md` — created (Phase 2)
- `.opencode/skills/plan/tasks/{problem,plan,validate,pddl,ground,fallback,state}.md` — created (Phase 2)
- `.opencode/tests/behaviors/` — created (Phase 3)
- `.opencode/AGENTS.md` — modified (Phase 4)
- Referencing task files — modified (Phase 4)

## Dependencies

None — independent from the `solve` spec. Both can be implemented in parallel.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)