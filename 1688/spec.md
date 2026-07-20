## Problem

The writing-plans pipeline (and all sequential pipelines) define mandatory step ordering with chain dependencies. Each step's output is the next step's input. A sub-agent dispatched for Step N must complete before Step N+1 begins.

A defective reasoning pattern has been observed: "Let me proceed with Step 8 (Solve) and Step 10 (Write) in parallel since they're independent sub-agent tasks." This is false — Step 10 (Write) depends on Step 9 (Z3 check of Solve output), which depends on Step 8 (Solve). The chain is: Step 8 → Step 9 → Step 10. They are NOT independent.

## Root Cause

The agent treated "sub-agent dispatch" as equivalent to "independent execution." Sub-agent dispatch is an execution mechanism, not a dependency declaration. Chain dependencies in the pipeline are structural invariants — they apply regardless of whether steps execute via sub-agent or inline.

## Fix

Add a prohibition to the writing-plans SKILL.md Mandatory Task Discipline (and any other pipeline-defining skill) that:

1. Pipeline steps with chain dependencies MUST execute sequentially — no parallel dispatch
2. "Sub-agent dispatch" does NOT imply "independent execution" — chain dependencies are structural invariants
3. Parallel execution is only permitted when explicitly declared as `parallel: true` in the step definition

## Affected Files

- `.opencode/skills/writing-plans/SKILL.md` — Mandatory Task Discipline
- `.opencode/skills/writing-plans/tasks/create.md` — Operating Protocol (add parallel annotation)
- `.opencode/skills/implementation-pipeline/SKILL.md` — Trigger Dispatch Table (if applicable)
- `.opencode/skills/spec-creation/SKILL.md` — Operating Protocol (if applicable)

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | writing-plans SKILL.md Mandatory Task Discipline states that chain-dependent steps MUST execute sequentially, and sub-agent dispatch does not imply independence | `string` | `grep -q "sequential" .opencode/skills/writing-plans/SKILL.md` |
| SC-2 | writing-plans create.md Operating Protocol annotates each step with `parallel: true/false` to make dependency explicit | `string` | `grep -q "parallel:" .opencode/skills/writing-plans/tasks/create.md` |
| SC-3 | Behavioral test: agent does NOT dispatch two chain-dependent steps in parallel when executing the pipeline | `behavioral` | `opencode-cli run` with pipeline execution prompt → stderr shows sequential dispatch, not parallel |

---

🤖 OpenCode (deepseek-v4-flash) created
