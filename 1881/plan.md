# Implementation Plan — [#1881](https://github.com/michael-conrad/.opencode/issues/1881) — Split 5 Overloaded Skills into Dispatcher + Sub-Skills

**Goal:** Split 5 overloaded skills (issue-operations, approval-gate, git-workflow, writing-plans, spec-creation) into dispatcher + sub-skill architecture to cap SKILL.md at 500 lines and task files at 200 lines each.

**Architecture:** Each overloaded skill becomes a dispatcher SKILL.md with Trigger Dispatch Table that routes to sub-skills. Each sub-skill owns its task files. Platform sub-skills preserved. 20 sub-skills total across 5 parent skills.

**Files:** ~120 files across `.opencode/skills/{issue-operations,approval-gate,git-workflow,writing-plans,spec-creation}*/*`

**Dispatch:** Pipeline execution via `implementation-pipeline` skill — orchestrator dispatches each phase to clean-room sub-agents.

## Blast Radius

- 5 overloaded skills (issue-operations, approval-gate, git-workflow, writing-plans, spec-creation)
- 20 new sub-skills created
- ~95 task files moved from original `tasks/` directories to sub-skill `tasks/` directories
- 9 guideline files updated with cross-references (000, 010, 020, 060, 080, 140, 141)
- AGENTS.md, README.md updated
- ~50 content-verification test scenarios updated
- ~20 behavioral tests updated
- skill-creator validate.md updated (Agent-Intent Pattern)
- New dispatcher template file created

## Concern Map Reference

| Concern | Phase |
|---------|-------|
| Shared infrastructure | Phase 1 — Validate and Update |
| issue-operations → 4 sub-skills | Phase 2 |
| approval-gate → 4 sub-skills | Phase 3 |
| git-workflow → 5 sub-skills | Phase 4 |
| writing-plans → 3 sub-skills | Phase 5 |
| spec-creation → 4 sub-skills | Phase 6 |
| Cross-skill integration | Phase 7 — Cross-Skill Sweep |

## Admonishment

> **Plan compliance is mandatory, not aspirational.** Every step in this plan MUST be executed in sequence. Skipping steps, reordering steps, or combining steps is a critical violation. The plan defines what to do; the orchestrator determines how to dispatch. All implementation-pipeline gate steps from `implementation-pipeline/SKILL.md` dispatch routing table are mandatory and MUST NOT be omitted.

## One-Step-at-a-Time Protocol

> **One step at a time.** Execute exactly one step, verify it, then proceed to the next. Do NOT batch steps. Do NOT parallelize unless explicitly marked as parallel. Every step produces evidence that the prior step completed correctly before moving forward.

## Step Status

Each step MUST maintain a status indicator:
- `[ ]` — Not yet started
- `[~]` — In progress
- `[x]` — Completed and verified

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps | Dispatch |
|-------|------|---------|-----|--------------|-------|----------|
| 1 | Validate and Update (Pre-Flight) | Shared infrastructure | SC-1 | None | 4-11 | sub-agent |
| 2 | Split issue-operations | issue-ops → 4 sub-skills | SC-1,2,3,4,5 | Phase 1 | 12-23 | sub-agent |
| 3 | Split approval-gate | approval-gate → 4 sub-skills | SC-1,2,3,4,5 | Phase 1 | 24-34 | sub-agent |
| 4 | Split git-workflow | git-workflow → 5 sub-skills | SC-1,2,3,4,5 | Phase 1 | 35-46 | sub-agent |
| 5 | Split writing-plans | writing-plans → 3 sub-skills | SC-1,2,3,4,5 | Phase 1 | 47-56 | sub-agent |
| 6 | Split spec-creation | spec-creation → 4 sub-skills | SC-1,2,3,4,5 | Phase 1 | 57-67 | sub-agent |
| 7 | Cross-Skill Sweep (Post) | Cross-skill integration | SC-6,7,8 | Phases 2-6 | 68-80 | sub-agent |

## Bottom Admonishment

> **Plan compliance is mandatory, not aspirational.** Every step in this plan MUST be executed in sequence. Skipping steps, reordering steps, or combining steps is a critical violation. The plan defines what to do; the orchestrator determines how to dispatch. All implementation-pipeline gate steps from `implementation-pipeline/SKILL.md` dispatch routing table are mandatory and MUST NOT be omitted.

## Self-Remediation Protocol

> **Self-remediation is the default response to failure.** When a step fails (RED test fails unexpectedly, GREEN verification fails, audit FAILs), the orchestrator MUST remediate before escalating. Remediation: diagnose root cause, fix, re-verify. Only after 2+ remediation attempts may the orchestrator escalate to the developer with both failure artifacts. No "skip and continue" — failure is a hard gate.

## Exit Criteria

- [ ] C1: 5 dispatcher SKILL.md files created (issue-operations, approval-gate, git-workflow, writing-plans, spec-creation)
- [ ] C2: 20 sub-skill directories and SKILL.md files created
- [ ] C3: All ~95 task files moved from original `tasks/` to sub-skill `tasks/`
- [ ] C4: All dispatcher Trigger Dispatch Tables map triggers to correct sub-skills
- [ ] C5: All platform sub-skills (github-mcp, gitbucket-api, local) preserved and referenced
- [ ] C6: All guideline/skill/test cross-references updated
- [ ] C7: All behavioral tests pass
- [ ] C8: All SCs from spec #1881 verified complete
