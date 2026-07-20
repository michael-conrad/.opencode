> **Full spec and artifacts: [`.opencode/.issues/1419/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1419)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1419/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

Spec #1418 describes an orchestrator dispatch loop for the gap-fill cascade. The risk analysis table lists a loop counter mitigation ("max 10 iterations as safety net") but there is no success criterion mandating it. A safety mechanism described in prose but not enforced by an SC is not a requirement — it is a suggestion. The spec will pass verification without the loop counter ever being implemented.

## Fix

Add a new success criterion to #1418's SC table:

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-11 | Orchestrator loop has a mandatory iteration counter (max 10) to prevent infinite dispatch loops when cascade repeatedly returns BLOCKED | `string` |

And add a corresponding critical violation to `000-critical-rules.md`:

```
### [critical-rules-gap-fill-loop] CRITICAL VIOLATION — Gap-fill cascade orchestrator loop without iteration counter

The orchestrator dispatch loop for gap-fill cascade MUST have a mandatory
iteration counter with a maximum of 10 iterations. Exceeding the limit MUST
halt the pipeline with a blocker report. An orchestrator loop without a
counter is an infinite-loop defect vector.
```

## Files Affected

| File | Change |
|------|--------|
| `guidelines/000-critical-rules.md` | Add Tier 1 critical violation for missing loop counter |
| `.opencode/.issues/1418/spec.md` | Add SC-11 to success criteria table |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)