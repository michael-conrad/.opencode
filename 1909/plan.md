# Implementation Plan — [#1909](https://github.com/michael-conrad/.opencode/issues/1909) — Restructure audit skill for DiMo 4-role chain dispatch

**Goal:** Rewire the audit skill's dispatch mechanism to route through the DiMo 4-role chain (Generator → Knowledge Supporter → Evaluator → Path Provider) instead of monolithic task files.

**Architecture:** Each audit type gets 4 role-specific task files dispatched as sequential clean-room sub-agents. The orchestrator passes only artifact paths between roles — no shared context.

**Files:** `.opencode/skills/audit/SKILL.md`, `.opencode/skills/audit/tasks/*.md` (36 new, 9 deleted, 2 modified), `.opencode/tests/behaviors/audit-dimo-4role-dispatch.sh` (new)

**Dispatch:** `skill({name: "audit"})` → Trigger Dispatch Table → DiMo 4-role chain → 4 sequential `task()` calls

## Blast Radius

| Phase | Risk Level | Key Impact |
|-------|-----------|------------|
| 1 — SKILL.md Restructure | medium | All orchestrators that dispatch audit tasks route through new DiMo chain |
| 2 — Create Role-Specific Task Files | high | 36 new files, Evaluator files stripped of Knowledge Supporter work |
| 3 — Remove Monolithic Task Files | high | 9 files deleted, irreversible without git history |
| 4 — Behavioral Tests | low | New behavioral test, no production impact |

## Concern Map Reference

| Phase | Primary Concern |
|-------|----------------|
| 1 | Rewrite audit skill description and dispatch tables to route through DiMo 4-role chain |
| 2 | Create 36 new role-specific task files (9 audit types × 4 DiMo roles) |
| 3 | Delete 9 monolithic task files and resolve Path Provider role ambiguity |
| 4 | Add behavioral enforcement test verifying agent dispatches 4-role chain |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. After each step, report the result before proceeding to the next step. Never batch multiple steps into a single response. Never skip ahead. Never assume a step completed without verifying.

> **Step Status:** After each step, update the step's checkbox from `- [ ]` to `- [x]` in the phase file. The checkbox state is the single source of truth for step completion. Do not rely on memory or session context to track progress.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range | Dispatch |
|-------|------|---------|-----|-------------|------------|----------|
| 1 | SKILL.md Restructure | Rewrite dispatch entry point | SC-1, SC-2, SC-7 | None | 1–12 | `skill({name: "audit"})` |
| 2 | Create Role-Specific Task Files | Create 36 role-specific task files | SC-3, SC-4, SC-5, SC-6 | Phase 1 | 13–52 | `skill({name: "audit"})` |
| 3 | Remove Monolithic Task Files | Delete 9 monolithic files, resolve ambiguity | SC-9, SC-10 | Phase 2 | 53–66 | `skill({name: "audit"})` |
| 4 | Behavioral Tests | Verify 4-role chain dispatch | SC-8, SC-11 | Phase 3 | 67–78 | `skill({name: "test-driven-development"})` |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **Self-remediation protocol:** When a step fails, diagnose the root cause, remediate, and re-execute the step. Do not skip the step. Do not proceed past a failed step. If remediation fails after 2 attempts, HALT and report the blocker.

## Exit Criteria

- [ ] C1. `audit/SKILL.md` description uses agent-intent language (SC-1)
- [ ] C2. `audit/SKILL.md` Trigger Dispatch Table routes to DiMo workflow (SC-2)
- [ ] C3. `audit/SKILL.md` DiMo section is authoritative dispatch instruction (SC-7)
- [ ] C4. 9 Generator task files exist (SC-3)
- [ ] C5. 9 Knowledge Supporter task files exist (SC-4)
- [ ] C6. 9 Path Provider task files exist (SC-5)
- [ ] C7. Evaluator task files contain no Knowledge Supporter work (SC-6)
- [ ] C8. 0 monolithic task files remain (SC-10)
- [ ] C9. Exactly one task file claims Path Provider role (SC-9)
- [ ] C10. Behavioral test passes for 4-role chain dispatch (SC-8)
- [ ] C11. Anti-lobotomization behavioral test passes (SC-11)
- [ ] C12. All SCs achieve 100% clean PASS
