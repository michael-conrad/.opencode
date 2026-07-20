> **Full spec and plan artifacts:** https://github.com/michael-conrad/.opencode/tree/issues-data/{N}/

## Problem

The Pre-Response Gate procedure (AGENTS.md) fires once per user message. When the gap-fill cascade auto-creates a spec or plan, the orchestrator treats it as an implementation intent rather than a dispatch trigger. The skill deck is never re-evaluated mid-response, so `spec-creation` and `writing-plans` are never loaded — the orchestrator writes inline instead.

## Scope

- **In scope:** Pre-Response Gate re-entry condition in AGENTS.md
- **In scope:** `dispatch_next` fields in approval-gate gap-fill cascade table
- **In scope:** Dispatch Next column in Authorization Scope Model table
- **In scope:** Behavioral test verifying orchestrator loads `spec-creation` after gap-fill cascade
- **Out of scope:** Changes to #1588's scope (SKILL.md inline instructions, write.md sub-agent markers, step status output)
- **Out of scope:** Changes to individual skill dispatch tables

## Approach

Two changes. First, add a re-entry condition to the Pre-Response Gate procedure in AGENTS.md: after executing a skill that produces a sub-decision requiring further dispatch, the orchestrator re-evaluates the skill deck against the sub-decision's intent. Second, update the approval-gate gap-fill cascade to include explicit `dispatch_next` fields naming the skills to load (spec-creation, writing-plans, git-workflow). The orchestrator reads `dispatch_next` and re-enters the gate with that skill name as the trigger.

## Impact

- **Risk 1:** Re-entry loop if `dispatch_next` cycles back to the same skill — mitigated by single-pass dispatch tracking
- **Risk 2:** Orchestrator context growth from repeated skill deck evaluation — mitigated by re-entry being bounded (max 3 per message)
- **Dependencies:** #1588 — Orchestrator inline-work bypass (separate concern: dispatch routing fixes)

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at {{SPEC_PATH}}.
After creation, `local-issues sync {N}` MUST be run and the result committed to create the local `.issues/{N}/` entry.
The implementation plan will be created in `.issues/{N}/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

---

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Pre-Response Gate procedure has re-entry condition documented | `string` | grep for "Re-entry condition" in AGENTS.md |
| SC-2 | Gap-fill cascade table has `dispatch_next` column with explicit skill names | `string` | grep for "dispatch_next" in approval-gate auto-dispatch.md |
| SC-3 | Behavioral test: orchestrator loads `spec-creation` after gap-fill cascade triggers | `behavioral` | `opencode-cli run` with "approved for plan" → stderr shows `skill({name: "spec-creation"})` |

## Files Affected

- `.opencode/AGENTS.md` — Pre-Response Gate procedure (add re-entry condition)
- `.opencode/skills/approval-gate/tasks/auto-dispatch.md` — add `dispatch_next` fields to gap-fill cascade
- `.opencode/skills/approval-gate/SKILL.md` — Authorization Scope Model table (add Dispatch Next column)

## Dependencies

- #1588 — Orchestrator inline-work bypass (separate concern: dispatch routing fixes)

## Out of Scope

- Changes to #1588's scope (SKILL.md inline instructions, write.md sub-agent markers, step status output)
- Changes to individual skill dispatch tables (covered by #1588)

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.issues/{N}/plan.md` before implementation begins.

🤖 OpenCode (deepseek-v4-flash) created