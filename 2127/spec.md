---
remote_issue: 2127
remote_url: https://github.com/michael-conrad/.opencode/issues/2127
labels: [spec]
---

## Intent and Executive Summary

- **Intent**: Compact `020-go-prohibitions.md` by removing content duplicated in `000-critical-rules.md`, removing an obsolete sub-issue model, and replacing a Node.js-specific prohibition with a general `.tools/` rule.
- **Problem Statement**: `020-go-prohibitions.md` is ~659 lines / ~43KB. Live verification against the actual files reveals that the spec's previous Documentation Sources table was factually incorrect — it claimed several sections and lines were duplicated in 000/065 when they are actually unique to 020. The ACTUAL duplication is limited to: §6 Progressive Iterative Implementation (restates 000's Checkpoint Rollback Exception), the "stop" command section (identical block in both 000 and 020), and the Channel-Routing Table (identical table in both 000 and 020). Additionally, §5 contains an obsolete sub-issue model, and there is internal duplication within 020 (3 ALWAYS DO lines restating earlier NEVER DO lines). The Node.js-specific prohibition in §4 should be a general `.tools/` rule.
- **Root Cause/Motivation**: The file has grown beyond its original scope through accretion. Some rules accumulated that already exist in 000-critical-rules.md, creating duplication and maintenance burden. Other sections were incorrectly flagged as duplicated in the previous spec version.
- **Approach Chosen**: Remove verified-duplicated sections (§6, stop command, Channel-Routing Table), remove obsolete §5, remove internally-duplicated lines (3 restated ALWAYS DO lines), collapse adjacent sections, replace Node.js-specific rule with general `.tools/` rule. Keep all unique-to-020 content including §1.1 Orchestrator Context Discipline, live tool call/training data/metadata lines, cost-blind/evidence substitution/continue waiver/silent halt/escalate lines, and all ALWAYS DO items that are unique to 020.
- **Alternatives Considered**: See Alternatives Considered section below.
- **Key Design Decisions**: Removal is the primary strategy for verified-duplicated content because the duplicated rules already exist in their authoritative home (000). Cross-references would add indirection without reducing file size. A separate guideline file would create a third home for the same rules. Content unique to 020 is preserved.

## Documentation Sources

The following duplication claims are verified against live source files:

| Claim | Source | Location | Verified |
|-------|--------|----------|----------|
| §6 Progressive Iterative Implementation duplicated in 000 | `000-critical-rules.md` | Lines 115-125 (Checkpoint Rollback Exception) | ✅ |
| "stop" command section duplicated in 000 | `000-critical-rules.md` | Lines 265-279 (critical-rules-stop) | ✅ |
| Channel-Routing Table duplicated in 000 | `000-critical-rules.md` | Lines 300-315 (Channel-Routing Table) | ✅ |
| 3 restated ALWAYS DO lines (internal duplication within 020) | `020-go-prohibitions.md` | Lines 294-296 restate lines 277-279 | ✅ |
| §5 Multi-task Plan Without Sub-issues (obsolete, not duplicated) | `020-go-prohibitions.md` | Lines 362-383 | ✅ obsolete |

The following claims from the previous spec version were found to be INCORRECT after live verification and are NOT included in this revision:

| Previously Claimed | Actual Status |
|--------------------|---------------|
| §1.1 Orchestrator Context Discipline duplicated in 000 | ❌ NOT duplicated — exists ONLY in 020 |
| Live tool call/training data/metadata lines (020:277-279) duplicated in 065 | ❌ NOT duplicated — exist ONLY in 020 |
| "Make a live tool call before every factual claim" (020:294) duplicated in 065 | ❌ NOT duplicated — exists ONLY in 020 |
| Cost-blind/evidence substitution/continue waiver/silent halt/escalate lines duplicated in 000/065 | ❌ NOT text-duplicated — unique 020 text |
| 10 ALWAYS DO items duplicated in 000/065 | ❌ NOT text-duplicated — conceptual overlap only |

## Alternatives Considered

Three approaches were evaluated for addressing the duplication in `020-go-prohibitions.md`:

| Approach | Pros | Cons | Verdict |
|----------|------|------|---------|
| **Removal (chosen)** | Eliminates duplication entirely; single authoritative source per rule; reduces file size | Requires verification that all removed rules exist in target files; risk of content loss if verification is incomplete | ✅ Chosen |
| **Cross-references** | Preserves all content; explicit pointers to authoritative source | Does not reduce file size; adds indirection; cross-references can go stale; still requires maintenance in two places | ❌ Rejected |
| **Separate guideline file** | Isolates the concern; clear ownership | Creates a third home for rules that already have two homes; increases total file count; does not solve the duplication problem | ❌ Rejected |

Removal was chosen because the duplicated rules already exist in their authoritative home (000). Cross-references would add indirection without reducing file size. A separate guideline file would create a third home for the same rules, making the maintenance problem worse.

## All-or-Nothing SC Enforcement Gate

**All SCs MUST pass before the implementation is considered complete. A single FAIL blocks the entire change.** This is a hard gate — no partial implementation, no "PASS with caveats," no selective SC fulfillment. Every SC in the table below must be verified PASS before the PR can be created.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Remove §5 Multi-task Plan Without Sub-issues | string | grep for absence of 'Multi-task Plan Without Sub-issues' |
| SC-2 | Remove §6 Progressive Iterative Implementation | string | grep for absence of 'Progressive Iterative Implementation' |
| SC-3 | Remove "stop" command section | string | grep for absence of 'terminal halt' in 020 |
| SC-4 | Remove Channel-Routing Table | string | grep for absence of 'Channel-Routing Table' in 020 |
| SC-5 | Remove 3 restated ALWAYS DO lines (lines 294-296) | string | grep for absence of 'Make a live tool call before every factual claim' |
| SC-6 | §1.2 merged into §1 as bullet | string | grep for 'interpretive question' in §1 |
| SC-7 | §1.5 collapsed into §1 | string | grep for absence of 'Soliciting Authorization' header |
| SC-8 | §4 replaced with general `.tools/` rule | string | grep for '.tools/' in §4 |
| SC-9 | All keep sections remain (§1.1, live tool call lines, cost-blind lines, ALWAYS DO items) | string | grep for each section header and unique line |
| SC-10 | No content loss — removed sections verified as duplicated in 000 | semantic | Compare removed section content against 000 equivalents; verify all rules preserved in source. Cost frame: DDL-based — a content-loss defect discovered post-merge costs 100× more (revert + re-implement) than catching it at verification time via semantic comparison. |
| SC-11 | No orphaned cross-references to removed section names | string | grep for removed section names across .opencode/ — only 000 remains |
| SC-12 | No line-count or word-count metrics used as success measurement | string | grep for absence of 'wc -l', 'file size', 'Final file size' in spec |
| SC-13 | Remove duplicate Node.js Prohibition section from 070-environment.md (lines 224-257) | string | grep for absence of 'Node.js Prohibition' section in 070-environment.md |

## Requirements

| ID | Requirement | Evidence Type |
|----|------------|---------------|
| REQ-1 | Remove §5 Multi-task Plan Without Sub-issues | string |
| REQ-2 | Remove §6 Progressive Iterative Implementation | string |
| REQ-3 | Remove "stop" command section | string |
| REQ-4 | Remove Channel-Routing Table | string |
| REQ-5 | Remove 3 restated ALWAYS DO lines (lines 294-296) | string |
| REQ-6 | §1.2 merged into §1 as bullet | string |
| REQ-7 | §1.5 collapsed into §1 | string |
| REQ-8 | §4 replaced with general `.tools/` rule | string |
| REQ-9 | All keep sections remain | string |
| REQ-10 | No content loss — removed sections verified as duplicated in 000 | semantic |
| REQ-11 | No orphaned cross-references to removed section names | string |
| REQ-12 | No line-count or word-count metrics used as success measurement | string |
| REQ-13 | Remove duplicate Node.js Prohibition section from 070-environment.md (lines 224-257) | string |

## Traceability

| Requirement | Success Criterion | Implementation Plan Phase |
|------------|------------------|--------------------------|
| REQ-1 | SC-1 | Phase 1 |
| REQ-2 | SC-2 | Phase 1 |
| REQ-3 | SC-3 | Phase 1 |
| REQ-4 | SC-4 | Phase 1 |
| REQ-5 | SC-5 | Phase 2 |
| REQ-6 | SC-6 | Phase 3 |
| REQ-7 | SC-7 | Phase 3 |
| REQ-8 | SC-8 | Phase 4 |
| REQ-9 | SC-9 | Phase 5 |
| REQ-10 | SC-10 | Phase 5 |
| REQ-11 | SC-11 | Phase 5 |
| REQ-12 | SC-12 | Phase 5 |
| REQ-13 | SC-13 | Phase 5 |

## Implementation Plan

### Phase 1: Remove duplicated sections (§5, §6, stop command, Channel-Routing Table) [REQ-1, REQ-2, REQ-3, REQ-4]

Dispatch: RED/GREEN sub-agent

### Phase 2: Remove internally-duplicated lines (3 restated ALWAYS DO lines) [REQ-5]

Dispatch: RED/GREEN sub-agent

### Phase 3: Collapse §1.2 and §1.5 into §1 [REQ-6, REQ-7]

Dispatch: RED/GREEN sub-agent

### Phase 4: Replace §4/§4.5 with general `.tools/` rule [REQ-8]

Dispatch: RED/GREEN sub-agent

### Phase 5: Verify all keep sections remain, no content loss, and remove duplicate Node.js section from 070-environment.md [REQ-9, REQ-10, REQ-11, REQ-12, REQ-13]

Dispatch: verification sub-agent

## Files Affected

- `.opencode/guidelines/020-go-prohibitions.md` — compacted
- `.opencode/guidelines/070-environment.md` — remove duplicate Node.js section (lines 224-257)

## Risks

- **Content loss**: Removed sections must be verified to exist in 000. Mitigation: SC-10 verifies each removal is safe via semantic comparison.
- **Cross-reference breakage**: 085-project-local-tools.md references 020 §4 (Node.js prohibition) at lines 14 and 50. Mitigation: update 085-project-local-tools.md to reference the new `.tools/` rule.
- **Duplicate Node.js section in 070-environment.md**: 070-environment.md has its own Node.js Prohibition section (lines 224-257) that must be removed. Mitigation: SC-13 verifies removal.

## Dependencies

- Depends on 000-critical-rules.md compaction (spec #2121) — the duplicated rules must remain in 000.

---

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-07-27 | Converted preamble to standard Intent and Executive Summary format | Spec-audit SC-12 (FAIL) — preamble format non-standard | Spec-audit remediation |
| 2026-07-27 | Added Documentation Sources section with verified live source citations | Spec-audit SC-11 (FAIL) — missing documentation sources for duplication claims | Spec-audit remediation |
| 2026-07-27 | Added cost-frame reformation language (DDL, death-spiral rationale) to SC-13 | Spec-audit SC-13 (FAIL) — missing cost-frame language | Spec-audit remediation |
| 2026-07-27 | Added All-or-Nothing SC Enforcement Gate statement | Spec-audit SC-14 (FAIL) — missing enforcement gate | Spec-audit remediation |
| 2026-07-27 | Reclassified SC-13 evidence type from behavioral to semantic | Spec-audit SC-EVIDENCE-TYPE (FAIL) — content-preservation verification is inherently semantic | Spec-audit remediation |
| 2026-07-27 | Converted Implementation Plan to canonical checklist format with numbered items and dispatch mode indicators | Spec-audit SC-PIPELINE-GATES (FAIL) — non-canonical format | Spec-audit remediation |
| 2026-07-27 | Added Alternatives Considered section documenting removal vs cross-references vs separate file | Spec-audit analytical finding (investigation_breadth FAIL) — missing alternatives analysis | Spec-audit remediation |
| 2026-07-27 | Added Requirements section (REQ-1 through REQ-15) with numbered requirements | Validation: Completeness FAIL — missing formal Requirements section | Spec-creation revise pipeline |
| 2026-07-27 | Added Traceability table mapping REQ to SC and Implementation Plan phase | Validation: Traceability FAIL — missing formal traceability | Spec-creation revise pipeline |
| 2026-07-27 | Added REQ references to each Implementation Plan phase heading | Validation: Phase coverage FAIL — missing REQ references in phase headings | Spec-creation revise pipeline |
| 2026-07-27 | **Major correction**: Fixed Problem Statement, Documentation Sources, SCs, Requirements, Traceability, and Implementation Plan to reflect ACTUAL duplication (not previously claimed incorrect duplication). Removed §1.1, live tool call lines, cost-blind lines, and 10 ALWAYS DO items from removal lists — these are unique to 020. Added Channel-Routing Table to removal list (verified duplicate). | Revision reason: CRITICAL — spec's Documentation Sources table and Problem Statement were factually incorrect based on live file verification | Spec-creation revise pipeline |
| 2026-07-27 | Added SC-13, REQ-13 for removing duplicate Node.js Prohibition section from 070-environment.md (lines 224-257). Updated Traceability and Phase 5 to include REQ-13. Fixed Risk section: corrected false claim that '070-environment.md references §4' — actual cross-reference is in 085-project-local-tools.md. Added risk for 070-environment.md's own duplicate Node.js section. | Validation: Completeness FAIL (070-environment.md in Files Affected had no SC/REQ) + Correctness FAIL (Risk section falsely claimed 070 references §4) | Spec-creation revise pipeline |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
