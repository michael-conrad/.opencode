# Plan: Plan template pipeline mandate + spec-creation pipeline enforcement

**Issue:** #2009
**Spec:** `.opencode/.issues/2009/spec.md`
**Status:** DRAFT
**Created:** 2026-07-19

## Goal

Fix two structural defects: (1) enforce spec-creation pipeline as sole spec creation path via Tier 1 critical rule + behavioral test, (2) mandate full implementation pipeline in plan template with plan-fidelity audit check.

## Architecture

Single-phase plan. Three implementation items covering 4 files: critical rule upgrade, behavioral test, plan template, audit evaluator.

## Files

| File | Change | SCs |
|------|--------|-----|
| `.opencode/guidelines/000-critical-rules.md` | Upgrade direct `github_issue_write` for spec content to Tier 1 CRITICAL VIOLATION | SC-1 |
| `.opencode/tests-v2/behaviors/spec-creation-pipeline-routing.sh` | New behavioral test: agent routes spec creation through spec-creation pipeline | SC-2 |
| `.opencode/skills/writing-plans-creation/tasks/write.md` | Add mandatory Pipeline Steps section with all 15 implementation pipeline stages | SC-3 |
| `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md` | Add pipeline completeness check — FAILs if mandatory steps missing | SC-4 |

## Phase Table

| Phase | File | Description | Steps | SCs |
|-------|------|-------------|-------|-----|
| 1 | `plan-01.md` | Fix critical rule, behavioral test, plan template, audit evaluator | 1-22 | SC-1 through SC-5 |

## Exit Criteria

| SC ID | Criterion | Evidence Type | Verification |
|-------|-----------|---------------|-------------|
| SC-1 | Direct `github_issue_write` for spec content is Tier 1 CRITICAL VIOLATION in 000-critical-rules.md | structural | `read` 000-critical-rules.md → find rule with Tier 1 classification |
| SC-2 | Behavioral enforcement test verifies agent routes spec creation through spec-creation pipeline (FAILs on direct write) | behavioral | `opencode run` → verify agent uses spec-creation pipeline, not direct write |
| SC-3 | `write.md` plan template includes mandatory Pipeline Steps section with all 15 stages | structural | `read` write.md → find Pipeline Steps section with all stages |
| SC-4 | Plan-fidelity audit checks for mandatory pipeline steps and FAILs if missing | behavioral | `opencode run` → verify plan-fidelity FAILs on missing pipeline steps |
| SC-5 | All 8 SCs from #1962 remain satisfied | structural | `grep` for SC-1 through SC-8 in #1962 spec → all present |

## Safety/Rollback

**Phase 1 — Safety/Rollback:**
- Destructive operations: None — only file edits and new test file
- Rollback plan: `git checkout -- .opencode/guidelines/000-critical-rules.md .opencode/skills/writing-plans-creation/tasks/write.md .opencode/skills/audit/tasks/plan-fidelity-evaluator.md` + `rm .opencode/tests-v2/behaviors/spec-creation-pipeline-routing.sh`
- Data loss risk: None

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1 | `.opencode/guidelines/000-critical-rules.md` | ✅ | `ls` confirmed |
| 2 | `.opencode/tests-v2/behaviors/` | ✅ | `ls` confirmed |
| 3 | `.opencode/skills/writing-plans-creation/tasks/write.md` | ✅ | `ls` confirmed |
| 4 | `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md` | ✅ | `ls` confirmed |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| `write.md` plan template has no Pipeline Steps section | `read` task file | ✅ |
| `implementation-pipeline/SKILL.md` TDT defines 15+ pipeline stages | `read` SKILL.md | ✅ |
| critical-rules-XXX is Tier 2 (overridable) | `read` 000-critical-rules.md | ✅ |
| No behavioral test for spec-creation pipeline routing | `ls tests-v2/behaviors/` → no matching file | ✅ |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | Tier 1 critical rule for spec-creation bypass | 1 | 4 (RED), 5 (GREEN) |
| SC-2 | Behavioral test for spec-creation pipeline routing | 1 | 4 (RED), 5 (GREEN) |
| SC-3 | write.md plan template with mandatory Pipeline Steps | 1 | 6 (RED), 7 (GREEN) |
| SC-4 | Plan-fidelity audit checks for pipeline steps | 1 | 8 (RED), 9 (GREEN) |
| SC-5 | #1962 SCs remain satisfied | 1 | 15 (VbC) |

## Self-Review Evidence

- [ ] Plan goal matches spec goal: ✅
- [ ] All SCs traced to steps: ✅ — 5 SCs, 3 RED/GREEN cycles
- [ ] No scope creep: ✅ — only files in scope per spec
- [ ] Feasibility verified: ✅ — all files confirmed to exist
- [ ] Safety documented: ✅ — no destructive operations
- [ ] Rollback plan exists: ✅
- [ ] All 5 spec SCs represented in exit criteria: ✅
- [ ] Evidence types match spec: ✅ — 3 structural + 2 behavioral
- [ ] Full implementation pipeline included: ✅ — 22 steps
