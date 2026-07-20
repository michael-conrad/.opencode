---
title: "SPEC-FIX: SKILL.md Invocation sections dispatch pipelines with [sub-task] steps to sub-agents that cannot call task()"
status: draft
created: 2026-07-20
license: MIT
provenance: AI-generated
issue: 2032
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-20

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

Multiple SKILL.md Invocation sections dispatch entire pipelines containing `[sub-task]` steps to sub-agents via `task()`. A sub-agent **cannot** call `task()` — that is an orchestrator-level capability. This is a category error: skill card content (routing metadata) dispatched to a sub-agent.

The affected skills include:

- **`spec-creation/SKILL.md`** — Invocation dispatches the 25-step `create` pipeline to a sub-agent. The pipeline contains `[sub-task]` steps that require `task()` calls.
- **`writing-plans/SKILL.md`** — Invocation dispatches the 17-step `create` pipeline to a sub-agent. The pipeline contains `[sub-task]` steps that require `task()` calls.
- Any other SKILL.md whose Invocation section dispatches a pipeline containing `[sub-task]` steps.

## Root Cause

The Invocation section in each SKILL.md defines a canonical dispatch string that sends the entire pipeline to a sub-agent. But the pipeline contains steps marked `[sub-task]` — steps that require the executor to call `task()` to dispatch further sub-agents. A sub-agent cannot do this.

The correct pattern (per critical-rules-XXX):

| Artifact | File | Consumer | Content | Action |
|----------|------|----------|---------|--------|
| Skill Card | SKILL.md | Orchestrator | Routing metadata | Load via skill(), read in own context, do NOT dispatch |
| Task Card | tasks/<name>.md | Sub-agent | Execution procedure | Dispatch via task() |

## Fix

For each affected SKILL.md, restructure the Invocation section so the canonical dispatch string sends a **task card** (a single `.md` file with entry criteria, steps, exit criteria) — not the entire pipeline. The task card is what the sub-agent reads and executes.

The orchestrator then executes the pipeline steps inline (or dispatches each step individually), rather than tasking the entire pipeline to a sub-agent.

## Affected Files

| File | Defect |
|------|--------|
| `.opencode/skills/spec-creation/SKILL.md` | Invocation dispatches 25-step pipeline to sub-agent |
| `.opencode/skills/writing-plans/SKILL.md` | Invocation dispatches 17-step pipeline to sub-agent |
| Any other SKILL.md with `[sub-task]` in pipeline dispatched via Invocation | Same pattern |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `spec-creation/SKILL.md` Invocation dispatches a task card (not the full pipeline) | `string` | grep Invocation section — must show task card path, not pipeline steps |
| SC-2 | `writing-plans/SKILL.md` Invocation dispatches a task card (not the full pipeline) | `string` | grep Invocation section — must show task card path, not pipeline steps |
| SC-3 | No SKILL.md Invocation section dispatches a pipeline containing `[sub-task]` steps to a sub-agent | `string` | grep for `[sub-task]` in all SKILL.md Invocation sections — must not appear |
| SC-4 | All affected task cards exist and contain entry criteria, steps, and exit criteria | `string` | verify each referenced task card file exists and has the required sections |
| SC-5 | Behavioral test: agent dispatches spec-creation task correctly without pipeline bypass | `behavioral` | `opencode run` with spec creation prompt — verify stderr shows correct task card dispatch |

## Risk and Edge Cases

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Other SKILL.md files have the same pattern not yet identified | Medium | Medium | Full grep for `[sub-task]` in all SKILL.md Invocation sections |
| Task card restructuring changes the pipeline execution model | Medium | Medium | Verify each task card has complete entry/exit criteria before deployment |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep -r "\[sub-task\]" .opencode/skills/*/SKILL.md` | Identify all SKILL.md files with sub-task steps in Invocation |
| Direct source search | `grep -r "\[sub-task\]" .opencode/skills/spec-creation/SKILL.md` | Confirm spec-creation pattern |
| Direct source search | `grep -r "\[sub-task\]" .opencode/skills/writing-plans/SKILL.md` | Confirm writing-plans pattern |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

*Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)*
