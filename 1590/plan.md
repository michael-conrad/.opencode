# Implementation Plan — [#1590](https://github.com/michael-conrad/.opencode/issues/1590) — SKILL.md Trigger Dispatch Table pipeline entry gate + farmage description pattern

## Goal

1. Remove sub-step entries from Trigger Dispatch Tables in `spec-creation/SKILL.md` and `writing-plans/SKILL.md`, keeping only pipeline entry points
2. Establish farmage description pattern as the mandatory standard for all skill cards
3. Update all affected skill card descriptions to farmage pattern
4. Update skill-creator infrastructure (template, validate task, dispatch table) to enforce the pattern

## Architecture

Six phases — Phases A and B are independent (parallel). Phase C depends on A+B. Phases D, E, F are independent of each other and of A/B/C.

## SC-ID Traceability

| SC ID | Criterion | Phase | Evidence Type | Verification Method |
|-------|----------|-------|---------------|---------------------|
| SC-1 | spec-creation dispatch table — no sub-step entries | A | `string` | grep returns 0 matches |
| SC-1 (Tasks) | spec-creation Tasks table — no sub-step entries | A | `string` | grep returns 0 matches |
| SC-3 | spec-creation Invocation — 2 entries | A | `string` | grep count = 2 |
| SC-2 | writing-plans dispatch table — only create/retroactive/completion | B | `string` | grep returns 0 matches for sub-steps |
| SC-4 | writing-plans Programmatic Invocation — 3 entries | B | `string` | grep count = 3 |
| SC-5 | Behavioral test: sequential step execution | C | `behavioral` | opencode-cli run |
| SC-6 | Behavioral test: no direct write dispatch | C | `behavioral` | opencode-cli run |
| SC-7 | spec-creation description — farmage pattern | D | `string` | grep for `Trigger phrases:` |
| SC-8 | writing-plans description — farmage pattern | D | `string` | grep for `Trigger phrases:` |
| SC-9 | adversarial-audit description — farmage pattern | D | `string` | grep for `Trigger phrases:` |
| SC-10 | plan description — farmage pattern + spec.md requirement | D | `string` | grep for `Trigger phrases:` and `spec.md` |
| SC-11 | solve description — farmage pattern + contract/state requirement | D | `string` | grep for `Trigger phrases:` and `Contract YAML` |
| SC-12 | skill-creator description — farmage pattern | D | `string` | grep for `Trigger phrases:` |
| SC-13 | routing-only-template — farmage format spec | E | `string` | grep for `farmage pattern` |
| SC-14 | validate task — farmage enforcement checks | E | `string` | grep for `Farmage Description Pattern` |
| SC-15 | skill-creator dispatch table — audit + farmage entries | F | `string` | grep for `skill card audit` and `farmage pattern` |

## Phase A — Edit spec-creation/SKILL.md

**Files:** `.opencode/skills/spec-creation/SKILL.md`
**SCs:** SC-1, SC-1 (Tasks), SC-3
**Dependencies:** None (parallel with Phase B)

### Steps

- [ ] 1. Remove sub-step entries from Trigger Dispatch Table — keep only `create` and `completion`
- [ ] 2. Remove sub-step entries from Tasks table — keep only `create` and `completion`
- [ ] 3. Remove sub-step entries from Invocation table — keep only `create` and `completion`
- [ ] 4. Verify: grep for sub-step names in dispatch table returns 0 matches

## Phase B — Edit writing-plans/SKILL.md

**Files:** `.opencode/skills/writing-plans/SKILL.md`
**SCs:** SC-2, SC-4
**Dependencies:** None (parallel with Phase A)

### Steps

- [ ] 1. Remove sub-step entries from Trigger Dispatch Table — keep only `create`, `retroactive`, `completion`
- [ ] 2. Remove sub-step entries from Programmatic Invocation table — keep only `create`, `retroactive`, `completion`
- [ ] 3. Verify: grep for sub-step names returns 0 matches

## Phase C — Behavioral enforcement tests

**Files:** `.opencode/tests/behaviors/1590-sc5-sequential-step-execution.sh`, `.opencode/tests/behaviors/1590-sc6-no-direct-write-dispatch.sh`
**SCs:** SC-5, SC-6
**Dependencies:** Phase A AND Phase B complete

### Steps

- [ ] 1. Create behavioral test for SC-5 (sequential step execution)
- [ ] 2. Create behavioral test for SC-6 (no direct write dispatch)

## Phase D — Update skill descriptions to farmage pattern

**Files:** 6 SKILL.md files
**SCs:** SC-7 through SC-12
**Dependencies:** None (independent)

### Steps

- [ ] 1. Update `spec-creation/SKILL.md` description — add `Invoke for:` (9 items), `Trigger phrases:` (18 phrases)
- [ ] 2. Update `writing-plans/SKILL.md` description — add `Invoke for:` (7 items), `Trigger phrases:` (12 phrases)
- [ ] 3. Update `adversarial-audit/SKILL.md` description — add `Also use when`, `Invoke for:` (13 items), `Trigger phrases:` (11 phrases)
- [ ] 4. Update `plan/SKILL.md` description — add `Also use when`, `Invoke for:` (8 items), `Trigger phrases:` (14 phrases), spec.md requirement
- [ ] 5. Update `solve/SKILL.md` description — add `Also use when`, `Invoke for:` (9 items), `Trigger phrases:` (11 phrases), contract/state requirement
- [ ] 6. Update `skill-creator/SKILL.md` description — add `Also use when`, `Invoke for:` (7 items), `Trigger phrases:` (12 phrases)
- [ ] 7. Verify all 6: grep for `Trigger phrases:` returns 1 match each

## Phase E — Update skill-creator infrastructure

**Files:** `.opencode/skills/skill-creator/reference/routing-only-template.md`, `.opencode/skills/skill-creator/tasks/validate.md`
**SCs:** SC-13, SC-14
**Dependencies:** None (independent)

### Steps

- [ ] 1. Add farmage description format specification to `routing-only-template.md` — include all 7 rules
- [ ] 2. Add Farmage Description Pattern (MANDATORY) section to `validate.md` — include 7 validation checks
- [ ] 3. Verify: grep for `farmage pattern` in template returns 1 match
- [ ] 4. Verify: grep for `Farmage Description Pattern` in validate task returns 1 match

## Phase F — Update skill-creator dispatch table

**Files:** `.opencode/skills/skill-creator/SKILL.md`
**SCs:** SC-15
**Dependencies:** None (independent)

### Steps

- [ ] 1. Add dispatch table entry: `"skill card audit" / "review skills" / "audit skill cards"` → `validate` with `audit_mode: "full"`
- [ ] 2. Add dispatch table entry: `"description pattern" / "farmage pattern" / "enforce description pattern"` → `validate` with `audit_mode: "farmage"`
- [ ] 3. Verify: grep for `skill card audit` and `farmage pattern` in dispatch table returns 1 match each

## Exit Criteria

- C1-C4: Dispatch tables and invocation sections trimmed (SC-1 through SC-4)
- C5-C6: Behavioral tests exist (SC-5, SC-6)
- C7-C12: All 6 skill descriptions follow farmage pattern (SC-7 through SC-12)
- C13: Routing-only template includes farmage format spec (SC-13)
- C14: Validate task includes farmage enforcement checks (SC-14)
- C15: Skill-creator dispatch table has audit and farmage entries (SC-15)
- All changes committed on feature branch
