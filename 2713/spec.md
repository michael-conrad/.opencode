<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# [SPEC] SC subject-matter discipline — criteria verify behavior or content, never byte-exactness or toolchain guarantees

## 1. Problem Statement

The agent keeps authoring success criteria whose subject is byte-exact equality or what the build toolchain already guarantees, instead of the deliverable's behavior or content. The developer's stated rule, 2026-11-04: SCs target the deliverable's behavior or its content — never byte-exact matches as such, never a check on whether the build tool is doing its job (§5 carries the verbatim utterance).

Measured pattern (research card
[sc-subject-matter-byte-exact-performativity.md](../research-cards/sc-subject-matter-byte-exact-performativity.md), 2026-11-04): 35 deck-store tickets carry byte-identical/exact language. The observed performative shapes, each read in context:

- **Toolchain-guarantee criteria** — "TypeScript compiles without errors" (`tsc --noEmit`) as an SC (`.opencode#2097` SC-11, root-store #300 SC-11): the instrument observes the toolchain, not the deliverable.
- **Scope-restatement byte guards** — `.opencode#2618` SC-4 (`floor.md`/`routing.md` byte-identical though the change never touches them); `.opencode#2444`'s read-only "canonical documents byte-identical before/after". The scoped diff already states this.
- **Manufactured RED** — `.opencode#2460` Item 5: "RED: field-diff check fails against a deliberately mutated fixture (test validates its own sensitivity)" — a RED produced by mutating the input the check reads, then un-mutating it, evidences the check's sensitivity, never the criterion.
- **Byte-equality as drift control** — `.opencode#2458` SC-3's six-card byte-identical inlining, explicitly retired by `.opencode#2618` NREQ-3 as a retired old-deck mechanism, replaced by link integrity.
- **Count-threshold targets** — the `#2347` SC-8 family, ruled false targets once already (`.opencode#2411`).

Legitimate uses exist and must stay legitimate: byte-exactness where identity or preservation is itself the stated requirement — `.opencode#2346` SC-1b (safety-critical blocks preserved during condensation of the same file), `.opencode#2304` SC-3 (git commands untouched by a prose sweep of that same file), `.opencode#2660` (preserved passages), `.opencode#2643` (archive content preservation), root-store #374 (point-in-time records).

The validators never fired: `.opencode#2643`'s validation defended a byte-identical shorthand as "the only capable reading"; `.opencode#2660`'s validation spent its judgment adjudicating a one-space soft-wrap delta under a byte-exact requirement. `validation-standards.md` findings 5 (incapable instrument) and 7 (trivially-true restatement) name the genus abstractly and passed these criteria in practice.

## 2. Root Cause / Motivation

`skills/spec/SKILL.md` rule 3 constrains *how* an SC is checked ("behavioral SCs get a runtime verification instrument; structural SCs get a fact-decidable check") and never *what* an SC may be about — "fact-decidable" reads as grep/diff/byte-equality, the easiest decidable check. The implement card's rule 7 carries the correct rule for tests ("Never test an artifact the build system already guarantees", with offender classes (a) source-content inspection, (b) framework re-read tautologies, (c) assertion-shaped placeholders) but nothing equivalent governs SC authoring, so the performative criterion is authored upstream and flows into plans and tests. The `#2411` false-target rule retired to `attic/` in the deck restructure — no live anchor remains — and covered only reduction thresholds. Store precedent feeds the mimicry: the agent reads prior specs and copies the pattern forward.

## 3. Approach Chosen

Two files inside `skills/spec/`:

1. `skills/spec/SKILL.md` rule 3 gains the subject-matter constraint: an SC's subject is the deliverable's behavior (a runtime effect the deliverable owns) or its content (what the deliverable states or contains); the toolchain prohibition; and the byte-exactness reservation with its identity/preservation carve-out.
2. `skills/spec/references/validation-standards.md` gains the five observed shapes as described classes for reviewer judgment inside the existing defect-class structure — never a keyword table, per that page's own constitution ("no keyword lists, no trigger-word tables"; judgment, not lexical checks).

The new rule subsumes the retired `#2411` false-numerical-target rule — a count/byte/percentage reduction threshold is neither behavior nor content — so no attic restoration is needed and the attic copy stays retired.

## 4. Alternatives Considered & Why Discarded

1. **Anchor the rule in `floor.md`** — discarded: always-loaded surface discipline; the rule is spec-stage-scoped, card-level content.
2. **Add a tests-v2 behavioral pickup scenario** asserting an agent refuses a byte-exact SC — discarded for this change: the validation dispatch reading the sharpened reference is the in-flow enforcement point; the scenario is heavier machinery than the observed failure requires.
3. **Amend the plan card / `plan-validation-standards.md` too** — discarded: plans derive entirely from the spec; fixing the source stops the flow, and cascading the rule into a second card duplicates it (single-sourcing discipline).
4. **Restore `#2411`'s attic rule** — discarded: it targets reduction thresholds (a narrower genus) and its anchors are retired; the new rule subsumes the threshold case.

## 5. User Intent / Original Prompt

- "defect. the agent keeps incorportating performative useless fucking byte exact checks. research." (2026-11-04)
- "the SCs are supposed to be for *behavior* or *content*, not fucking byte exact matches, nor for if gradle is doing its job, etc." (2026-11-04)
- "proceed to spec creation" (2026-11-04)

The observed failures come from the same session's research findings, recorded in the research card cited in §1.

## 6. Not Included

- The plan card and `plan-validation-standards.md` — plans derive entirely from the spec; fixing the source stops the flow.
- A tests-v2 behavioral pickup scenario — see Alternatives item 2.
- Retroactive remediation of existing specs' criteria.
- The implement card — its rule 7 already states the test-side rule.
- `floor.md` — card-scoped directive stays card-level (always-loaded surface discipline).
- Restoring `#2411`'s attic rule — the new rule subsumes it.

## 7. Requirements

- **R-1 — SC subject matter.** Rule 3 of `skills/spec/SKILL.md` SHALL state that every SC asserts the deliverable's behavior — a runtime effect the deliverable owns — or its content — what the deliverable states or contains — and nothing else.
- **R-2 — The toolchain prohibition.** Rule 3 SHALL prohibit, as SC subjects, what the build system or toolchain already guarantees: compilation, packaging, a tool succeeding at its own job.
- **R-3 — The byte-exactness reservation.** Rule 3 SHALL reserve byte-exact instruments for criteria whose stated requirement is itself identity or preservation — guarding sections of a file the same change edits, point-in-time records, content-preservation moves — and SHALL state that a byte-exact check never substitutes for a behavioral or content criterion, never serves as a reduction target, and never restates the change's declared scope.
- **R-4 — The validator-side shapes.** The validation standards' per-criterion defect classes SHALL name the five observed shapes as judgment descriptions within the existing structure, each carrying the identity/preservation carve-out so legitimate byte-exact criteria are not flagged: the toolchain-guarantee criterion (incapable instrument — the instrument observes the toolchain, not the deliverable); the count/byte/percentage reduction-threshold target (incapable instrument — the instrument answers "how many" when the requirement asks whether the content is right); the scope-restatement byte guard (trivially-true restatement — the scoped diff already states it); byte-equality asserted as drift control where a content or link check answers the criterion's question (trivially-true restatement); and the manufactured RED (incapable instrument — a RED produced by mutating the input the check reads and un-mutating it evidences the check's sensitivity, never the criterion). The additions are defect descriptions for reviewer judgment: no keyword list, no trigger-word table, no scripted check.
- **R-5 — Single sourcing.** The rule SHALL live in exactly one authoring place (the spec card) and one validation place (the validation reference); no other card or reference gains a copy, and the implement card's existing test-side rule 7 is neither duplicated nor modified.
- **R-6 — Whole-card conversion.** Each substantively edited file SHALL return its entire normative prose under the deck's writing discipline (guidelines/ainglish-writing-discipline.md) — the whole-card-on-touch adoption rule.

## 8. Success Criteria

| ID | Criterion | Class | Instrument | Sources |
|----|-----------|-------|------------|---------|
| SC-1 | Rule 3 states the subject-matter constraint — SC subjects are the deliverable's behavior or content — binding SC authorship | structural | Read rule 3; the operative sentence states the constraint and binds the SC author | `skills/spec/SKILL.md` |
| SC-2 | Rule 3 prohibits, as SC subjects, what the build system or toolchain already guarantees — compilation, packaging, a tool succeeding at its own job | structural | Read rule 3; the prohibition clause is present with its scope | `skills/spec/SKILL.md` |
| SC-3 | Rule 3 reserves byte-exact instruments for criteria whose stated requirement is itself identity or preservation, and states that a byte-exact check never substitutes for a behavioral or content criterion, never serves as a reduction target, and never restates the change's declared scope | structural | Read rule 3; the reservation clause and its three never-clauses are present | `skills/spec/SKILL.md` |
| SC-4 | The validation standards name the five observed shapes as judgment descriptions inside the existing defect-class structure, with the carve-out stated, and no keyword table or scripted check enters the page | structural | Read the defect classes; each shape present as a described class with its ground; the page's no-keyword-list constitution intact | `skills/spec/references/validation-standards.md` |
| SC-5 | The rule is single-sourced: the operative phrasing appears only in the spec card and the validation reference; the implement card is unchanged | structural | Search `skills/` for the rule's operative phrasing — matches only in the two owning files; `implement/SKILL.md` carries no new copy | `skills/` tree |
| SC-6 | Both edited files' entire normative prose reads under the writing discipline | structural | Read each edited file end-to-end; the discipline's families hold across the whole normative body (judgment recorded in the validation record) | both edited files |
| SC-7 | Deck validation is green after the edits | structural | `./.opencode/tools/skildeck lint` exits 0 | deck tooling |

### Per-SC RED/GREEN

- **SC-1** — RED: read the current rule 3; no subject-matter constraint exists. GREEN: rule 3 states it. verify: read.
- **SC-2** — RED: rule 3 carries no toolchain prohibition. GREEN: the prohibition clause is present. verify: read.
- **SC-3** — RED: rule 3 carries no byte-exactness reservation. GREEN: the reservation clause and its three never-clauses are present. verify: read.
- **SC-4** — RED: the defect classes name none of the five observed shapes. GREEN: each shape present as a described class, the carve-out stated, the page's constitution intact. verify: read.
- **SC-5** — verify-only post-condition: post-edit search of `skills/` finds the operative phrasing only in the two owning files (pre-change it exists nowhere; the criterion guards against duplication during implementation, and its RED is any third-file match).
- **SC-6** — verify-only: the whole-card conversion is part of the edit's obligation; verified by the end-to-end read.
- **SC-7** — verify-only regression guard: the deck's own validator stays green across the edits.

## 9. Edge Cases

1. **Artifact-content criteria remain valid.** "The fat jar contains the service registration" asserts content of the deliverable's artifact — the gradle card owns what artifacts contain. The prohibition targets what the toolchain guarantees by construction (build succeeds, compiles, packages), not artifact-content claims.
2. **Serialized-artifact identity.** A criterion that a redistributed artifact preserves its license header verbatim: identity IS the stated requirement; the carve-out applies.
3. **Same-file section guards.** `.opencode#2460`'s SC-5 (frontmatter fields of the edited file byte-identical) is a legitimate same-file drift guard; the same ticket's Item 5 (mutate-fixture RED) is the defect. The rule targets cross-file scope restatements and manufactured evidence, not same-file guards.
4. **Test-suite-green as a criterion.** Not covered by the toolchain clause — tests can fail, so the toolchain does not guarantee suite-green; an SC that only restates suite-green adds nothing and is caught by the existing trivially-true-restatement finding. Judgment decides; the new rule does not widen to it.

## 10. Traceability / Documentation Sources

| Source | Type | Used for | Verified |
|--------|------|----------|----------|
| `skills/spec/SKILL.md` | edit target | current rule 3 text (read 2026-11-04) | live read |
| `skills/spec/references/validation-standards.md` | edit target | defect classes, constitution, criteria-invariance closing rule (full read 2026-11-04) | live read |
| `skills/implement/SKILL.md` rule 7 | source of the offender-class framing; excluded from change | test-side rule text (read 2026-11-04) | live read |
| [research card](../research-cards/sc-subject-matter-byte-exact-performativity.md) | evidence base | defect population, classification, root cause | 2026-11-04 |
| `attic/reference/spec-structure-standards.md`, `attic/skills/audit/tasks/spec-audit-evaluator.md` | retired `#2411` anchors | subsumption claim | live read 2026-11-04 |
| Observed-failure tickets: `.opencode#2097`, `#2618`, `#2444`, `#2460`, `#2458`, `#2411`, `#2346`, `#2304`, `#2660`, `#2643`; root-store `#300`, `#374` | observed failures | each named shape and legitimate instance read in its own record | 2026-11-04 |

Traceability: SC-1 ← R-1; SC-2 ← R-2; SC-3 ← R-3; SC-4 ← R-4; SC-5 ← R-5; SC-6 ← R-6; SC-7 ← deck card standards. R-1/R-2/R-3 ← the developer's stated rule (§5, verbatim) + the root-cause gap; R-4 ← the validators-never-fired failures (#2643, #2660); R-5 ← the deck's single-sourcing discipline (`skills/spec/SKILL.md` rule 5, provenance `.opencode#2660`); R-6 ← the writing discipline's whole-card-on-touch rule.

## 11. Cost Frame

- **Action cost:** low — a two-file prose edit inside one card's directory; each edit deterministic and individually verifiable.
- **Skipping cost:** every future spec can ship performative criteria that flow into plans as manufactured RED, and validators keep spending judgment on byte-deltas (the `#2660` one-space adjudication) instead of content — against a 35-ticket precedent base that feeds the mimicry.
- **Correctness is the only success metric** — no score for speed, brevity, or economy.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
