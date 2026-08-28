---
number: 2352
title: '[SPEC] Condense 080-code-standards.md — move DI/provenance/attribution to skill cards'
status: open
labels:
  - needs-approval
  - spec-draft
---

> **Full spec and artifacts: [`2352/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2352)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2352/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

| # | Field | Content |
|---|-------|---------|
| 1 | **Problem Statement** | The preloaded `.opencode/guidelines/080-code-standards.md` costs ~14.2k tokens (~21% of the agent's preload burden, the 2nd largest single file). Roughly 65% of its content is procedural prose — typing conventions, design rules, DI mandates, print rules, tool selection, numbering, attribution/byline, provenance headers, cross-reference standards, YAML standard, and triple co-application — that agents only need on-demand. Preloading this procedural bulk taxes every session's system context. |
| 2 | **Root Cause / Motivation** | 080 is a Tier 1 guideline preloaded into the `instructions[]` array in `.opencode/opencode.jsonc`. It mixes two distinct kinds of content: (a) procedural code-standards conventions that are only relevant when writing code, and (b) enforcement cores — the enforcement-test mandate, the behavioral-test-substitution prohibition, and critical-rules-XXX blocks — that must remain visible at all times. Preloading procedural content that is not universally needed wastes context every session. Condensing 080 addresses the root cause: procedural content belongs behind on-demand Read-links, not in the always-loaded preload. |
| 3 | **Approach Chosen** | Relocate the procedural sections of 080 into shared references (`code-standards-shared`, `attribution-provenance`) loaded via mandatory Read-links, aligning design/DI authority to the `programming-principles` skill (already the master source) and wiring the retained enforcement cores to the `test-driven-development` skill (canonical source). 080 remains in the `instructions[]` array but holds only the condensed enforcement core plus Read-links to the relocated procedural content. |
| 4 | **Alternatives Considered & Why Discarded** | **Full removal of 080 from preload.** Discarded — a warning comment in `opencode.jsonc` and regression #497 establish that all 12 Tier 1 guidelines MUST stay loaded; removing 080 caused a critical safety regression. **Leaving 080 unchanged.** Discarded — this preserves the ~14.2k token burden and defeats the purpose of the change. **Moving everything to skills, including enforcement cores.** Discarded — enforcement cores must remain preloaded so the agent enforces them without a dispatch. |
| 5 | **Key Design Decisions** | (a) **Preload invariance:** 080 MUST remain in the `instructions[]` array; the shared references MUST NOT be added to preload (loaded on-demand via Read-links). Tradeoff: agents no longer see procedural sections inline, but must follow Read-links when needed — an acceptable cost given the token savings. (b) **Verbatim enforcement retention:** the enforcement cores (Enforcement Test Mandate + critical-rules-009/042/test-integrity/BEH-EV/XXX/023×3/060 blocks) are retained verbatim in 080. Tradeoff: preserving the exact text avoids subtle semantic drift but leaves enforcement text inline. (c) **Authority alignment:** `programming-principles` remains the master source for design/DI; `test-driven-development` remains the canonical source for the enforcement-test mandate/evidence taxonomy. 080 links to them; never the reverse. Tradeoff: eliminates duplicate authority but requires correct Read-link wiring. |
| 6 | **User Intent / Original Prompt** | "Condense 080-code-standards.md — move DI/provenance/attribution to skill cards" (`.opencode#2352`). The developer requested the reduction of 080's preloaded token burden by relocating procedural content while retaining the enforcement cores. |

## 2. Not Included

- **Removing any enforcement core** — Rationale: the stated risk is losing the enforcement-test mandate; the mitigation is retaining enforcement cores verbatim.
- **Altering the preload mechanism** — Rationale: the `instructions[]` array warning forbids removing any Tier 1 guideline; 080 stays loaded.
- **Changing enforcement semantics** — Rationale: relocation is a structural (token-burden) change, not a semantic change to enforcement behavior.
- **Rewording or condensing the enforcement-core text** — Rationale: verbatim retention prevents subtle drift in critical-rule semantics.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | A `code-standards-shared` reference exists holding the relocated procedural sections (Typing, Modern Python, Libraries, DI mandate + generic mandate, Print rules, Linting, Tool Selection by File Type, Numbering, Cross-Reference Standards, YAML Standard, Triple Co-Application, Parameter Naming Convention) preserved verbatim from 080. | structural | `read` the reference file; `diff` against the corresponding 080 sections to confirm verbatim preservation |
| SC-2 | An `attribution-provenance` reference exists holding the AI Co-Authored Attribution and Provenance Headers sections relocated from 080, preserved verbatim. | structural | `read` the reference file; `diff` against 080 lines 164-436 to confirm verbatim preservation |
| SC-3 | 080-code-standards.md is condensed: the relocated procedural sections are replaced with mandatory Read-links to the shared references, while the enforcement cores (Enforcement Test Mandate and critical-rules-009/042/test-integrity/BEH-EV/XXX/023×3/060 blocks) remain verbatim, and 080 remains in the `instructions[]` array. | structural | `read` 080 and verify: Read-links use the mandatory `Read [Text](path)` pattern; enforcement cores match the original text (diff); `grep` `opencode.jsonc` confirms 080 still present in `instructions[]` |
| SC-4 | The design/DI authority aligns to the `programming-principles` skill as the master source: the condensed 080 Read-links to `programming-principles` for design/DI conventions, with no reversed (reverse) reference and no duplicated authority. | structural | `grep` 080 and `programming-principles/SKILL.md` for cross-references; confirm the master-source relationship is one-directional |
| SC-5 | The retained enforcement cores in 080 correctly Read-link to the canonical `test-driven-development/SKILL.md` sections (Enforcement Test Mandate, Evidence Type Taxonomy, Behavioral RED/GREEN gate, Test Integrity Mandate), with no stale or duplicated definitions inline. | structural | `grep` the Read-link targets in 080; `read` `test-driven-development/SKILL.md` to confirm the linked sections exist |
| SC-6 | The preloaded token burden of 080 is substantially reduced relative to the ~14.2k baseline, and no enforcement core was lost in the condensation. | structural | Measure pre/post token count of 080 with a token-count script; verify enforcement cores present (diff) |
| SC-7 | An agent consuming the condensed 080 still enforces the retained enforcement cores — specifically, the behavioral-test-substitution prohibition — with no regression from condensation. | behavioral | Run a behavioral enforcement test via `opencode run` through the `with-test-home` harness; assert via stderr-based helpers (`assert_stderr_pattern_present`) that the agent enforces the retained core rather than substituting grep/structural checks |

## 4. Requirements

- R-1. The system SHALL relocate the procedural sections of 080-code-standards.md to shared references (code-standards-shared, attribution-provenance) loaded via mandatory Read-links.
- R-2. The system SHALL retain the enforcement-test mandate, the behavioral-test-substitution prohibition, and the critical-rules-XXX blocks (derivation provenance, evidence-type classification gate) in 080-code-standards.md verbatim.
- R-3. The system SHALL keep 080-code-standards.md in the Tier 1 `instructions[]` array; condensation SHALL NOT remove the file from preload.
- R-4. The system SHALL align the design/DI authority to the `programming-principles` skill as the master source, with no reversed reference.
- R-5. The system SHALL wire the retained enforcement cores in 080 to the canonical `test-driven-development/SKILL.md` definitions.
- R-6. The system SHALL achieve a substantial reduction in the preloaded token burden of 080 relative to the ~14.2k baseline while preserving every enforcement core.
- R-7. The system SHALL preserve stable anchors referenced by other files (critical-rules-023 references 080; critical-rules-060 references 080 §Terminology Note; programming-principles skill line 68 references 080).

## 5. Items

### Item 1 (SC-1): Create code-standards-shared reference

- RED: Enforcement test asserts the `code-standards-shared` reference does not yet exist (file absent).
- GREEN: Create the shared reference file holding the relocated procedural sections verbatim.
- verify: `read` + `diff` against the corresponding 080 sections to confirm verbatim preservation.
- commit: The new shared reference file.

### Item 2 (SC-2): Create attribution-provenance reference

- RED: Enforcement test asserts the `attribution-provenance` reference does not yet exist.
- GREEN: Create the shared reference holding the AI Co-Authored Attribution and Provenance Headers sections verbatim.
- verify: `read` + `diff` against 080 lines 164-436 to confirm verbatim preservation.
- commit: The new attribution-provenance reference file.

### Item 3 (SC-3): Condense 080-code-standards.md preloaded file

- RED: Enforcement test asserts 080 still contains the full procedural sections (uncondensed) — test fails because it expects condensation.
- GREEN: Replace the relocated procedural sections in 080 with mandatory Read-links, retaining the enforcement cores verbatim; confirm 080 remains in `instructions[]`.
- verify: `read` 080 (Read-link form + enforcement cores verbatim via diff); `grep` `opencode.jsonc` for 080 presence.
- commit: Condensed 080-code-standards.md.

### Item 4 (SC-4): Relocate design/DI authority to programming-principles skill

- RED: Enforcement test asserts the condensed 080 does not yet link to `programming-principles` for design/DI.
- GREEN: Wire the condensed 080 Read-link to `programming-principles` and ensure the master-source relationship is one-directional (no reversed reference, no duplicate authority).
- verify: `grep` 080 and `programming-principles/SKILL.md` for cross-references.
- commit: 080 + programming-principles wiring changes.

### Item 5 (SC-5): Wire enforcement cores to test-driven-development skill

- RED: Enforcement test asserts the retained enforcement cores do not yet Read-link to the canonical TDD skill sections.
- GREEN: Wire the retained enforcement cores in 080 to `test-driven-development/SKILL.md` canonical sections.
- verify: `grep` Read-link targets; `read` `test-driven-development/SKILL.md` to confirm linked sections exist.
- commit: 080 enforcement-core Read-links.

### Item 6 (SC-6): Verify token-burden reduction

- RED: Enforcement test asserts token reduction has not been measured/achieved.
- GREEN: Measure the preloaded token burden of 080 before and after condensation; confirm substantial reduction and enforcement-core retention.
- verify: token-count script; `read` 080 for enforcement-core presence.
- commit: Verification evidence artifact.

### Item 7 (SC-7): Behavioral enforcement: enforcement core retained and enforced

- RED: Behavioral enforcement test asserts the condensed 080 does NOT lead the agent to enforce the behavioral-test-substitution prohibition (no regression) — expects enforcement, so test is written to detect the regression.
- GREEN: Confirm the condensed 080 (with retained cores and TDD wiring) causes an agent to enforce the retained core behaviorally.
- verify: Behavioral test via `with-test-home opencode run`; stderr-based assertion helpers (`assert_stderr_pattern_present`) confirm enforcement of the retained core — NOT grep/string substitution.
- commit: Behavioral enforcement test + evidence artifact.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/guidelines/080-code-standards.md` (current, 663 lines) | Source file being condensed; contains the procedural sections and enforcement cores to relocate/retain | Satisfied |
| `.opencode/skills/programming-principles/SKILL.md` | Master source for design/DI authority; receives the relocated design-principles reference wiring | Satisfied |
| `.opencode/skills/test-driven-development/SKILL.md` | Canonical source for the enforcement-test mandate, evidence taxonomy, behavioral RED/GREEN gate, test integrity; receives the wired enforcement cores | Satisfied |
| `.opencode/opencode.jsonc` `instructions[]` array | Preload config; 080 must remain in the array; shared refs must NOT be added | Satisfied |
| Research card `spec-writing-ai-agents-opencode-skill-architecture` | Corroborates token-efficiency rationale and skill-card/task-card division | Satisfied |
| Research card `pre-response-gate-skill-description-design` | Confirms on-demand skill dispatch preserves availability without preload cost | Satisfied |
| Research card `cross-reference-form-comparison` | Confirms mandatory Read-link pattern as the reliable cross-reference form | Satisfied |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1, SC-2 | Phase 1, Phase 2 |
| R-2 | SC-3, SC-5 | Phase 3, Phase 5 |
| R-3 | SC-3 | Phase 3 |
| R-4 | SC-4 | Phase 4 |
| R-5 | SC-5 | Phase 5 |
| R-6 | SC-6 | Phase 6 |
| R-7 | SC-3, SC-4, SC-5 | Phase 3, Phase 4, Phase 5 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `.opencode/guidelines/080-code-standards.md` | config/guideline | `.opencode/guidelines/080-code-standards.md` | Verified by `read` — 663 lines, sections at lines 13-543 (procedural) and 438-440 + 545-663 (enforcement cores) |
| `.opencode/opencode.jsonc` | config | `.opencode/opencode.jsonc` | Verified by `read` — 080 at `instructions[]` line 86; warning comment lines 69-76 |
| `.opencode/skills/programming-principles/SKILL.md` | doc (skill) | `.opencode/skills/programming-principles/SKILL.md` | Verified by `read` — line 68 master-source relationship with 080 |
| `.opencode/skills/test-driven-development/SKILL.md` | doc (skill) | `.opencode/skills/test-driven-development/SKILL.md` | Verified by `read` — contains Enforcement Test Mandate, Evidence Type Taxonomy, Behavioral RED/GREEN gate, Test Integrity Mandate |
| Research card `spec-writing-ai-agents-opencode-skill-architecture` | doc (research card) | `.opencode/.issues/research-cards/` | Verified via research-card-consultation.yaml (confidence 0.90) |
| Research card `pre-response-gate-skill-description-design` | doc (research card) | `.opencode/.issues/research-cards/` | Verified via research-card-consultation.yaml (confidence 0.9) |
| Research card `cross-reference-form-comparison` | doc (research card) | `.opencode/.issues/research-cards/` | Verified via research-card-consultation.yaml |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the shared reference exists and preserves content verbatim costs one read + diff. Skipping means a structurally wrong shared reference isn't caught until the first spec created from it fails audit.
- **SC-2:** Verifying the attribution-provenance reference preserves byline semantics costs one read + diff. Skipping means a byline-preservation defect ships and breaks traceability — a 1000× downstream cost when the audit trail is found falsified.
- **SC-3:** Verifying the condensation retains enforcement cores verbatim and 080 stays preloaded costs one read + grep. Skipping means an enforcement core is silently dropped — the stated risk — and the safety regression propagates to every session, compounding exponentially.
- **SC-4:** Verifying the master-source relationship is one-directional costs one grep. Skipping means reversed authority or duplicated design content, which every downstream spec must then resolve.
- **SC-5:** Verifying the enforcement cores Read-link to the canonical TDD skill costs one grep + read. Skipping means a stale or duplicate definition survives, and the enforcement-test mandate loses its canonical source.
- **SC-6:** Measuring the token-burden reduction costs one token-count run. Skipping means the primary objective (token savings) is unverified, and the condensation may have shipped without achieving its goal.
- **SC-7:** Running the behavioral enforcement test costs minutes of execution time via `opencode run`. Skipping means the behavioral-test-substitution prohibition regresses silently — the death spiral: structural PASS ships a behavioral defect that costs 1000× more to fix downstream. The behavioral test is the break that catches the regression at gate 1.

## 11. Edge Cases

| Condition | Expected Behavior | Resolution |
|-----------|-------------------|------------|
| **Input boundary — empty procedural section** | A relocated section that is empty or near-empty MUST still be represented (the Read-link exists) or explicitly documented as not requiring relocation. | The shared reference is created for each relocated concern even if sparse; no section is silently dropped. |
| **Input boundary — enforcement core missing during condensation** | If an enforcement core (Enforcement Test Mandate or any critical-rules block) is absent from the condensed 080, verification FAILs. | Restore the core verbatim from the original and re-verify (state-analysis recovery path REFS_CREATED→CONDENSED). |
| **State transition — REFS_CREATED → CONDENSED failure** | If enforcement core dropped or altered during condensation. | Restore the core verbatim from the original; re-verify (per state-analysis failure transition). |
| **State transition — CONDENSED → VERIFIED failure** | If token reduction not achieved OR behavioral enforcement test FAILs. | Diagnose (incomplete condensation or enforcement regression), remediate, re-verify (per state-analysis failure transition). |
| **Failure mode — 080 removed from instructions array** | Verification checks `grep opencode.jsonc`; absence is a FAIL (preload invariance invariant violated). | Re-add 080 to the `instructions[]` array; never remove it. |
| **Failure mode — Read-link uses wrong form** | A `See file §section` citation instead of the mandatory `Read [Text](path)` pattern is a FAIL (Read-Link Cross-Reference Rule). | Rewrite the cross-reference in the mandatory Read-link form. |
| **Failure mode — reversed authority (080 as master source)** | If `programming-principles` or `test-driven-development` begins referencing 080 as authoritative, verification FAILs. | Re-point the authority so 080 links to the skills, never the reverse. |
| **Failure mode — stable anchor breakage** | If an external reference (critical-rules-023, critical-rules-060, programming-principles line 68) points to a relocated section by a now-moved anchor. | Re-point the external reference to the shared reference / preserved stable anchor. |
| **Concurrency — multiple agents editing 080** | The condensation is a single-branch change; concurrent edits to 080 could conflict. | Coordinate via the git-workflow branch discipline; resolve conflicts through the conflict-resolution workflow. |
| **Recovery — behavioral test cannot execute** | Per the retained behavioral-test-substitution prohibition, an unexecutable behavioral test is a FAIL, not a structural-substitute PASS. | Attempt remediation (alternative model, infrastructure check); exhaustive remediation before escalation; NEVER substitute grep/structural evidence. |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
