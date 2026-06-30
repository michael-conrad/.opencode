# [SPEC-FIX] SKILL.md Trigger Dispatch Table has no pipeline entry gate — allows skipping mandatory pipeline steps

## Problem

SKILL.md cards have three structural elements that interact to create a bypass that allows the orchestrator to skip mandatory pipeline steps:

1. **Trigger Dispatch Table** — lists all tasks as independently dispatchable entries, including sub-steps of a pipeline. The orchestrator reads this as a menu and picks individual tasks.

2. **Operating Protocol** — a sequential numbered checkbox list with chain dependencies that defines the correct execution order. This IS the gate.

3. **Invocation section** — provides canonical `task()` strings for every task, including sub-steps. This reads as: "Pick the task you need and dispatch it."

The orchestrator follows the path of least resistance: Trigger Dispatch Table → find task → Invocation section → get canonical string → dispatch. The sequential Operating Protocol is never checked because the dispatch table offers individual tasks as independent entry points.

## Root Cause

The Trigger Dispatch Table exposes sub-steps of a pipeline as standalone dispatchable entries. The sequential numbered checkbox list in the Operating Protocol already encodes the correct dependency order — but the dispatch table provides a bypass by listing sub-steps directly.

## Evidence

### spec-creation/SKILL.md

Trigger Dispatch Table lists: `requirements`, `decompose`, `traceability`, `risk`, `diagram`, `write`, `change-control`, `completion` — all as standalone entries.

Operating Protocol has 10 sequential steps with chain dependencies. Step 9 (`write`) chains on `step_5, step_8` — meaning requirements, decompose, traceability, risk, solve model, solve check, and plan plan must all complete first.

The orchestrator dispatched `write` directly without running steps 1-8 because the dispatch table offered `write` as a standalone entry.

### writing-plans/SKILL.md

Trigger Dispatch Table lists: `research`, `readiness`, `structure`, `solve`, `write`, `revisit`, `validate`, `audit-fidelity`, `audit-concern` — all as standalone entries.

Operating Protocol has 22 sequential steps. The orchestrator dispatched `write` directly without running the pipeline.

## Fix

### A. Remove sub-step entries from Trigger Dispatch Tables

Remove sub-step entries from the Trigger Dispatch Table. Only expose pipeline entry points. The sequential numbered Operating Protocol IS the gate — the orchestrator MUST follow it in order.

#### spec-creation/SKILL.md

**Remove from Trigger Dispatch Table:** `requirements`, `decompose`, `traceability`, `risk`, `diagram`, `write`, `change-control`, `completion`

**Keep only:** `"write spec" / "create spec"` → dispatches the full Operating Protocol (steps 1-10)

The Invocation section should only list the pipeline entry point, not individual sub-steps.

#### writing-plans/SKILL.md

**Remove from Trigger Dispatch Table:** `research`, `readiness`, `structure`, `solve`, `write`, `revisit`, `validate`, `audit-fidelity`, `audit-concern`

**Keep only:** `create`, `retroactive`, `completion`

The Programmatic Invocation table should only list pipeline entry points, not individual sub-steps.

### B. Farmage description pattern (MANDATORY for all skill cards)

All SKILL.md `description` fields MUST follow the farmage/opencode-skills pattern for reliable agent matching:

```
description: "Use when <primary use case>. Also use when <secondary use cases>. Invoke for: <comma-separated task list>. <Mandatory enforcement statement>. Trigger phrases: <comma-separated trigger phrase list>."
```

**Rules:**
1. `Use when` — primary use case (1 sentence)
2. `Also use when` — secondary/edge case use (1 sentence, omit if none)
3. `Invoke for:` — comma-separated list of task names the skill handles
4. Enforcement statement — e.g., "Spec creation is REQUIRED before implementation."
5. `Trigger phrases:` — comma-separated list of natural language phrases an agent might say to invoke this skill
6. Max 1024 characters (opencode limit)
7. Exclusion clauses (`— distinct from <exclusion>`) for skills that could false-match

This pattern applies to ALL skill cards in `.opencode/skills/` — both existing and new.

#### Skill cards updated to farmage pattern

| Skill | Description changes |
|-------|-------------------|
| `spec-creation` | Added `Invoke for:` (9 items), `Trigger phrases:` (18 phrases) |
| `writing-plans` | Added `Invoke for:` (7 items), `Trigger phrases:` (12 phrases) |
| `adversarial-audit` | Added `Also use when`, `Invoke for:` (13 items), `Trigger phrases:` (11 phrases) |
| `plan` | Added `Also use when`, `Invoke for:` (8 items), `Trigger phrases:` (14 phrases). Added requirement: "An approved spec stored as a local `spec.md` file is REQUIRED before any plan operation." |
| `solve` | Added `Also use when` (spec-creation/writing-plans pipeline context), `Invoke for:` (9 items), `Trigger phrases:` (11 phrases). Added requirement: "Contract YAML files (variable declarations + logical constraints) and state YAML files (variable assignments) are REQUIRED." |
| `skill-creator` | Added `Also use when` (farmage enforcement, skill card audit), `Invoke for:` (7 items), `Trigger phrases:` (12 phrases) |

### C. Routing-only template updated with farmage pattern

The `routing-only-template.md` at `.opencode/skills/skill-creator/reference/routing-only-template.md` now includes the farmage description format specification with all 7 rules inline in the template.

### D. skill-creator validate task updated with farmage enforcement

The `validate.md` task at `.opencode/skills/skill-creator/tasks/validate.md` now includes a **Farmage Description Pattern (MANDATORY)** section with 7 validation checks that all skill cards must pass.

### E. skill-creator dispatch table expanded

Added two new dispatch table entries to `skill-creator/SKILL.md`:
- `"skill card audit" / "review skills" / "audit skill cards"` → `validate` with `audit_mode: "full"`
- `"description pattern" / "farmage pattern" / "enforce description pattern"` → `validate` with `audit_mode: "farmage"`

### F. Orchestrator Behavior

When the orchestrator loads a skill and matches a trigger, it reads the Operating Protocol and executes the sequential numbered checkbox list in order. Each step's dispatch indicator tells it whether to dispatch a sub-agent or execute inline. The orchestrator does NOT skip steps — it follows the numbered sequence.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Pipeline Step Binding | Re-Entry Step | Verification Gate | Artifact Path | Phase Binding |
|----|-----------|---------------|---------------------|----------------------|---------------|-------------------|---------------|---------------|
| SC-1 | `spec-creation/SKILL.md` Trigger Dispatch Table has only pipeline entry points — no sub-step entries | `string` | grep for sub-step task names in dispatch table — must return 0 matches | edit-files | null | ci | `skills/spec-creation/SKILL.md` | common |
| SC-2 | `writing-plans/SKILL.md` Trigger Dispatch Table has only `create`, `retroactive`, `completion` — no sub-step entries | `string` | grep for sub-step task names in dispatch table — must return 0 matches | edit-files | null | ci | `skills/writing-plans/SKILL.md` | common |
| SC-3 | `spec-creation/SKILL.md` Invocation section lists only pipeline entry point | `string` | Invocation section has 1 entry, not 8 | edit-files | null | ci | `skills/spec-creation/SKILL.md` | common |
| SC-4 | `writing-plans/SKILL.md` Programmatic Invocation table lists only pipeline entry points | `string` | Programmatic Invocation has 3 entries, not 9 | edit-files | null | ci | `skills/writing-plans/SKILL.md` | common |
| SC-5 | Behavioral test: "write spec" → orchestrator executes Operating Protocol steps 1-10 in order | `behavioral` | `opencode-cli run` with "write spec" → stderr shows sequential step execution | create-test | null | pre-commit | `./tmp/behavioral-evidence-*/` | common |
| SC-6 | Behavioral test: orchestrator does NOT dispatch `write` directly when sub-step entries removed | `behavioral` | `opencode-cli run` with "write spec" → stderr shows no direct `write` dispatch | create-test | null | pre-commit | `./tmp/behavioral-evidence-*/` | common |
| SC-7 | `spec-creation/SKILL.md` description follows farmage pattern | `string` | grep for `Trigger phrases:` in description — must return 1 match | edit-files | null | ci | `skills/spec-creation/SKILL.md` | common |
| SC-8 | `writing-plans/SKILL.md` description follows farmage pattern | `string` | grep for `Trigger phrases:` in description — must return 1 match | edit-files | null | ci | `skills/writing-plans/SKILL.md` | common |
| SC-9 | `adversarial-audit/SKILL.md` description follows farmage pattern | `string` | grep for `Trigger phrases:` in description — must return 1 match | edit-files | null | ci | `skills/adversarial-audit/SKILL.md` | common |
| SC-10 | `plan/SKILL.md` description follows farmage pattern and requires approved spec.md | `string` | grep for `Trigger phrases:` and `spec.md` in description — must return 1 match each | edit-files | null | ci | `skills/plan/SKILL.md` | common |
| SC-11 | `solve/SKILL.md` description follows farmage pattern and requires contract/state YAML | `string` | grep for `Trigger phrases:` and `Contract YAML` in description — must return 1 match each | edit-files | null | ci | `skills/solve/SKILL.md` | common |
| SC-12 | `skill-creator/SKILL.md` description follows farmage pattern | `string` | grep for `Trigger phrases:` in description — must return 1 match | edit-files | null | ci | `skills/skill-creator/SKILL.md` | common |
| SC-13 | `routing-only-template.md` includes farmage description format specification | `string` | grep for `farmage pattern` in template — must return 1 match | edit-files | null | ci | `skills/skill-creator/reference/routing-only-template.md` | common |
| SC-14 | `skill-creator/tasks/validate.md` includes farmage pattern enforcement checks | `string` | grep for `Farmage Description Pattern` in validate task — must return 1 match | edit-files | null | ci | `skills/skill-creator/tasks/validate.md` | common |
| SC-15 | `skill-creator/SKILL.md` dispatch table has entries for skill card audit and farmage enforcement | `string` | grep for `skill card audit` and `farmage pattern` in dispatch table — must return 1 match each | edit-files | null | ci | `skills/skill-creator/SKILL.md` | common |

## Files

- `.opencode/skills/spec-creation/SKILL.md` — remove sub-step entries from dispatch table and invocation; update description to farmage pattern
- `.opencode/skills/writing-plans/SKILL.md` — remove sub-step entries from dispatch table and programmatic invocation; update description to farmage pattern
- `.opencode/skills/adversarial-audit/SKILL.md` — update description to farmage pattern
- `.opencode/skills/plan/SKILL.md` — update description to farmage pattern with spec requirement
- `.opencode/skills/solve/SKILL.md` — update description to farmage pattern with contract/state requirement
- `.opencode/skills/skill-creator/SKILL.md` — update description to farmage pattern; add dispatch table entries for skill card audit and farmage enforcement
- `.opencode/skills/skill-creator/reference/routing-only-template.md` — add farmage description format specification
- `.opencode/skills/skill-creator/tasks/validate.md` — add farmage pattern enforcement checks
- `.opencode/tests/behaviors/` — behavioral enforcement tests

## Dependencies

- #1588 — Orchestrator inline-work bypass (separate concern: SKILL.md inline instructions)
- #1591 — Audit: SKILL.md dispatch tables expose sub-steps as standalone entries (audit spec)

## Risks

- Low. Removing sub-step entries from dispatch tables does not change the Operating Protocol — the sequential checklist still works. The orchestrator simply cannot bypass it by picking individual tasks from a menu.
- Sub-step tasks that are genuinely standalone (not part of a pipeline) should remain in the dispatch table. The audit (#1591) will identify which skills need changes.

## Change Control

- 2026-06-29: Initial spec-fix from session analysis
- 2026-06-29: **Revised — root cause is dispatch table exposing sub-steps as standalone entries. Fix is to remove sub-step entries, not add a separate gate section. The sequential Operating Protocol IS the gate.**
- 2026-06-29: Added Pipeline Step Binding, Re-Entry Step, Verification Gate, Artifact Path, Phase Binding columns to SC table
- 2026-06-29: Added farmage pattern description standard to spec. Updated spec-creation, writing-plans, and adversarial-audit descriptions. Added SC-7, SC-8, SC-9.
- 2026-06-29: Updated plan, solve, skill-creator descriptions to farmage pattern. Updated routing-only-template and validate task. Added dispatch table entries for skill card audit. Added SC-10 through SC-15.
