# Plan: DISPATCH_GATE Migration Broke Enforcement Chain

**Spec:** [#1836](https://github.com/michael-conrad/.opencode/issues/1836)
**Spec file:** `.opencode/.issues/1836/spec.md`
**Created:** 2026-07-10
**Authorization scope:** `for_pr` (label: `approved-for-pr`)

## Goal

Restore hard-gate enforcement content from `operating-protocol.md` files back into SKILL.md files where `skill()` loads it, add analysis-depth prevention gate to plan creation pipeline, add TDD chaining triggers to dispatch tables, and write behavioral enforcement tests.

## Architecture

The fix operates on 4 skills across the `.opencode` submodule:

| Skill | File | Change |
|-------|------|--------|
| `test-driven-development` | `SKILL.md` | Restore Five Core Principles as inline prose |
| `test-driven-development` | `tasks/operating-protocol.md` | Remove restored content |
| `writing-plans` | `SKILL.md` | Restore operating protocol as inline prose |
| `writing-plans` | `tasks/operating-protocol.md` | Remove restored content |
| `writing-plans` | `tasks/validate.md` | Add analysis-depth checks |
| `implementation-pipeline` | `SKILL.md` | Restore moved content + add TDD chaining triggers |
| `executing-plans` | `SKILL.md` | Add per-item TDD cycle enforcement triggers |
| `tests/behaviors/` | `tdd-interleaving.sh` | New behavioral test |
| `tests/behaviors/` | `analysis-depth-gate.sh` | New behavioral test |

## Affected Files

| File | Phase | Change Type |
|------|-------|-------------|
| `.opencode/skills/test-driven-development/SKILL.md` | 1 | Restore inline prose |
| `.opencode/skills/test-driven-development/tasks/operating-protocol.md` | 1 | Remove restored content |
| `.opencode/skills/writing-plans/SKILL.md` | 1 | Restore inline prose |
| `.opencode/skills/writing-plans/tasks/operating-protocol.md` | 1 | Remove restored content |
| `.opencode/skills/implementation-pipeline/SKILL.md` | 1, 3 | Restore content + add triggers |
| `.opencode/skills/writing-plans/tasks/validate.md` | 2 | Add analysis-depth checks |
| `.opencode/skills/executing-plans/SKILL.md` | 3 | Add TDD enforcement triggers |
| `.opencode/tests/behaviors/tdd-interleaving.sh` | 4 | New behavioral test |
| `.opencode/tests/behaviors/analysis-depth-gate.sh` | 4 | New behavioral test |

## Phase Table

| Phase | Title | SCs | Evidence Types |
|-------|-------|-----|----------------|
| 1 | Restore Hard-Gate Content to SKILL.md | SC-1, SC-2, SC-3, SC-4, SC-5, SC-10 | `string` |
| 2 | Add Analysis-Depth Prevention Gate | SC-6 | `string` |
| 3 | Add TDD Chaining Triggers to Dispatch Tables | SC-7, SC-8 | `string` |
| 4 | Behavioral Tests + Audit | SC-9, SC-11 | `behavioral`, `string` |

## Exit Criteria

- All 4 phases complete with verified PASS for all SCs
- SC-1 through SC-6, SC-9, SC-10 verified via `grep` (string evidence)
- SC-7, SC-8 verified via `opencode-cli run` + `assert_semantic` (behavioral evidence)
- All behavioral SCs have `behavior_run` artifact generation + `behavioral-test-evaluation` clean-room dispatch in their exit criteria
- Full enforcement test suite passes (`bash .opencode/tests/test-enforcement.sh --changed`)

## Self-Review Evidence

- [ ] Spec reference present: `Spec: #1836`
- [ ] No placeholders (TBD/TODO)
- [ ] All SCs mapped to phases
- [ ] Global sequential numbering across all phases
- [ ] Behavioral SCs have model-execution-and-evaluation exit criteria
- [ ] All SCs carry `evidence_type` annotation in phase files
- [ ] All implementation-pipeline gate steps enumerated in phase structure

> **One step at a time protocol:** Execute phases in order. Do not skip ahead. If a phase fails, remediate before proceeding. Each phase produces verified PASS before the next phase begins.
>
> **Self-remediation protocol:** If a verification step fails, diagnose the root cause, fix it, and re-verify. Do not proceed past a FAIL. If re-verification also fails, HALT and report the blocker.
