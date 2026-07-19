# Plan: writing-plans workflow defects fix

**Issue:** #1962
**Spec:** `.opencode/.issues/1962/spec.md`
**Status:** DRAFT
**Created:** 2026-07-19

## Goal

Fix structural defects in `writing-plans` and `writing-plans-creation` skills: correct TDT entries, contract paths, dispatch routing, add Z3 gates per #1962, and ensure all 8 spec SCs are satisfied.

## Architecture

Single-phase plan. All changes are structural/config modifications to skill metadata files and task files. No pipeline logic changes. The plan follows the dispatcher pattern established by `spec-creation`/`spec-creation-decomposition`.

## Files

| File | Change | SCs |
|------|--------|-----|
| `.opencode/skills/writing-plans/SKILL.md` | TDT → 4 entries (`create`, `update`, `retroactive`, `holistic-self-check`), Pipeline section with 4 workflows, Invocation with 4 canonical dispatch strings. Document `clean-room` as internal/referenced task (not a TDT entry). | SC-1, SC-2, SC-7, SC-8 |
| `.opencode/skills/writing-plans-creation/SKILL.md` | Convert from skill card to task card: remove YAML frontmatter, remove "Skill:" header, remove Contracts section, remove TDT/Invocation (already absent). Keep plain task list. | SC-3 |
| `.opencode/skills/writing-plans-creation/tasks/create.md` | Fix 11 contract paths from `writing-plans/contracts/` to `writing-plans-creation/contracts/`. Add plan-creation-pipeline dispatch step. Update chain refs. | SC-4, SC-5 |
| `.opencode/skills/writing-plans-creation/tasks/update.md` | Fix contract paths from `writing-plans/contracts/` to `writing-plans-creation/contracts/`. | SC-4 |
| `.opencode/skills/writing-plans-creation/tasks/retroactive.md` | Fix contract paths from `writing-plans/contracts/` to `writing-plans-creation/contracts/`. | SC-4 |
| `.opencode/skills/writing-plans-creation/tasks/pre-plan-readiness.md` | Add solve readiness gate (already done per eda50974). | SC-6 |

## Phase Table

| Phase | Description | Steps | SCs |
|-------|-------------|-------|-----|
| 1 | Fix skill metadata and task files | 1-8 | SC-1 through SC-8 |

## Exit Criteria

| SC ID | Criterion | Evidence Type | Verification |
|-------|-----------|---------------|-------------|
| SC-1 | `writing-plans` TDT has exactly 4 user-facing workflow entries (`create`, `update`, `retroactive`, `holistic-self-check`) | structural | `read` SKILL.md → count TDT rows = 4 |
| SC-2 | `writing-plans` Pipeline section documents 4 workflows with step-level dispatch classification | structural | `read` SKILL.md → find Pipeline section with 4 workflows |
| SC-3 | `writing-plans-creation` is a task card (not a skill card) — no YAML frontmatter, no "Skill:" header, no TDT, no Invocation | structural | `read` SKILL.md → no YAML frontmatter, no "Skill:" header |
| SC-4 | All contract paths in `create.md`, `update.md`, `retroactive.md` resolve to `writing-plans-creation/contracts/` | structural | `bash` check each path exists; `grep` for no remaining `writing-plans/contracts/` |
| SC-5 | `create` workflow dispatches to `plan-creation-pipeline` with Z3 gates | behavioral | `opencode run` → verify skill dispatch in stderr |
| SC-6 | `pre-plan-readiness` has `solve` readiness gate | structural | `read` pre-plan-readiness.md → find solve check |
| SC-7 | All canonical dispatch strings follow DISPATCH_GATE format in Invocation | structural | `read` Invocation sections → verify format |
| SC-8 | No orphaned tasks in `writing-plans-creation/tasks/` — all tasks referenced by Pipeline or documented as internal | structural | `ls tasks/` vs Pipeline task refs → diff empty |

## Safety/Rollback

**Phase 1 — Safety/Rollback:**
- Destructive operations: None — only file edits to skill metadata and task files
- Rollback plan: `git checkout -- .opencode/skills/writing-plans*/` to revert all changes
- Data loss risk: None

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1 | `.opencode/skills/writing-plans/SKILL.md` | ✅ | `ls` confirmed |
| 2 | `.opencode/skills/writing-plans-creation/SKILL.md` | ✅ | `ls` confirmed |
| 3 | `.opencode/skills/writing-plans-creation/tasks/create.md` | ✅ | `ls` confirmed |
| 4 | `.opencode/skills/writing-plans-creation/tasks/update.md` | ✅ | `ls` confirmed |
| 5 | `.opencode/skills/writing-plans-creation/tasks/retroactive.md` | ✅ | `ls` confirmed |
| 6 | `.opencode/skills/writing-plans-creation/tasks/pre-plan-readiness.md` | ✅ | `ls` confirmed |
| 7 | `.opencode/skills/writing-plans-creation/contracts/` | ✅ | `ls` confirmed |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| `writing-plans-creation` has 16 task files, 0 TDT entries | `ls tasks/` + `read(SKILL.md)` | ✅ |
| Contract files at `writing-plans-creation/contracts/` | `ls contracts/` | ✅ |
| `create.md` references `writing-plans/contracts/` (11 matches) | `grep "writing-plans/contracts" create.md` | ✅ |
| `spec-creation` parent routes to sub-skills with 3 TDT entries | `read(SKILL.md)` | ✅ |
| `spec-creation-decomposition` has no TDT | `read(SKILL.md)` | ✅ |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | TDT has exactly 4 entries | 1 | 1 |
| SC-2 | Pipeline section with 4 workflows | 1 | 1 |
| SC-3 | writing-plans-creation is task card (no YAML, no "Skill:") | 1 | 2 |
| SC-4 | Contract paths resolve to writing-plans-creation/contracts/ | 1 | 3, 4, 5 |
| SC-5 | plan-creation-pipeline dispatch | 1 | 3 |
| SC-6 | pre-plan-readiness solve gate | 1 | 6 |
| SC-7 | Canonical dispatch strings | 1 | 1 |
| SC-8 | No orphaned tasks | 1 | 1, 2 |

## Self-Review Evidence

- [ ] Plan goal matches spec goal: ✅ — both target writing-plans workflow defects
- [ ] All SCs traced to steps: ✅ — 8 SCs, 6 step groups
- [ ] No scope creep: ✅ — only files in scope per spec
- [ ] Feasibility verified: ✅ — all files confirmed to exist
- [ ] Safety documented: ✅ — no destructive operations
- [ ] Rollback plan exists: ✅ — `git checkout` revert
- [ ] All 8 spec SCs represented in exit criteria: ✅
- [ ] Evidence types match spec: ✅ — 7 structural + 1 behavioral per spec
- [ ] writing-plans-creation has NO TDT (task card): ✅
- [ ] clean-room documented as internal/referenced, not TDT entry: ✅
- [ ] retroactive is 4th TDT entry: ✅
