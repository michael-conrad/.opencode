<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# Plan — .opencode#2670 (docs-currentness duty and rule-compliance counterweight)

Derives entirely from `.opencode/.issues/2670/spec.md` (validated PASS, zero findings). All criteria are structural; every instrument is a file-read or a tool run against `.opencode/tools/reference-integrity`. No code, build tools, or language cards are in scope — the deliverables are deck prose in named files; no card beyond the spec's named surfaces is touched. All paths are relative to the `.opencode` submodule root.

## Items

### Item 1 — SC-1: docs-currentness row (implementation-workflow.md)

- **Deliverable:** a new row in the pre-implementation table of `skills/implement/references/implementation-workflow.md` carrying R-1's five elements: (a) the scope class — every surface the change implements against that is documented outside this repository (library APIs, language features, configuration formats, wire formats, dependency versions), with which-surface judgment at cycle time; (b) consultation — current authoritative documentation (official docs at the current version, live registry, consumed source/type hints) before the first code-write of that surface, per-surface and per-cycle, re-triggered on mid-cycle changes; (c) the in-chat statement — what the documentation established, brief and discriminating; (d) the not-verification list — memory, training data, prior sessions' knowledge, similar-library analogy, stale posts; (e) composition pointers — witnessed deprecations follow the deprecation encounter protocol (pointer), and `implement` item 6's consumed-framework pass remains the special case it is (pointer).
- **RED:** read the pre-implementation table — no docs-currentness row exists (verification: `grep -c "documentation" skills/implement/references/implementation-workflow.md` inside the table's row set returns no such row; the grep assertion "table contains a docs-currentness row" fails against current state).
- **GREEN:** author the row per the deliverable, in the table's row order after the existing rows (it composes with, not replaces, the consumed-framework row).
- **Instrument:** read the table and check each of the five elements against the row text (SC-1's instrument, all-elements-required); run `./.opencode/tools/reference-integrity` on the file for the new pointer to `guidelines/deprecation-encounter-protocol.md`.

### Item 2 — SC-2: pointer clause (implement SKILL.md item 2)

- **Deliverable:** `skills/implement/SKILL.md` item 2 names the docs-currentness step as part of the pre-implementation work — one clause pointing at `implementation-workflow.md`'s step, restating none of R-1's content.
- **RED:** read item 2 — it does not name the docs-currentness step (assertion fails against current state).
- **GREEN:** append the pointing clause to item 2. Execution depends on Item 1's row existing to point at.
- **Instrument:** read the card; verify presence in item 2 and non-duplication (no R-1 element restated).

### Item 3 — SC-3: clarify-first clause (floor.md)

- **Deliverable:** one sentence in `floor.md`'s Authorization vocabulary / standing-formula region: a terse developer message that could plausibly authorize or touch a prohibited or authorization-gated surface is clarified first — never acted on under its most convenient reading.
- **RED:** read `floor.md` — the clause is absent.
- **GREEN:** author the sentence in the region. Independent of Items 1–2.
- **Instrument:** read `floor.md`; verify the clause's presence and placement in the region.

### Item 4 — SC-4: compliance-is-action clause (floor.md)

- **Deliverable:** one sentence in the same region: knowledge of a rule — including citing it — never stands as satisfaction of the rule; compliance is the action, never the citation.
- **RED:** read `floor.md` — the clause is absent.
- **GREEN:** author the sentence adjacent to Item 3's clause. Independent; may execute in the same edit pass as Item 3 without merging their verifications.
- **Instrument:** read `floor.md`.

### Item 5 — SC-5: option-listing clause (floor.md)

- **Deliverable:** one sentence in the same region: an option listing names no prohibited surface; raising a prohibited surface as an option is the defect the owning rule already states, with the floor clause as the general statement and per-card rules stating their instances (tests-v2 R-20's model-instance remains the particular case).
- **RED:** read `floor.md` — the clause is absent.
- **GREEN:** author the sentence adjacent to Items 3–4's clauses. Independent; same edit pass as Items 3–4 is permitted with separate verifications.
- **Instrument:** read `floor.md`.

### Item 6 — SC-6: examination clause (verify SKILL.md)

- **Deliverable:** `skills/verify/SKILL.md` gains the R-6 clause as a new numbered item in the reviewer-duties list (spec §2's stated form): the reviewer's diff examination includes the change's externally-documented-surface usage judged for adequacy against current documentation; usage the current documentation contradicts is a correctness finding under the existing churn rule.
- **RED:** read the card — no such examination duty exists among the reviewer's items.
- **GREEN:** author the clause in the reviewer-duties list. Depends on no other item.
- **Instrument:** read the card.

### Item 7 — SC-7: provenance anchors and reference integrity (all edited files)

- **Deliverable:** every file edited in Items 1–6 carries its provenance anchor on both applicable surfaces (frontmatter `provenance:` line for cards; `<!-- Provenance: … -->` comment for `floor.md`) with this issue's anchor (`.opencode#2670`) appended; all new cross-file pointers resolve under `reference-integrity`.
- **RED:** grep the provenance surfaces of the four target files — no `.opencode#2670` anchor present.
- **GREEN:** append the anchor to each edited file's surfaces. Depends on Items 1–6 (it annotates their files).
- **Instrument:** grep both surfaces on all four files for the anchor; run `./.opencode/tools/reference-integrity` over the changed files; the run reports no broken pointers.

## Dependency order

Item 1 → Item 2 (Item 2's pointer targets Item 1's row). Item 3, Item 4, Item 5 are mutually independent (same file, separate verifications). Item 6 is independent. Item 7 last — it annotates every file Items 1–6 edited and runs the integrity instrument over the complete change. No cycles.

## Out of scope (spec §6, inherited verbatim)

Mechanized enforcement of any kind; attic restorations; changes to the session-init banner, `research`, deprecation-encounter-protocol, or tests-v2 R-20's text; new cards or guidelines; floor restructuring beyond the three clauses; re-review loops.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)