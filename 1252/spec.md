---
number: 1252
title: "[SPEC-FIX] Direct instruction to create plan should imply authorization"
state: OPEN
---

---
id: FIX
type: spec-fix
title: "[SPEC-FIX] Direct instruction to create plan should imply authorization"
status: draft
created: 2026-06-16
author: Michael Conrad
affected-files:
  - .opencode/skills/approval-gate/SKILL.md
  - .opencode/guidelines/010-approval-gate.md
related:
  - NewsRx/hermes-ingest-pubmed#14
---

## Summary

When a user gives a direct, unambiguous instruction like `"#14, create plan"`, the approval gate should treat this as implicit authorization for plan creation — not block with "no approved-for-* label found."

## Problem

The current authorization gate requires an `approved-for-*` label on the spec before allowing plan creation. However, a user saying `"#14, create plan"` is a direct instruction to create a plan — it IS authorization. The gate currently blocks this with:

```
Status: BLOCKED — No authorization for plan creation
Labels: [SPEC] only — no approved-for-* label
```

This forces the user to issue a separate authorization phrase ("approved #14 for plan") even though they already gave a direct instruction. The gate is treating the user's explicit directive as insufficient.

## Root Cause

The `verify-authorization` task in `approval-gate` checks for `approved-for-*` labels and explicit authorization phrases ("approved", "go") but does not recognize direct imperative instructions like `"create plan"`, `"implement #N"`, or `"write plan for #N"` as authorization for the requested action.

## Fix

Add a pattern in the authorization detection that recognizes direct imperative instructions as authorization for the requested action:

- `"#N, create plan"` → authorization for plan creation (`for_plan` scope)
- `"#N, implement"` → authorization for implementation (`for_implementation` scope)
- `"#N, create PR"` → authorization for PR creation (`for_pr` scope)
- `"write plan for #N"` → authorization for plan creation (`for_plan` scope)

The scope should match the action requested: plan creation → `for_plan`, implementation → `for_implementation`, etc.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `"#14, create plan"` is treated as authorization for plan creation (for_plan scope) | behavioral |
| SC-2 | `"#14, implement"` is treated as authorization for implementation (for_implementation scope) | behavioral |
| SC-3 | `"#14, create PR"` is treated as authorization for PR creation (for_pr scope) | behavioral |
| SC-4 | Existing explicit authorization phrases ("approved", "go") continue to work unchanged | behavioral |
| SC-5 | The fix is documented in both approval-gate SKILL.md and 010-approval-gate.md | string |

## Affected Files

- `.opencode/skills/approval-gate/SKILL.md` — authorization detection logic
- `.opencode/guidelines/010-approval-gate.md` — authorization scope documentation

*Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)*