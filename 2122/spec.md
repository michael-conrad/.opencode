---
remote_issue: 2122
remote_url: https://github.com/michael-conrad/.opencode/issues/2122
labels: [spec]
---

## Intent and Executive Summary

### Problem Statement

`010-approval-gate.md` is ~250 lines / ~13.7KB. While better-structured than 000, it contains sections that are only relevant when specific skills are dispatched — not at session start. These sections consume preloaded context unnecessarily.

### Root Cause / Motivation

The approval-gate guideline was written as a monolithic reference document. As the skill ecosystem grew, sections that govern internal skill behavior (label management, bug discovery protocol, re-implementation workflow) remained in the guideline file, forcing every agent session to load content that is only relevant when specific skills are dispatched.

### Approach Chosen

Move 6 skill-specific sections from `010-approval-gate.md` to their respective skill/task cards. Keep 13 universal/orchestrator-level sections in the guideline. Each section moves to the skill card that governs the domain it describes.

### Alternatives Considered & Why Discarded

See the [Alternatives Considered](#alternatives-considered) section below.

### Key Design Decisions

- **Section-to-skill-card mapping**: Each section moves to the skill card whose domain it governs (e.g., Label Handling → approval-gate skill card, Audit Auto-Fix Exemption → audit skill card). This ensures the content is loaded only when the relevant skill is dispatched.
- **No content rewriting**: Moved sections retain their original wording. Only the file location changes. This minimizes review surface and eliminates content-drift risk.
- **Verification via behavioral comparison**: SC-8 uses a clean-room sub-agent to compare moved section content against target card content, verifying no text was lost or altered during the move.

## Problem

`010-approval-gate.md` is ~250 lines / ~13.7KB. While better-structured than 000, it contains sections that are only relevant when specific skills are dispatched — not at session start. These sections consume preloaded context unnecessarily.

## Proposed Solution

Move 6 sections to their respective skill/task cards. Keep 13 sections that are universal or orchestrator-level.

### Move to skill/task cards:

| Section | Destination | Rationale |
|---|---|---|
| Spec-to-Plan Approval Cascade + Edge Cases | `approval-gate` skill card | Internal approval-gate logic — only relevant when that skill is dispatched |
| Re-implementation Workflow | `approval-gate` skill card | Procedure only followed when approval-gate-006 fires |
| Label Handling | `approval-gate` skill card | Label management is the approval-gate skill's job |
| Audit Auto-Fix Exemption | `audit` skill card | Only relevant when audit is dispatched |
| Bug Report Response | `issue-operations` skill card | Bug-to-spec workflow is an issue-operations concern |
| Bug Discovery Protocol | `approval-gate` skill card | Authorization boundary enforcement — approval-gate's domain |

### Keep (universal/orchestrator-level, must be in every agent's context):

- Tier 0 Zero Tolerance Rules table
- Mandatory Requirements
- Issue Creation Is Reporting
- Decision Table: Authorization + File Modifications
- Explicit Authorization Priority
- Authorization Scope + Scope Model
- Scope Is Permission, Not Shortcut
- Multi-Task Plan Authorization
- Authorization Carry-Forward
- Revision Revokes Approval
- Action Authorization Classification
- `for_analysis` Allowlist/Blocklist
- Key Edge Cases

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Spec-to-Plan Approval Cascade content exists in `approval-gate` skill card | string | grep for cascade rule in approval-gate/SKILL.md. **Cost if FAIL**: Orphaned cross-references in 010-approval-gate.md — agents reading 010 will find a broken reference to a section that no longer exists. |
| SC-2 | Re-implementation Workflow content exists in `approval-gate` skill card | string | grep for re-implementation steps in approval-gate/SKILL.md. **Cost if FAIL**: Agents following approval-gate-006 (spec revision) will not find the re-implementation procedure — they will halt without a recovery path. |
| SC-3 | Label Handling content exists in `approval-gate` skill card | string | grep for label rules in approval-gate/SKILL.md. **Cost if FAIL**: Agents will not apply or remove `approved-for-*` labels correctly — authorization state becomes untracked. |
| SC-4 | Audit Auto-Fix Exemption content exists in `audit` skill card | string | grep for auto-fix exemption in audit/SKILL.md. **Cost if FAIL**: Audit sub-agents will not know they can auto-fix non-substantive formatting issues — every audit run produces false-positive formatting findings. |
| SC-5 | Bug Report Response content exists in `issue-operations` skill card | string | grep for bug-to-spec workflow in issue-operations/SKILL.md. **Cost if FAIL**: Agents receiving bug reports will not know to create a spec issue — bugs go unrecorded. |
| SC-6 | Bug Discovery Protocol content exists in `approval-gate` skill card | string | grep for bug discovery protocol in approval-gate/SKILL.md. **Cost if FAIL**: Agents discovering bugs during implementation will not halt and report — they will continue working on the wrong scope. |
| SC-7 | All 13 keep sections remain in 010-approval-gate.md | string | grep for each section header in 010-approval-gate.md. **Cost if FAIL**: A keep section accidentally removed means every agent session loses that context — authorization scope model, action classification, or edge cases go missing. |
| SC-8 | No content loss — all bullet points from each moved section appear verbatim in the target card, no text truncated, all cross-references updated to target card paths | behavioral | Clean-room sub-agent reads source section from 010-approval-gate.md and target card from destination SKILL.md, compares: (a) every bullet point present verbatim, (b) no text truncated, (c) all internal cross-references updated to target card paths. PASS only if all 3 checks pass for all 6 moved sections. **Cost if FAIL**: Content silently lost during move — downstream agents receive incomplete rules. |
| SC-9 | No orphaned cross-references to moved sections in other files | string | grep for moved section names across `.opencode/` — only target cards and 010 remain. **Cost if FAIL**: Other files reference moved sections by name — those references become dead links. |
| SC-10 | No line-count or word-count metrics used as success measurement | string | grep for absence of 'wc -l', 'file size', 'Final file size' in spec. **Cost if FAIL**: Spec uses size metrics as success proxies — implementation quality is measured by file size, not behavioral correctness. |

### Enforcement Gate

All SCs MUST pass before implementation is considered complete. A single FAIL blocks the entire implementation.

## Implementation Plan

- [ ] 1. Phase 1: Move Spec-to-Plan Cascade, Re-implementation, Label Handling to approval-gate skill [dispatch: git-workflow-commit]
  - Move Spec-to-Plan Approval Cascade + Edge Cases section from 010-approval-gate.md to approval-gate/SKILL.md
  - Move Re-implementation Workflow section from 010-approval-gate.md to approval-gate/SKILL.md
  - Move Label Handling section from 010-approval-gate.md to approval-gate/SKILL.md
  - Remove all 3 sections from 010-approval-gate.md
- [ ] 2. Phase 2: Move Audit Auto-Fix Exemption to audit skill [dispatch: git-workflow-commit]
  - Move Audit Auto-Fix Exemption section from 010-approval-gate.md to audit/SKILL.md
  - Remove section from 010-approval-gate.md
- [ ] 3. Phase 3: Move Bug Report Response to issue-operations skill [dispatch: git-workflow-commit]
  - Move Bug Report Response section from 010-approval-gate.md to issue-operations/SKILL.md
  - Remove section from 010-approval-gate.md
- [ ] 4. Phase 4: Move Bug Discovery Protocol to approval-gate skill [dispatch: git-workflow-commit]
  - Move Bug Discovery Protocol section from 010-approval-gate.md to approval-gate/SKILL.md
  - Remove section from 010-approval-gate.md
- [ ] 5. Phase 5: Verify all 13 keep sections remain and no content loss [dispatch: verification-before-completion]
  - Run SC-7 grep verification: all 13 keep section headers present in 010-approval-gate.md
  - Run SC-8 behavioral comparison: clean-room sub-agent compares all 6 moved sections against target cards
  - Run SC-9 grep verification: no orphaned cross-references to moved sections

## Files Affected

- `.opencode/guidelines/010-approval-gate.md` — compacted
- `.opencode/skills/approval-gate/SKILL.md` — receives 4 sections
- `.opencode/skills/audit/SKILL.md` — receives 1 section
- `.opencode/skills/issue-operations/SKILL.md` — receives 1 section

## Risks

- **Content loss**: Moved sections must have equivalent content in target cards. Mitigation: SC-8 requires behavioral comparison with 3 enumerable checks (bullet points verbatim, no truncation, cross-references updated).
- **Orphaned cross-references**: If other files reference the moved sections by name, those references break. Mitigation: SC-9 verifies no orphaned refs.

## Edge Cases

### (a) Target SKILL.md already contains content with the same section header

If a target SKILL.md already has a section with the same header as the section being moved, the move must merge the content rather than duplicate. Resolution: read the target SKILL.md before moving, check for header conflicts, and merge content under a single header with a note indicating the source.

### (b) Moved section's cross-references cannot be updated

If a moved section references a file path or section that does not exist in the target card's context, the cross-reference must be updated to the correct path in the target card. Resolution: update all internal file/section references in the moved section to be correct relative to the target card's location. If a reference cannot be resolved, flag it in the implementation output for manual review.

### (c) Rollback plan if Phase 5 verification fails

If Phase 5 verification (SC-7, SC-8, SC-9) produces any FAIL, the implementation must roll back: revert all section moves, restore 010-approval-gate.md to its pre-move state, and report the specific SC(s) that failed with diagnostic evidence. No partial moves are permitted — all 6 sections move together or none move.

## Alternatives Considered

### Approach A: Move sections to skill cards (chosen)

Move 6 skill-specific sections from the guideline to their respective skill cards. The guideline retains only universal/orchestrator-level content. This is the chosen approach because it directly addresses the root cause: skill-specific content is loaded only when the relevant skill is dispatched, reducing preloaded context waste.

### Approach B: Lazy-load sections within the guideline

Keep all sections in 010-approval-gate.md but add a "load only when relevant" mechanism (e.g., trigger-based loading markers). **Discarded** because the guideline file format does not support conditional loading — the entire file is loaded at session start regardless of markers. This approach would require a new loading mechanism that does not exist.

### Approach C: Split 010 into multiple guideline files

Split 010-approval-gate.md into multiple smaller guideline files (e.g., 010-approval-gate-core.md, 010-approval-gate-skills.md). **Discarded** because guideline files are loaded by trigger pattern matching in INDEX.md, not by skill dispatch. Splitting would not change the loading behavior — all guideline files are still loaded at session start. The skill card loading mechanism (loaded only when `skill()` is called) is the correct isolation boundary.

### Approach D: Keep everything in 010 with better organization

Reorganize 010-approval-gate.md with clearer section headers and a table of contents. **Discarded** because reorganization does not reduce preloaded context — the same ~13.7KB is still loaded at every session start. The problem is content volume, not content organization.

## Dependencies

- None. Self-contained refactoring.

## Documentation Sources

N/A — This spec is a refactoring of internal guideline and skill card files. No external APIs, configuration values, environment variables, or library patterns are referenced.

---

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-07-25 | Added ## Intent and Executive Summary preamble with 5 standard fields | Spec audit SC-12 FAIL — missing standard preamble | Spec audit remediation |
| 2026-07-25 | Added ## Alternatives Considered section with 4 approaches | Spec audit research_adequacy.investigation_breadth FAIL — no alternatives considered | Spec audit remediation |
| 2026-07-25 | Added ## Documentation Sources section (N/A) | Spec audit SC-11 FAIL — missing documentation sources | Spec audit remediation |
| 2026-07-25 | Rewrote SC-8 with 3 enumerable binary checks (bullet points verbatim, no truncation, cross-references updated) | Spec audit SC-9/SC-DET FAIL — non-deterministic language in SC-8 | Spec audit remediation |
| 2026-07-25 | Added cost-frame (DDL) language to each SC explaining downstream cost of failure | Spec audit SC-13 FAIL — missing cost-frame language | Spec audit remediation |
| 2026-07-25 | Added ## Enforcement Gate section: all SCs must pass, single FAIL blocks implementation | Spec audit SC-14 FAIL — missing all-or-nothing enforcement gate | Spec audit remediation |
| 2026-07-25 | Converted Implementation Plan from ### headings to canonical `- [ ] N.` checklist format with dispatch indicators | Spec audit SC-PIPELINE-GATES FAIL — non-canonical phase format | Spec audit remediation |
| 2026-07-25 | Added ## Edge Cases section with 3 scenarios (target header conflict, unresolvable cross-references, rollback plan) | Re-audit research_adequacy.edge_case_discovery FAIL — missing edge case analysis | Spec audit remediation |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
