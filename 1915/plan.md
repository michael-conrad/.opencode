# Plan: Sub-agent Dispatch Architecture

**Issue:** #1915
**Spec:** https://github.com/michael-conrad/.opencode/issues/1915
**Authorization Scope:** `for_pr`
**Halt At:** `pr_created`

## Goal

Eliminate two structural defects in the sub-agent dispatch architecture:
1. **Defect 1 (Sub-Agent Dispatching Sub-Agents):** Task files instruct sub-agents to dispatch other sub-agents via `task()`, which sub-agents cannot do. Fix: move dispatch instructions to orchestrator-level SKILL.md Trigger Dispatch Tables.
2. **Defect 2 (DiMo Chain Bypass):** Three audit task files declare DiMo chain architecture but are monolithic — a single sub-agent does all 4 roles inline. Fix: split into 4 separate role files.

## Architecture

The fix follows a consistent pattern across all affected files:
- **For Defect 1:** Identify sub-agent dispatch instructions in task files → move to SKILL.md Trigger Dispatch Table → replace with artifact reference in task file
- **For Defect 2:** Split monolithic task into 4 role files (generator, knowledge-supporter, evaluator, path-provider) → update SKILL.md for sequential dispatch

## Affected Files

| File | Change Type |
|------|-------------|
| `skills/writing-plans/tasks/create.md` | Restructure (Defect 1) |
| `skills/writing-plans/SKILL.md` | Update Trigger Dispatch Table |
| `skills/spec-creation/tasks/analytical-artifacts.md` | Restructure (Defect 1) |
| `skills/spec-creation/SKILL.md` | Update Trigger Dispatch Table |
| `skills/spec-creation/tasks/create.md` | Restructure (Defect 1) |
| `skills/verification-before-completion/tasks/behavioral-test-evaluation.md` | Restructure (Defect 1) |
| `skills/verification-before-completion/SKILL.md` | Update Trigger Dispatch Table |
| `skills/audit/tasks/closure-verification.md` | Split into 4 role files (Defect 2) |
| `skills/audit/tasks/closure-verification/generator.md` | New file |
| `skills/audit/tasks/closure-verification/knowledge-supporter.md` | New file |
| `skills/audit/tasks/closure-verification/evaluator.md` | New file |
| `skills/audit/tasks/closure-verification/path-provider.md` | New file |
| `skills/audit/tasks/spec-summary.md` | Split into 4 role files (Defect 2) |
| `skills/audit/tasks/spec-summary/generator.md` | New file |
| `skills/audit/tasks/spec-summary/knowledge-supporter.md` | New file |
| `skills/audit/tasks/spec-summary/evaluator.md` | New file |
| `skills/audit/tasks/spec-summary/path-provider.md` | New file |
| `skills/audit/tasks/coherence-extraction.md` | Split into 4 role files (Defect 2) |
| `skills/audit/tasks/coherence-extraction/generator.md` | New file |
| `skills/audit/tasks/coherence-extraction/knowledge-supporter.md` | New file |
| `skills/audit/tasks/coherence-extraction/evaluator.md` | New file |
| `skills/audit/tasks/coherence-extraction/path-provider.md` | New file |
| `skills/audit/SKILL.md` | Update Trigger Dispatch Table |
| `.opencode/tests/behaviors/sub-agent-dispatch-rejection.sh` | New behavioral test |

## Phase Table

| Phase | Name | SCs | Files Changed | Risk |
|-------|------|-----|---------------|------|
| 1 | Restructure `writing-plans/tasks/create.md` | SC-1, SC-2 | 2 | Medium |
| 2 | Restructure `spec-creation/tasks/analytical-artifacts.md` | SC-1, SC-3 | 2 | Medium |
| 3 | Restructure `spec-creation/tasks/create.md` | SC-1, SC-4 | 2 | Low |
| 4 | Restructure `verification-before-completion/tasks/behavioral-test-evaluation.md` | SC-1, SC-5 | 2 | Low |
| 5 | Split `audit/tasks/closure-verification.md` into DiMo chain | SC-6 | 6 | Medium |
| 6 | Split `audit/tasks/spec-summary.md` into DiMo chain | SC-7 | 6 | Medium |
| 7 | Split `audit/tasks/coherence-extraction.md` into DiMo chain | SC-8 | 6 | Medium |
| 8 | Behavioral enforcement test for SC-9 | SC-9 | 1 | Low |

## SC-to-Phase Traceability

| SC ID | Criterion | Phase(s) |
|-------|-----------|----------|
| SC-1 | No task file contains sub-agent dispatch instructions | 1, 2, 3, 4 |
| SC-2 | `writing-plans/tasks/create.md` restructured | 1 |
| SC-3 | `spec-creation/tasks/analytical-artifacts.md` restructured | 2 |
| SC-4 | `spec-creation/tasks/create.md` restructured | 3 |
| SC-5 | `verification-before-completion/tasks/behavioral-test-evaluation.md` restructured | 4 |
| SC-6 | `audit/tasks/closure-verification.md` split into 4 role files | 5 |
| SC-7 | `audit/tasks/spec-summary.md` split into 4 role files | 6 |
| SC-8 | `audit/tasks/coherence-extraction.md` split into 4 role files | 7 |
| SC-9 | Behavioral test: sub-agent returns BLOCKED on impossible dispatch | 8 |
| SC-10 | Existing correctly-implemented DiMo chain files unchanged | All (invariant) |

## Exit Criteria

- [ ] All 8 phases complete with verified PASS
- [ ] All 10 SCs verified (9 behavioral/string, 1 structural)
- [ ] All 4 SKILL.md Trigger Dispatch Tables updated
- [ ] Behavioral test for SC-9 passes
- [ ] All existing DiMo chain files confirmed unchanged (SC-10)
- [ ] Feature branch pushed and PR created

## Safety/Rollback

- **No destructive operations in any phase** — all changes are file edits and new file creations
- **Rollback:** `git checkout feature/1915-sub-agent-dispatch-architecture -- <affected-files>` for each phase
- **Data loss risk:** None — all changes are to skill/task/test files, not data

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| All | All affected files exist in `.opencode/skills/` | ✅ | Confirmed by spec body and codebase map |
| All | `task()` tool is not available to sub-agents | ✅ | Confirmed by system prompt tool list |
| All | DiMo chain protocol (4 roles) is documented in audit SKILL.md | ✅ | Confirmed by spec non-goals section |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| Sub-agents do not have `task()` tool | System prompt tool list | ✅ |
| 7 affected task files exist | Spec body Affected Files section | ✅ |
| 3 DiMo chain task files are monolithic | Spec body Defect 2 table | ✅ |
| 9 correctly-implemented DiMo chain files exist | Spec body SC-10 | ✅ |

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
