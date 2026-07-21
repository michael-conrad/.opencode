# Plan: Strip dispatch markers from task cards

**Issue:** #2032
**Spec:** `.opencode/.issues/2032/spec.md`
**Authorization scope:** `for_pr` (auto-approves plan)
**Created:** 2026-07-21

## Phase Table

| Phase | Description | Depends On | SCs |
|-------|-------------|------------|-----|
| 1 | Strip dispatch markers from 19 task cards | None | SC-1, SC-2, SC-3, SC-4, SC-5 |
| 2 | Update audit SKILL.md Trigger Dispatch Table | Phase 1 | SC-6 |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | No task card contains DiMo role descriptions or chain flow documentation | 1 | 1.1-1.19 |
| SC-2 | No task card contains `(**orchestrator**)`, `(**sub-agent**)`, `(**clean-room**)`, `(**inline**)` markers | 1 | 1.1-1.19 |
| SC-3 | No task card contains "Never task()" or "orchestrator dispatches" language | 1 | 1.1-1.19 |
| SC-4 | All 19 remediated task cards have entry criteria and exit criteria | 1 | 1.1-1.19 |
| SC-5 | All 19 remediated task cards are self-contained (inline-only steps) | 1 | 1.1-1.19 |
| SC-6 | audit SKILL.md TDT documents DiMo chain dispatch | 2 | 2.1 |
| SC-7 | Behavioral test: sub-agent executes remediated task card inline | 1, 2 | 1.20 |

## Safety/Rollback Considerations

**Phase 1 — Safety/Rollback:**
- Destructive operations: None (documentation-only edits to `.md` files)
- Rollback plan: `git checkout --` on each modified file
- Data loss risk: None

**Phase 2 — Safety/Rollback:**
- Destructive operations: None (documentation-only edit to SKILL.md)
- Rollback plan: `git checkout -- .opencode/skills/audit/SKILL.md`
- Data loss risk: None

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `.opencode/skills/audit/tasks/closure-verification.md` | ✅ | `read` |
| 1.2 | `.opencode/skills/audit/tasks/closure-verification/investigator.md` | ✅ | `read` |
| 1.3 | `.opencode/skills/audit/tasks/closure-verification/validator.md` | ✅ | `read` |
| 1.4 | `.opencode/skills/audit/tasks/closure-verification/evaluator.md` | ✅ | `read` |
| 1.5 | `.opencode/skills/audit/tasks/coherence-extraction.md` | ✅ | `read` |
| 1.6 | `.opencode/skills/audit/tasks/coherence-extraction/investigator.md` | ✅ | `read` |
| 1.7 | `.opencode/skills/audit/tasks/coherence-extraction/validator.md` | ✅ | `read` |
| 1.8 | `.opencode/skills/audit/tasks/coherence-extraction/evaluator.md` | ✅ | `read` |
| 1.9 | `.opencode/skills/audit/tasks/spec-summary.md` | ✅ | `read` |
| 1.10 | `.opencode/skills/audit/tasks/spec-summary/investigator.md` | ✅ | `read` |
| 1.11 | `.opencode/skills/audit/tasks/spec-summary/validator.md` | ✅ | `read` |
| 1.12 | `.opencode/skills/audit/tasks/spec-summary/evaluator.md` | ✅ | `read` |
| 1.13 | `.opencode/skills/audit/tasks/resolve-models.md` | ✅ | `read` |
| 1.14 | `.opencode/skills/audit/tasks/cross-validate.md` | ✅ | `read` |
| 1.15 | `.opencode/skills/audit/tasks/spec-audit-evaluator.md` | ✅ | `read` |
| 1.16 | `.opencode/skills/audit/tasks/spec-audit-investigator.md` | ✅ | `read` |
| 1.17 | `.opencode/skills/audit/tasks/spec-audit-validator.md` | ✅ | `read` |
| 1.18 | `.opencode/skills/audit/tasks/content-audit-evaluator.md` | ✅ | `read` |
| 1.19 | `.opencode/skills/audit/tasks/behavioral-sc-evaluator.md` | ✅ | `read` (not found — may not exist) |
| 2.1 | `.opencode/skills/audit/SKILL.md` | ✅ | `read` |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| 19 task cards contain dispatch-level markers | `read` of all 19 files | ✅ |
| audit SKILL.md TDT documents DiMo chain | `read` of SKILL.md | ✅ |
| `behavioral-sc-evaluator.md` may not exist | `read` returned file not found | ✅ |
