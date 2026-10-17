## Problem

The deck's agent-facing cross-reference format has flip-flopped across deck
generations and is now defined only implicitly:

- The pre-rip deck used citation-style references (`See \`FILE.md\`
  §SECTION`, `See SKILLNAME skill`) — .opencode#1923 recorded the failure
  mode (agents treat citations as decorative and never load the target).
- .opencode#1988 (78 experimental runs) and .opencode#1958 (2026-07) ruled
  the canonical form `Load [Text](path)` for the pre-rip deck; #1958's
  Phase-1 audit found 568 cross-references across 153 files, 141 in
  nonconforming forms (`See [text](path)`, bare `§N`/`§Name`, non-linked
  `See file.md`, bare skill references).
- The deck revision (.opencode#2490, 2026-10-03) replaced the deck
  wholesale. The post-rip deck's cards use `Read [Text](path)`
  (e.g. `skills/implement/SKILL.md`, `skills/programming-principles/SKILL.md`)
  and `tools/reference-integrity` (.opencode#2489 SC-12) validates exactly
  that form — passing on all 63 agent-facing files as of 2026-10-17. The
  #1958 `Load` ruling now governs content preserved under `attic/` only.

The canonical form therefore lives in no normative location. Its only
definitions are the regex inside `tools/reference-integrity` and a
harness-scoped mention in `tests-v2/AGENTS.md` §6c ("run before committing"
— a manual instruction, not a deck-authoring rule). No card or guideline
states the form, its meaning, or its validator where deck prose is actually
authored. Each deck generation has re-decided the format from scratch
(`See` → `Load` → `Read`); nothing at the authoring moment prevents the next
flip-flop or the reintroduction of variant forms. As of 2026-10-17 the live
deck is clean (zero `See \`` and zero `Load [` matches in tracked content
outside `attic/`) — the risk is recurrence, not current state.

## Root Cause

The format decision is recorded only in artifacts a deck author does not
load at authoring time. The card that governs deck authoring —
`skill-creator`, whose description triggers on every edit under `skills/`,
`guidelines/`, and `floor.md` — carries no cross-reference rule.

## Fix

The implementer adds one short normative section to
`.opencode/skills/skill-creator/SKILL.md` carrying these five fixed elements:

1. The canonical form: `Read [descriptive text](relative/path)`.
2. The meaning: the link is a load directive, not a citation — it instructs
   the reading agent to load the target file.
3. The nonconforming forms: `See \`file.md\``, bare `§N`, bare file names,
   `Load [...]`.
4. The validator: `./.opencode/tools/reference-integrity` validates that
   every such link resolves.
5. The temporal scope: forwards-only — the rule binds when deck prose is
   written or revised; existing content converts when touched.

Suggested wording (the implementer may adjust phrasing and placement within
the card body, provided the five elements appear as normative statements):

> **Agent-facing cross-references.** When deck prose points an agent at
> content in another deck file, use `Read [descriptive text](relative/path)`.
> The link is a load directive, not a citation — it instructs the reading
> agent to load the target. Other forms (`See \`file.md\``, bare `§N`, bare
> file names, `Load [...]`) are nonconforming.
> `./.opencode/tools/reference-integrity` validates that every such link
> resolves. Forwards-only: existing content converts when touched.

The edit is developer-directed (2026-10-17, scope narrowed in-session to
this statement only) and routes through this same card's governance. The
card's content standards bind the edit: root-agnostic (deck-relative paths
only), fact-decidable predicate (form presence and link resolvability are
script-checkable; nothing here scripts a judgment), lean body (the section
stays within the card's size discipline), and provenance updated in both
surfaces the card carries it — the frontmatter `provenance:` value and the
HTML provenance comment — each extended to name .opencode#1925 (deck
convention: both surfaces carry the same provenance, cf. `skills/gh-cli/SKILL.md`).

## Out of Scope

- Wiring `tools/reference-integrity` into pre-commit/pre-push or CI — no
  observed broken-link recurrence since the tool landed (.opencode#2489);
  the admission gate does not admit mechanism without observed recurrence.
- Extending the tool to detect citation-style or legacy forms — those
  patterns are extinct in tracked live content.
- Behavioral enforcement tests of link-following — .opencode#1926's intent;
  a separate open issue, not remediated by this spec.
- New guideline files or any `floor.md` change — an on-demand authoring
  concern gains no standing always-injected surface.
- Converting grandfathered references anywhere outside the touched card.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `skills/skill-creator/SKILL.md` contains the normative cross-reference statement carrying all five fixed elements from Fix | `structural` | grep the file for each fixed element's distinctive substring — `Read [descriptive text](relative/path)`, `load directive, not a citation`, `Load [...]`, `reference-integrity`, `Forwards-only` — every grep must match |
| SC-2 | The change is confined to the single intended file | `structural` | `git diff --name-only` against the feature branch base lists only `.opencode/skills/skill-creator/SKILL.md` |
| SC-3 | The amended card stays intact: frontmatter keys and all non-provenance values unchanged, both provenance surfaces (frontmatter `provenance:` value and HTML provenance comment) name .opencode#1925, all pre-existing sections otherwise unaltered | `structural` | inspect the diff: frontmatter keys unchanged and only the `provenance:` value extended with .opencode#1925; HTML provenance comment updated to match; no deletions outside the added section |

## Affected Files

- `.opencode/skills/skill-creator/SKILL.md` — one added normative section;
  no other file.

## Impact

- Consumers: deck authors — agents editing any file under `skills/`,
  `guidelines/`, or `floor.md` load `skill-creator` first by its
  description trigger, so the rule is in context at the only moment
  fragmentation can be prevented: authoring time.
- Risk: none at runtime. Documentation-only change to one on-demand card.
- Blast radius: one file. The validator, harness docs, floor, and all other
  cards are untouched. Grandfathering means no existing content changes.

## Alternatives Considered

- **Hook wiring** (invoke `reference-integrity` from `pre-commit`): rejected —
  a fail-closed fact check, but the stranded-references failure that
  motivated it (.opencode#2489) predates the tool and no second incident is
  on record; the admission gate does not admit mechanism without observed
  recurrence.
- **Standing behavioral test** of link-following (.opencode#1926's intent):
  rejected — the observed failure predates the deck revision, .opencode#1988's
  78 runs banked the behavioral evidence, and tests-v2 §6b's performative-test
  retirement precedent bars standing tests without defect coverage.
- **New guideline file or a `floor.md` line**: rejected — a guideline loads
  on content need, not on deck-authoring intent (worse trigger point), and a
  floor line buys permanent always-injected tokens in every session for an
  on-demand concern.

## Interdependency Ordering

- **BLOCKED BY**: Nothing (ships independently)
- **BLOCKS**: Nothing
- **INDEPENDENT OF**: .opencode#1926 (behavioral tests — remains open,
  unaffected by this spec)

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
