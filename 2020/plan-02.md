---
title: "Phase 2: Fix SKILL.md Invocation sections"
phase: 2
issue: 2020
status: draft
risk: low
Dispatch: sub-agent
---

## Entry Criteria

- [ ] Phase 1 audit results available
- [ ] Phase 1 Z3 check passed

## Steps

- [ ] 4. Fix spec-creation/SKILL.md Invocation (**sub-agent**)

    1. Change Invocation entries that dispatch the `create` pipeline (23 `[sub-task]` steps) to `inline` (orchestrator executes)
    2. Ensure each `[sub-task]` step in the pipeline has its own dispatch entry in the Trigger Dispatch Table

- [ ] 5. Fix writing-plans/SKILL.md Invocation (**sub-agent**)

    1. Change Invocation entries that dispatch the `create` pipeline (16 `[sub-task]` steps) to `inline` (orchestrator executes)
    2. Ensure each `[sub-task]` step in the pipeline has its own dispatch entry in the Trigger Dispatch Table

- [ ] 6. Z3 check — solve check verify fix output (**sub-agent**)

    Run `.opencode/tools/solve check` with the fix contract.

## Exit Criteria

- [ ] All marked Invocation sections fixed — verify: `grep -c '\[sub-task\]' .opencode/skills/spec-creation/SKILL.md .opencode/skills/writing-plans/SKILL.md` returns 0
- [ ] Each `[sub-task]` step has a TDT dispatch entry — verify: audit artifact shows 1:1 mapping
- [ ] Z3 check passes — verify: `.opencode/tools/solve check` exits 0

### Evidence Type Annotations

| SC | Evidence Type | Verification Method |
|----|---------------|---------------------|
| SC-1 | string | `grep` exit code + audit artifact inspection + `.opencode/tools/solve check` exit code |

## SC Coverage

- SC-1 (no `[sub-task]` in Invocation sections)

## Safety Rollback

```bash
git checkout -- .opencode/skills/spec-creation/SKILL.md .opencode/skills/writing-plans/SKILL.md
```

## Concern Transition

Phase 2 general Invocation fix must precede Phase 3 writing-plans-specific fix to avoid conflict.
