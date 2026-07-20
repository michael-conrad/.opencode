## Defects

- D2 FAIL — description "task()ing any execution sub-agent" doesn't enumerate TDT's analyze/completion tasks
- D3 INCOMPLETE — omits scope-discovery requirement

## Current → Proposed

**Current:** "Use when task()ing any execution sub-agent to independently determine scope. Pre-analysis MUST be performed before dispatch — always required."

**Proposed:** "Use when performing pre-analysis via independent investigation before dispatching an execution sub-agent — discover the actual scope, don't accept orchestrator-provided context. Dispatch is REQUIRED before every task()."

## Required Action

Update `.opencode/skills/pre-analysis/SKILL.md` frontmatter `description` field with proposed text.