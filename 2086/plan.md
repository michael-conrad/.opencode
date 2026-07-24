# Plan: Audit skill DiMo chain dispatch

## Phase Table

| Phase | Name | Concern | Skill+Task Reference | Dispatch Mode |
|-------|------|---------|---------------------|---------------|
| 1 | DiMo dispatch pattern fix | C1/C2/C3 — all three SCs are tightly coupled text edits to SKILL.md | `customize-opencode` (SKILL.md edit) | `(**inline**)` |

## Phase 1: DiMo dispatch pattern fix

### Entry Criteria
- `.opencode/skills/audit/SKILL.md` exists and is readable
- All 7 analytical artifacts present and current

### Steps

1. **Edit DiMo Chain Invocation section (SC-1)**
   - Replace the canonical dispatch string at lines 102-108 to specify orchestrator dispatches each role as a separate `task()` call
   - The dispatch string must show 4 sequential `task()` calls (Investigator → Validator → Evaluator → Arbiter) with artifact path passing between them

2. **Edit Trigger Dispatch Table header (SC-2)**
   - Update line 46 to clarify that each row dispatches 4 sequential `task()` calls, not a single monolithic dispatch

3. **Scan and remove residual monolithic language (SC-3)**
   - Search entire file for any language suggesting a single `task()` call dispatches the entire DiMo chain
   - Remove or rephrase any such language

### Exit Criteria
- SC-1: DiMo Chain Invocation section specifies orchestrator dispatches each role as separate `task()` call
- SC-2: Trigger Dispatch Table header clarifies 4 sequential `task()` calls per row
- SC-3: No remaining language suggesting monolithic single-task dispatch

## SC-to-Phase Mapping

| SC | Phase | Evidence Type |
|----|-------|---------------|
| SC-1 | 1 | string |
| SC-2 | 1 | string |
| SC-3 | 1 | string |
