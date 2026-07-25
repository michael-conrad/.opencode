---
remote_issue: 2129
remote_url: https://github.com/michael-conrad/.opencode/issues/2129
labels: [spec]
---

## Problem

`065-verification-honesty.md` is ~27KB. It contains sections duplicated in 000 (Single Exchange Window, Hard Failure Discipline, DDL Cost Model, DONE_WITH_CONCERNS coercion, Remediation-First Protocol), explanatory prose (Problem section, Relationship to Other Guidelines), and skill-card-level detail (Verification Comparison Semantics, Anti-Evasion Rules, Metadata Verification detail) that should be inlined into skill cards with back-links to 065 as master copy.

## Proposed Solution

### Remove (duplicated in 000):

| Section | Lines | Duplicated In |
|---|---|---|
| Single Exchange Window | 85-91 | 000 (Session-Verified State Trust) |
| Hard Failure Discipline + DDL Cost Model | 260-322 | 000 (Hard Failure Discipline) |

### Remove (explanatory prose, not rules):

| Section | Lines | Rationale |
|---|---|---|
| Problem | 21-31 | Teaching material, not a rule |
| What Constitutes Checking | 33-43 | Trigger-phrase table, anti-pattern |
| Memory vs Verified table | 69-77 | Duplicates COUNTS/NOT section |
| Relationship to Other Guidelines | 93-98 | All preloaded, already in context |
| Verification-Enforcement Boundary | 100-106 | Meta-commentary, dispatch mechanism handles it |

### Collapse:

| Section | Action |
|---|---|
| Zero Tolerance + Core Principle (lines 7-19) | Collapse 4 restatements to one statement |

### Keep (universal, not duplicated):

- Evidence Requirement + COUNTS/NOT (lines 45-67)
- No Exceptions (lines 78-83)
- Evidence Hierarchy table (lines 108-117)
- Pre-Response Factual Claim Gate (lines 119-141)
- FORBIDDEN/REQUIRED (lines 143-157)
- Metadata Verification — principle + full master table (lines 159-200)

### Move to skill cards with inline subsets + back-links to 065 as master copy:

| Section | Destination | Subset |
|---|---|---|
| Verification Comparison Semantics (lines 202-258) | `verification-before-completion` skill card | Full section inlined |
| Anti-Evasion Rules (lines 324-372) | `verification-before-completion` skill card | Full section inlined |
| Metadata Verification detail (table rows) | `verification-before-completion` skill card | STATUS markers, code references, process-completion flags |
| Metadata Verification detail (table rows) | `audit` skill card | STATUS markers, cross-references, code references, authorization currency, author identity |
| Metadata Verification detail (table rows) | `issue-operations` skill card | Labels, comments/body claims, sub-issue state |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Collapse Zero Tolerance + Core Principle to one statement | string | grep for single occurrence of core principle |
| SC-2 | Remove Problem section | string | grep for absence of '## Problem' |
| SC-3 | Remove What Constitutes Checking table | string | grep for absence of 'What Constitutes' |
| SC-4 | Remove Memory vs Verified table | string | grep for absence of 'Memory vs. Verified' |
| SC-5 | Remove Single Exchange Window | string | grep for absence of 'Single Exchange Window' |
| SC-6 | Remove Relationship to Other Guidelines | string | grep for absence of 'Relationship to Other Guidelines' |
| SC-7 | Remove Verification-Enforcement Boundary | string | grep for absence of 'Verification-Enforcement Boundary' |
| SC-8 | Remove Hard Failure Discipline + DDL | string | grep for absence of 'Hard Failure Discipline' |
| SC-9 | Evidence Requirement, No Exceptions, Evidence Hierarchy, Pre-Response Gate, FORBIDDEN/REQUIRED remain | string | grep for each section header |
| SC-10 | Metadata Verification master table remains in 065 | string | grep for 'Metadata Categories Requiring Verification' |
| SC-11 | Verification Comparison Semantics inlined in verification-before-completion with back-link | string | grep in verification-before-completion/SKILL.md |
| SC-12 | Anti-Evasion Rules inlined in verification-before-completion with back-link | string | grep in verification-before-completion/SKILL.md |
| SC-13 | Metadata Verification subsets inlined in verification-before-completion, audit, issue-operations with back-links | string | grep in each target skill card |

## Implementation Plan

### Phase 1: Collapse Zero Tolerance + Core Principle
### Phase 2: Remove Problem, What Constitutes, Memory vs Verified, Relationship, Verification-Enforcement Boundary
### Phase 3: Remove Single Exchange Window, Hard Failure Discipline + DDL
### Phase 4: Inline Verification Comparison Semantics into verification-before-completion with back-link
### Phase 5: Inline Anti-Evasion Rules into verification-before-completion with back-link
### Phase 6: Inline Metadata Verification subsets into verification-before-completion, audit, issue-operations with back-links
### Phase 7: Verify all keep sections remain

## Files Affected

- `.opencode/guidelines/065-verification-honesty.md` — compacted
- `.opencode/skills/verification-before-completion/SKILL.md` — receives 3 inline subsets + back-links
- `.opencode/skills/audit/SKILL.md` — receives 1 inline subset + back-link
- `.opencode/skills/issue-operations/SKILL.md` — receives 1 inline subset + back-link

## Risks

- **Cross-reference skipping**: Back-links are for human maintenance, not agent behavior. The inline content ensures agents see the rules. Mitigation: SC-11 through SC-13 verify inline content exists.
- **Drift**: If 065 master table changes, skill card copies become stale. Mitigation: audit guideline-audit task detects drift between 065 and skill card copies.

## Dependencies

- Depends on 000-critical-rules.md compaction (spec #2121) — the duplicated rules must remain in 000.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
