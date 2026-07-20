## Defects

- D2 FAIL — description "executing an approved plan through the implementation pipeline" doesn't enumerate TDT's 10 specific tasks (pre-work, assemble-work, verification-before-completion, finishing-checklist, review-prep, pr-creation)
- D3 INCOMPLETE — omits mandatory sub-agent dispatch language

## Current → Proposed

**Current:** "Use when executing an approved plan through the implementation pipeline. MUST dispatch here after plan approval, before any file modification."

**Proposed:** "Use when executing an approved plan via pre-work → assemble-work → verification-before-completion → finishing-checklist → review-prep → pr-creation workflow. Must dispatch to sub-agents — orchestrator routes, never executes inline."

## Required Action

Update `.opencode/skills/implementation-pipeline/SKILL.md` frontmatter `description` field with proposed text.