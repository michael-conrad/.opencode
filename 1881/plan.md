# Implementation Plan — [#1881](https://github.com/michael-conrad/.opencode/issues/1881) — Split 5 Overloaded Skills into Dispatcher + Sub-Skills

**Goal:** Split 5 overloaded skills (issue-operations, approval-gate, git-workflow, writing-plans, spec-creation) into dispatcher + sub-skill architecture to cap SKILL.md at 500 lines and task files at 200 lines each.

**Architecture:** Each overloaded skill becomes a dispatcher SKILL.md with Trigger Dispatch Table that routes to sub-skills. Each sub-skill owns its task files. Platform sub-skills preserved. 20 sub-skills total across 5 parent skills.

**Files:** ~120 files across `.opencode/skills/{issue-operations,approval-gate,git-workflow,writing-plans,spec-creation}*/*`

**Dispatch:** Step-level dispatch via `implementation-pipeline` skill — orchestrator dispatches each step to clean-room sub-agents per its dispatch indicator. No phase-level batching.

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

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **Dispatch discipline:** The plan defines WHAT to do; each step declares its own dispatch indicator. Steps marked `(**inline**)` execute directly by orchestrator. Steps marked `(**sub-agent**)` dispatch to sub-agents with context. Steps marked `(**clean-room**)` dispatch to sub-agents with routing metadata only. All implementation-pipeline gate steps from `implementation-pipeline/SKILL.md` Trigger Dispatch Table are mandatory and MUST NOT be omitted.

## One-Step-at-a-Time Protocol

> **One step at a time.** Execute exactly one step, verify it, then proceed to the next. Do NOT batch steps. Do NOT parallelize unless explicitly marked as parallel. Every step produces evidence that the prior step completed correctly before moving forward. Step-level dispatch is the ONLY valid dispatch mode — the orchestrator processes the plan INLINE, step by step.

## Step Status

Each step MUST maintain a status indicator:
- `[ ]` — Not yet started
- `[~]` — In progress
- `[x]` — Completed and verified

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps | Dispatch |
|-------|------|---------|-----|--------------|-------|----------|
| 1 | Validate and Update (Pre-Flight) | Shared infrastructure | SC-1 | None | 4–18 | step-level (per-item) |
| 2 | Split issue-operations | issue-ops → 4 sub-skills | SC-1,2,3,4,5 | Phase 1 | 19–35 | step-level (per-item) |
| 3 | Split approval-gate | approval-gate → 4 sub-skills | SC-1,2,3,4,5 | Phase 1 | 36–52 | step-level (per-item) |
| 4 | Split git-workflow | git-workflow → 5 sub-skills | SC-1,2,3,4,5 | Phase 1 | 53–77 | step-level (per-item) |
| 5 | Split writing-plans | writing-plans → 3 sub-skills | SC-1,2,3,4,5 | Phase 1 | 78–96 | step-level (per-item) |
| 6 | Split spec-creation | spec-creation → 4 sub-skills | SC-1,2,3,4,5 | Phase 1 | 97–117 | step-level (per-item) |
| 7 | Cross-Skill Sweep (Post) | Cross-skill integration | SC-6,7,8 | Phases 2–6 | 118–139 | step-level (per-item) |

## Bottom Admonishment

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

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
