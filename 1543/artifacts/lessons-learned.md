# Lessons Learned: Mandatory Skill Bypass — Phase 2 Plan Creation

**Date:** 2026-06-28
**Context:** Phase 2 (#1543) plan creation for complexity metric remediation
**Violation:** `writing-plans` skill bypass — orchestrator wrote plan inline instead of dispatching through 21-step pipeline

## What Happened

1. User directive: "create plan for phase 2. all findings must be remediated."
2. Agent response: Wrote a markdown plan file directly to `.opencode/.issues/1543/plan.md`
3. Agent skipped the `writing-plans` skill entirely — no skill dispatch, no sub-agent tasks, no Z3 checks
4. User opened the file and identified it as defective: "that is not a plan file"

## Root Cause Analysis

### Direct Cause
- Orchestrator received a directive that matched the `writing-plans` skill trigger ("create plan")
- Orchestrator did NOT evaluate the directive against available skill descriptions (Pre-Response Gate Procedure §1)
- Orchestrator did NOT call `skill({name: "writing-plans"})` before producing output (Pre-Response Gate Procedure §2)
- Orchestrator produced output without skill evaluation — bypassed quality gates that catch defects

### Contributing Factors
- Agent treated "create plan" as a simple content generation task, not a skill-gated workflow
- Agent did not recognize that plan creation has a mandatory 21-step pipeline with Z3 validation
- Agent prioritized speed over correctness — wrote directly instead of dispatching

### Violation Pattern
```
User directive → Agent matches intent → Agent writes directly → Defective output
                                                    ↑
                                            SKILL BYPASS HERE
```

Correct pattern:
```
User directive → Agent matches intent → Agent dispatches skill → Skill executes pipeline → Valid output
                                                    ↑
                                            SKILL DISPATCH HERE
```

## Consequences

| Impact | Description |
|--------|-------------|
| Defective artifact | Plan file created without Z3 validation, audits, or sub-agent verification |
| Wasted effort | Plan file must be discarded and recreated through proper pipeline |
| Trust erosion | User had to catch the mistake — agent did not self-correct |
| Pipeline contamination | If the defective plan had been used for implementation, all downstream work would inherit the defect |

## Skills Violated

| Skill | Requirement | Violation |
|-------|-------------|-----------|
| `writing-plans` | "All tasks are mandatory" | Orchestrator skipped all 21 steps |
| `writing-plans` | "Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded" | Orchestrator performed inline work |
| `approval-gate` | "Spec before code" | Plan created without spec approval verification |
| `000-critical-rules` | "Skill Bypass = Critical Violation" | Mandatory skill call was skipped |

## Fix Spec Requirements

A fix spec should address:

1. **Pre-Response Gate Enforcement**: Ensure the agent evaluates every directive against available skills before producing output
2. **Skill Dispatch Validation**: Verify that `skill()` is called for every trigger-matching directive
3. **Inline Work Detection**: Detect when the orchestrator writes files directly instead of dispatching sub-agents
4. **Defective Artifact Rejection**: Automatically reject plan files not created through the proper pipeline

## Corrective Action

1. Delete the defective plan file (done)
2. Follow the `writing-plans` 21-step pipeline to create a valid plan
3. Verify spec approval before proceeding with pipeline
