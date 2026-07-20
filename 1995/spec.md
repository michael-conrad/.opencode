## Problem

The `writing-plans-creation/tasks/write.md` Plan Format Requirements section does not specify a structured format for step parameters. The "Dispatch indicators" table shows bare examples:

```
| `(**sub-agent**)` | Dispatch via `task()` with phase file + orchestrator-provided context | `- [ ] 3. **RED (**sub-agent**).**` |
```

No specification for `- Command:`, `- SC:`, `- Expected:` or any other indented sub-bullet format. The write sub-agent defaults to inline prose, producing plans like:

```
- [ ] 3. **RED: Remove 8 fake dispatch entries from SKILL.md (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-1: verify SKILL.md Trigger Dispatch Table has exactly 3 entries. The test must fail because 11 entries currently exist. Target file: .opencode/skills/spec-creation/SKILL.md")` **→ SC-1**
```

This is the pattern seen in both #1993 and #1881 plans.

## Root Cause

Commit `8ae08fc7` added indented sub-bullets to the **Procedure** section of `write.md` (the task card's own internal procedure), but never propagated the format to the **Plan Format Requirements** section (what the sub-agent actually follows to produce plan output).

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Plan Format Requirements section specifies indented sub-bullet format for every step: `- Command:`, `- SC:`, `- Expected:` | `string` |
| SC-2 | Example in Dispatch Indicators table shows indented sub-bullets, not inline prose | `string` |
| SC-3 | Validation rules include check that every `(**sub-agent**)` step has `- Command:`, `- SC:`, `- Expected:` sub-bullets | `string` |
| SC-4 | Behavioral test: plan writer sub-agent produces steps with indented sub-bullets, not inline `task()` calls | `behavioral` |

## Files

- `.opencode/skills/writing-plans-creation/tasks/write.md`

## Dependencies

None. Independent of #1993.
