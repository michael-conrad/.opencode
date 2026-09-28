<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)

# [SPEC] Scope .opencode behavioral-test mandates to .opencode-targeted work

> **Spec folder:** `.opencode/.issues/2469/`
> **Repo:** michael-conrad/.opencode

## 1. Intent and Executive Summary

| # | Field | Content |
|---|-------|---------|
| 1 | **Problem Statement** | Agents using the .opencode deck in repos other than the .opencode deck repo mis-apply the `opencode run` behavioral-test requirements in two ways: (1) they treat the behavioral-test mandate (run via `opencode run` through the tests-v2 harness) as applying to ANY change they make, including changes in repos that do not provide the tests-v2 harness — producing failed runs or fabricated workarounds; (2) they alter their local copies of `.opencode` as an escape hatch from the mis-scoped mandate instead of leaving the deck untouched and routing deck concerns to the `.opencode` repo's issue tracker. |
| 2 | **Root Cause / Motivation** | The deck's rule text fuses two concerns — universal evidence rigor ("behavioral SCs require behavioral evidence") is expressed with deck-repo-specific harness mechanics ("MUST run via `opencode run`"), so agents outside the deck repo inherit harness mandates that cannot apply. Developer directive (binding): "if the spec isn't for .opencode then .opencode testframe is not to be used and the .opencode repo is not to be touched." Spec target repo is the bright line. |
| 3 | **Approach Chosen** | Add a canonical scope anchor to `tests-v2/AGENTS.md` (carrying both the harness-scope statement and the R-6 routing directive: deck defects route via issue-operations to `michael-conrad/.opencode`, no local deck patching), add scope qualifiers to the three guideline restatements (020 §1, 080 critical-rules-060, 091 behavioral variant) that Read-link the anchor, align the TDD SKILL.md §Evidence Type Taxonomy prose and the spec-structure-standards evidence table's behavioral row with a fallback instrument, and state deck-copy integrity (no local deck patching; deck defects route via issue-operations). |
| 4 | **Alternatives Considered & Why Discarded** | (1) Qualify the mandate inside each of the six files with full self-contained scope text — discarded: six inline variants drift; identical semantics require a single canonical anchor with Read-links. (2) Weaken the universal behavioral-evidence duty repo-wide — discarded: the defect is instrument availability, not evidence rigor; non-deck work still requires execution-based evidence via the strongest in-repo instrument. (3) Fix the parent-repo AGENTS.md Test Framework Discipline in this spec — discarded: cross-repo boundary specs are forbidden; the parent-repo conflict is reported separately as a parent-repo bug issue. |
| 5 | **Key Design Decisions** | (a) Single canonical scope anchor in `tests-v2/AGENTS.md`; every other file Read-links it rather than restating scope semantics. (b) Instrument conditionality is layered ON TOP of unchanged universal evidence-type rigor — the taxonomy types, precedence, and EVIDENCE_TYPE_MISMATCH semantics are untouched. (c) The self-referential case: behavioral SCs for this spec run in the deck repo itself, so the qualifiers MUST NOT exempt `.opencode`-targeted work from behavioral testing. (d) Deck-copy integrity is a prohibition with a routing path, not a discretion hedge. |
| 6 | **User Intent / Original Prompt** | Issue: "[SPEC] Scope .opencode behavioral-test mandates to .opencode-targeted work" (.opencode#2469), filed per the spec-creation pipeline with developer binding directive: "if the spec isn't for .opencode then .opencode testframe is not to be used and the .opencode repo is not to be touched." |

## 2. Not Included

- **Any file outside the `.opencode` repo** — cross-repo boundary specs are forbidden; the parent-repo AGENTS.md Test Framework Discipline conflict is reported separately as a parent-repo bug issue, not an SC here.
- **tests-v2 harness scripts** — the fix is rule-text scoping; harness mechanics are already correct for `.opencode`-targeted work.
- **Runtime plugins/tools** — no runtime code changes; this is guideline/skill-card/reference text only.
- **Universal evidence-type taxonomy changes** — types, precedence, and EVIDENCE_TYPE_MISMATCH semantics are UNCHANGED; only instrument availability becomes conditional.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | `tests-v2/AGENTS.md` SHALL gain a scope-anchor statement: the tests-v2 harness and `opencode run` mechanics apply only to `.opencode`-targeted work; for all other spec targets the framework is out of scope and `.opencode` SHALL NOT be modified; the anchor SHALL also carry the R-6 routing directive — deck defects route via issue-operations to the `michael-conrad/.opencode` issue tracker, and agents do NOT patch local `.opencode` copies to escape a mis-scoped mandate. | string | grep anchor text in `tests-v2/AGENTS.md` | `.opencode/tests-v2/AGENTS.md` (live read) |
| SC-2 | `020-go-prohibitions.md` §1 cost-blind clause SHALL carry the scope qualifier (instrument conditional on `.opencode`-targeted work; universal evidence duty unchanged) and Read-link the SC-1 anchor; semantics identical to the anchor, no divergent inline variant. | string | grep qualifier + Read-link in `020-go-prohibitions.md` | `.opencode/guidelines/020-go-prohibitions.md` (live read) |
| SC-3 | `080-code-standards.md` critical-rules-060 SHALL carry the scope qualifier (instrument conditional on `.opencode`-targeted work; universal evidence duty unchanged) and Read-link the SC-1 anchor; semantics identical to the anchor, no divergent inline variant. | string | grep qualifier + Read-link in `080-code-standards.md` | `.opencode/guidelines/080-code-standards.md` (live read) |
| SC-4 | `091-incremental-build.md` behavioral variant SHALL express instrument conditionality: `opencode run` instrument for `.opencode`-targeted items; strongest available in-repo instrument for other repos; universal behavioral-evidence duty unchanged; text SHALL Read-link the SC-1 anchor. | string | grep 091 behavioral-variant text | `.opencode/guidelines/091-incremental-build.md` (live read) |
| SC-5 | TDD SKILL.md §Evidence Type Taxonomy prose SHALL separate universal evidence-type rigor from deck-repo instrument mechanics; taxonomy types, precedence, and EVIDENCE_TYPE_MISMATCH semantics SHALL remain unchanged. | string | grep taxonomy prose + unchanged type table | `.opencode/skills/test-driven-development/SKILL.md` (live read) |
| SC-6 | `spec-structure-standards.md` evidence table behavioral row SHALL carry a primary instrument (deck repo: `opencode run`) plus a fallback instrument (strongest available execution-based evidence), aligned to SC-5 semantics via Read-link. | string | grep table row | `.opencode/reference/spec-structure-standards.md` (live read) |
| SC-7 | Behavioral RED: an agent given a real-domain non-`.opencode` change currently applies/uses the `.opencode` testframe (harness attempt or local deck edit) — the session artifact exhibits the mis-scoped behavior. | behavioral | artifact-generation scenario: `opencode run` via `with-test-home`; artifact-only generator produces `session.yaml`; exit 0 | `.opencode/tests-v2/AGENTS.md` §6a (live read) |
| SC-8 | Behavioral GREEN (clean-room evaluation of SC-7 artifacts): after changes, an agent with a non-`.opencode` change defers to in-repo instruments, does NOT invoke the tests-v2 harness, does NOT modify `.opencode` in any way, and routes deck concerns to the `michael-conrad/.opencode` issue tracker. | behavioral | clean-room sub-agent reads `session.yaml` from SC-7 artifacts and evaluates agent actions against this criterion | `.opencode/tests-v2/AGENTS.md` §6a (live read) |

**SC-7/SC-8 two-SC pattern justification:** per tests-v2 §6a, every behavioral test pairs an artifact-generation SC (SC-7) with a separate clean-room evaluation SC (SC-8); the two runs are never merged into a single dispatch. The fix is a deck rule change, so its behavioral SCs run in the deck repo — the self-referential case the qualifiers are designed to handle correctly (qualifiers MUST NOT exempt `.opencode`-targeted work from behavioral testing).

## 4. Requirements

R-1. The tests-v2 harness scope statement SHALL declare that the harness and `opencode run` mechanics apply only to `.opencode`-targeted work, and SHALL direct all other spec targets to in-repo instruments.

R-2. The deck rule text in 020-go-prohibitions.md §1 and 080-code-standards.md critical-rules-060 SHALL carry the scope qualifier and SHALL Read-link the canonical anchor in tests-v2/AGENTS.md.

R-3. The 091-incremental-build.md behavioral variant SHALL express instrument conditionality: `opencode run` for `.opencode`-targeted items and the strongest available in-repo instrument for all other repos.

R-4. The TDD skill card §Evidence Type Taxonomy SHALL separate universal evidence-type rigor from deck-repo instrument mechanics without altering taxonomy types, precedence, or EVIDENCE_TYPE_MISMATCH semantics.

R-5. The spec-structure-standards evidence table behavioral row SHALL declare a primary instrument (deck repo: `opencode run`) and a fallback instrument (strongest available execution-based evidence).

R-6. The deck rule text SHALL prohibit modifying local `.opencode` copies to escape a mis-scoped mandate, and SHALL route deck defects via issue-operations to the `michael-conrad/.opencode` issue tracker.

R-7. Behavioral verification of this spec SHALL follow the tests-v2 §6a two-SC pattern: an artifact-generation SC and a separate clean-room evaluation SC, and the qualifiers SHALL NOT exempt `.opencode`-targeted work from behavioral testing.

## 5. Items

### Item 1 (SC-1): Scope anchor in tests-v2/AGENTS.md

- RED: grep for the scope-anchor statement in `tests-v2/AGENTS.md` returns no match — the anchor does not exist yet.
- GREEN: add the explicit scope statement: harness + `opencode run` mechanics apply only to `.opencode`-targeted work; for any other spec target the harness is out of scope and `.opencode` SHALL NOT be modified. The anchor text also carries the R-6 routing directive: deck defects route via issue-operations to `michael-conrad/.opencode`, and agents do NOT patch local `.opencode` copies to escape a mis-scoped mandate.
- verify: grep confirms the anchor text and Read-link resolvability.
- commit: one commit covering `tests-v2/AGENTS.md` anchor statement.

### Item 2 (SC-2): Scope qualifier in 020-go-prohibitions.md §1

- RED: grep for the scope qualifier + Read-link in `020-go-prohibitions.md` §1 returns no match.
- GREEN: instrument the cost-blind clause with the scope qualifier and Read-link the SC-1 anchor; identical semantics, no divergent variant.
- verify: grep confirms qualifier + Read-link.
- commit: one commit covering `020-go-prohibitions.md`.

### Item 3 (SC-3): Scope qualifier in 080-code-standards.md critical-rules-060

- RED: grep for the scope qualifier + Read-link in `080-code-standards.md` critical-rules-060 returns no match.
- GREEN: add the same scope qualifier and Read-link the SC-1 anchor; identical semantics to SC-2.
- verify: grep confirms qualifier + Read-link.
- commit: one commit covering `080-code-standards.md`.

### Item 4 (SC-4): Instrument conditionality in 091-incremental-build.md

- RED: grep for instrument-conditional text in the 091 behavioral variant returns no match.
- GREEN: restate the behavioral variant with instrument conditionality (`opencode run` for deck items; strongest in-repo instrument otherwise) and Read-link the SC-1 anchor; universal duty unchanged.
- verify: grep confirms conditionality text + Read-link.
- commit: one commit covering `091-incremental-build.md`.

### Item 5 (SC-5): TDD skill card taxonomy separation

- RED: grep for deck/non-deck instrument separation in §Evidence Type Taxonomy prose returns no match.
- GREEN: add prose separating universal evidence-type rigor from deck-repo instrument mechanics; taxonomy table unchanged.
- verify: grep confirms new prose; diff confirms type table and EVIDENCE_TYPE_MISMATCH semantics unchanged.
- commit: one commit covering `test-driven-development/SKILL.md`.

### Item 6 (SC-6): Evidence table fallback instrument

- RED: grep the `spec-structure-standards.md` behavioral row for fallback instrument text returns no match.
- GREEN: extend the behavioral row with primary + fallback instrument wording aligned to SC-5.
- verify: grep confirms table row wording.
- commit: one commit covering `spec-structure-standards.md`.

### Item 7 (SC-7): Behavioral RED — artifact generation

- RED: behavioral scenario via `opencode run` (with-test-home): agent receives a real-domain non-`.opencode` change; the artifact-only generator script produces `session.yaml` and exits 0. The clean-room criterion (SC-8) judges the current unqualified deck — the mis-scoped harness attempt or local deck edit is the RED failure.
- GREEN: with Items 1-6 landed, re-run the same scenario; the agent defers to in-repo instruments.
- verify: scenario run produces `session.yaml` (artifact generation confirmed).
- commit: one commit covering the behavioral scenario script.

### Item 8 (SC-8): Behavioral GREEN — clean-room evaluation

- RED: clean-room evaluation of the pre-change SC-7 `session.yaml` against the GREEN criterion returns FAIL (agent exhibited mis-scoped behavior).
- GREEN: clean-room sub-agent reads the post-change `session.yaml` from SC-7 artifacts and evaluates: agent defers to in-repo instruments, does NOT invoke tests-v2, does NOT modify `.opencode`, routes deck concerns to `michael-conrad/.opencode`. Verdict PASS.
- verify: clean-room evaluation verdict recorded for both RED (pre-change FAIL) and GREEN (post-change PASS) legs.
- commit: one commit covering the evaluation verdict artifact.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/tests-v2/AGENTS.md` §6a | Defines the two-SC behavioral pattern SC-7/SC-8 consume | Satisfied (exists) |
| `.opencode/tests-v2/with-test-home` | Required harness wrapper for all `opencode run` behavioral verification | Satisfied (exists) |
| `.opencode/tools/local-issues` | Deck-defect routing path referenced by the prohibition text | Satisfied (exists) |
| tests-v2 §4 ordered precondition cycle | commit → push → fresh fetch → verify effective commit in remote ref → run; required before behavioral runs | Satisfied (exists) |
| Developer directive 2026-09-27 ("spec isn't for .opencode → testframe not used, .opencode not touched") | Motivating constraint for the scope anchor | Satisfied |

## 7. Traceability

| Requirement | SC(s) | Item(s) |
|-------------|-------|---------|
| R-1 | SC-1 | Item 1 |
| R-2 | SC-2, SC-3 | Item 2, Item 3 |
| R-3 | SC-4 | Item 4 |
| R-4 | SC-5 | Item 5 |
| R-5 | SC-6 | Item 6 |
| R-6 | SC-1, SC-8 | Item 1, Item 8 |
| R-7 | SC-7, SC-8 | Item 7, Item 8 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| 020-go-prohibitions.md §1 | code (guideline) | `.opencode/guidelines/020-go-prohibitions.md` | Read (pre-spec inspection) |
| 080-code-standards.md critical-rules-060 | code (guideline) | `.opencode/guidelines/080-code-standards.md` | Read (pre-spec inspection) |
| 091-incremental-build.md behavioral variant | code (guideline) | `.opencode/guidelines/091-incremental-build.md` | Read (pre-spec inspection) |
| TDD SKILL.md §Evidence Type Taxonomy | code (skill card) | `.opencode/skills/test-driven-development/SKILL.md` | Read (pre-spec inspection) |
| spec-structure-standards.md evidence table | doc (reference) | `.opencode/reference/spec-structure-standards.md` | Read (pre-spec inspection) |
| tests-v2/AGENTS.md (harness scope; §6a; §4) | doc (harness spec) | `.opencode/tests-v2/AGENTS.md` | Read (pre-spec inspection) |
| Parent AGENTS.md Test Framework Discipline | doc (reported separately) | root repo `AGENTS.md`, "Test Framework Discipline" section | Read (pre-spec inspection; parent-repo bug filed separately) |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the anchor statement costs one grep pass. Skipping costs weeks of drift: without a canonical anchor, each consumer file restates scope text and divergent variants ship undetected until a cross-repo incident surfaces them.
- **SC-2:** Verifying the 020 qualifier costs one grep pass. Skipping costs days-to-weeks: the cost-blind clause keeps its unqualified harness mandate and every agent reading it outside the deck repo re-attempts `opencode run`, producing failed runs that surface only after wasted session time.
- **SC-3:** Verifying the 080 qualifier costs one grep pass. Skipping costs the same downstream latency as SC-2 at the critical-rules-060 consumption point, where behavioral-evidence claims are made during verification gates.
- **SC-4:** Verifying the 091 conditionality costs one grep pass. Skipping costs days: per-SC TDD cycles inherit the unqualified harness mandate and non-deck items stall on a harness that cannot exist in their repo.
- **SC-5:** Verifying the taxonomy prose separation costs one grep pass plus a table diff. Skipping costs hours-to-days: taxonomy consumers keep fusing rigor with instrument, and a spec-audit or VbC gate fails late in the pipeline instead of at authoring time.
- **SC-6:** Verifying the evidence-table row costs one grep pass. Skipping costs days: specs authored from the table declare a behavioral instrument their repo cannot provide, and the mismatch surfaces at the first plan-execution cycle.
- **SC-7:** Running the artifact-generation scenario costs minutes of execution time — a bounded delay. Skipping costs the full downstream rework when the mis-scoping defect ships: every non-deck session repeats the failed-run/fabricated-workaround loop, compounding per session.
- **SC-8:** Running the clean-room evaluation costs minutes of clean-room dispatch time. Skipping costs the loss of the only behavioral proof that the fix changes agent behavior — string evidence alone passes while the mis-scoped behavior continues in production, a 1000× escalation by the tiered cost table.

## 11. Edge Cases

- **Condition:** The spec's own behavioral SCs run in the deck repo (self-referential case). **Expected behavior:** the qualifiers apply — `.opencode`-targeted work keeps full behavioral testing via the harness. **Resolution:** SC-8 clean-room criterion verifies the qualifier does NOT exempt deck work.
- **Condition:** A non-deck repo has no execution-based instrument available at all. **Expected behavior:** the agent SHALL NOT invoke the tests-v2 harness and SHALL NOT patch the deck; it reports the missing instrument rather than fabricating a substitute. **Resolution:** universal rigor duty states the requirement; unavailability is reported, never worked around.
- **Condition:** A deck defect is discovered while working in a non-deck repo. **Expected behavior:** the agent routes the defect via issue-operations to `michael-conrad/.opencode` and does NOT patch the local deck copy. **Resolution:** R-6 prohibition + SC-1 anchor routing directive + SC-8 criterion.
- **Condition:** The behavioral harness (`with-test-home`) fails or times out during SC-7/SC-8. **Expected behavior:** verdict is FAIL with diagnosis (cause analysis before any excuse); structural substitutes are prohibited. **Resolution:** remediate harness, re-run.
- **Failure mode:** downstream vendored `.opencode` copies carry OLD unqualified text until submodule sync. **Expected behavior:** propagation-delayed, not instant; no action in this spec. **Resolution:** accepted; submodule sync propagates the fix.
- **State boundaries:** the universal evidence-type taxonomy (behavioral/semantic/string/structural, precedence, EVIDENCE_TYPE_MISMATCH) is unchanged by this spec; only instrument availability becomes conditional.

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-09-27 | Initial spec draft | — | Spec-creation pipeline |
| 2026-09-28 | Revision: (1) added the missing 6-field preamble (Intent and Executive Summary table). (2) Added missing sections: Not Included, Requirements (R-1..R-7 SHALL per RFC 2119), Items (per-SC TDD cycles), Dependencies, Traceability, Enforcement Gate, Cost Frame (per-SC dark-prose-007 per cost-model-standards.md), Edge Cases, Change Control. (3) Split compound SC-2 (020+080 bundle) into atomic SC-2 (020) and SC-3 (080); renumbered downstream SCs (SC-3→4 … SC-7→8); decomposed compound prohibition claims into atomic SCs (SC-2/SC-3/SC-4 each one file, SC-8 one criterion). (4) Split §6a two-SC leg into explicit SC-7 (artifact generation) and SC-8 (clean-room evaluation) per tests-v2 §6a, replacing the implicit note. (5) Added 5-column SC table (Documentation Sources column) per spec-structure-standards + create.md Step 2.1. (6) Normalized normative language to SHALL/SHALL NOT. (7) Deleted stale analytical artifacts (directory `.opencode/.issues/2469/artifacts/` removed) — prior artifacts labeled anchor SC-6 / parent-repo SC-7 and mis-assigned evidence types against the revised SC map; regeneration is a create-pipeline step. No linked plan exists (checked `.opencode/.issues/2469/plan.md`). | Validation findings from spec-creation-validation (7 findings) | Developer-issued revise dispatch (validation_findings) |
| 2026-09-28 | Revision: (1) COMPLETENESS — extended SC-1's anchor criterion and Item 1 GREEN text to name the R-6 routing directive as part of the anchor statement (deck defects route via issue-operations to `michael-conrad/.opencode`; agents do NOT patch local `.opencode` copies to escape a mis-scoped mandate), giving R-6 a string-verifiable carrier file (`tests-v2/AGENTS.md`) and adding R-6→SC-1 to the Traceability table; Approach Chosen and Edge Cases deck-defect row updated to match. (2) SHALL-CONFORMANCE — replaced the lowercase unqualified "must" in the SC-7/SC-8 pattern justification ("the qualifiers must handle correctly") with the normative "are designed to handle correctly". (3) LINE-NUMBER REFERENCE — replaced the Documentation Sources citation "root repo `AGENTS.md` lines 45-47" with the stable anchor "Test Framework Discipline" section per the cross-reference standards. | Validation findings from spec-creation-validation (3 findings: COMPLETENESS substantive; SHALL-CONFORMANCE mechanical; LINE-NUMBER REFERENCE mechanical) | Developer-issued revise dispatch (validation_findings) |