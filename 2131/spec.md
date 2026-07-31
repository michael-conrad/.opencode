---
remote_issue: 2131
remote_url: https://github.com/michael-conrad/.opencode/issues/2131
labels: [spec]
---

## Problem

`080-code-standards.md` conflates multiple concerns in a single file: project-specific rules (parsing pipeline, ConfigurationManager), testing procedure that belongs in the `test-driven-development` skill card, and sections duplicated in `000-critical-rules.md` (Test Integrity Mandate, Behavioral RED/GREEN). This semantic overlap creates ambiguity about where a rule lives, which file takes precedence, and whether a change to one file must be mirrored in another. The file's sprawl is a symptom of missing concern boundaries, not a size problem.

## Proposed Solution

### Generalize (project-specific → universal):

| Section | Before | After |
|---|---|---|
| Parsing Logic Changes (lines 20-25) | References `src/commons/parsing/`, `0100_ingest_xml.ipynb` | "Changes to data processing pipelines that affect extracted metadata require a full pipeline rerun" |
| Libraries & Packages (lines 60-70) | References NLTK, `ConfigurationManager`, `project-config.ini`, `210-scripting.md` | "Use domain-appropriate libraries for specialized tasks. Use project-provided abstractions for data file paths." |

### Move to skill card:

| Section | Destination |
|---|---|
| Enforcement Test Mandate (lines 418-575) | `test-driven-development` skill card |

### Remove (duplicated in 000):

| Section | Lines |
|---|---|
| Behavioral RED/GREEN as Primary Enforcement Gate | 576-606 (restates Enforcement Test Mandate) |
| Test Integrity Mandate | 608-718 (in 000) |

### Keep (universal, generalized):

- Scope, Typing, Design Principles, Modern Python, Print Statements, Linting & Tool Selection, Numbering, AI Co-Authored Attribution, Provenance Headers, Cross-Reference Standards, YAML Standard, Triple Co-Application, Parameter Naming Convention

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Parsing Logic Changes generalized (no project-specific paths) | string + semantic | grep for absence of 'src/commons/parsing' + semantic analysis that generalized text preserves the constraint (pipeline rerun required on metadata-affecting changes) |
| SC-2 | Libraries & Packages generalized (no project-specific names) | string + semantic | grep for absence of 'ConfigurationManager' + semantic analysis that generalized text preserves the intent (use project-provided abstractions for paths) |
| SC-3 | Enforcement Test Mandate moved to test-driven-development skill card | string + semantic | grep for 'Enforcement Test Mandate' in test-driven-development/SKILL.md + semantic analysis that all subsections (Evidence Type Taxonomy, SC-to-Test Traceability, RED-Phase Ordering, Behavioral RED/GREEN gate) are present in the destination |
| SC-4 | Behavioral RED/GREEN section removed from 080 | string + semantic | grep for absence of 'Behavioral RED/GREEN as Primary Enforcement Gate' in 080 + semantic analysis that the section's normative content (behavioral tests are PRIMARY) is preserved in 000 or the destination skill |
| SC-5 | Test Integrity Mandate section removed from 080 | string + semantic | grep for absence of 'Test Integrity Mandate' in 080 + semantic analysis that all 6 rules (No Lobotomizing, Timeout Diagnosable, Research Sub-Agents, FAIL is Hard Gate, Clean-Room Semantic Inspection, Artifact Generated is NOT PASS) are preserved in 000 |
| SC-6 | All keep sections remain in 080 | string + semantic | grep for each section header + semantic analysis that no keep section lost content during generalization |
| SC-7 | No constraint loss in generalized Parsing Logic Changes | semantic | Clean-room sub-agent reads before/after text and confirms: (a) the pipeline-rerun requirement is preserved, (b) the scope of "metadata-affecting changes" is not narrowed, (c) no project-specific paths leaked into the generalized version |
| SC-8 | No constraint loss in moved Enforcement Test Mandate | semantic | Clean-room sub-agent reads source and destination and confirms: (a) all normative rules are present in the destination, (b) no rules were dropped during the move, (c) cross-references to 000 are updated to point to the correct section |
| SC-9 | No constraint loss in removed sections (Behavioral RED/GREEN, Test Integrity Mandate) | semantic | Clean-room sub-agent reads 080 before/after and 000 to confirm: (a) all normative content from removed sections exists in 000, (b) no content was silently dropped, (c) cross-references in 080 that pointed to removed sections are updated |

## Implementation Plan

### Phase 1: Generalize Parsing Logic Changes and Libraries & Packages sections
### Phase 2: Move Enforcement Test Mandate to test-driven-development skill card
### Phase 3: Remove Behavioral RED/GREEN and Test Integrity Mandate sections
### Phase 3.5: Lobotomization gate — run behavioral enforcement tests to verify no constraint loss
- Run `bash .opencode/tests-v2/test-enforcement.sh --changed` to verify content-verification tests pass
- Run `bash .opencode/tests-v2/behaviors/<relevant-scenario>.sh` to verify behavioral tests pass
- If any behavioral test fails, the move/removal has caused constraint loss — revert and investigate
### Phase 4: Verify all keep sections remain

## Files Affected

- `.opencode/guidelines/080-code-standards.md` — compacted
- `.opencode/skills/test-driven-development/SKILL.md` — receives Enforcement Test Mandate

## Risks

- **Content loss**: Removed sections must be verified to exist in 000. Mitigation: SC-4, SC-5, SC-9 verify removal is safe via string + semantic evidence.
- **Lobotomization during move**: Moving content between files can silently drop constraints (e.g., a rule about behavioral test primacy gets lost in translation). Mitigation: Phase 3.5 lobotomization gate runs behavioral tests before and after the move; SC-7, SC-8, SC-9 provide semantic verification of constraint preservation.
- **Cross-reference staleness**: After moves/removals, internal cross-references in 080 may point to sections that no longer exist. Mitigation: SC-9(c) requires cross-reference audit.

## Dependencies

- Depends on 000-critical-rules.md compaction (spec #2121) — the Test Integrity Mandate must remain in 000.

---

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-07-31 | Reframed problem from size-based to semantic organization; added SC-7/SC-8/SC-9 (semantic analysis); upgraded SC-1 through SC-6 to string + semantic; added Phase 3.5 lobotomization gate; added lobotomization risk | Spec revision request: size metrics are not a valid problem justification; string-only evidence does not protect against lobotomization | spec-creation pipeline |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
