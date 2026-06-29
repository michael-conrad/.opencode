---
session: 2026-06-29
consumed: false
---

# Session 2026-06-29 — Correction Catalog

## Defect 1: writing-plans/tasks/write.md sub-agent dispatch contradiction

### Root Cause

`writing-plans/tasks/write.md` Procedure section has 5 sub-steps marked `(**sub-agent**)` (steps 1-5: write header, write phase sections, validate dispatch markers, apply approval cascade, sync cross-reference). However, the `write` task is itself dispatched as a sub-agent from `create.md` step 10 (`(**sub-agent**) Write`). The Mandatory Task Discipline item 4 in `writing-plans/SKILL.md` states: **"Sub-agents must not dispatch sub-agents."**

This creates a three-way structural contradiction:

1. `create.md` step 10 dispatches `write` as a sub-agent
2. `write.md` has 5 sub-steps marked `(**sub-agent**)`
3. SKILL.md item 4 forbids sub-agents from dispatching sub-agents

The sub-agent executing `write.md` cannot dispatch those 5 sub-steps. It is stuck — the task file tells it to dispatch sub-agents, but the discipline forbids it.

### Secondary Tension

`writing-plans/SKILL.md` §Programmatic Invocation table says `write` → "Orchestrator reads `tasks/write.md` and executes steps inline", but `create.md` step 10 dispatches it as a sub-agent, not inline. The SKILL.md and create.md disagree on how `write` is executed.

### Manifestation

When the orchestrator dispatched the `write` task as a sub-agent, the sub-agent received a task file telling it to dispatch 5 sub-agents. Unable to do so (per discipline item 4), the sub-agent either:
- Combined all 5 sub-steps into a single blob of work (what happened in practice)
- Produced a plan that was not validated against the Plan Format Requirements
- Left the orchestrator with no way to verify each sub-step independently

### Classification

**Systemic** — affects all plan creation workflows. Every time `create.md` step 10 dispatches `write` as a sub-agent, the contradiction fires.

### Remediation Target

`writing-plans/tasks/write.md` — change the 5 `(**sub-agent**)` markers on steps 1-5 to `(**inline**)`. The sub-agent executing `write.md` is already a clean-room worker and can perform these sub-steps directly.

### Related Issues

- #1374 — writing-plans create.md Plan Format Requirements hardcodes step sequence
- #1447 — Plan phase structure inconsistency between structure.md and write.md
- #1378 — Evidence type classification gate
- #1588 — Orchestrator inline-work bypass (covers this fix)

### Evidence

- `writing-plans/tasks/write.md` lines 22-45: 5 sub-steps marked `(**sub-agent**)`
- `writing-plans/tasks/create.md` line 66-68: step 10 dispatches `write` as sub-agent
- `writing-plans/SKILL.md` line 19: Mandatory Task Discipline item 4 "Sub-agents must not dispatch sub-agents"
- `writing-plans/SKILL.md` line 49: Programmatic Invocation says `write` → "Orchestrator reads tasks/write.md and executes steps inline"

## Defect 2: Gap-fill cascade has no dispatch routing — orchestrator had to guess how to "auto-create plan"

### Root Cause

The user said "approved for PR: .opencode#1579". This is an **authorization phrase**, not a "create plan" phrase. The `writing-plans/SKILL.md` Trigger Dispatch Table says:

```
| "create plan" / "implementation plan" / "write plan" / "plan" / "draft plan" | `create` |
```

None of those triggers match "approved for PR." The orchestrator loaded `writing-plans` because the `for_pr` scope's gap-fill says "auto-create plan" — but that's **prose in the approval-gate**, not a dispatch table entry. The orchestrator had to figure out HOW to "auto-create a plan" without any trigger phrase matching.

The orchestrator fell through to the Programmatic Invocation table, which lists `write` as a standalone entry with a concrete file path. It read `write.md` and executed inline. The `create` task was never triggered because no trigger phrase in the dispatch table matched the user's message or the gap-fill intent.

### The Actual Decision Chain

1. User: "approved for PR: .opencode#1579"
2. `approval-gate` matches → determines `for_pr` scope
3. Gap-fill prose: "auto-create spec+plan+auto-approve+auto-PR"
4. Orchestrator needs to figure out HOW to "auto-create plan"
5. Loads `writing-plans` skill
6. Reads Trigger Dispatch Table: triggers are "create plan" / "implementation plan" / "write plan" / "plan" / "draft plan"
7. **None of these match "approved for PR" or "auto-create plan"**
8. Falls through to Programmatic Invocation table: `write` → "read `tasks/write.md` and execute inline"
9. Reads `write.md` — never reads `create.md`
10. Executes inline

### Why the `create` Task Was Never Activated

The `create` task requires a trigger phrase that never appeared in the conversation. The user said "approved for PR" — not "create plan" or "write plan." The gap-fill cascade in `approval-gate` says "auto-create plan" but doesn't specify which skill or task to use. The orchestrator had to infer the mechanism and inferred wrong.

### Classification

**Systemic** — affects ALL gap-fill cascades. Every time `for_pr` or `for_implementation` scope triggers "auto-create plan," the orchestrator must guess how to do it. The dispatch table has no entry for the gap-fill intent.

### Remediation Target

- `approval-gate` skill: gap-fill cascade steps must explicitly name which skills and tasks to dispatch (e.g., "auto-create plan → dispatch `writing-plans --task create`")
- `writing-plans/SKILL.md` Trigger Dispatch Table: add a trigger for gap-fill cascade intent (e.g., "auto-create plan" / "gap-fill plan")
- `writing-plans/SKILL.md` Programmatic Invocation table: remove `write` as a standalone entry — it is a sub-task of `create`, not a direct entry point

### Related Issues

- #1588 — Orchestrator inline-work bypass (covers SKILL.md fix)
- #1579 — Plan writer step status instruction block

### Evidence

- Session transcript: orchestrator loaded `writing-plans` but never read `create.md`
- `writing-plans/SKILL.md` Trigger Dispatch Table: no trigger for "auto-create plan" or "approved for PR"
- `approval-gate` skill: gap-fill prose says "auto-create plan" without specifying which skill or task
