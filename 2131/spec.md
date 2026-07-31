---
remote_issue: 2131
remote_url: https://github.com/michael-conrad/.opencode/issues/2131
labels: [spec]
---

## Intent and Executive Summary

| Field | Content |
|-------|---------|
| **Problem Statement** | `080-code-standards.md` conflates multiple concerns: project-specific rules (parsing pipeline, ConfigurationManager), testing procedure that belongs in the `test-driven-development` skill card, and sections duplicated in `000-critical-rules.md` (Behavioral RED/GREEN). |
| **Root Cause / Motivation** | The file grew organically without concern-boundary enforcement. Testing procedure was added to the nearest file (080) rather than the appropriate skill card. Project-specific references were never generalized. |
| **Approach Chosen** | Compaction: generalize project-specific references, move testing procedure to the skill card, remove sections duplicated in 000, keep all universal content. Every move/removal is gated by semantic analysis verifying no constraint loss. |
| **Alternatives Considered & Why Discarded** | See Alternatives Considered section below. |
| **Key Design Decisions** | (1) Compaction preserves all normative content — no content is removed without verification that it exists in the destination. (2) Semantic analysis gates every move/removal — grep-only verification is insufficient for constraint-preservation. (3) Test Integrity Mandate stays in 080 because only a summary exists in 000. |

## Objective

Reorganize `080-code-standards.md` by moving testing procedure to the `test-driven-development` skill card, removing sections duplicated in `000-critical-rules.md`, and generalizing project-specific references — without losing any semantic constraints.

## Problem

`080-code-standards.md` conflates multiple concerns in a single file: project-specific rules (parsing pipeline, ConfigurationManager), testing procedure that belongs in the `test-driven-development` skill card, and sections duplicated in `000-critical-rules.md` (Behavioral RED/GREEN). The file's sprawl is a symptom of missing concern boundaries, not a size problem.

## Requirements

| ID | Requirement |
|----|-------------|
| REQ-1 | Project-specific references in Parsing Logic Changes and Libraries & Packages sections must be generalized to universal language |
| REQ-2 | Enforcement Test Mandate section must move from 080 to the test-driven-development skill card with no constraint loss |
| REQ-3 | Behavioral RED/GREEN section must be removed from 080 (normative content preserved in 000) |
| REQ-4 | Test Integrity Mandate must remain in 080 (only a summary exists in 000) |
| REQ-5 | All keep sections must remain in 080 with their content intact |

## Alternatives Considered

| Alternative | Description | Rejected Because |
|-------------|-------------|------------------|
| **Full rewrite** | Rewrite 080 from scratch with clean concern boundaries | Risk of silent content loss exceeds benefit; existing content is correct, only misplaced. Compaction preserves all normative content. |
| **Split into multiple files** | Create separate files for testing rules, project-specific rules, and universal standards | Increases navigation overhead for a single concern domain (code standards). The file's content is all related to code standards — the issue is misplaced content (testing procedure in a standards file), not too many topics in one file. |
| **Leave as-is** | No changes to 080 | Perpetuates the concern-boundary conflation: testing procedure lives in a code-standards file, project-specific rules block portability, and duplicated sections create drift risk. |

## Proposed Solution

### Generalize (project-specific → universal):

| Section | Before | After |
|---|---|---|
| Parsing Logic Changes (lines 20-25) | References `src/commons/parsing/`, `0100_ingest_xml.ipynb` | "Changes to data processing pipelines that affect extracted metadata require a full pipeline rerun" |
| Libraries & Packages (lines 60-70) | References NLTK, `ConfigurationManager`, `project-config.ini`, `210-scripting.md` | "Use domain-appropriate libraries for specialized tasks. Use project-provided abstractions for data file paths." |

### Move to skill card:

| Section | Destination |
|---|---|
| Enforcement Test Mandate (lines 418-573) | `test-driven-development` skill card |

### Remove (duplicated in 000):

| Section | Lines |
|---|---|
| Behavioral RED/GREEN as Primary Enforcement Gate | 574-604 (restates Enforcement Test Mandate) |

### Keep (universal, generalized):

- Scope, Typing, Design Principles, Modern Python, Print Statements, Linting & Tool Selection, Numbering, AI Co-Authored Attribution, Provenance Headers, Cross-Reference Standards, YAML Standard, Triple Co-Application, Parameter Naming Convention, Test Integrity Mandate

## Traceability

| Requirement | Success Criteria | Phase |
|-------------|-----------------|-------|
| REQ-1 | SC-1, SC-2, SC-7 | Phase 1 |
| REQ-2 | SC-3, SC-8 | Phase 2 |
| REQ-3 | SC-4, SC-9 | Phase 3 |
| REQ-4 | SC-5 | Phase 3 (no-op — stays in 080) |
| REQ-5 | SC-6 | Phase 4 |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Parsing Logic Changes generalized (no project-specific paths) | string + semantic | grep for absence of 'src/commons/parsing' + semantic analysis that generalized text preserves the constraint (pipeline rerun required on metadata-affecting changes) |
| SC-2 | Libraries & Packages generalized (no project-specific names) | string + semantic | grep for absence of 'ConfigurationManager' + semantic analysis that generalized text preserves the intent (use project-provided abstractions for paths) |
| SC-3 | Enforcement Test Mandate moved to test-driven-development skill card | string + semantic | grep for 'Enforcement Test Mandate' in test-driven-development/SKILL.md + semantic analysis that all subsections (Evidence Type Taxonomy, SC-to-Test Traceability, RED-Phase Ordering, Behavioral RED/GREEN gate) are present in the destination |
| SC-4 | Behavioral RED/GREEN section removed from 080 | string + semantic | grep for absence of 'Behavioral RED/GREEN as Primary Enforcement Gate' in 080 + semantic analysis that the section's normative content (behavioral tests are PRIMARY) is preserved in 000 or the destination skill |
| SC-5 | Test Integrity Mandate remains in 080 with content intact | string + semantic | grep for 'Test Integrity Mandate' in 080 + semantic analysis that all 6 rules (No Lobotomizing, Timeout Diagnosable, Research Sub-Agents, FAIL is Hard Gate, Clean-Room Semantic Inspection, Artifact Generated is NOT PASS) are present |
| SC-6 | All keep sections remain in 080 with their original section headers and no content removed or reworded | string + semantic | grep for each keep section header + semantic analysis comparing before/after content of each keep section — PASS only if every keep section's content is byte-identical to the original (no changes during generalization of adjacent sections) |
| SC-7 | Generalized Parsing Logic Changes preserve the pipeline-rerun constraint | semantic | Clean-room sub-agent reads before/after text and confirms: (a) the pipeline-rerun requirement is present in the generalized version, (b) the scope of "metadata-affecting changes" is not narrowed, (c) no project-specific paths leaked into the generalized version. PASS only if all three sub-checks pass. |
| SC-8 | Moved Enforcement Test Mandate preserves all normative rules in the destination | semantic | Clean-room sub-agent reads source and destination and confirms: (a) every normative rule from the source section is present in the destination, (b) no rules were dropped during the move, (c) cross-references to 000 are updated to point to the correct section. PASS only if all three sub-checks pass. |
| SC-9 | Removed Behavioral RED/GREEN section's normative content exists in 000 | semantic | Clean-room sub-agent reads 080 before/after and 000 to confirm: (a) every normative statement from the removed section exists in 000, (b) no content was silently dropped, (c) cross-references in 080 that pointed to removed sections are updated. PASS only if all three sub-checks pass. |

## Implementation Plan

### Phase 1 (REQ-1): Generalize Parsing Logic Changes and Libraries & Packages sections
### Phase 2 (REQ-2): Move Enforcement Test Mandate to test-driven-development skill card
### Phase 3 (REQ-3, REQ-4): Remove Behavioral RED/GREEN section; verify Test Integrity Mandate stays in 080
### Phase 3.5 (REQ-2, REQ-3): Lobotomization gate — run behavioral enforcement tests to verify no constraint loss
- Run `bash .opencode/tests-v2/test-enforcement.sh --changed` to verify content-verification tests pass
- Run `bash .opencode/tests-v2/behaviors/<relevant-scenario>.sh` to verify behavioral tests pass
- If any behavioral test fails, the move/removal has caused constraint loss — revert and investigate
### Phase 4 (REQ-5): Verify all keep sections remain

## Files Affected

- `.opencode/guidelines/080-code-standards.md` — compacted
- `.opencode/skills/test-driven-development/SKILL.md` — receives Enforcement Test Mandate

## Edge Cases

| Scenario | Handling |
|----------|----------|
| **Destination file (test-driven-development/SKILL.md) already has an Enforcement Test Mandate section** | Before moving, check for existing content. If present, merge: preserve both sections, deduplicate overlapping rules, flag for review. |
| **Generalized text loses specificity** | Phase 3.5 lobotomization gate catches this. If behavioral tests fail, revert the generalization and re-evaluate the replacement text. |
| **Cross-reference in 080 points to a removed section** | SC-9(c) requires cross-reference audit. Any stale reference must be updated to point to the correct location in 000. |
| **Keep section was accidentally modified during generalization of adjacent content** | SC-6 verification catches this. If a keep section's content changed, revert the unintended modification. |
| **Behavioral RED/GREEN section's normative content does not exist in 000** | SC-4 and SC-9 verify this. If the content is missing from 000, do NOT remove the section from 080 — keep it and flag the gap. |

## Documentation Sources

| Source | Type | Purpose |
|--------|------|---------|
| `.opencode/guidelines/080-code-standards.md` | Internal file | Source file being compacted — all line ranges verified against live file |
| `.opencode/guidelines/000-critical-rules.md` | Internal file | Destination for removed Behavioral RED/GREEN content — verified that normative content exists at lines 829-838 |
| `.opencode/skills/test-driven-development/SKILL.md` | Internal file | Destination for moved Enforcement Test Mandate — verified that section does not already exist |

## All-or-Nothing Gate

This spec's success criteria are an all-or-nothing gate: ALL 9 SCs (SC-1 through SC-9) must PASS for the compaction to be considered complete. If any single SC FAILs, the compaction is incomplete and must be remediated before proceeding. Partial compaction is not permitted — partial changes leave the file in an inconsistent state with some content moved, some removed, and some generalized, making the file harder to navigate than before.

## Risks

- **Content loss**: Removed sections must be verified to exist in 000. Mitigation: SC-4, SC-9 verify removal is safe via string + semantic evidence.
- **Lobotomization during move**: Moving content between files can silently drop constraints (e.g., a rule about behavioral test primacy gets lost in translation). Mitigation: Phase 3.5 lobotomization gate runs behavioral tests before and after the move; SC-7, SC-8, SC-9 provide semantic verification of constraint preservation.
- **Cross-reference staleness**: After moves/removals, internal cross-references in 080 may point to sections that no longer exist. Mitigation: SC-9(c) requires cross-reference audit.

## Dependencies

- None.

---

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-07-31 | Reframed problem from size-based to semantic organization; added SC-7/SC-8/SC-9 (semantic analysis); upgraded SC-1 through SC-6 to string + semantic; added Phase 3.5 lobotomization gate; added lobotomization risk | Spec revision request: size metrics are not a valid problem justification; string-only evidence does not protect against lobotomization | spec-creation pipeline |
| 2026-07-31 | Added Requirements section (REQ-1 through REQ-5) and Traceability table; fixed Remove table (Test Integrity Mandate stays in 080); fixed line ranges (418-573, 574-604, 606-717); scoped SC-6 as single check; removed Phase 3 (Test Integrity Mandate removal); removed #2121 dependency | Validation findings: missing requirements/traceability, Test Integrity Mandate not fully in 000, line range inaccuracies, SC-6 compound, plan/risks out of date | spec-creation pipeline |
| 2026-07-31 | Added Objective section; added REQ references to phase headings | Validation findings: missing Objective section, phase headings lacked REQ references | spec-creation pipeline |
| 2026-07-31 | Added Intent and Executive Summary (5-field preamble), Edge Cases section, Documentation Sources section, All-or-Nothing Gate statement; tightened SC-6/7/8/9 wording to remove open-ended quality terms and implicit behavior | Spec-audit FAIL findings: SC-8 (edge cases), SC-9/SC-DET (determinism), SC-11 (doc sources), SC-12 (preamble), SC-14 (gate statement), research_adequacy (edge case analysis) | spec-creation pipeline |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
