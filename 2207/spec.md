---
issue: 2207
title: "[SPEC] Remediate incomplete 000-critical-rules.md compaction — delete remaining moved rules, fix drift from later specs"
status: approved
approved: true
approved_scope: for_plan
---

> **Full spec and artifacts: [`.opencode/.issues/2207/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2207)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2207/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Objective

Delete 22 excess critical-rules blocks that were never removed by #2121 Phase 3, classify the unclassified `critical-rules-073`, and verify all success criteria.

## Background

Issue #2121 moved 123 skill-specific rules from `.opencode/guidelines/000-critical-rules.md` into their respective target files (Phase 1) and was supposed to delete them from the source file (Phase 3). Phase 3 was never executed — 22 excess rule blocks remain in the source file. Additionally, `critical-rules-073` was added post-#2121 and was never classified as universal or moved.

The current state (verified from live file):
- **41 rule headers** in the file (expected 18 per #2121 SC-10, plus 1 unclassified 073 = 19 universal)
- **22 excess rules** that should have been deleted by #2121 Phase 3
- **0 orphaned rules** targeting deleted skill directories — the 5 rules claimed in the original spec draft do not exist in the file (they were already removed or never existed)
- **1 unclassified rule** (`critical-rules-073`)
- **6 Read[] cross-refs** and **2 Why This Matters tables** (all in excess rules, will auto-resolve on deletion)
- **8 dark prose instances** (all in excess rules, will auto-resolve on deletion)

## Not Included

- No changes to target files that already received embedded rules during #2121 Phase 1
- No re-verification of #2121 SC-3 (rules already embedded in targets)
- No changes to the 19 universal rules that correctly remain in the file
- No content changes to any rule bodies — only deletion
- No re-homing of orphaned rules — none exist

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The 22 excess rule blocks listed in the Excess Rules table are deleted from `.opencode/guidelines/000-critical-rules.md` | string | For each of the 22 excess rule headers (full text), `grep -qF "<full header text>" .opencode/guidelines/000-critical-rules.md` returns 1 (not found) |
| SC-2 | `critical-rules-073` is classified: either kept as a universal rule in `000-critical-rules.md` (with Tier 1 classification) or moved to an appropriate target file | semantic | Read the rule body and evaluate: if universal (applies to ALL agents at ALL times), keep in source; if skill-specific, move to target file |
| SC-3 | The total count of `### [critical-rules-*]` rule headers in the file equals 19 (18 universal + 1 classified 073) | string | `grep -cE "^### \[critical-rules-" .opencode/guidelines/000-critical-rules.md` returns 19 |
| SC-4 | No `Read[` cross-references to preloaded guidelines remain in the file | string | `grep -cE "Read \[.*guidelines/" .opencode/guidelines/000-critical-rules.md` returns 0 |
| SC-5 | No "Why This Matters" tables remain in the file | string | `grep -cE "Why This Matters" .opencode/guidelines/000-critical-rules.md` returns 0 |
| SC-6 | Per-entry dark prose framing ("Professional engineers... amateurs...") appears fewer than 3 times in the file | string | `grep -cE "Professional engineers|amateurs" .opencode/guidelines/000-critical-rules.md` returns < 3 |
| SC-7 | No rule in the file references a deleted skill directory (`executing-plans/` or `implementation-pipeline/`) | string | `grep -cE "executing-plans|implementation-pipeline" .opencode/guidelines/000-critical-rules.md` returns 0 |

## Requirements

1. The agent SHALL delete each of the 22 excess rule blocks from `.opencode/guidelines/000-critical-rules.md` by removing the full `### [critical-rules-*]` header and all body content between it and the next rule header or section boundary.
2. The agent SHALL classify `critical-rules-073` by reading its body and determining whether it is universal (applies to ALL agents at ALL times) or skill-specific.
3. The agent SHALL verify all success criteria after all modifications are complete.
4. The agent SHALL execute phases sequentially (Phase 1 → Phase 2 → Phase 3) to avoid edit conflicts.

## Items

| Item | SC | Description |
|------|----|-------------|
| 1 | SC-1 | Delete 22 excess rule blocks from source |
| 2 | SC-2 | Classify critical-rules-073 |
| 3 | SC-3, SC-4, SC-5, SC-6, SC-7 | Verify all SCs |

## Dependencies

- **#2121**: This spec is a direct follow-up to #2121. The 22 excess rules were supposed to be deleted by #2121 Phase 3.
- **`.opencode/guidelines/000-critical-rules.md`**: The sole file modified by this spec.

## Traceability

| Requirement | SCs | Phase |
|-------------|-----|-------|
| R1 | SC-1 | Phase 1 |
| R2 | SC-2 | Phase 2 |
| R3 | SC-3, SC-4, SC-5, SC-6, SC-7 | Phase 3 |
| R4 | All | All |

## Excess Rules to Delete (Phase 1)

These 22 rule blocks were moved to target files by #2121 Phase 1 but were never deleted from the source file by #2121 Phase 3. Each must be deleted from `.opencode/guidelines/000-critical-rules.md`.

| # | Rule Header | Target File (from #2121) |
|---|-------------|--------------------------|
| 1 | `[critical-rules-028] Offer-to-Edit Bypass — offering to modify files without spec` | `.opencode/guidelines/020-go-prohibitions.md` |
| 2 | `[critical-rules-009] Authorization-Free Actions — no deliberation required` | `.opencode/guidelines/020-go-prohibitions.md` |
| 3 | `[critical-rules-027] Confirmation ≠ Authorization` | `.opencode/guidelines/020-go-prohibitions.md` |
| 4 | `[critical-rules-027] Feedback ≠ Authorization — treating technical input as implementation permission` | `.opencode/guidelines/020-go-prohibitions.md` |
| 5 | `[critical-rules-009] Silent Agent Termination — producing no output before stopping` | `.opencode/guidelines/020-go-prohibitions.md` |
| 6 | `[critical-rules-034] Inline Screening of Authorization Sets (Tier 2 — cannot be mechanically enforced)` | `.opencode/guidelines/020-go-prohibitions.md` |
| 7 | `[critical-rules-009] Silent Halt Without Prompt — no spec/plan search before stopping` | `.opencode/guidelines/020-go-prohibitions.md` |
| 8 | `[critical-rules-034] Inline Work — orchestrator performing file modifications without sub-agent task() (Tier 2 — cannot be mechanically enforced)` | `.opencode/guidelines/020-go-prohibitions.md` |
| 9 | `[critical-rules-035] DISPATCH_GATE Checkpoint skipped` | `.opencode/guidelines/020-go-prohibitions.md` |
| 10 | `[critical-rules-034] Orchestrator Inline Work = pipeline contamination (Tier 2 — cannot be mechanically enforced)` | `.opencode/guidelines/020-go-prohibitions.md` |
| 11 | `[critical-rules-042] Discard on Sub-Agent Failure` | `.opencode/guidelines/020-go-prohibitions.md` |
| 12 | `[critical-rules-034] Tool-Recipe Task() — sub-agents as API proxies (Tier 2 — cannot be mechanically enforced)` | `.opencode/guidelines/020-go-prohibitions.md` |
| 13 | `[critical-rules-042] Gate Non-Waiver Principle — "continue" does not waive mandatory gates` | `.opencode/guidelines/020-go-prohibitions.md` |
| 14 | `[critical-rules-048] Skill Pre-Read + Inline Execution — reading skill task files and executing steps manually` | `.opencode/guidelines/020-go-prohibitions.md` |
| 15 | `[critical-rules-044] Preloading Sub-Agent Context — task()ing with pre-determined file paths/line numbers/outcomes` | `.opencode/guidelines/020-go-prohibitions.md` |
| 16 | `[critical-rules-043] Universal Re-Task Mandate — no inline fallback on sub-agent failure` | `.opencode/guidelines/020-go-prohibitions.md` |
| 17 | `[critical-rules-063] Orchestrator Context Lean — orchestrator holds routing metadata only` | `.opencode/guidelines/020-go-prohibitions.md` |
| 18 | `[critical-rules-065] Result Contract Frugality — result contracts limited to routing-significant data` | `.opencode/guidelines/020-go-prohibitions.md` |
| 19 | `[critical-rules-dispatch-gate-canonical] Canonical Dispatch String Violation — orchestrator uses custom prompt after reading canonical dispatch string` | `.opencode/guidelines/020-go-prohibitions.md` |
| 20 | `[critical-rules-071] Revision-Not-Replacement — defective sub-agent deliverables MUST be revised, not replaced` | `.opencode/guidelines/020-go-prohibitions.md` |
| 21 | `[critical-rules-072] No-Inline-Fix — orchestrator MUST NOT inline-fix defective sub-agent output` | `.opencode/guidelines/020-go-prohibitions.md` |
| 22 | `[critical-rules-066] Terminology Standardization — all context references must use standardized vocabulary` | `.opencode/guidelines/020-go-prohibitions.md` |

## Unclassified Rule (Phase 2)

| Rule | Current Status | Classification Options |
|------|---------------|----------------------|
| `[critical-rules-073] CRITICAL VIOLATION — Reading source files with intent to modify without for_implementation+ scope` | Tier 1, added post-#2121, never classified | **Universal**: applies to ALL agents at ALL times (keep in source, adds to 18 count) OR **Move**: skill-specific (delete from source, embed in target) |

## Risks

- **Over-deletion**: Accidentally deleting a universal rule. Mitigation: SC-3 verifies the final header count is exactly 19.
- **Edit conflicts**: All phases modify the same file. Mitigation: R4 requires sequential execution.

## Alternatives Considered

| Alternative | Reason Rejected |
|-------------|-----------------|
| Leave the file as-is (41 headers) | The 18-header target from #2121 was never achieved; the file still contains 22 excess rules that waste context |
| Re-run #2121 Phase 3 as a standalone fix | The unclassified 073 is a separate concern that needs its own classification decision |

## Change Control

| Date | Change | Reason | Author |
|------|--------|--------|--------|
| 2026-07-31 | Revised spec: corrected excess count from 23→22, removed orphaned-rules section (0 orphaned rules exist in file), removed SC-2/SC-3, corrected Read[] count 5→6, corrected dark prose count 7→8, updated phase plan to 3 phases | Validation found factual errors in original spec | Validation audit |
