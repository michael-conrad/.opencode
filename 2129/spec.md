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

**Cost frame:** All 17 SCs are string-type grep verifications — each costs ~0.1s to run with zero false positives. There is no behavioral test cost or death-spiral risk. The cost of running all 17 verifications is bounded at ~2s total, making exhaustive verification the default — not an optimization target.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Collapse Zero Tolerance + Core Principle to one section (one heading, no duplicate content) | string | grep -c '## Zero Tolerance Rule' -> 1, grep -c '## Core Principle' -> 0 |
| SC-2 | Remove Problem section | string | grep -c '^## Problem$' -> 0 |
| SC-3 | Remove What Constitutes Checking table | string | grep -c "What Constitutes" -> 0 |
| SC-4 | Remove Memory vs Verified table | string | grep -c "Memory vs" -> 0 |
| SC-5 | Remove Single Exchange Window | string | grep -c "Single Exchange Window" -> 0 |
| SC-6 | Remove Relationship to Other Guidelines | string | grep -c "Relationship to Other Guidelines" -> 0 |
| SC-7 | Remove Verification-Enforcement Boundary | string | grep -c "Verification-Enforcement Boundary" -> 0 |
| SC-8 | Remove Hard Failure Discipline + DDL + DONE_WITH_CONCERNS + Remediation-First | string | grep -c "Hard Failure Discipline" -> 0 |
| SC-9a | Keep: Evidence Requirement, No Exceptions, Pre-Response Gate, FORBIDDEN/REQUIRED | string | grep '## Evidence Requirement\|## No Exceptions\|## Pre-Response Factual Claim Gate' -> 3 |
| SC-9b | Remove Evidence Hierarchy table | string | grep -c "Evidence Hierarchy" -> 0 |
| SC-10 | Remove Metadata Verification master table, distribute rows to VbC operating-protocol.md, audit task files, issue-operations-core task files | string | grep -c "Metadata Categories Requiring Verification" -> 0 |
| SC-11 | Inline Verification Comparison Semantics in verification-before-completion/tasks/operating-protocol.md, no back-link | string | grep "Verification Comparison\|exact match for external\|Per-Field Independence" operating-protocol.md -> 3 |
| SC-12 | Inline Anti-Evasion Rules + verification artifact manifest in verification-before-completion/tasks/operating-protocol.md, no back-link | string | grep "Anti-Evasion\|verification artifact manifest" operating-protocol.md -> 2 |
| SC-13 | Inline Metadata Verification subsets in verification-before-completion/tasks/operating-protocol.md, audit task files, issue-operations-core task files, no back-links | string | grep "Metadata Verification\|No Metadata Trust" operating-protocol.md -> 1+ AND in audit/tasks/ -> 1+ AND in issue-operations-core/tasks/ -> 1+ |
| SC-14 | Remove critical-rules stubs + Fabricating URLs (end-of-file section) | string | Line count of 065 < 375 lines |
| SC-15 | Remove DDL cross-reference footnote from 080-code-standards.md Evidence Type Taxonomy | string | grep "Cost explanation" 080-code-standards.md -> 0 |
| SC-16 | Remove DDL cross-reference from 020-go-prohibitions.md cost-blind section | string | grep "065.*Cost Model" 020-go-prohibitions.md -> 0 |
| SC-17 | Remove DONE_WITH_CONCERNS coercion rule from implementation-pipeline/SKILL.md | string | grep "DONE_WITH_CONCERNS" implementation-pipeline/SKILL.md -> 0 |

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
