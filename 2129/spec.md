---
remote_issue: 2129
remote_url: https://github.com/michael-conrad/.opencode/issues/2129
labels: [spec]
---

> **Full spec and artifacts: [`.opencode/.issues/2129/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2129/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2129/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Intent and Executive Summary

Compact `065-verification-honesty.md` by removing explanatory prose, cross-reference stubs, and procedural content that should live in skill task files. Relocate 3 sections to task files. Remove DDL cross-references from 080 and 020. Remove DONE_WITH_CONCERNS coercion rule from implementation-pipeline. All 17 SCs are string-type grep verifications.

## Problem Statement

`065-verification-honesty.md` is ~35KB (35,078 bytes, verified by `wc -c`). Every sub-agent that loads this Tier 1 guideline pays the context cost for content that does not enforce behavior: explanatory prose, cross-reference stubs (critical-rules blocks at end of file that repeat references already present in 000), and procedural content (Verification Comparison Semantics, Anti-Evasion Rules, Metadata Verification detail) that should live in skill task files where sub-agents actually read it.

## Root Cause / Motivation

065 grew beyond its mandate as a guideline file through accretion — content was added over time without any compaction pass. Git log confirms 20+ commits touching 065 since its creation, adding sections like the DDL cost model, Anti-Evasion Rules, and critical-rules stubs without any corresponding removal. Sections that were originally single-purpose (verification honesty rules) accumulated explanatory prose, research citations, and cross-reference stubs. The Evidence Hierarchy table, Fabricating URLs block, and critical-rules stubs (end-of-file section) are structural orphans — the Evidence Hierarchy table classifies rules already enforced by FORBIDDEN/REQUIRED lists, the Fabricating URLs block duplicates procedural steps already in git-workflow task files (verified by grep), and the critical-rules stubs merely repeat references present in 000.

## Approach Chosen

Selective compaction: remove explanatory sections, relocate procedural content to skill task files, remove cross-reference stubs, and remove the DDL cost model (operational rules already encoded in 020 and 080). Collapse duplicated restatements (Zero Tolerance + Core Principle). Remove DDL cross-reference footnotes from 080 and 020. Remove DONE_WITH_CONCERNS coercion rule from implementation-pipeline. Each removed section is verified absent via grep.

## Alternatives Considered & Why Discarded

| Alternative | Why Discarded |
|-------------|---------------|
| Full rewrite of 065 | Unnecessary — most content is correct, just misplaced. Selective compaction preserves the working rules. |
| Delete 065 entirely | Rules in 065 (Pre-Response Gate, FORBIDDEN/REQUIRED, Evidence Requirement) are not duplicated elsewhere. Deletion would lose enforcement. |
| Split 065 into multiple guideline files | Would increase Tier 1 load count. Keeping one compact file is lower context cost than loading multiple files. |
| Keep as-is | 35KB of context waste per sub-agent load is not acceptable. Compaction is the minimum viable change. |

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Remove master Metadata table, distribute rows to task files | Sub-agents read task files, not 065 |
| Inline to task files, not SKILL.md | SKILL.md is orchestrator routing surface — task files are where sub-agents read |
| No back-links from 065 to task files | Content must be where sub-agents read it, not referenced from elsewhere |
| Delete DDL cost model entirely, don't relocate | Operational rules already encoded in 020 and 080 |
| Remove Evidence Hierarchy table | Rules it classifies already enforced by FORBIDDEN/REQUIRED lists and Pre-Response Gate |
| Remove DONE_WITH_CONCERNS coercion from impl-pipeline | DONE_WITH_CONCERNS is not a valid sub-agent status — documenting coercion of an invalid state is dead weight |

## Scope

Compaction of `065-verification-honesty.md`: remove 12 sections (explanatory, stubs, or procedural), collapse Zero Tolerance + Core Principle, remove Evidence Hierarchy table, remove Metadata Verification master table and distribute rows to skill task files, remove critical-rules stubs and Fabricating URLs orphan. Cross-reference cleanup: remove DDL footnotes from 080 and 020, remove DONE_WITH_CONCERNS coercion rule from implementation-pipeline. Inline 3 sections to skill task files.

## Documentation Sources

All source files verified to exist at their expected paths (verified by `ls`):

| Source File | Size | Purpose |
|-------------|------|---------|
| `.opencode/guidelines/065-verification-honesty.md` | 35,078 bytes | Target of compaction |
| `.opencode/skills/verification-before-completion/tasks/operating-protocol.md` | 3,232 bytes | Receives inlined content |
| `.opencode/skills/audit/tasks/` | 44 task files | Receives Metadata Verification subset |
| `.opencode/skills/issue-operations-core/tasks/` | 16 task files | Receives Metadata Verification subset |
| `.opencode/guidelines/080-code-standards.md` | — | Remove DDL footnote |
| `.opencode/guidelines/020-go-prohibitions.md` | — | Remove DDL reference |
| `.opencode/skills/implementation-pipeline/SKILL.md` | — | Remove DONE_WITH_CONCERNS rule |

Commit history for 065 (verified by `git log --oneline --follow`): 20+ commits since creation, adding sections without corresponding removals — confirming accretion pattern.

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Target task files have unexpected structure | Each inlining operation reads the target file first to verify structure before editing — HALT on unexpected format |
| Cross-references from other files break | After compaction, grep each removed section header across the codebase — any remaining reference is a broken link requiring a follow-up fix commit |
| #2121 not merged when this spec is implemented | Precondition: SKIP this spec if #2121 is not merged |
| Another spec modifies 065 concurrently | Stale-base detection via pre-work: verify no unmerged PRs modify 065 before starting |

## Preconditions

- **#2121 (000-critical-rules.md compaction) MUST be merged before this spec is implemented.** The sections being removed in this spec overlap with content that #2121 reorganizes.
- Target task files must exist at their expected paths before inlining operations begin.

## SC Enforcement Gate

All SCs (SC-1 through SC-17) MUST pass for this spec to be considered complete. If any SC fails, the implementation is BLOCKED until remediation resolves the failure.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Cost Frame |
|----|-----------|---------------|---------------------|------------|
| SC-1 | Collapse Zero Tolerance + Core Principle to one section (one heading, no duplicate content) | string | Verify only one `## Zero Tolerance Rule` heading exists in 065 and no `## Core Principle` heading remains | ~0.1s grep |
| SC-2 | Remove Problem section | string | Verify no `^## Problem$` heading exists in 065 | ~0.1s grep |
| SC-3 | Remove What Constitutes Checking table | string | Verify no "What Constitutes" text exists in 065 | ~0.1s grep |
| SC-4 | Remove Memory vs Verified table | string | Verify no "Memory vs" text exists in 065 | ~0.1s grep |
| SC-5 | Remove Single Exchange Window | string | Verify no "Single Exchange Window" text exists in 065 | ~0.1s grep |
| SC-6 | Remove Relationship to Other Guidelines | string | Verify no "Relationship to Other Guidelines" text exists in 065 | ~0.1s grep |
| SC-7 | Remove Verification-Enforcement Boundary | string | Verify no "Verification-Enforcement Boundary" text exists in 065 | ~0.1s grep |
| SC-8 | Remove Hard Failure Discipline + DDL + DONE_WITH_CONCERNS + Remediation-First | string | Verify no "Hard Failure Discipline" text exists in 065 | ~0.1s grep |
| SC-9a | Keep: Evidence Requirement, No Exceptions, Pre-Response Gate, FORBIDDEN/REQUIRED | string | Verify all 3 headings (`## Evidence Requirement`, `## No Exceptions`, `## Pre-Response Factual Claim Gate`) are present in 065 | ~0.1s grep |
| SC-9b | Remove Evidence Hierarchy table | string | Verify no "Evidence Hierarchy" text exists in 065 | ~0.1s grep |
| SC-10 | Remove Metadata Verification master table, distribute rows to VbC operating-protocol.md, audit task files, issue-operations-core task files | string | Verify no "Metadata Categories Requiring Verification" text exists in 065 | ~0.1s grep |
| SC-11 | Inline Verification Comparison Semantics in verification-before-completion/tasks/operating-protocol.md, no back-link | string | Verify "Verification Comparison", "exact match for external", and "Per-Field Independence" all present in operating-protocol.md | ~0.1s grep |
| SC-12 | Inline Anti-Evasion Rules + verification artifact manifest in verification-before-completion/tasks/operating-protocol.md, no back-link | string | Verify "Anti-Evasion" and "verification artifact manifest" both present in operating-protocol.md | ~0.1s grep |
| SC-13 | Inline Metadata Verification subsets in verification-before-completion/tasks/operating-protocol.md, audit task files, issue-operations-core task files, no back-links | string | Verify "Metadata Verification" or "No Metadata Trust" present in operating-protocol.md AND in at least one audit/task file AND in at least one issue-operations-core/task file | ~0.1s grep |
| SC-14 | Remove critical-rules stubs + Fabricating URLs (end-of-file section) | string | Verify 065 line count is under 375 lines | ~0.1s wc |
| SC-15 | Remove DDL cross-reference footnote from 080-code-standards.md Evidence Type Taxonomy | string | Verify no "Cost explanation" text exists in 080-code-standards.md | ~0.1s grep |
| SC-16 | Remove DDL cross-reference from 020-go-prohibitions.md cost-blind section | string | Verify no "065.*Cost Model" pattern exists in 020-go-prohibitions.md | ~0.1s grep |
| SC-17 | Remove DONE_WITH_CONCERNS coercion rule from implementation-pipeline/SKILL.md | string | Verify no "DONE_WITH_CONCERNS" text exists in implementation-pipeline/SKILL.md | ~0.1s grep |

## Files Affected

- `.opencode/guidelines/065-verification-honesty.md` — compacted
- `.opencode/skills/verification-before-completion/tasks/operating-protocol.md` — receives Verification Comparison Semantics, Anti-Evasion Rules, verification artifact manifest, Metadata Verification subset
- `.opencode/skills/audit/tasks/` — receives Metadata Verification subset
- `.opencode/skills/issue-operations-core/tasks/` — receives Metadata Verification subset
- `.opencode/guidelines/080-code-standards.md` — remove DDL cross-reference footnote
- `.opencode/guidelines/020-go-prohibitions.md` — remove DDL cross-reference
- `.opencode/skills/implementation-pipeline/SKILL.md` — remove DONE_WITH_CONCERNS coercion rule

## Dependencies

- **BLOCKING: #2121 (000-critical-rules.md compaction) must be merged before this spec.** Implemented sections being removed in this spec overlap with #2121's reorganization.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flask)
