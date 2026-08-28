# [SPEC] Condense 065-verification-honesty.md — move evidence examples to verification skill

## 1. Intent and Executive Summary

1. **Problem Statement:** The Tier 1 preloaded guideline `.opencode/guidelines/065-verification-honesty.md` consumes ~1.9k tokens of preload budget on every session. Roughly 35% of its content is procedural — evidence-requirement examples, session-scoped verification detail, and pre-response gate procedure — that duplicates content already available in the verification / verification-before-completion / verification-enforcement skills.

2. **Root Cause / Motivation:** The guideline is always preloaded into every agent's context regardless of whether verification is performed. Procedural evidence examples are reinforcement, not unique content — they belong in a single source of truth (the skill cards, loaded on-demand). Keeping them in the preload wastes budget on every session and creates a duplication drift risk between the guideline and the skills.

3. **Approach Chosen:** Condense the guideline to retain only the honesty core (Zero Tolerance Rule), the Pre-Response Factual Claim Gate (with numbered procedure + halt condition), and a condensed Session-Scoped Verification subsection. Relocate the procedural evidence examples (What COUNTS as Evidence ✅/❌ tables, Evidence Requirement bullets, No Exceptions, FORBIDDEN/REQUIRED lists) to the verification skill card (`.opencode/skills/verification/SKILL.md`), and add mandatory `Read [Text](path)` links from the guideline to the skills so relocated detail remains reachable.

4. **Alternatives Considered & Why Discarded:**
   - *Relocate the session-scoped detail entirely (remove the subsection):* Discarded — enforcement test SC-004 requires a 'Session-Scoped Verification' subsection present in the guideline. Removing it would break the enforcement test (conflict C7). Retain a condensed subsection (header + one-line definition) instead.
   - *Leave the guideline unchanged:* Discarded — fails the ≥0.7k token savings target and leaves duplicated procedural detail in preload.
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
- **Behavioral honesty regression** — verifying that agents still follow the honesty core after condensation IS included (SC-10); this is not excluded.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The guideline SHALL retain the Zero Tolerance Rule (never-rely-on-memory core) unchanged in substance. | string | grep the Zero Tolerance Rule section present in the condensed guideline | `.opencode/guidelines/065-verification-honesty.md` |
| SC-2 | The guideline SHALL retain the '## Pre-Response Factual Claim Gate' section with numbered procedure and '### Halt Condition' subsection. | string | grep '## Pre-Response Factual Claim Gate' and '### Halt Condition' in the guideline | `.opencode/guidelines/065-verification-honesty.md` |
| SC-3 | The guideline SHALL retain a condensed 'Session-Scoped Verification' subsection (header + one-line definition) per enforcement SC-004. | string | grep 'Session-Scoped Verification' in the guideline | `.opencode/guidelines/065-verification-honesty.md` |
| SC-4 | The guideline SHALL remove the inline 'What COUNTS as Evidence' ✅/❌ tables. | string | grep the 'What COUNTS as Evidence' table headers absent from the guideline | `.opencode/guidelines/065-verification-honesty.md` |
| SC-5 | The guideline SHALL remove the surrounding procedural detail (Evidence Requirement bullets, No Exceptions, FORBIDDEN/REQUIRED lists) that is not part of the retained core or gate. | string | grep the Evidence Requirement bullets, No Exceptions, and FORBIDDEN/REQUIRED list markers absent from the guideline | `.opencode/guidelines/065-verification-honesty.md` |
| SC-6 | The verification skill SHALL contain the relocated evidence examples/detail (single canonical home: `.opencode/skills/verification/SKILL.md`). | string | grep evidence examples present in `.opencode/skills/verification/SKILL.md` | `.opencode/skills/verification/SKILL.md` |
| SC-7 | The guideline SHALL use mandatory `Read [Text](path)` links to the verification skills for relocated detail. | string | grep 'Read [' in guideline pointing to verification skills | `.opencode/guidelines/065-verification-honesty.md` |
| SC-8 | The enforcement test `.opencode/tests-v2/test-verification-honesty.sh` SHALL still pass its static content checks (SC-001..SC-005). | string | run static grep checks of test-verification-honesty.sh | `.opencode/tests-v2/test-verification-honesty.sh` |
| SC-9 | The guideline token/line count SHALL be reduced by at least 0.7k tokens (explicit minimum reduction threshold). | string | measure token count before vs after; assert reduction ≥ 0.7k tokens | `.opencode/guidelines/065-verification-honesty.md` |
| SC-10 | Agents SHALL still follow the honesty core (never-rely-on-memory) after condensation. | behavioral | behavioral scenario via opencode run (with-test-home harness) asserting honesty compliance on a real-domain prompt | `.opencode/guidelines/065-verification-honesty.md`, `.opencode/tests-v2/` |

## 4. Requirements

- R-1. The guideline SHALL be condensed to reduce preloaded token cost by at least 0.7k tokens.
- R-2. The guideline SHALL retain the zero-tolerance never-rely-on-memory core (Zero Tolerance Rule), and agents SHALL continue to follow it behaviorally.
- R-3. The guideline SHALL retain the Pre-Response Factual Claim Gate section with its numbered procedure and halt condition.
- R-4. The guideline SHALL remove the inline evidence-example tables and surrounding procedural detail.
- R-5. The verification skill SHALL contain the relocated evidence examples/detail (single canonical home).
- R-6. The guideline SHALL retain a condensed Session-Scoped Verification subsection while relocating surrounding procedural detail.
- R-7. The guideline SHALL use mandatory `Read [Text](path)` links to the verification skills for relocated detail.
- R-8. The guideline SHALL remain preloaded (opencode.jsonc instructions array entry unchanged).
- R-9. The enforcement test SHALL still pass its static content checks after condensation.

## 5. Items

### Item 1 (SC-1): Retain zero-tolerance core

- RED: enforcement test asserts the Zero Tolerance Rule section is present (string grep) — fails if condensation removes it.
- GREEN: keep the Zero Tolerance Rule text unchanged in the condensed guideline.
- verify: grep the Zero Tolerance Rule section present in `.opencode/guidelines/065-verification-honesty.md`.
- commit: guideline edit.

### Item 2 (SC-2): Retain Pre-Response Factual Claim Gate

- RED: enforcement test asserts '## Pre-Response Factual Claim Gate' with numbered procedure + halt condition present — fails if removed or unnumbered.
- GREEN: keep the gate section and numbered procedure + '### Halt Condition' subsection in the condensed guideline.
- verify: grep '## Pre-Response Factual Claim Gate' and '### Halt Condition'.
- commit: guideline edit.

### Item 3 (SC-3): Retain Session-Scoped Verification subsection (condensed)

- RED: enforcement test SC-004 asserts 'Session-Scoped Verification' subsection present — fails if removed entirely.
- GREEN: retain a condensed 'Session-Scoped Verification' subsection (header + one-line definition); relocate surrounding detail.
- verify: grep 'Session-Scoped Verification' in the guideline.
- commit: guideline edit.

### Item 4 (SC-4): Remove inline 'What COUNTS as Evidence' tables

- RED: enforcement test asserts the 'What COUNTS as Evidence' ✅/❌ tables are no longer inline (SC-001/SC-002) — fails if retained.
- GREEN: remove/move the evidence-example tables from the guideline.
- verify: grep the 'What COUNTS as Evidence' table headers absent from the guideline.
- commit: guideline edit.

### Item 5 (SC-5): Remove surrounding procedural detail

- RED: grep asserts the Evidence Requirement bullets, No Exceptions, and FORBIDDEN/REQUIRED lists are no longer inline — fails if retained.
- GREEN: remove the surrounding procedural detail (Evidence Requirement bullets, No Exceptions, FORBIDDEN/REQUIRED lists) from the guideline, preserving the retained core and gate.
- verify: grep the procedural-detail markers absent from the guideline.
- commit: guideline edit.

### Item 6 (SC-6): Add relocated evidence content to the verification skill

- RED: grep relocated evidence examples present in `.opencode/skills/verification/SKILL.md` — fails if absent.
- GREEN: add the relocated evidence examples/detail to the verification skill card (single canonical home).
- verify: grep evidence examples present in `.opencode/skills/verification/SKILL.md`.
- commit: skill card edit.

### Item 7 (SC-7): Add Read-links from guideline to verification skills

- RED: grep 'Read [' in the guideline pointing to verification skills — fails if absent or wrong form.
- GREEN: add `Read [Text](path)` links from the guideline to the verification skills for relocated detail.
- verify: grep 'Read [' in guideline pointing to verification skills.
- commit: guideline edit.

### Item 8 (SC-8): Enforcement test still passes

- RED: run static grep checks of test-verification-honesty.sh — fails if any check breaks.
- GREEN: condensation preserves all static content checks (SC-001..SC-005).
- verify: run static grep checks of `.opencode/tests-v2/test-verification-honesty.sh`.
- commit: no test change (or reconciled test update only if conflict C7 forces it).

### Item 9 (SC-9): Achieve token savings ≥ 0.7k

- RED: measure guideline token count — fails if not reduced by at least 0.7k tokens.
- GREEN: condensation reduces the guideline size by ≥ 0.7k tokens while retaining the honesty core.
- verify: measure token count before vs after; assert reduction ≥ 0.7k tokens.
- commit: guideline edit.

### Item 10 (SC-10): Behavioral honesty compliance

- RED: behavioral scenario (opencode run via with-test-home) shows an agent failing to follow the never-rely-on-memory core after condensation — fails.
- GREEN: condensation preserves agent behavioral compliance with the honesty core.
- verify: run behavioral scenario via opencode run (with-test-home) and inspect stderr for honesty-compliance agent actions.
- commit: no source change (behavioral verification of retained core).

## 6. Dependencies

- **Reference:** `.opencode#2372` — "[SPEC] Update verification skill — anchor verification-honesty & authority-source link" (michael-conrad/.opencode).
  **Relationship:** Becomes the canonical home for the relocated evidence examples; should be merged first or coordinated so the skills already anchor the relocated detail.
  **Status:** OPEN (pending).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-9 | Phase 1 |
| R-2 | SC-1, SC-10 | Phase 1, 3 |
| R-3 | SC-2 | Phase 1 |
| R-4 | SC-4, SC-5 | Phase 1 |
| R-5 | SC-6 | Phase 2 |
| R-6 | SC-3 | Phase 1 |
| R-7 | SC-7 | Phase 2 |
| R-8 | SC-1 | Phase 1 |
| R-9 | SC-8 | Phase 3 |

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
- **SC-2:** Verifying the gate section costs one grep read. Skipping means the Pre-Response Factual Claim Gate is lost and agents produce unverified claims.
- **SC-3:** Verifying the condensed subsection costs one grep read. Skipping means enforcement SC-004 fails and the enforcement test breaks.
- **SC-4:** Verifying the evidence tables are removed costs one grep read. Skipping means the condensation is a no-op for the tables.
- **SC-5:** Verifying the procedural detail is removed costs one grep read. Skipping means no token savings and the condensation is a no-op.
- **SC-6:** Verifying the verification skill contains relocated content costs one grep read. Skipping means the detail is lost entirely (violates I1).
- **SC-7:** Verifying the Read-links costs one grep read. Skipping means relocated detail is unreachable.
- **SC-8:** Running the enforcement test costs minutes. Skipping means a regression in the honesty enforcement ships to production and costs 1000× more to fix.
- **SC-9:** Verifying token savings costs one measurement. Skipping means the preload budget is not reclaimed.
- **SC-10:** Running the behavioral honesty scenario costs minutes (with-test-home harness). Skipping means behavioral compliance with the retained honesty core is unverified — the static grep checks alone cannot confirm agents still follow the rule.

## 11. Edge Cases

- **Input boundaries:** Empty guideline (nothing to condense) — not applicable; the guideline has substantive content.
- **State transitions:** AS-IS → CONDENSED (SC-001..SC-005 must still pass; SC-4/SC-5/SC-9 verify removal and savings); CONDENSED → SKILLS-UPDATED (relocated content present in the verification skill + Read-links); SKILLS-UPDATED → VERIFIED (enforcement test passes + behavioral honesty compliance).
- **Failure modes:** If condensation removes the Session-Scoped Verification subsection → SC-004 FAIL (conflict C7). If skills updated without Read-links → relocated detail unreachable (SC-7 FAIL). If relocated detail lands in the wrong skill (not the canonical verification skill) → SC-6 FAIL. If token reduction is below the 0.7k minimum threshold → SC-9 FAIL (condensation incomplete). If behavioral honesty regresses after condensation → SC-10 FAIL.
- **Concurrency:** No concurrent state; single-file documentation condensation.
- **Recovery:** If a static check fails, restore the affected section; the enforcement test is the gate. If the behavioral honesty check fails, restore the procedural detail that supports the core until compliance is re-established.

## Change Control

- **2026-08-28 — Revision (validation findings from spec validation):** Decomposed compound SC-4 into atomic SC-4 (remove evidence tables) + SC-5 (remove procedural detail); changed all grep-based SC evidence types from `structural` to `string`; made SC-6 deterministic (single canonical home: `.opencode/skills/verification/SKILL.md` instead of "at least one of"); defined explicit ≥0.7k minimum reduction threshold for token-savings SC-9; added behavioral SC-10 for the Tier 1 honesty core; added R-9 requirement tracing the enforcement-test SC (fixes orphan SC); updated Items (1:1 item-SC mapping, 10 items), Traceability, Cost Frame, and Edge Cases to match. Authorized by: spec-validation findings (aggregate FAIL on traceability, evidence-type, testability/determinism, and compound-SC defects).

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
