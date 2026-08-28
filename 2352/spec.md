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
| 3 | **Approach Chosen** | Relocate the procedural sections of 080 into shared references (`code-standards-shared`, `attribution-provenance`) loaded via mandatory Read-links, aligning design/DI authority to the `programming-principles` skill (already the master source) and wiring the retained enforcement cores to the `test-driven-development` skill (canonical source). 080 remains in the `instructions[]` array but holds only the condensed enforcement core plus Read-links to the relocated procedural content. The condensation is considered successful only when the preloaded token burden of 080 is reduced by at least 40% (post-condensation count ≤ 8,500 tokens) with no enforcement core lost. |
| 4 | **Alternatives Considered & Why Discarded** | **Full removal of 080 from preload.** Discarded — a warning comment in `opencode.jsonc` and regression #497 establish that all 12 Tier 1 guidelines MUST stay loaded; removing 080 caused a critical safety regression. **Leaving 080 unchanged.** Discarded — this preserves the ~14.2k token burden and defeats the purpose of the change. **Moving everything to skills, including enforcement cores.** Discarded — enforcement cores must remain preloaded so the agent enforces them without a dispatch. |
| 5 | **Key Design Decisions** | (a) **Preload invariance:** 080 MUST remain in the `instructions[]` array; the shared references MUST NOT be added to preload (loaded on-demand via Read-links). Tradeoff: agents no longer see procedural sections inline, but must follow Read-links when needed — an acceptable cost given the token savings. (b) **Verbatim enforcement retention:** the enforcement cores (Enforcement Test Mandate + critical-rules-009/042/test-integrity/BEH-EV/XXX/023×3/060 blocks) are retained verbatim in 080. Tradeoff: preserving the exact text avoids subtle semantic drift but leaves enforcement text inline. (c) **Authority alignment:** `programming-principles` remains the master source for design/DI; `test-driven-development` remains the canonical source for the enforcement-test mandate/evidence taxonomy. 080 links to them; never the reverse. Tradeoff: eliminates duplicate authority but requires correct Read-link wiring. |
| 6 | **User Intent / Original Prompt** | "Condense 080-code-standards.md — move DI/provenance/attribution to skill cards" (`.opencode#2352`). The developer requested the reduction of 080's preloaded token burden by relocating procedural content while retaining the enforcement cores. |

## 2. Not Included

- **Removing any enforcement core** — Rationale: the stated risk is losing the enforcement-test mandate; the mitigation is retaining enforcement cores verbatim.
- **Altering the preload mechanism** — Rationale: the `instructions[]` array warning forbids removing any Tier 1 guideline; 080 stays loaded.
- **Changing enforcement semantics** — Rationale: relocation is a structural (token-burden) change, not a semantic change to enforcement behavior.
- **Rewording or condensing the enforcement-core text** — Rationale: verbatim retention prevents subtle drift in critical-rule semantics.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | A `code-standards-shared` reference exists holding the relocated procedural sections (Typing, Modern Python, Libraries, DI mandate + generic mandate, Print rules, Linting, Tool Selection by File Type, Numbering, Cross-Reference Standards, YAML Standard, Triple Co-Application, Parameter Naming Convention) preserved verbatim from 080. | string | `read` the reference file; `diff` against the corresponding 080 sections to confirm verbatim preservation | `.opencode/guidelines/080-code-standards.md` |
| SC-2 | An `attribution-provenance` reference exists holding the AI Co-Authored Attribution and Provenance Headers sections relocated from 080, preserved verbatim. | string | `read` the reference file; `diff` against 080 lines 164-436 to confirm verbatim preservation | `.opencode/guidelines/080-code-standards.md` |
| SC-3a | Every relocated procedural section in the condensed 080 is replaced with a mandatory `Read [Text](path)` link to its corresponding shared reference. | string | `read` 080 and `grep` for the `Read [Text](path)` pattern per relocated section | `.opencode/guidelines/080-code-standards.md`; research card `cross-reference-form-comparison` |
| SC-3b | No relocated procedural section body remains inline in the condensed 080. | string | `read` 080 and confirm each relocated section body is absent inline | `.opencode/guidelines/080-code-standards.md`; research card `cross-reference-form-comparison` |
| SC-4 | The enforcement cores (Enforcement Test Mandate and critical-rules-009/042/test-integrity/BEH-EV/XXX/023×3/060 blocks) are retained verbatim in the condensed 080. | string | `diff` the enforcement-core text in the condensed 080 against the original 080 enforcement-core text to confirm verbatim retention | `.opencode/guidelines/080-code-standards.md` |
| SC-5 | 080-code-standards.md remains present in the `instructions[]` array of `.opencode/opencode.jsonc`. | string | `grep` `opencode.jsonc` for 080's presence in the `instructions[]` array | `.opencode/opencode.jsonc` |
| SC-6a | The design/DI authority in the condensed 080 aligns to the `programming-principles` skill as the master source via a mandatory Read-link. | string | `grep` 080 for the Read-link to `programming-principles` | `.opencode/guidelines/080-code-standards.md`; `.opencode/skills/programming-principles/SKILL.md` |
| SC-6b | No reversed reference exists — `programming-principles`/SKILL.md does not reference 080 as authoritative. | string | `grep` `programming-principles/SKILL.md` for any reversed reference to 080 as authoritative | `.opencode/guidelines/080-code-standards.md`; `.opencode/skills/programming-principles/SKILL.md` |
| SC-8a | The retained enforcement cores in 080 Read-link to the canonical `test-driven-development/SKILL.md` sections (Enforcement Test Mandate, Evidence Type Taxonomy, Behavioral RED/GREEN gate, Test Integrity Mandate). | string | `grep` the Read-link targets in 080 | `.opencode/guidelines/080-code-standards.md`; `.opencode/skills/test-driven-development/SKILL.md` |
| SC-8b | The `test-driven-development/SKILL.md` sections linked from 080 (Enforcement Test Mandate, Evidence Type Taxonomy, Behavioral RED/GREEN gate, Test Integrity Mandate) exist in the skill. | string | `read` `test-driven-development/SKILL.md` to confirm the linked sections exist | `.opencode/skills/test-driven-development/SKILL.md` |
| SC-9 | The condensed 080 contains no stale or duplicated enforcement-core definitions inline — the enforcement cores link to the canonical `test-driven-development/SKILL.md` definitions rather than re-defining them inline. | string | `diff`/`grep` 080 to confirm no stale or duplicated enforcement-core definition text remains inline | `.opencode/guidelines/080-code-standards.md`; `.opencode/skills/test-driven-development/SKILL.md` |
| SC-10 | The preloaded token burden of 080 is reduced by at least 40% relative to the ~14.2k token baseline — i.e., the post-condensation token count of 080 is ≤ 8,500 tokens. | structural | Measure pre/post token count of 080 with a token-count script; assert post-condensation count ≤ 8,500 tokens | `.opencode/guidelines/080-code-standards.md`; research card `spec-writing-ai-agents-opencode-skill-architecture` |
| SC-12 | An agent consuming the condensed 080 still enforces the retained enforcement cores — specifically, the behavioral-test-substitution prohibition — with no regression from condensation. | behavioral | Run a behavioral enforcement test via `opencode run` through the `with-test-home` harness; assert via stderr-based helpers (`assert_stderr_pattern_present`) that the agent enforces the retained core rather than substituting grep/structural checks | `.opencode/guidelines/080-code-standards.md`; `.opencode/skills/test-driven-development/SKILL.md` |

## 4. Requirements

- R-1. The system SHALL relocate the procedural sections of 080-code-standards.md to shared references (code-standards-shared, attribution-provenance) loaded via mandatory Read-links.
- R-2. The system SHALL retain the enforcement-test mandate, the behavioral-test-substitution prohibition, and the critical-rules-XXX blocks (derivation provenance, evidence-type classification gate) in 080-code-standards.md verbatim.
- R-3. The system SHALL keep 080-code-standards.md in the Tier 1 `instructions[]` array; condensation SHALL NOT remove the file from preload.
- R-4. The system SHALL align the design/DI authority to the `programming-principles` skill as the master source, with no reversed reference and no duplicated authority.
- R-5. The system SHALL wire the retained enforcement cores in 080 to the canonical `test-driven-development/SKILL.md` definitions, with no stale or duplicated definitions inline.
- R-6. The system SHALL reduce the preloaded token burden of 080 by at least 40% relative to the ~14.2k baseline (post-condensation count ≤ 8,500 tokens) while preserving every enforcement core.
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

### Item 3 (SC-3a): Replace procedural sections in 080 with Read-links

- RED: Enforcement test asserts 080 still contains the full procedural sections (uncondensed) — test fails because it expects condensation.
- GREEN: Replace the relocated procedural sections in 080 with mandatory `Read [Text](path)` links to the shared references.
- verify: `read` 080 and `grep` for the `Read [Text](path)` pattern per relocated section.
- commit: Condensed 080-code-standards.md (Read-link replacement).

### Item 4 (SC-3b): Confirm no relocated procedural section body remains inline

- RED: Enforcement test asserts at least one relocated procedural section body still remains inline in 080.
- GREEN: Remove any remaining relocated procedural section body inline text so every relocated section is represented only by its Read-link.
- verify: `read` 080 and confirm each relocated section body is absent inline.
- commit: Condensed 080-code-standards.md (inline-body removal).

### Item 5 (SC-4): Retain enforcement cores verbatim in 080

- RED: Enforcement test asserts the enforcement cores in 080 do not yet match the original verbatim text.
- GREEN: Retain the enforcement cores (Enforcement Test Mandate + critical-rules-009/042/test-integrity/BEH-EV/XXX/023×3/060 blocks) verbatim in the condensed 080.
- verify: `diff` the enforcement-core text in the condensed 080 against the original 080 enforcement-core text.
- commit: 080 enforcement-core verbatim retention.

### Item 6 (SC-5): Keep 080 in instructions[] array

- RED: Enforcement test asserts 080 is absent from the `instructions[]` array (expected presence) — test fails because removal is forbidden.
- GREEN: Confirm 080 remains present in the `instructions[]` array of `opencode.jsonc`.
- verify: `grep` `opencode.jsonc` for 080 presence.
- commit: No commit required if unchanged; verify-only item.

### Item 7 (SC-6a): Wire design/DI authority to programming-principles master source

- RED: Enforcement test asserts the condensed 080 does not yet link to `programming-principles` for design/DI.
- GREEN: Wire the condensed 080 Read-link to `programming-principles` as the master source.
- verify: `grep` 080 for the Read-link to `programming-principles`.
- commit: 080 + programming-principles wiring changes.

### Item 8 (SC-6b): Confirm no reversed reference

- RED: Enforcement test asserts `programming-principles`/SKILL.md still references 080 as authoritative.
- GREEN: Confirm the master-source relationship is one-directional — `programming-principles` does not reference 080 as authoritative.
- verify: `grep` `programming-principles/SKILL.md` for any reversed reference to 080 as authoritative.
- commit: 080 + programming-principles wiring changes (if a reversed reference is corrected).

### Item 9 (SC-8a): Wire enforcement cores to test-driven-development canonical sections

- RED: Enforcement test asserts the retained enforcement cores do not yet Read-link to the canonical TDD skill sections.
- GREEN: Wire the retained enforcement cores in 080 to `test-driven-development/SKILL.md` canonical sections.
- verify: `grep` the Read-link targets in 080.
- commit: 080 enforcement-core Read-links.

### Item 10 (SC-8b): Verify linked TDD sections exist

- RED: Enforcement test asserts the linked TDD sections are not confirmed present in the skill.
- GREEN: Confirm the `test-driven-development/SKILL.md` sections linked from 080 (Enforcement Test Mandate, Evidence Type Taxonomy, Behavioral RED/GREEN gate, Test Integrity Mandate) exist in the skill.
- verify: `read` `test-driven-development/SKILL.md` to confirm the linked sections exist.
- commit: Verification evidence artifact.

### Item 11 (SC-9): Remove stale/duplicate enforcement definitions from 080

- RED: Enforcement test asserts stale or duplicated enforcement-core definitions remain inline in 080.
- GREEN: Remove stale or duplicated enforcement-core definition text, keeping only the Read-links to the canonical TDD definitions.
- verify: `diff`/`grep` 080 to confirm no stale or duplicated enforcement-core definition text remains inline.
- commit: 080 de-duplication of enforcement definitions.

### Item 12 (SC-10): Measure token-burden reduction against hard threshold

- RED: Enforcement test asserts the token reduction has not been measured against the hard threshold.
- GREEN: Measure the preloaded token burden of 080 before and after condensation; assert post-condensation count ≤ 8,500 tokens (≥40% reduction).
- verify: token-count script; assert the hard numeric threshold.
- commit: Verification evidence artifact.

### Item 13 (SC-12): Behavioral enforcement: enforcement core retained and enforced

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
| R-1 | SC-1, SC-2, SC-3a, SC-3b | Phase 1, Phase 2, Phase 3 |
| R-2 | SC-4, SC-8a, SC-8b, SC-9, SC-12 | Phase 4, Phase 8, Phase 9, Phase 10, Phase 12 |
| R-3 | SC-5 | Phase 5 |
| R-4 | SC-6a, SC-6b | Phase 6 |
| R-5 | SC-8a, SC-8b, SC-9, SC-12 | Phase 8, Phase 9, Phase 10, Phase 12 |
| R-6 | SC-10 | Phase 11 |
| R-7 | SC-3a, SC-3b, SC-6a, SC-6b, SC-8a, SC-8b | Phase 3, Phase 6, Phase 8, Phase 9 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|--------------|----------|
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
- **SC-3a:** Verifying every relocated procedural section is replaced by a Read-link costs one read + grep. Skipping means a procedural section silently remains preloaded, defeating the token-burden objective.
- **SC-3b:** Verifying no relocated procedural section body remains inline costs one read. Skipping means a relocated section body stays inline, defeating the token-burden objective.
- **SC-4:** Verifying the enforcement cores are retained verbatim costs one diff. Skipping means an enforcement core is silently altered or dropped — the stated risk — and the safety regression propagates to every session.
- **SC-5:** Verifying 080 stays in the `instructions[]` array costs one grep. Skipping means a preload-invariance violation ships, removing a Tier 1 guideline from preload.
- **SC-6a:** Verifying the design/DI authority Read-links to the `programming-principles` master source costs one grep. Skipping means the design/DI authority is not wired to the master source.
- **SC-6b:** Verifying no reversed reference exists (programming-principles does not reference 080 as authoritative) costs one grep. Skipping means reversed authority, which every downstream spec must then resolve.
- **SC-8a:** Verifying the retained enforcement cores Read-link to the canonical TDD skill sections costs one grep. Skipping means a stale or duplicate definition survives, and the enforcement-test mandate loses its canonical source.
- **SC-8b:** Verifying the linked TDD sections exist costs one read. Skipping means the enforcement cores reference a non-existent section, breaking the Read-link.
- **SC-9:** Verifying no stale/duplicate enforcement definitions remain inline costs one diff/grep. Skipping means a duplicate enforcement definition persists, creating two authorities for the same rule.
- **SC-10:** Measuring the token-burden reduction against the hard threshold costs one token-count run. Skipping means the primary objective (token savings) is unverified, and the condensation may have shipped without achieving its goal.
- **SC-12:** Running the behavioral enforcement test costs minutes of execution time via `opencode run`. Skipping means the behavioral-test-substitution prohibition regresses silently — the death spiral: structural PASS ships a behavioral defect that costs 1000× more to fix downstream. The behavioral test is the break that catches the regression at gate 1.

## 11. Edge Cases

| Condition | Expected Behavior | Resolution |
|-----------|-------------------|------------|
| **Input boundary — empty procedural section** | A relocated section that is empty or near-empty MUST still be represented (the Read-link exists) or explicitly documented as not requiring relocation. | The shared reference is created for each relocated concern even if sparse; no section is silently dropped. |
| **Input boundary — enforcement core missing during condensation** | If an enforcement core (Enforcement Test Mandate or any critical-rules block) is absent from the condensed 080, SC-4 verification FAILs. | Restore the core verbatim from the original and re-verify (state-analysis recovery path REFS_CREATED→CONDENSED). |
| **Threshold boundary — token reduction below 40%** | If the post-condensation token count of 080 exceeds 8,500 tokens (less than 40% reduction), SC-10 verification FAILs. | Diagnose the incomplete condensation (a procedural section left inline), relocate the remaining procedural content, and re-measure against the hard threshold. |
| **State transition — REFS_CREATED → CONDENSED failure** | If enforcement core dropped or altered during condensation. | Restore the core verbatim from the original; re-verify (per state-analysis failure transition). |
| **State transition — CONDENSED → VERIFIED failure** | If the hard token threshold is not achieved OR the behavioral enforcement test FAILs. | Diagnose (incomplete condensation or enforcement regression), remediate, re-verify (per state-analysis failure transition). |
| **Failure mode — 080 removed from instructions array** | Verification checks `grep opencode.jsonc`; absence is a FAIL (preload invariance invariant violated). | Re-add 080 to the `instructions[]` array; never remove it. |
| **Failure mode — Read-link uses wrong form** | A `See file §section` citation instead of the mandatory `Read [Text](path)` pattern is a FAIL (Read-Link Cross-Reference Rule). | Rewrite the cross-reference in the mandatory Read-link form. |
| **Failure mode — reversed authority (080 as master source)** | If `programming-principles` or `test-driven-development` begins referencing 080 as authoritative, SC-6b verification FAILs. | Re-point the authority so 080 links to the skills, never the reverse. |
| **Failure mode — duplicated design/DI authority** | If the design/DI authority prose remains duplicated inline in 080 after condensation, SC-3b verification FAILs (no relocated section body remains inline). | Remove the duplicated prose, retaining only the Read-link to `programming-principles`. |
| **Failure mode — stale/duplicate enforcement definition** | If a stale or duplicated enforcement-core definition remains inline in 080, SC-9 verification FAILs. | Remove the stale/duplicate definition, retaining only the Read-link to the canonical TDD section. |
| **Failure mode — stable anchor breakage** | If an external reference (critical-rules-023, critical-rules-060, programming-principles line 68) points to a relocated section by a now-moved anchor. | Re-point the external reference to the shared reference / preserved stable anchor. |
| **Concurrency — multiple agents editing 080** | The condensation is a single-branch change; concurrent edits to 080 could conflict. | Coordinate via the git-workflow branch discipline; resolve conflicts through the conflict-resolution workflow. |
| **Recovery — behavioral test cannot execute** | Per the retained behavioral-test-substitution prohibition, an unexecutable behavioral test is a FAIL, not a structural-substitute PASS. | Attempt remediation (alternative model, infrastructure check); exhaustive remediation before escalation; NEVER substitute grep/structural evidence. |

## 12. Change Control

| Date | What Changed | Why | Authorized By |
|------|--------------|-----|---------------|
| 2026-08-28 | Decomposed compound SCs into atomic SCs: SC-3 → SC-3/4/5 (Read-links, enforcement verbatim, instructions[] presence); SC-4 → SC-6/7 (no reversed reference, no duplicated authority); SC-5 → SC-8/9 (Read-links resolve, no stale/duplicate definitions); SC-6 → SC-10/11 (token reduction, no enforcement core lost). Renumbered the SC set to SC-1..SC-12. Updated Items (1:1 item-SC mapping), Traceability, Cost Frame, and Edge Cases to match the decomposed atomic SC set. | Validation finding (2) COMPOUND-SC and (3) DECOMPOSITION — each SC must be atomic with a single deliverable and binary verifiability. | Validation gate (spec-auditor) |
| 2026-08-28 | Pinned SC-10 to a hard numeric threshold: ≥40% token reduction (post-condensation ≤ 8,500 tokens relative to the ~14.2k baseline). Updated R-6, Cost Frame, and Edge Cases to reflect the deterministic threshold. | Validation finding (1) DETERMINISM — "substantially reduced" has no numeric threshold and is not binary-verifiable. | Validation gate (spec-auditor) |
| 2026-08-28 | Added a Documentation Sources column to the Success Criteria table (Section 3) with non-empty entries for every SC, referencing the Section 8 Documentation Sources. The SC table is now 5 columns (ID, Criterion, Evidence Type, Verification Method, Documentation Sources), satisfying validate.md Step 3.1's Documentation Sources conformance check. | Validation finding (4) DOCUMENTATION-SOURCES — the 4-column SC table lacks the Documentation Sources column validate.md Step 3.1 requires. | Validation gate (spec-auditor) |
| 2026-08-28 | Aggregate FAIL remediation (four defects): (1) TRACEABILITY — added SC-12 to the Section 7 Traceability table (traces to R-2/R-5). (2) EVIDENCE_TYPE_MISMATCH — corrected SC-1..SC-9 evidence types from "structural" to "string", since their diff/grep content-comparison methods are string evidence per the canonical taxonomy (SC-10 remains structural as a numeric token-count measurement; SC-12 remains behavioral). (3) COMPOUND-SC — decomposed SC-8 into atomic SC-8a (wiring verification) and SC-8b (linked-section existence check), with corresponding Items 8/9. (4) DECOMPOSITION/COVERAGE — removed SC-11 (no enforcement core lost) as it is entailed by SC-4 (cores retained verbatim), and renumbered the downstream Items accordingly. Updated sc-summary.yaml, Items (1:1 item-SC mapping), Traceability, Cost Frame, and Edge Cases to match the revised SC set. | Validation findings: Aggregate FAIL on four defects (TRACEABILITY, EVIDENCE_TYPE_MISMATCH, COMPOUND-SC, DECOMPOSITION/COVERAGE). | Validation gate (spec-auditor) |
| 2026-08-28 | Aggregate FAIL remediation (three defects + recurring pattern): (1) COMPOUND-SC — decomposed SC-3 into atomic SC-3a (Read-link present per relocated section) + SC-3b (no relocated procedural section body remains inline), with corresponding Items 3/4. (2) COMPOUND-SC — decomposed SC-6 into atomic SC-6a (Read-link to programming-principles master source present) + SC-6b (no reversed reference), with corresponding Items 7/8. (3) COMPOUND-SC + COVERED-BY-PRIOR — removed SC-7 (no duplicated design/DI authority) as its requirement set is entailed by SC-3a/SC-3b (content removed + Read-link remains). Comprehensive decomposition audit of ALL SCs performed to eliminate the recurring compound-SC failure pattern (5 consecutive FAILs, each surfacing a new compound SC); all remaining SCs (SC-1, SC-2, SC-4, SC-5, SC-8a, SC-8b, SC-9, SC-10, SC-12) verified atomic. Renumbered Items to a sequential 1:1 item-SC mapping (Item 1..13). Updated sc-summary.yaml (sc_count 13), Items, Traceability, Cost Frame, and Edge Cases to match the final atomic SC set. | Validation findings: Aggregate FAIL on three structural defects (SC-3 compound, SC-7 compound, SC-7 covered-by-SC-3) plus a recurring compound-SC pattern across 5 consecutive validations. | Validation gate (spec-auditor) |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
