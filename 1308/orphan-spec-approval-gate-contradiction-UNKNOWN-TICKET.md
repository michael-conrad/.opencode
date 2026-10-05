## Problem

Contradictory rules across `010-approval-gate.md` about whether issue creation/update requires authorization under default scope (`for_analysis`).

### Contradiction

Line 216 (under `for_analysis` ✅ Allowlist) allows: "Create/update GitHub Issues" — no authorization needed. But the Action Authorization Classification table (line 194-206) lists actions and their authorization requirements separately, and readers cannot know whether line 216 or the classification table takes precedence for issue operations that overlap (e.g., closing issues).

### Expected behavior

Issue creation/updates are allowed by default for all scopes — including `for_analysis`. No gating behind `for_implementation` is required.

## Fix

### 1. Add resolution text as a blockquote after line 216

Insert immediately after the "Create/update GitHub Issues" allowlist item:

```
> **Resolution:** This allowlist item overrides the Action Authorization Classification table for all issue-related operations (create, update, close, add labels/comments). No authorization beyond the scope keyword is required.
```

### 2. Add a note to the Action Authorization Classification table

After line 206 ("Run tests, verification"), add:

```
| Close issues | Yes (after PR merge confirmed) — **subject to `for_analysis` allowlist override** |
```

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Resolution blockquote present as immediate sibling of "Create/update GitHub Issues" allowlist item | String | Content-verification: grep for "allowlist item overrides the Action Authorization Classification table" |
| SC-2 | Action Authorization Classification table references the allowlist override for Close issues row | String | Content-verification: in the classification table section, grep -A5 "Close issues" must find "allowlist override" within 5 lines |
