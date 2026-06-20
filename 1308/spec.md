## Problem

Contradictory rules across `010-approval-gate.md` about whether issue creation/update requires authorization under default scope (`for_analysis`).

### Contradiction 1 — Internal to `010-approval-gate.md`

Line 216 (under `for_analysis` ✅ Allowlist) says:
> `- Create/update GitHub Issues (specs, plans, bug reports)`

Line 194+ (Action Authorization Classification table) has conflicting authorization gating that led an agent to block issue writes for a repo owner.

### Contradiction 2 — Between files

Line 216 of `010-approval-gate.md` permits "Create/update GitHub Issues" under all scopes (defaulting to `for_analysis`). But no other file overrides or qualifies this rule, leaving the classification table's intent ambiguous as to which scope it applies to.

### Expected behavior

Issue creation/updates are allowed by default for all scopes — including `for_analysis`. No gating behind `for_implementation` is required.

## Fix

1. Add explicit override text immediately after line 216 to clarify:
   > This permission includes creating, updating, and closing GitHub Issues for spec/plan tracking purposes. It applies under ALL authorization scopes including `for_analysis`. No separate authorization beyond the scope keyword is required.

2. Cross-reference this in the Action Authorization Classification table (around line 194) to indicate that issue operations fall under this override.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Line 216 clarifier text present and unambiguous | String | Content-verification: grep for "ALL authorization scopes including `for_analysis`" in the file |
| SC-2 | Table classification table updated to remove ambiguity | String | Content-verification: grep for issue operations reference in Action Authorization Classification |
