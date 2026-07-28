---
remote_issue: 2129
remote_url: https://github.com/michael-conrad/.opencode/issues/2129
labels: [spec]
---

> **Full spec and artifacts: [`.opencode/.issues/2129/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2129/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2129/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem Statement

`065-verification-honesty.md` is ~35KB of context waste. Every sub-agent that loads this Tier 1 guideline pays the context cost for content that doesn't change behavior: explanatory prose, cross-reference stubs (critical-rules blocks that merely repeat references already present in 000), and procedural content (Verification Comparison Semantics, Anti-Evasion Rules, Metadata Verification detail) that should live in skill task files where sub-agents actually read it. Verified by grep: the critical-rules blocks at lines 374-467 reference content from 000 but are not consumed by any executing agent—they are maintenance artifacts.

## Root Cause / Motivation

065 grew beyond its mandate as a guideline file through accretion — content was added over time without any compaction pass. Sections that were originally single-purpose (verification honesty rules) accumulated explanatory prose, research citations, and cross-reference stubs that are never read by executing agents. The Evidence Hierarchy table, Fabricating URLs block, and critical-rules stubs are all content that serves no behavioral function.

## Approach Chosen

Selective compaction: remove explanatory sections (teaching material, not rules), procedural content moved to skill task files, cross-reference stubs ignored by agents, and the DDL cost model (explanatory prose; operational rules already encoded in 020 and 080). Collapse duplicated restatements (Zero Tolerance + Core Principle). Relocate procedural content (Verification Comparison Semantics, Anti-Evasion Rules, Metadata Verification subsets) to skill task files where sub-agents read them during execution.

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Remove master Metadata table, distribute rows to task files | Sub-agents read task files, not 065 — the master table has no executing consumer |
| Inline to task files, not SKILL.md | SKILL.md is orchestrator routing surface — task files are where sub-agents read |
| No back-links from 065 to task files | Cross-reference stubs are ignored by agents — the content just needs to be where sub-agents read it |
| Delete DDL cost model entirely, don't relocate | Operational rules (cost-blind verification, evidence type hierarchy) already encoded in 020 and 080 — DDL is explanatory prose only |
| Remove Evidence Hierarchy table | Rules it classifies (live-source only, no memory-as-evidence) already enforced by FORBIDDEN/REQUIRED lists and Pre-Response Gate |

## Scope

Remove 12 sections (duplicated, explanatory, or stubs). Collapse Zero Tolerance + Core Principle. Move 3 sections to skill task files (no back-links). Remove Evidence Hierarchy table. Remove Metadata Verification master table and distribute rows to skill task files. Remove critical-rules stubs and Fabricating URLs orphan.

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Target task files have unexpected structure | Each inlining operation reads the target file first to verify structure before editing — HALT on unexpected format |
| Cross-references from other files break | After compaction, grep each removed section header across the codebase — any remaining reference is a broken link requiring a follow-up fix commit |
| #2121 not merged when this spec is implemented | Precondition: SKIP this spec if #2121 is not merged. The sections being removed in this spec may be modified by #2121 — implementing on an unmerged base produces merge conflicts |
| Another spec modifies 065 concurrently | Stale-base detection via pre-work: verify no unmerged PRs modify 065 before starting |

## Preconditions

- **#2121 (000-critical-rules.md compaction) MUST be merged before this spec is implemented.** The sections being removed in this spec overlap with content that #2121 reorganizes. Implementing without #2121 first will produce incorrect results.
- Target task files must exist at their expected paths before inlining operations begin.

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
| SC-8 | Remove Hard Failure Discipline + DDL + DONE_WITH_CONCERNS + Remediation-First | string |
| SC-9a | Keep: Evidence Requirement, No Exceptions, Pre-Response Gate, FORBIDDEN/REQUIRED | string |
| SC-9b | Remove Evidence Hierarchy table | string |
| SC-10 | Remove Metadata Verification master table, distribute rows to skill task files | string |
| SC-11 | Inline Verification Comparison Semantics in VbC operating protocol, no back-link | string |
| SC-12 | Inline Anti-Evasion Rules + verification artifact manifest in VbC operating protocol, no back-link | string |
| SC-13 | Inline Metadata Verification subsets in VbC, audit, issue-operations task files, no back-links | string |
| SC-14 | Remove critical-rules stubs + Fabricating URLs (lines 374-467) | string |

## Files Affected

- `.opencode/guidelines/065-verification-honesty.md` — compacted
- `.opencode/skills/verification-before-completion/tasks/operating-protocol.md` — receives Verification Comparison Semantics, Anti-Evasion Rules, verification artifact manifest, Metadata Verification subset
- `.opencode/skills/audit/tasks/` — receives Metadata Verification subset
- `.opencode/skills/issue-operations/tasks/` — receives Metadata Verification subset
- `.opencode/guidelines/080-code-standards.md` — remove DDL cross-reference footnote
- `.opencode/guidelines/020-go-prohibitions.md` — remove DDL cross-reference
- `.opencode/skills/implementation-pipeline/SKILL.md` — remove DONE_WITH_CONCERNS coercion rule (line 82)

## Dependencies

- **BLOCKING: #2121 (000-critical-rules.md compaction) must be merged before this spec.** The sections being removed in this spec overlap with #2121's reorganization. Do not implement until #2121 is in trunk.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
