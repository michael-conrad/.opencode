# Preliminary Code Path Inventory — Dispatch Discipline

## Path 1: Skill invocation (correct target model)

```
User message
  → Pre-Response Gate (system prompt): scan available_skills
  → skill({name}) → SKILL.md loads into orchestrator context
  → orchestrator reads TDT + Invocation (routing metadata)
  → orchestrator EXECUTES the workflow steps directly
  → where workflow says "dispatch via task()": orchestrator calls
    task(subagent_type=..., prompt="execute <task> from <skill>. Read <skill>/tasks/<task>.md first")
  → sub-agent (leaf) reads task card, executes, returns result contract
  → orchestrator receives contract, continues workflow
```

## Path 2: Skill invocation (defective — whole-card forwarding)

```
User message
  → Pre-Response Gate: scan skills
  → skill({name}) → SKILL.md loads
  → ORCHESTRATOR FORWARDS ENTIRE SKILL.md to task(subagent_type="general", prompt=<card content>)
  → sub-agent (leaf) receives routing metadata it cannot execute
  → Either: pre-flight guard fires → BLOCKED ORCHESTRATOR_ONLY_SKILL_CARD (harness absorbs it)
  → Or: sub-agent tries to follow TDT → cannot call task() → malfunction/hallucinated execution
```

## Path 3: Plan execution (correct target model)

```
"implement" / approved plan exists
  → orchestrator loads executing-plans skill card
  → orchestrator READS the plan file directly
  → orchestrator executes plan steps one by one IN ITS OWN CONTEXT
  → where a step says dispatch via task(): orchestrator dispatches that step's task card
  → orchestrator checkpoints per SC, verifies, continues
```

## Path 4: Plan execution (defective — whole-plan forwarding)

```
"implement"
  → prompts/default.txt: "hand off to executing-plans skill via sub-agent"
  → orchestrator dispatches ENTIRE PLAN (or entire executing-plans workflow) to one sub-agent
  → leaf sub-agent reads plan; plan steps requiring task() cannot execute
  → sub-agent either stalls, fabricates completion, or returns partial work as complete
```

## Path 5: Contradiction resolution inside orchestrator (why malfunction happens)

When directives conflict, resolution order in current deck:
- prompts/default.txt (highest priority in practice) says both A and B
- 022 says A with HALT-on-inline enforcement
- 000-critical-rules says B for the whole-card case only
- Skill cards say B in TDT/Invocation but contain blanket "every step → task()" clauses

A model reading all of these averages them: dispatch MORE (safe under A), including wholes
(the thing B prohibits). The observed malfunction is this averaging made visible.

## Path 6: Enforcement feedback (partial)

```
Whole-card forwarded → sub-agent pre-flight guard → BLOCKED → orchestrator
  re-tasks clean-room with same canonical string (max 2 retries) → same BLOCKED
  → per Post-task() Output Guarantee → double-failure report + halt
```
The guard converts the defect into a stall, not a correction — the orchestrator
never learns the correct pattern because no directive tells it what went wrong.