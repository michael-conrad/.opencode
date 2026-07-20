## Defects

- D2 FAIL — description "generating operational runbooks" doesn't enumerate TDT's generate/track/completion tasks explicitly
- D3 INCOMPLETE — omits progress tracking and completion workflow steps

## Current → Proposed

**Current:** "Use when generating operational runbooks for infrastructure incidents or procedures. SRE discipline is REQUIRED."

**Proposed:** "Use when generating, tracking progress of, and completing operational runbooks for infrastructure incidents — always follow SRE discipline for incident documentation."

## Required Action

Update `.opencode/skills/sre-runbook/SKILL.md` frontmatter `description` field with proposed text.