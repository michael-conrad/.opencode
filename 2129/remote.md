---
remote_issue: 2129
remote_url: https://github.com/michael-conrad/.opencode/issues/2129
---

> **Full spec and artifacts: [`.opencode/.issues/2129/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2129/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2129/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

`065-verification-honesty.md` contains sections duplicated in 000, explanatory prose, and skill-card-level detail that should be inlined into skill cards.

## Scope

Remove 8 sections (duplicated or explanatory). Collapse Zero Tolerance + Core Principle. Move 3 sections to skill cards with inline subsets + back-links.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Collapse Zero Tolerance + Core Principle to one statement | string |
| SC-2 | Remove Problem section | string |
| SC-3 | Remove What Constitutes Checking table | string |
| SC-4 | Remove Memory vs Verified table | string |
| SC-5 | Remove Single Exchange Window | string |
| SC-6 | Remove Relationship to Other Guidelines | string |
| SC-7 | Remove Verification-Enforcement Boundary | string |
| SC-8 | Remove Hard Failure Discipline + DDL | string |
| SC-9 | Keep sections (Evidence Requirement, No Exceptions, Evidence Hierarchy, Pre-Response Gate, FORBIDDEN/REQUIRED) remain | string |
| SC-10 | Metadata Verification master table remains in 065 | string |
| SC-11 | Verification Comparison Semantics inlined in verification-before-completion with back-link | string |
| SC-12 | Anti-Evasion Rules inlined in verification-before-completion with back-link | string |
| SC-13 | Metadata Verification subsets inlined in verification-before-completion, audit, issue-operations with back-links | string |

## Files Affected

- `.opencode/guidelines/065-verification-honesty.md`
- `.opencode/skills/verification-before-completion/SKILL.md`
- `.opencode/skills/audit/SKILL.md`
- `.opencode/skills/issue-operations/SKILL.md`

## Dependencies

- Depends on 000-critical-rules.md compaction (#2121).

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
