---
remote_issue: 2130
remote_url: https://github.com/michael-conrad/.opencode/issues/2130
labels: [spec]
---

## Problem

`067-context-completeness.md` is ~120 lines / ~6.5KB. Already compact, but contains teaching material (Why This Matters table, Examples table), a duplicate Core Principle section, and a When This Applies table that can be replaced with a one-sentence exception.

## Proposed Solution

### Remove (teaching material, not rules):

| Section | Lines | Rationale |
|---|---|---|
| Why This Matters table | 19-28 | Teaching material. No public config deck uses this pattern. |
| Examples table | 97-101 | Teaching material illustrating staleness rule. Rule already stated. |

### Remove (all preloaded, already in context):

| Section | Lines |
|---|---|
| Relationship to Other Guidelines | 103-110 |

### Collapse:

| Section | Action |
|---|---|
| Core Principle (lines 15-17) | Merge into Zero Tolerance — same rule, same wording |

### Replace:

| Section | Current | Replacement |
|---|---|---|
| When This Applies table (lines 38-48) | 8-row decision table | One sentence: "Before any action on a resource, read all comments. Exception: passive reading (no subsequent action) does not require comment reading." |

### Keep:

- Zero Tolerance Rule
- Scope of Resources table (PR review comments clarification is critical)
- Evidence Requirement + COUNTS/NOT
- Staleness Rule + Significant Actions list + De Minimis Bound
- FORBIDDEN/REQUIRED

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Core Principle collapsed into Zero Tolerance | string | grep for single occurrence of 'read ALL comments' |
| SC-2 | Why This Matters table removed | string | grep for absence of 'Why This Matters' |
| SC-3 | When This Applies table replaced with one-sentence exception | string | grep for 'passive reading' |
| SC-4 | Examples table removed | string | grep for absence of 'Resource last read' |
| SC-5 | Relationship to Other Guidelines removed | string | grep for absence of 'Relationship to Other Guidelines' |
| SC-6 | Zero Tolerance, Scope of Resources, Evidence Requirement, Staleness Rule, FORBIDDEN/REQUIRED remain | string | grep for each section header |

## Implementation Plan

### Phase 1: Collapse Core Principle into Zero Tolerance
### Phase 2: Remove Why This Matters, Examples, Relationship
### Phase 3: Replace When This Applies table with one-sentence exception
### Phase 4: Verify all keep sections remain

## Files Affected

- `.opencode/guidelines/067-context-completeness.md` — compacted

## Risks

- **None.** Self-contained refactoring of existing content. No cross-references to remove.

## Dependencies

- None.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
