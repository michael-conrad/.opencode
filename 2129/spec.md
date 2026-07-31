---
remote_issue: 2129
remote_url: https://github.com/michael-conrad/.opencode/issues/2129
labels: [spec]
approved: for_pr
---

> **Full spec and artifacts: [`.opencode/.issues/2129/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2129/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2129/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Intent and Executive Summary

Compact `065-verification-honesty.md` by removing explanatory prose, cross-reference stubs, and procedural content that should live in skill task files. Relocate 2 sections to task files. Remove DDL cross-references from 080 and 020. Remove DONE_WITH_CONCERNS coercion rule from writing-plans/reference/implementation-workflow.md. All 26 SCs are string-type grep verifications.

## Problem Statement

`065-verification-honesty.md` is ~35KB (35,117 bytes, verified by `wc -c`). Every sub-agent that loads this Tier 1 guideline pays the context cost for content that does not enforce behavior: explanatory prose, cross-reference stubs (critical-rules blocks at end of file that repeat references already present in 000), and procedural content (Verification Comparison Semantics, Anti-Evasion Rules, Metadata Verification detail) that should live in skill task files where sub-agents actually read it.

## Root Cause / Motivation

065 grew beyond its mandate as a guideline file through accretion — content was added over time without any compaction pass. Git log confirms 20+ commits touching 065 since its creation, adding sections like the DDL cost model, Anti-Evasion Rules, and critical-rules stubs without any corresponding removal. Sections that were originally single-purpose (verification honesty rules) accumulated explanatory prose, research citations, and cross-reference stubs. The Evidence Hierarchy table, Fabricating URLs block, and critical-rules stubs (end-of-file section) are structural orphans — the Evidence Hierarchy table classifies rules already enforced by FORBIDDEN/REQUIRED lists, the Fabricating URLs block duplicates procedural steps already in git-workflow task files (verified by grep), and the critical-rules stubs merely repeat references present in 000.

The core enforcement rules (Evidence Requirement, No Exceptions, Pre-Response Factual Claim Gate, FORBIDDEN/REQUIRED) are not accreted content — they are the original behavioral enforcement mechanism that defines 065's mandate. These sections must be preserved because they are the root cause anchor: they are what makes 065 a behavioral enforcement guideline rather than documentation. SC-9a traces to this root cause element.

## Approach Chosen

Selective compaction: remove explanatory sections, relocate procedural content to skill task files, remove cross-reference stubs, and remove the DDL cost model (operational rules already encoded in 020 and 080). Collapse duplicated restatements (Zero Tolerance + Core Principle). Remove DDL cross-reference footnotes from 080 and 020. Remove DONE_WITH_CONCERNS coercion rule from writing-plans/reference/implementation-workflow.md. Each removed section is verified absent via grep.

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
| Remove DONE_WITH_CONCERNS coercion from writing-plans/reference/implementation-workflow.md | DONE_WITH_CONCERNS is not a valid sub-agent status — documenting coercion of an invalid state is dead weight |

## Scope

Compaction of `065-verification-honesty.md`: remove 12 sections (explanatory, stubs, or procedural), collapse Zero Tolerance + Core Principle, remove Evidence Hierarchy table, remove Metadata Verification master table and distribute rows to skill task files, remove critical-rules stubs and Fabricating URLs orphan. Cross-reference cleanup: remove DDL footnotes from 080 and 020, remove DONE_WITH_CONCERNS coercion rule from writing-plans/reference/implementation-workflow.md. Inline 3 sections to skill task files.

## Documentation Sources

All source files verified to exist at their expected paths (verified by `ls`):

| Source File | Size | Purpose |
|-------------|------|---------|
| `.opencode/guidelines/065-verification-honesty.md` | 35,117 bytes | Target of compaction |
| `.opencode/skills/verification-before-completion/tasks/operating-protocol.md` | 3,232 bytes | Receives inlined content |
| `.opencode/skills/audit/tasks/` | 41 task files | Receives Metadata Verification subset |
| `.opencode/skills/issue-operations-core/tasks/` | 15 task files | Receives Metadata Verification subset |
| `.opencode/guidelines/080-code-standards.md` | — | Remove DDL footnote |
| `.opencode/guidelines/020-go-prohibitions.md` | — | Remove DDL reference |
| `.opencode/skills/writing-plans/reference/implementation-workflow.md` | — | Remove DONE_WITH_CONCERNS rule |

Commit history for 065 (verified by `git log --oneline --follow`): 20+ commits since creation, adding sections without corresponding removals — confirming accretion pattern.

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Target task files have unexpected structure | Each inlining operation reads the target file first to verify structure before editing — HALT on unexpected format |
| Cross-references from other files break | After compaction, grep each removed section header across the codebase — any remaining reference is a broken link requiring a follow-up fix commit |
| #2121 not fully merged when this spec is implemented | Precondition: verify current #2121 state — partially implemented, some overlap content already moved. Check 000 before proceeding |
| Another spec modifies 065 concurrently | Stale-base detection via pre-work: verify no unmerged PRs modify 065 before starting |

## Preconditions

- **#2121 (000-critical-rules.md compaction) is partially implemented — some overlap content has already been moved, but the issue is still open.** The sections being removed in this spec overlap with content that #2121 reorganizes. Verify current 000 state before implementation: some rule headers may already be relocated.
- Target task files must exist at their expected paths before inlining operations begin.

## SC Enforcement Gate

All SCs (SC-1 through SC-17, SC-9a1 through SC-9a4, SC-10a through SC-10e, SC-11a through SC-11b, SC-12a through SC-12b) MUST pass. Note: SC-13 was merged into SC-10a-e during revision — SC-10a-e covers the original SC-13 intent. for this spec to be considered complete. If any SC fails, the implementation is BLOCKED until remediation resolves the failure.

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
| SC-9a1 | Keep: Evidence Requirement heading in 065 | string | Verify `## Evidence Requirement` heading present in 065 | ~0.1s grep |
| SC-9a2 | Keep: No Exceptions heading in 065 | string | Verify `## No Exceptions` heading present in 065 | ~0.1s grep |
| SC-9a3 | Keep: Pre-Response Factual Claim Gate heading in 065 | string | Verify `## Pre-Response Factual Claim Gate` heading present in 065 | ~0.1s grep |
| SC-9a4 | Keep: FORBIDDEN/REQUIRED headings in 065 | string | Verify `## 🚫 FORBIDDEN` and `## ✅ REQUIRED` headings present in 065 | ~0.1s grep |
| SC-9b | Remove Evidence Hierarchy table | string | Verify no "Evidence Hierarchy" text exists in 065 | ~0.1s grep |
| SC-10a | Remove Metadata Verification master table from 065 | string | Verify no "Metadata Categories Requiring Verification" text exists in 065 | ~0.1s grep |
| SC-10b | Distribute Metadata Verification rows to VbC operating-protocol.md | string | Verify "Metadata Verification" or "No Metadata Trust" present in operating-protocol.md | ~0.1s grep |
| SC-10c | Distribute Metadata Verification rows to audit task files | string | Verify "Metadata Verification" or "No Metadata Trust" present in at least one audit/task file | ~0.1s grep |
| SC-10d | Distribute Metadata Verification rows to issue-operations-core task files | string | Verify "Metadata Verification" or "No Metadata Trust" present in at least one issue-operations-core/task file | ~0.1s grep |
| SC-10e | No back-links from 065 to Metadata Verification content | string | Verify no "Metadata Verification" text exists in 065 | ~0.1s grep |
| SC-11a | Inline Verification Comparison Semantics in operating-protocol.md | string | Verify "Verification Comparison", "exact match for external", and "Per-Field Independence" all present in operating-protocol.md | ~0.1s grep |
| SC-11b | No back-link from 065 to Verification Comparison Semantics | string | Verify no "Verification Comparison" text exists in 065 | ~0.1s grep |
| SC-12a | Inline Anti-Evasion Rules + verification artifact manifest in operating-protocol.md | string | Verify "Anti-Evasion" and "verification artifact manifest" both present in operating-protocol.md | ~0.1s grep |
| SC-12b | No back-link from 065 to Anti-Evasion Rules | string | Verify no "Anti-Evasion" text exists in 065 | ~0.1s grep |
| SC-14 | Remove critical-rules stubs + Fabricating URLs (end-of-file section) | string | Verify 065 line count is under 375 lines | ~0.1s wc |
| SC-15 | Remove DDL cross-reference footnote from 080-code-standards.md Evidence Type Taxonomy | string | Verify no "Cost explanation" text exists in 080-code-standards.md | ~0.1s grep |
| SC-16 | Remove DDL cross-reference from 020-go-prohibitions.md cost-blind section | string | Verify no "065.*Cost Model" pattern exists in 020-go-prohibitions.md | ~0.1s grep |
| SC-17 | Remove DONE_WITH_CONCERNS coercion rule from writing-plans/reference/implementation-workflow.md | string | Verify no "DONE_WITH_CONCERNS" text exists in writing-plans/reference/implementation-workflow.md | ~0.1s grep |

## Phases

### Phase 1: Remove sections from 065 (REQ-1)

Remove 9 sections from `065-verification-honesty.md`: Problem, What Constitutes Checking, Memory vs Verified, Single Exchange Window, Relationship to Other Guidelines, Verification-Enforcement Boundary, Hard Failure Discipline, Evidence Hierarchy, and end-of-file critical-rules stubs + Fabricating URLs.

**SCs covered:** SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9b, SC-14

### Phase 2: Collapse Zero Tolerance + Core Principle (REQ-2)

Merge `## Zero Tolerance Rule` and `## Core Principle` into a single section. Remove the `## Core Principle` heading.

**SCs covered:** SC-1

### Phase 3: Inline content to task files (REQ-3)

Inline Verification Comparison Semantics (SC-11a, SC-11b) and Anti-Evasion Rules + verification artifact manifest (SC-12a, SC-12b) to `verification-before-completion/tasks/operating-protocol.md`.

**SCs covered:** SC-11a, SC-11b, SC-12a, SC-12b

### Phase 4: Remove Metadata Verification master table from 065 + distribute rows (REQ-4)

Remove the `## Metadata Verification Extension` section from 065 (SC-10a). Distribute rows to VbC operating-protocol.md (SC-10b), audit task files (SC-10c), and issue-operations-core task files (SC-10d). Verify no back-links remain in 065 (SC-10e).

**SCs covered:** SC-10a, SC-10b, SC-10c, SC-10d, SC-10e

### Phase 5: Cross-reference cleanup (REQ-5)

Remove DDL cross-reference footnote from 080 (SC-15), DDL cross-reference from 020 (SC-16), and DONE_WITH_CONCERNS coercion rule from writing-plans/reference/implementation-workflow.md (SC-17).

**SCs covered:** SC-15, SC-16, SC-17

### Phase 6: Verify kept sections (REQ-6)

Verify that Evidence Requirement, No Exceptions, Pre-Response Factual Claim Gate, FORBIDDEN, and REQUIRED headings remain in 065.

**SCs covered:** SC-9a1, SC-9a2, SC-9a3, SC-9a4

## Traceability

| Requirement | SCs | Phase |
|-------------|-----|-------|
| REQ-1: Remove 9 sections from 065 | SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9b, SC-14 | Phase 1 |
| REQ-2: Collapse Zero Tolerance + Core Principle | SC-1 | Phase 2 |
| REQ-3: Inline 2 content sections to task files | SC-11a, SC-11b, SC-12a, SC-12b | Phase 3 |
| REQ-4: Remove Metadata Verification master table + distribute rows | SC-10a, SC-10b, SC-10c, SC-10d, SC-10e | Phase 4 |
| REQ-5: Cross-reference cleanup (080, 020, writing-plans) | SC-15, SC-16, SC-17 | Phase 5 |
| REQ-6: Verify kept sections remain in 065 | SC-9a1, SC-9a2, SC-9a3, SC-9a4 | Phase 6 |

## Files Affected

- `.opencode/guidelines/065-verification-honesty.md` — compacted
- `.opencode/skills/verification-before-completion/tasks/operating-protocol.md` — receives Verification Comparison Semantics, Anti-Evasion Rules, verification artifact manifest, Metadata Verification subset
- `.opencode/skills/audit/tasks/` — receives Metadata Verification subset
- `.opencode/skills/issue-operations-core/tasks/` — receives Metadata Verification subset
- `.opencode/guidelines/080-code-standards.md` — remove DDL cross-reference footnote
- `.opencode/guidelines/020-go-prohibitions.md` — remove DDL cross-reference
- `.opencode/skills/writing-plans/reference/implementation-workflow.md` — remove DONE_WITH_CONCERNS coercion rule

## Dependencies

- **BLOCKING: #2121 (000-critical-rules.md compaction) is partially implemented but still open.** Some overlap content has already been moved from 000 to other guideline files. Verify current 000 state before implementation — the compaction is in progress, not complete.

---

## Change Control

| Date | Change | Reason | Author |
|------|--------|--------|--------|
| 2026-07-31 | SC-17: target changed from `implementation-pipeline/SKILL.md` to `writing-plans/reference/implementation-workflow.md` | `implementation-pipeline/SKILL.md` does not exist; DONE_WITH_CONCERNS content lives in `writing-plans/reference/implementation-workflow.md` | Codebase audit |
| 2026-07-31 | Files Affected: `implementation-pipeline/SKILL.md` → `writing-plans/reference/implementation-workflow.md` | Same reason as SC-17 | Codebase audit |
| 2026-07-31 | Plan Phase 5: target changed from `implementation-pipeline/SKILL.md` to `writing-plans/reference/implementation-workflow.md` | Same reason as SC-17 | Codebase audit |
| 2026-07-31 | Precondition (#2121): updated from "must be merged" to "partially implemented, still open" | #2121 is partially implemented — 000 went from 141 to 41 rule headers but issue is still open | Codebase audit |
| 2026-07-31 | Dependencies: updated #2121 status to reflect partial implementation | Same reason as precondition update | Codebase audit |
| 2026-07-31 | Added Phases section with 6 phases mapping work to REQ references | Spec validation: missing Phases section | Spec validation |
| 2026-07-31 | Added Traceability table linking requirements to SCs to phases | Spec validation: missing Traceability table | Spec validation |
| 2026-07-31 | Decomposed SC-9a into SC-9a1, SC-9a2, SC-9a3, SC-9a4 (atomic headings) | Spec validation: compound SC-9a | Spec validation |
| 2026-07-31 | Decomposed SC-10 into SC-10a (remove table) + SC-10b/SC-10c/SC-10d (distribute rows) | Spec validation: compound SC-10 | Spec validation |
| 2026-07-31 | Decomposed SC-11 into SC-11a (inline) + SC-11b (no back-link) | Spec validation: compound SC-11 | Spec validation |
| 2026-07-31 | Decomposed SC-12 into SC-12a (inline) + SC-12b (no back-link) | Spec validation: compound SC-12 | Spec validation |
| 2026-07-31 | Decomposed SC-13 into SC-13a (operating-protocol), SC-13b (audit), SC-13c (issue-ops-core), SC-13d (no back-links) | Spec validation: compound SC-13 | Spec validation |
| 2026-07-31 | Updated plan SC references to match new atomic SC numbering | Spec validation: plan must match spec SCs | Spec validation |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flask)
