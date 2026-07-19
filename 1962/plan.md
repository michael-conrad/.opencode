# Plan: writing-plans workflow defects fix

**Issue:** #1962
**Spec:** `.opencode/.issues/1962/spec.md`
**Status:** DRAFT
**Created:** 2026-07-19

## Goal

Fix structural defects in `writing-plans` and `writing-plans-creation` skills: correct TDT entries, contract paths, dispatch routing, add Z3 gates per #1962, and ensure all 12 spec SCs are satisfied.

## Architecture

Single-phase plan. All changes are structural/config modifications to skill metadata files and task files. No pipeline logic changes. The plan follows the dispatcher pattern established by `spec-creation`/`spec-creation-decomposition`.

## Files

| File | Change | SC |
|------|--------|----|
| `.opencode/skills/writing-plans/SKILL.md` | TDT → 4 entries, add Pipeline section (4 workflows), fix Invocation with canonical dispatch strings for all 12 pipeline steps | SC-2, SC-7 |
| `.opencode/skills/writing-plans-creation/SKILL.md` | Convert to task card: remove YAML frontmatter, "Skill:" header, Contracts section. Add complete TDT with 12 pipeline step entries and Invocation | SC-1, SC-3 |
| `.opencode/skills/writing-plans-creation/tasks/create.md` | Fix 11 contract paths to `writing-plans-creation/contracts/`, add plan-creation-pipeline dispatch, annotate all steps with dispatch classification | SC-3, SC-8, SC-9 |
| `.opencode/skills/writing-plans-creation/tasks/update.md` | Fix contract paths, add dispatch classification, align with create.md pattern | SC-10 |
| `.opencode/skills/writing-plans-creation/tasks/retroactive.md` | Fix contract paths, add dispatch classification, add TDT entry | SC-5, SC-10 |
| `.opencode/skills/writing-plans-creation/tasks/pre-plan-readiness.md` | Add solve readiness gate, add TDT entry | SC-4 |
| `.opencode/skills/writing-plans-creation/tasks/clean-room.md` | Add TDT entry classified as clean-room dispatch | SC-6 |
| `.opencode/skills/writing-plans-holistic/SKILL.md` | Add Trigger Dispatch Table for holistic-self-check dispatch | SC-11 |

## Phase Table

| Phase | Description | Steps | SCs |
|-------|-------------|-------|-----|
| 1 | Fix skill metadata and task files | 1-12 | SC-1 through SC-12 |

## Exit Criteria

| SC ID | Criterion | Evidence Type | Verification |
|-------|-----------|---------------|-------------|
| SC-1 | `writing-plans-creation/SKILL.md` has complete TDT with 12 pipeline step entries | structural | `read` SKILL.md → count TDT rows = 12 |
| SC-2 | `writing-plans/SKILL.md` TDT routes all 11 pipeline steps with correct dispatch classification | structural | `read` SKILL.md → verify TDT entries match pipeline steps |
| SC-3 | All contract references in `create.md` point to `writing-plans-creation/contracts/` | structural | `grep` create.md → no matches for `writing-plans/contracts/` |
| SC-4 | `pre-plan-readiness.md` has TDT entry and is positioned as pre-flight gate before readiness | structural | `read` pre-plan-readiness.md → find TDT entry + solve gate |
| SC-5 | `retroactive.md` has TDT entry for direct dispatch via "retroactive plan" trigger | structural | `read` retroactive.md → find TDT entry |
| SC-6 | `clean-room.md` has TDT entry classified as clean-room dispatch | structural | `read` clean-room.md → find TDT entry with clean-room classification |
| SC-7 | `writing-plans/SKILL.md` Invocation section has canonical dispatch strings for all 12 pipeline steps | structural | `read` Invocation → verify 12 dispatch strings |
| SC-8 | Pipeline steps in `create.md` annotated with `(**inline**)`, `(**sub-agent**)`, or `(**clean-room**)` classification | structural | `grep` create.md → verify all steps have classification tags |
| SC-9 | `create` pipeline dispatches to `plan-creation-pipeline` for Z3-verified phase solvability AND retains internal `solve` steps | behavioral | `opencode run` → verify skill dispatch in stderr |
| SC-10 | `update.md` and `retroactive.md` pipelines updated with same fixes | structural | `read` each file → verify contract paths + dispatch classification |
| SC-11 | `writing-plans-holistic/SKILL.md` TDT added for `holistic-self-check` dispatch | structural | `read` SKILL.md → find TDT section |
| SC-12 | All Z3 `solve check` steps validate against correct contract templates per step | behavioral | `opencode run` → verify solve check in stderr |

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
| 7 | `.opencode/skills/writing-plans-creation/tasks/clean-room.md` | ✅ | `ls` confirmed |
| 8 | `.opencode/skills/writing-plans-creation/contracts/` | ✅ | `ls` confirmed (22 contract files) |
| 9 | `.opencode/skills/writing-plans-holistic/SKILL.md` | ✅ | `ls` confirmed |
| 10 | `.opencode/.issues/1962/artifacts/` | ✅ | `ls` confirmed (9 artifact files) |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| `writing-plans-creation` has 16 task files, 0 TDT entries | `ls tasks/` + `read(SKILL.md)` | ✅ |
| Contract files at `writing-plans-creation/contracts/` (22 files) | `ls contracts/` | ✅ |
| `create.md` references `writing-plans/contracts/` (11 matches) | `grep "writing-plans/contracts" create.md` | ✅ |
| `spec-creation` parent routes to sub-skills with 3 TDT entries | `read(SKILL.md)` | ✅ |
| `spec-creation-decomposition` has no TDT | `read(SKILL.md)` | ✅ |
| Analytical artifacts exist at `.opencode/.issues/1962/artifacts/` | `ls artifacts/` | ✅ |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | writing-plans-creation/SKILL.md has TDT with 12 entries | 1 | 2 |
| SC-2 | writing-plans/SKILL.md TDT routes all 11 pipeline steps | 1 | 1 |
| SC-3 | Contract paths in create.md point to writing-plans-creation/contracts/ | 1 | 3 |
| SC-4 | pre-plan-readiness.md has TDT entry + solve gate | 1 | 6 |
| SC-5 | retroactive.md has TDT entry | 1 | 5 |
| SC-6 | clean-room.md has TDT entry | 1 | 7 |
| SC-7 | Invocation has canonical dispatch strings for all 12 steps | 1 | 1 |
| SC-8 | Pipeline steps annotated with dispatch classification | 1 | 3 |
| SC-9 | create dispatches to plan-creation-pipeline + retains solve steps | 1 | 3 |
| SC-10 | update.md and retroactive.md updated with same fixes | 1 | 4, 5 |
| SC-11 | writing-plans-holistic/SKILL.md has TDT | 1 | 8 |
| SC-12 | Z3 solve check steps validate against correct contract templates | 1 | 3, 6 |

## Self-Review Evidence

- [ ] Plan goal matches spec goal: ✅ — both target writing-plans workflow defects
- [ ] All SCs traced to steps: ✅ — 12 SCs, 8 step groups
- [ ] No scope creep: ✅ — only files in scope per spec
- [ ] Feasibility verified: ✅ — all files confirmed to exist
- [ ] Safety documented: ✅ — no destructive operations
- [ ] Rollback plan exists: ✅ — `git checkout` revert
- [ ] All 12 spec SCs represented in exit criteria: ✅
- [ ] Evidence types match spec: ✅ — structural + behavioral per spec
