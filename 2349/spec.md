# [SPEC] Condense 065-verification-honesty.md — move evidence examples to verification skill

## 1. Intent and Executive Summary

1. **Problem Statement:** The Tier 1 preloaded guideline `.opencode/guidelines/065-verification-honesty.md` consumes ~1.9k tokens of preload budget on every session. Roughly 35% of its content is procedural — evidence-requirement examples, session-scoped verification detail, and pre-response gate procedure — that duplicates content already available in the verification / verification-before-completion / verification-enforcement skills.

2. **Root Cause / Motivation:** The guideline is always preloaded into every agent's context regardless of whether verification is performed. Procedural evidence examples are reinforcement, not unique content — they belong in a single source of truth (the skill cards, loaded on-demand). Keeping them in the preload wastes budget on every session and creates a duplication drift risk between the guideline and the skills.

3. **Approach Chosen:** Condense the guideline to retain only the honesty core (Zero Tolerance Rule), the Pre-Response Factual Claim Gate (with numbered procedure + halt condition), and a condensed Session-Scoped Verification subsection. Relocate the procedural evidence examples (What COUNTS as Evidence ✅/❌ tables, Evidence Requirement bullets, No Exceptions, FORBIDDEN/REQUIRED lists) to the verification skill card (`.opencode/skills/verification/SKILL.md`), and add mandatory `Read [Text](path)` links from the guideline to the skills so relocated detail remains reachable.

4. **Alternatives Considered & Why Discarded:**
   - *Relocate the session-scoped detail entirely (remove the subsection):* Discarded — enforcement test SC-004 requires a 'Session-Scoped Verification' subsection present in the guideline. Removing it would break the enforcement test (conflict C7). Retain a condensed subsection (header + one-line definition) instead.
   - *Leave the guideline unchanged:* Discarded — leaves duplicated procedural detail in preload.
   - *Distribute relocated detail across multiple verification skill cards:* Discarded — an "at least one of" target is non-deterministic (validation finding 3). The verification skill card is the single canonical home for the relocated evidence examples, per dependency #2372.

5. **Key Design Decisions:**
   - Retain the honesty core + gate preloaded (never move the zero-tolerance core) — tradeoff: preload budget stays non-zero but correctness-critical content stays always-available.
   - Relocate evidence detail to the verification skill card via Read-links — tradeoff: agents must follow Read-links to reach relocated detail, but only on-demand (no preload cost).
   - Keep the guideline in the opencode.jsonc instructions array (preload entry unchanged) — tradeoff: config untouched, avoids churn.

6. **User Intent / Original Prompt:** Condense `065-verification-honesty.md` — move evidence examples to verification skill. (Issue `.opencode#2349`.)

## 2. Not Included

- **Removing the verification-honesty zero-tolerance core** — the never-rely-on-memory rule is Tier 1 and must remain preloaded (non-requirement N1).
- **Changing the config preload mechanism** — the guideline stays in the opencode.jsonc instructions array (non-requirement N2).
- **Rewriting the verification skills' overall structure** — only relocated evidence/detail content is added; skill card structure and invocation strings are unchanged (non-requirement N3).
- **Behavioral honesty regression** — verifying that agents still follow the honesty core after condensation IS included (SC-9); this is not excluded.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The guideline SHALL retain the Zero Tolerance Rule (never-rely-on-memory core) unchanged in substance. | string | grep the Zero Tolerance Rule section present in the condensed guideline | `.opencode/guidelines/065-verification-honesty.md` |
| SC-2a | The guideline SHALL retain the '## Pre-Response Factual Claim Gate' section with its numbered procedure. | string | grep '## Pre-Response Factual Claim Gate' and its numbered procedure markers in the guideline | `.opencode/guidelines/065-verification-honesty.md` |
| SC-2b | The guideline SHALL retain the '### Halt Condition' subsection of the Pre-Response Factual Claim Gate. | string | grep '### Halt Condition' in the guideline | `.opencode/guidelines/065-verification-honesty.md` |
| SC-3 | The guideline SHALL retain a condensed 'Session-Scoped Verification' subsection (header + one-line definition) per enforcement SC-004. | string | grep 'Session-Scoped Verification' in the guideline | `.opencode/guidelines/065-verification-honesty.md` |
| SC-4 | The guideline SHALL remove the inline 'What COUNTS as Evidence' ✅/❌ tables. | string | grep the 'What COUNTS as Evidence' table headers absent from the guideline | `.opencode/guidelines/065-verification-honesty.md` |
| SC-5a | The guideline SHALL remove the '## Evidence Requirement' bullets that are not part of the retained core or gate. | string | grep '## Evidence Requirement' markers absent from the guideline | `.opencode/guidelines/065-verification-honesty.md` |
| SC-5b | The guideline SHALL remove the '## No Exceptions' section that is not part of the retained core or gate. | string | grep '## No Exceptions' markers absent from the guideline | `.opencode/guidelines/065-verification-honesty.md` |
| SC-5c | The guideline SHALL remove the '🚫 FORBIDDEN' lists that are not part of the retained core or gate. | string | grep '🚫 FORBIDDEN' list markers absent from the guideline | `.opencode/guidelines/065-verification-honesty.md` |
| SC-5d | The guideline SHALL remove the '✅ REQUIRED' lists that are not part of the retained core or gate. | string | grep '✅ REQUIRED' list markers absent from the guideline | `.opencode/guidelines/065-verification-honesty.md` |
| SC-6 | The verification skill SHALL contain the relocated evidence examples/detail (single canonical home: `.opencode/skills/verification/SKILL.md`). | string | grep evidence examples present in `.opencode/skills/verification/SKILL.md` | `.opencode/skills/verification/SKILL.md` |
| SC-7 | The guideline SHALL use mandatory `Read [Text](path)` links to the verification skills for relocated detail. | string | grep 'Read [' in guideline pointing to verification skills | `.opencode/guidelines/065-verification-honesty.md` |
| SC-8 | The enforcement test `.opencode/tests-v2/test-verification-honesty.sh` SHALL still pass its static content checks (SC-001..SC-005). | string | run static grep checks of test-verification-honesty.sh | `.opencode/tests-v2/test-verification-honesty.sh` |
| SC-9 | Agents SHALL still follow the honesty core (never-rely-on-memory) after condensation. | behavioral | behavioral scenario via opencode run (with-test-home harness) asserting honesty compliance on a real-domain prompt | `.opencode/guidelines/065-verification-honesty.md`, `.opencode/tests-v2/` |
| SC-10 | The opencode.jsonc instructions array entry for the guideline SHALL remain unchanged (config preload retention). | string | grep the guideline's instructions-array entry unchanged in opencode.jsonc | `.opencode/opencode.jsonc` |

## 4. Requirements

- R-1. The guideline SHALL retain the zero-tolerance never-rely-on-memory core (Zero Tolerance Rule), and agents SHALL continue to follow it behaviorally.
- R-2. The guideline SHALL retain the Pre-Response Factual Claim Gate section with its numbered procedure and halt condition.
- R-3. The guideline SHALL remove the inline evidence-example tables and surrounding procedural detail.
- R-4. The verification skill SHALL contain the relocated evidence examples/detail (single canonical home).
- R-5. The guideline SHALL retain a condensed Session-Scoped Verification subsection while relocating surrounding procedural detail.
- R-6. The guideline SHALL use mandatory `Read [Text](path)` links to the verification skills for relocated detail.
- R-7. The guideline SHALL remain preloaded (opencode.jsonc instructions array entry unchanged).
- R-8. The enforcement test SHALL still pass its static content checks after condensation.

## 5. Items

### Item 1 (SC-1): Retain zero-tolerance core

- RED: enforcement test asserts the Zero Tolerance Rule section is present (string grep) — fails if condensation removes it.
- GREEN: keep the Zero Tolerance Rule text unchanged in the condensed guideline.
- verify: grep the Zero Tolerance Rule section present in `.opencode/guidelines/065-verification-honesty.md`.
- commit: guideline edit.

### Item 2 (SC-2a): Retain Pre-Response Factual Claim Gate numbered procedure

- RED: enforcement test asserts '## Pre-Response Factual Claim Gate' with its numbered procedure present — fails if removed or unnumbered.
- GREEN: keep the gate section and its numbered procedure in the condensed guideline.
- verify: grep '## Pre-Response Factual Claim Gate' and its numbered procedure markers.
- commit: guideline edit.

### Item 3 (SC-2b): Retain Halt Condition subsection

- RED: enforcement test asserts '### Halt Condition' subsection present — fails if removed.
- GREEN: keep the '### Halt Condition' subsection in the condensed guideline.
- verify: grep '### Halt Condition'.
- commit: guideline edit.

### Item 4 (SC-3): Retain Session-Scoped Verification subsection (condensed)

- RED: enforcement test SC-004 asserts 'Session-Scoped Verification' subsection present — fails if removed entirely.
- GREEN: retain a condensed 'Session-Scoped Verification' subsection (header + one-line definition); relocate surrounding detail.
- verify: grep 'Session-Scoped Verification' in the guideline.
- commit: guideline edit.

### Item 5 (SC-4): Remove inline 'What COUNTS as Evidence' tables

- RED: enforcement test asserts the 'What COUNTS as Evidence' ✅/❌ tables are no longer inline (SC-001/SC-002) — fails if retained.
- GREEN: remove/move the evidence-example tables from the guideline.
- verify: grep the 'What COUNTS as Evidence' table headers absent from the guideline.
- commit: guideline edit.

### Item 6 (SC-5a): Remove Evidence Requirement bullets

- RED: grep asserts the '## Evidence Requirement' bullets are no longer inline — fails if retained.
- GREEN: remove the '## Evidence Requirement' bullets from the guideline, preserving the retained core and gate.
- verify: grep the '## Evidence Requirement' markers absent from the guideline.
- commit: guideline edit.

### Item 7 (SC-5b): Remove No Exceptions section

- RED: grep asserts the '## No Exceptions' section is no longer inline — fails if retained.
- GREEN: remove the '## No Exceptions' section from the guideline, preserving the retained core and gate.
- verify: grep the '## No Exceptions' markers absent from the guideline.
- commit: guideline edit.

### Item 8 (SC-5c): Remove FORBIDDEN lists

- RED: grep asserts the '🚫 FORBIDDEN' lists are no longer inline — fails if retained.
- GREEN: remove the '🚫 FORBIDDEN' lists from the guideline, preserving the retained core and gate.
- verify: grep the '🚫 FORBIDDEN' markers absent from the guideline.
- commit: guideline edit.

### Item 9 (SC-5d): Remove REQUIRED lists

- RED: grep asserts the '✅ REQUIRED' lists are no longer inline — fails if retained.
- GREEN: remove the '✅ REQUIRED' lists from the guideline, preserving the retained core and gate.
- verify: grep the '✅ REQUIRED' markers absent from the guideline.
- commit: guideline edit.

### Item 10 (SC-6): Add relocated evidence content to the verification skill

- RED: grep relocated evidence examples present in `.opencode/skills/verification/SKILL.md` — fails if absent.
- GREEN: add the relocated evidence examples/detail to the verification skill card (single canonical home).
- verify: grep evidence examples present in `.opencode/skills/verification/SKILL.md`.
- commit: skill card edit.

### Item 11 (SC-7): Add Read-links from guideline to verification skills

- RED: grep 'Read [' in the guideline pointing to verification skills — fails if absent or wrong form.
- GREEN: add `Read [Text](path)` links from the guideline to the verification skills for relocated detail.
- verify: grep 'Read [' in guideline pointing to verification skills.
- commit: guideline edit.

### Item 12 (SC-8): Enforcement test still passes

- RED: run static grep checks of test-verification-honesty.sh — fails if any check breaks.
- GREEN: condensation preserves all static content checks (SC-001..SC-005).
- verify: run static grep checks of `.opencode/tests-v2/test-verification-honesty.sh`.
- commit: no test change (or reconciled test update only if conflict C7 forces it).

### Item 13 (SC-9): Behavioral honesty compliance

- RED: behavioral scenario (opencode run via with-test-home) shows an agent failing to follow the never-rely-on-memory core after condensation — fails.
- GREEN: condensation preserves agent behavioral compliance with the honesty core.
- verify: run behavioral scenario via opencode run (with-test-home) and inspect stderr for honesty-compliance agent actions.
- commit: no source change (behavioral verification of retained core).

### Item 14 (SC-10): Config preload retention

- RED: grep asserts the guideline's opencode.jsonc instructions-array entry is unchanged — fails if the entry was removed or altered.
- GREEN: leave the guideline's opencode.jsonc instructions-array entry unchanged.
- verify: grep the guideline's instructions-array entry unchanged in opencode.jsonc.
- commit: no config change.

## 6. Dependencies

- **Reference:** `.opencode#2372` — "[SPEC] Update verification skill — anchor verification-honesty & authority-source link" (michael-conrad/.opencode).
  **Relationship:** Becomes the canonical home for the relocated evidence examples; should be merged first or coordinated so the skills already anchor the relocated detail.
  **Status:** OPEN (pending).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1, SC-9 | Phase 1, 3 |
| R-2 | SC-2a, SC-2b | Phase 1 |
| R-3 | SC-4, SC-5a, SC-5b, SC-5c, SC-5d | Phase 1 |
| R-4 | SC-6 | Phase 2 |
| R-5 | SC-3 | Phase 1 |
| R-6 | SC-7 | Phase 2 |
| R-7 | SC-10 | Phase 1 |
| R-8 | SC-8 | Phase 3 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| 065-verification-honesty.md | guideline | `.opencode/guidelines/065-verification-honesty.md` | read (current session) |
| verification skill card | skill | `.opencode/skills/verification/SKILL.md` | read (current session) |
| verification-before-completion skill card | skill | `.opencode/skills/verification-before-completion/SKILL.md` | read (current session) |
| verification-enforcement skill card | skill | `.opencode/skills/verification-enforcement/SKILL.md` | read (current session) |
| enforcement test | test | `.opencode/tests-v2/test-verification-honesty.sh` | pre-spec-inspection artifact |
| opencode.jsonc | config | `.opencode/opencode.jsonc` | pre-spec-inspection artifact |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the core is retained costs one grep read. Skipping means the honesty core is silently weakened and the Tier 1 never-rely-on-memory rule ships degraded.
- **SC-2a:** Verifying the gate's numbered procedure is retained costs one grep read. Skipping means the numbered procedure of the Pre-Response Factual Claim Gate is lost and agents produce unverified claims.
- **SC-2b:** Verifying the Halt Condition subsection is retained costs one grep read. Skipping means the halt-condition subsection is lost and agents fail to halt on unverifiable claims.
- **SC-3:** Verifying the condensed subsection costs one grep read. Skipping means enforcement SC-004 fails and the enforcement test breaks.
- **SC-4:** Verifying the evidence tables are removed costs one grep read. Skipping means the condensation is a no-op for the tables.
- **SC-5a:** Verifying the Evidence Requirement bullets are removed costs one grep read. Skipping means the condensation is a no-op for the Evidence Requirement bullets.
- **SC-5b:** Verifying the No Exceptions section is removed costs one grep read. Skipping means the condensation is a no-op for the No Exceptions section.
- **SC-5c:** Verifying the FORBIDDEN lists are removed costs one grep read. Skipping means no condensation benefit and the condensation is a no-op for the FORBIDDEN lists.
- **SC-5d:** Verifying the REQUIRED lists are removed costs one grep read. Skipping means no condensation benefit and the condensation is a no-op for the REQUIRED lists.
- **SC-6:** Verifying the verification skill contains relocated content costs one grep read. Skipping means the detail is lost entirely (violates I1).
- **SC-7:** Verifying the Read-links costs one grep read. Skipping means relocated detail is unreachable.
- **SC-8:** Running the enforcement test costs minutes. Skipping means a regression in the honesty enforcement ships to production and costs 1000× more to fix.
- **SC-9:** Running the behavioral honesty scenario costs minutes (with-test-home harness). Skipping means behavioral compliance with the retained honesty core is unverified — the static grep checks alone cannot confirm agents still follow the rule.
- **SC-10:** Verifying the config preload entry is unchanged costs one grep read. Skipping means the preload mechanism is silently altered and the honesty core is no longer always-available.

## 11. Edge Cases

- **Input boundaries:** Empty guideline (nothing to condense) — not applicable; the guideline has substantive content.
- **State transitions:** AS-IS → CONDENSED (SC-001..SC-005 must still pass; SC-4/SC-5a/SC-5b/SC-5c/SC-5d verify removal); CONDENSED → SKILLS-UPDATED (relocated content present in the verification skill + Read-links); SKILLS-UPDATED → VERIFIED (enforcement test passes + behavioral honesty compliance).
- **Failure modes:** If condensation removes the Session-Scoped Verification subsection → SC-004 FAIL (conflict C7). If skills updated without Read-links → relocated detail unreachable (SC-7 FAIL). If relocated detail lands in the wrong skill (not the canonical verification skill) → SC-6 FAIL. If behavioral honesty regresses after condensation → SC-9 FAIL. If the config preload entry is altered → SC-10 FAIL (preload mechanism changed).
- **Concurrency:** No concurrent state; single-file documentation condensation.
- **Recovery:** If a static check fails, restore the affected section; the enforcement test is the gate. If the behavioral honesty check fails, restore the procedural detail that supports the core until compliance is re-established.

## Change Control

- **2026-08-28 — Revision (validation findings from spec validation):** Decomposed compound SC-4 into atomic SC-4 (remove evidence tables) + SC-5 (remove procedural detail); changed all grep-based SC evidence types from `structural` to `string`; made SC-6 deterministic (single canonical home: `.opencode/skills/verification/SKILL.md` instead of "at least one of"); defined an explicit minimum reduction threshold for the size-reduction SC-9; added behavioral SC-10 for the Tier 1 honesty core; added R-9 requirement tracing the enforcement-test SC (fixes orphan SC); updated Items (1:1 item-SC mapping, 10 items), Traceability, Cost Frame, and Edge Cases to match. Authorized by: spec-validation findings (aggregate FAIL on traceability, evidence-type, testability/determinism, and compound-SC defects).
- **2026-08-29 — Revision (removal of false-target size-reduction SC):** Removed SC-9 (the hard token-reduction minimum threshold) and its associated R-1, Item 13, traceability row, cost-frame entry, and edge-case failure mode; removed all numeric token-reduction threshold references and "token savings" threshold language from the spec. Renumbered the remaining SCs (SC-10→SC-9, SC-11→SC-10), Requirements (R-2..R-9→R-1..R-8), and Items (Item 14→13, Item 15→14); updated the Not Included SC-10 reference, Cost Frame, Edge Cases, Traceability, and sc-summary.yaml (sc_count 15→14, plan_item renumber). Rationale: condensation savings are an emergent property of correctly implementing the content-based SCs — a hard numerical threshold incentivizes aggressive trimming to hit a number rather than faithful implementation. Authorized by: spec revision request for `.opencode#2349`.
- **2026-08-28 — Revision (validation findings — compound-SC/atomicity):** Decomposed compound SC-2 into atomic SC-2a (retain Pre-Response Factual Claim Gate numbered procedure) + SC-2b (retain Halt Condition subsection); decomposed compound SC-5 into atomic SC-5a (remove Evidence Requirement bullets) + SC-5b (remove No Exceptions section) + SC-5c (remove FORBIDDEN/REQUIRED lists); updated sc-summary.yaml, Items (1:1 item-SC mapping, 13 items), Traceability (R-3→SC-2a/SC-2b, R-4→SC-4/SC-5a/SC-5b/SC-5c), Cost Frame, and Edge Cases to match the decomposed atomic SC set; ensured the analytical artifacts directory `.opencode/.issues/2349/artifacts/` is present. Authorized by: spec-validation findings (aggregate FAIL on compound-SC/atomicity).
- **2026-08-28 — Revision (validation findings — traceability + compound-SC):** (1) Fixed R-8 traceability: added atomic SC-11 (opencode.jsonc instructions-array entry unchanged) as the faithful trace target for R-8, replacing the weak R-8→SC-1 mapping (SC-1 verifies the zero-tolerance core, not the config); updated sc-summary.yaml, Items (added Item 15), Traceability (R-8→SC-11), Cost Frame, and Edge Cases. (2) Decomposed compound SC-5c into atomic SC-5c (remove FORBIDDEN lists) + SC-5d (remove REQUIRED lists); updated sc-summary.yaml, Items (added Item 9), Traceability (R-4→SC-4/SC-5a/SC-5b/SC-5c/SC-5d), Cost Frame, and Edge Cases to match. Authorized by: spec-validation findings (aggregate FAIL on traceability and compound-SC defects).

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
