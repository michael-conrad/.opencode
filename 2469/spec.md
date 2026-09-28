# [SPEC] Scope .opencode behavioral-test mandates to .opencode-targeted work

## Problem

Agents using the .opencode deck in repos other than the .opencode deck repo
mis-apply the `opencode run` behavioral-test requirements in two ways:

1. They treat the behavioral-test mandate (run via `opencode run` through the
   tests-v2 harness) as applying to ANY change they make, including changes in
   repos that do not provide the tests-v2 harness — producing failed runs or
   fabricated workarounds.
2. They alter their local copies of `.opencode` as an escape hatch from the
   mis-scoped mandate instead of leaving the deck untouched and routing deck
   concerns to the `.opencode` repo's issue tracker.

Root cause: the deck's rule text fuses two concerns — universal evidence rigor
("behavioral SCs require behavioral evidence") is expressed with
deck-repo-specific harness mechanics ("MUST run via `opencode run`"), so
agents outside the deck repo inherit harness mandates that cannot apply.

Developer directive (binding): "if the spec isn't for .opencode then .opencode
testframe is not to be used and the .opencode repo is not to be touched."
Spec target repo is the bright line.

## Scope

IN: `.opencode/guidelines/020-go-prohibitions.md` §1 cost-blind clause;
`.opencode/guidelines/080-code-standards.md` critical-rules-060;
`.opencode/guidelines/091-incremental-build.md` behavioral variant;
`.opencode/skills/test-driven-development/SKILL.md` §Evidence Type Taxonomy
prose; `.opencode/reference/spec-structure-standards.md` evidence table row
behavioral; `.opencode/tests-v2/AGENTS.md` scope-anchor statement.

OUT: any file outside the `.opencode` repo (cross-repo boundary specs are
forbidden — the parent-repo AGENTS.md Test Framework Discipline conflict is
reported separately as a parent-repo bug issue, not an SC here); tests-v2
harness scripts; runtime plugins/tools.

## Approach

1. Canonical scope anchor: add an explicit scope statement to
   `.opencode/tests-v2/AGENTS.md` — the tests-v2 harness (and `opencode run`
   behavioral-testing mechanics) applies ONLY to `.opencode`-targeted work;
   for any other spec target the harness is out of scope and `.opencode` must
   not be modified.
2. Scope qualifiers in 020 §1, 080 critical-rules-060, and 091 behavioral
   variant: instrument (`opencode run` + tests-v2 helpers) is conditional on
   the work targeting the `.opencode` deck repo; universal evidence-rigor duty
   (behavioral/semantic/string/structural distinction and precedence)
   is UNCHANGED for all repos — non-deck work uses the strongest available
   in-repo instrument (pytest, script execution, runtime verification).
3. Skill-card alignment: TDD SKILL.md §Evidence Type Taxonomy prose separates
   universal evidence-type rigor from deck-specific instrument mechanics;
   spec-structure-standards.md evidence table's behavioral row gains a
   fallback instrument (primary: deck repo `opencode run`; fallback: strongest
   available execution-based evidence).
4. Deck-copy integrity: rule text states agents must NOT patch local `.opencode`
   copies to escape a mis-scoped mandate; deck defects route via
   issue-operations to `michael-conrad/.opencode`.

## Success Criteria

| SC | Requirement | Evidence type | Verify |
|----|-------------|---------------|--------|
| SC-1 | `tests-v2/AGENTS.md` gains a scope-anchor statement: harness + `opencode run` mechanics apply only to `.opencode`-targeted work; for all other targets the framework is out of scope and `.opencode` must not be modified | string | grep anchor text in tests-v2/AGENTS.md |
| SC-2 | `020-go-prohibitions.md` §1 cost-blind clause and `080-code-standards.md` critical-rules-060 carry the scope qualifier and Read-link the SC-1 anchor; identical semantics, no divergent variant | string | grep qualifiers + Read-links in both files |
| SC-3 | `091-incremental-build.md` behavioral variant expresses instrument conditionality: `opencode run` instrument for `.opencode`-targeted items; strongest available instrument for other repos; universal behavioral-evidence duty unchanged | string | grep 091 behavioral-variant text |
| SC-4 | TDD SKILL.md §Evidence Type Taxonomy prose separates universal evidence-type rigor from deck-repo instrument mechanics; taxonomy types, precedence, EVIDENCE_TYPE_MISMATCH semantics unchanged | string | grep taxonomy prose + unchanged type table |
| SC-5 | `spec-structure-standards.md` evidence table behavioral row: primary instrument (deck repo: `opencode run`) + fallback (strongest available execution-based evidence) | string | grep table row |
| SC-6 | Behavioral RED: agent given a real-domain non-`.opencode` change applies/uses the `.opencode` testframe (harness attempt or local deck edit) — current behavior fails the criterion | behavioral | opencode run via with-test-home; session.yaml; clean-room evaluation |
| SC-7 | Behavioral GREEN: after changes, agent with a non-`.opencode` change defers to in-repo instruments, does NOT invoke the tests-v2 harness, does NOT modify `.opencode` in any way, and routes deck concerns to `michael-conrad/.opencode` issue tracker | behavioral | opencode run via with-test-home; session.yaml; clean-room evaluation |

Evidence-type note: SC-6/SC-7 follow the tests-v2 §6a two-SC pattern (artifact
generation + clean-room session.yaml evaluation). The fix is a deck rule
change, so its behavioral SCs run in the deck repo — the self-referential case
the qualifiers must handle correctly (qualifiers must NOT exempt
`.opencode`-targeted work from behavioral testing).

## Impact

- Files: 6 `.opencode` files listed in Scope; no harness scripts, no runtime code.
- Downstream vendored `.opencode` copies propagate via submodule sync — the fix
  is propagation-delayed, not instant.
- Universal evidence rigor preserved: non-deck work still requires execution-
  based (behavioral-type) evidence via the strongest available in-repo
  instrument; only the deck-harness mechanics become conditional.

## Documentation Sources

- `.opencode/guidelines/020-go-prohibitions.md` §1 (cost-blind verification clause)
- `.opencode/guidelines/080-code-standards.md` critical-rules-060
- `.opencode/guidelines/091-incremental-build.md` behavioral variant
- `.opencode/skills/test-driven-development/SKILL.md` §Evidence Type Taxonomy
- `.opencode/reference/spec-structure-standards.md` evidence table
- `.opencode/tests-v2/AGENTS.md` (harness scope; §6a two-SC pattern)

---

*Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)*