**Defects:** D2 FAIL, D3 INCOMPLETE — desc "task()ing any execution sub-agent to independently determine scope" but TDT has 2 tasks (analyze/completion).

**Current:** "Use when task()ing any execution sub-agent to independently determine scope. Pre-analysis MUST be performed before dispatch — always required."
**Proposed:** "Use when performing pre-analysis before dispatching an execution sub-agent — discover the actual scope via independent investigation, not orchestrator-provided context. Dispatch is REQUIRED before every task()."

**Required action:** Update `skills/pre-analysis/SKILL.md` description field to match proposed text.