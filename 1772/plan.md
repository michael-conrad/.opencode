# Implementation Plan — [#1672](https://github.com/michael-conrad/.opencode/issues/1672) — DiMo-Aligned Adversarial Audit

**Goal:** Replace the cross-model-family adversarial audit system with a DiMo-aligned architecture: same-model, role-differentiated agent chaining. Eliminate ~1,900 lines of cross-model infrastructure (4 auditor cards, resolve-models tool, qualified-auditor-pool.sh) and replace with a single role-differentiated auditor card + 15 refactored task files.

**Architecture:** The plan follows a 5-phase sequential dependency chain. Each phase produces a deliverable that the next phase depends on. Phase 1 deletes old infrastructure, Phase 2 creates the new role card, Phase 3 refactors task files to use DiMo roles, Phase 4 updates the SKILL.md dispatch logic, Phase 5 adds behavioral tests. Each phase follows the implementation-pipeline RED/GREEN cycle.

**Spec:** [#1672](https://github.com/michael-conrad/.opencode/issues/1672)

**Files:**
- `.opencode/agents/` — Delete 4 files, create 1 file
- `.opencode/tools/resolve-models` — Delete
- `.opencode/tests/qualification/qualified-auditor-pool.sh` — Delete
- `.opencode/skills/adversarial-audit/tasks/*.md` — Modify 15 files
- `.opencode/skills/adversarial-audit/SKILL.md` — Modify
- `.opencode/tests/behaviors/` — Create 2 behavioral test scripts

> **⚠️ COMPLIANCE REQUIREMENT:** Every step in this plan is mandatory. Skipping, combining, or reordering steps produces defective deliverables that must be discarded. The orchestrator MUST execute every step in sequence. No step may be omitted because it seems "not needed" — if a step appears unnecessary, include it anyway. This is non-waivable.

> **⚠️ ONE STEP AT A TIME:** Execute exactly one step at a time. After each step, verify the result before proceeding to the next. Do not batch steps. Do not parallelize. Each step's output is the next step's input.

> **⚠️ STEP STATUS:** Before executing any step, check its status. If already completed (verified by evidence), skip it. If in progress, complete it. If not started, begin. After each step, update its status.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps |
|-------|------|---------|-----|--------------|-------|
| 1 | Eliminate Cross-Model Infrastructure | Delete 4 auditor cards, resolve-models, qualified-auditor-pool.sh, INSUFFICIENT_FAMILIES references | SC-1, SC-2, SC-3, SC-12 | None | 3-20 |
| 2 | Create DiMo Role-Differentiated Auditor Card | Create single auditor-role.md with all 4 DiMo roles, interaction protocols, Judger role | SC-4 | Phase 1 | 21-38 |
| 3 | Refactor 15 Task Files | Remove audit_phase, embed DiMo roles, add pre-clean step, artifact paths, Judger integration | SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11 | Phase 1, 2 | 39-56 |
| 4 | Update SKILL.md and Dispatch Logic | Update SKILL.md to reference DiMo architecture, remove resolve-models from dispatch routing | SC-5 | Phase 1, 2, 3 | 57-74 |
| 5 | Behavioral Tests | Write behavioral enforcement tests for SC-13 and SC-14 | SC-13, SC-14 | Phase 1, 2, 3, 4 | 75-92 |

> **⚠️ COMPLIANCE REQUIREMENT:** Every step in this plan is mandatory. Skipping, combining, or reordering steps produces defective deliverables that must be discarded. The orchestrator MUST execute every step in sequence. No step may be omitted because it seems "not needed" — if a step appears unnecessary, include it anyway. This is non-waivable.

> **⚠️ SELF-REMEDIATION PROTOCOL:** If a step fails, the orchestrator MUST NOT proceed. Diagnose the root cause, remediate, and re-run the failed step. If remediation fails twice, report BLOCKED with both failure artifacts. Do NOT skip the failed step. Do NOT reclassify FAIL as "PASS with caveats." Do NOT proceed past a FAIL.

## Exit Criteria

- [ ] C1. All 4 model-specific auditor cards removed from `.opencode/agents/` (SC-1)
- [ ] C2. `resolve-models` tool removed from `.opencode/tools/` (SC-2)
- [ ] C3. `qualified-auditor-pool.sh` removed (SC-3)
- [ ] C4. 1 role-differentiated auditor card (`auditor-role.md`) exists at `.opencode/agents/` (SC-4)
- [ ] C5. Dispatch contract reduced to 2 fields: `spec_local_dir`, `artifact_evidence_dir` (SC-5)
- [ ] C6. All 15 task files self-contained with embedded DiMo role persona — no conditional logic on `audit_phase` (SC-6)
- [ ] C7. Artifact directory uses `./tmp/{issue-N}/artifacts/{task-name}/` with role-named files (SC-7)
- [ ] C8. Downstream roles read upstream artifacts: Knowledge Supporter → Path Provider → Evaluator → Judger (SC-8)
- [ ] C9. Pre-clean step (step 0) at top of each task checklist removes only this task's artifact files (SC-9)
- [ ] C10. Sequential dispatch per task checklist: role-1 → if PASS → role-2 → if PASS → role-3 → etc. (SC-10)
- [ ] C11. Remediation restarts from pre-clean step (step 0) — all prior artifacts in this task's directory removed (SC-11)
- [ ] C12. No `INSUFFICIENT_FAMILIES` error state exists in any remaining code (SC-12)
- [ ] C13. Behavioral: agent dispatches DiMo role chain (not cross-model auditors) during adversarial audit (SC-13)
- [ ] C14. Behavioral: agent handles single-model-family environment without error (SC-14)
