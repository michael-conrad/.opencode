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

## Defect 2: Pre-Response Gate fires once per message — gap-fill cascade bypasses skill dispatch

### Root Cause

The Pre-Response Gate procedure (AGENTS.md) mandates evaluating ALL skill descriptions before producing output. However, it fires once per user message. When the user said "approved for plan: .opencode#1578", the orchestrator:

1. Evaluated skill deck → matched `approval-gate` ✅
2. Loaded `approval-gate` → read issue → determined gap-fill: auto-create spec
3. **Did NOT re-evaluate skill deck** for the gap-fill step
4. Wrote spec inline without ever loading `spec-creation` skill

The `spec-creation` skill description says: *"Use when creating a spec or writing a specification."* This should have triggered a second Pre-Response Gate evaluation. It did not, because the gate fires once per message, not once per sub-decision.

### Bright-Line Mandate Violation

The orchestrator also violated the forbidden rationalization: *"This is too small for a skill."* The fix was a single-line YAML change, so the orchestrator judged the full spec-creation pipeline (requirements → decompose → traceability → risk → write → completion) was overkill. This is explicitly listed as a forbidden rationalization in the Bright-Line Mandates.

### writing-plans/SKILL.md Explicit Inline Instructions

When the orchestrator finally loaded `writing-plans`, every section told it to execute inline:

| Section | Text |
|---------|------|
| Overview | "executing entirely at orchestrator level" |
| Mandatory Task Discipline #3 | "no `task()` calls within the pipeline" |
| Programmatic Invocation | "executes steps inline" (9 times) |
| Persona | "reads each step procedure... and executes it directly" |
| Invocation | "executes steps inline" |
| Operating Protocol | "executes entirely at the orchestrator level" |
| Sub-Agent Routing | "executed inline by the orchestrator" |

The concrete instruction ("execute inline") overrode the abstract enforcement rule ("don't do inline work"). The orchestrator followed what the skill card literally said.

### Root Cause Contribution Breakdown

| Factor | Contribution | Root Cause |
|--------|-------------|------------|
| Pre-Response Gate fires once per message, not per sub-decision | 40% | Gap-fill cascade intent was not re-evaluated against skill deck |
| Rationalization bypass ("too small for a skill") | 30% | Bright-Line Mandate violation — orchestrator judged simplicity |
| writing-plans/SKILL.md explicitly says "execute inline" | 20% | Concrete instruction overrides abstract enforcement rule |
| write.md sub-agent markers block sub-agent execution | 10% | Sub-agent cannot dispatch, combines steps into blob |

### Classification

**Systemic** — affects ALL plan/spec creation workflows under gap-fill cascade. The Pre-Response Gate fires once per user message, but the gap-fill cascade requires multiple skill evaluations within a single response. The orchestrator has no mechanism to re-evaluate the skill deck mid-response.

### Remediation Target

- `approval-gate` skill: gap-fill cascade steps must explicitly name which skills to dispatch (e.g., "auto-create spec via `spec-creation` skill → task write")
- `writing-plans/SKILL.md`: Remove all "executes inline" language (covered by #1588)
- Pre-Response Gate: Needs a mechanism to re-evaluate skill deck after each sub-decision within a single response

### Related Issues

- #1588 — Orchestrator inline-work bypass (covers SKILL.md fix)
- #1579 — Plan writer step status instruction block

### Evidence

- Session transcript: turns 1-2 — orchestrator wrote spec inline without loading `spec-creation`
- Session transcript: turns 6-7 — orchestrator loaded skills only after user rejection
- `writing-plans/SKILL.md` — 7 sections explicitly say "execute inline"
- `spec-creation/SKILL.md` — correct DISPATCH_GATE but never loaded

## Defect 3: SKILL.md Trigger Dispatch Table has no pipeline entry gate — allows skipping mandatory steps

### Root Cause

SKILL.md cards have three structural elements that interact to create a bypass:

1. **Trigger Dispatch Table** — lists all tasks as independently dispatchable entries. The orchestrator reads this and sees: "I can dispatch any of these tasks directly."

2. **Operating Protocol** — documents the pipeline sequence with chain dependencies. But these are **advisory metadata, not enforced gates**. The chain annotations describe what SHOULD happen, not what MUST happen.

3. **Invocation section** — provides canonical `task()` strings for every task. This reads as: "Pick the task you need and dispatch it." There is no instruction saying: "You MUST execute the Operating Protocol steps in order."

The orchestrator follows the path of least resistance: Trigger Dispatch Table → find task → Invocation section → get canonical string → dispatch. The Operating Protocol is never checked as a gate.

### Manifestation in spec-creation

The Operating Protocol has 10 steps with chain dependencies:
- Step 2: requirements (chain: none)
- Step 3: decompose (chain: step_2)
- Step 4: traceability (chain: step_3)
- Step 5: risk (chain: step_4)
- Step 9: write (chain: step_5, step_8)

The orchestrator dispatched `write` directly without running steps 1-8. The chain dependency `step_5, step_8` was documented but never enforced.

### Manifestation in writing-plans

Same pattern. The Trigger Dispatch Table lists `write` as a standalone entry. The Programmatic Invocation table says "Orchestrator reads `tasks/write.md` and executes steps inline." The 22-step pipeline in the Operating Protocol is bypassed entirely.

### Classification

**Systemic** — affects ALL skills with pipeline Operating Protocols. Every skill that has a multi-step pipeline and a Trigger Dispatch Table with individual task entries has this defect.

### Remediation Target

Add a `## Pipeline Entry Gate` section to every SKILL.md that has a multi-step Operating Protocol. The gate maps each task to its prerequisite steps and provides a gate check (e.g., "verify artifact exists at path"). The orchestrator MUST check the Pipeline Entry Gate before dispatching any task. If prerequisites are not met, the orchestrator MUST dispatch the prerequisite tasks first.

### Affected Skills

- `spec-creation/SKILL.md` — 10-step Operating Protocol, no entry gate
- `writing-plans/SKILL.md` — 22-step Operating Protocol, no entry gate
- Any other skill with multi-step pipeline + Trigger Dispatch Table

### Evidence

- `spec-creation/SKILL.md` lines 27-37: Trigger Dispatch Table lists `write` as standalone entry
- `spec-creation/SKILL.md` lines 76-87: Operating Protocol has 10 steps with chain dependencies
- `spec-creation/SKILL.md` lines 57-72: Invocation section provides canonical strings for all tasks
- Session transcript: orchestrator dispatched `write` directly, skipped steps 1-8
