# [SPEC] Test-tier discipline — smoke + regression default for cycles and PRs, full suite non-default

**GitHub issue: #2541**

## Purpose

Stop full-suite test runs from consuming implementation capacity. The
observed pattern, reported by the developer this session: when every PR and
every implementation cycle runs all tests, sessions end up doing nothing but
running tests. Verification must stay proportional to the change.

## Requirement source

- Developer statement (this session, 2026-10-07): smoke tests and regression
  tests exist for this purpose; the goal is to NOT run all tests for every
  PR or implementation cycle; the deck's skill and detail cards must address
  this directly, structured for progressive disclosure.

## Scope

| Artifact | Change |
|----------|--------|
| `.opencode/skills/implement/SKILL.md` | card-level mandate: smoke + regression default, full suite non-default |
| `.opencode/skills/implement/references/implementation-workflow.md` | tier definitions table; amend full-suite baseline and post-regression rows to tiered form |

Out of scope: the `verify` card (its reviewer runs evidence checks against
stated requirements, not scheduled suites); floor.md (always-loaded surface
stays unchanged — this is card-level content); any scripting of tier
selection.

## Success criteria

### SC-1 (structural)

The `implement` skill card and its implementation-workflow reference state
the tiered test mandate, with progressive-disclosure structure:

1. `SKILL.md` states: smoke + regression are the default for every
   implementation cycle and PR; the full suite is never the default —
   reserved for release boundaries or explicit developer request.
2. `references/implementation-workflow.md` defines the three tiers (smoke,
   regression, full), states when each runs, and notes that tier selection
   is judgment (intent-decidable — no script decides scope).
3. The reference's full-suite mandates are gone: the pre-implementation
   baseline row and the RED-GREEN post-regression row no longer say "run the
   suite" / "re-run the suite" in unscoped form.
4. `floor.md` is unchanged by this spec's implementation.

**Verification instrument:** read both files; fact-decidable checks —
`grep` the card for the tier mandate, the reference for the tier table and
the judgment note, and confirm the two amended rows reference tiers instead
of the whole suite.

## Admission-gate record (deck governance)

1. **Observed failure** — developer-reported pattern this session: full-suite
   runs per PR/cycle leave no capacity for work ("you end up doing nothing
   but running tests").
2. **Consumer** — the `implement` card, loaded at implementation start and
   before every mid-cycle change (routing index); its workflow reference,
   loaded first per the card.
3. **Mechanism/trigger** — card text fires at cycle start; tier definitions
   sit one level deep in the reference (progressive disclosure).
4. **Predicate classification** — tier SELECTION is intent-decidable:
   judgment decides what changed and which tiers apply; scripts are
   forbidden. The card/reference TEXT carrying the mandate is
   fact-decidable (SC-1's instrument).
5. **Domain match** — n/a; no external protocol adopted.
6. **Root-agnostic** — no repo names or absolute paths in the added text.
7. **What it replaces** — amends the reference's unscoped full-suite
   baseline/post-regression mandates to tiered form; adds one card-level
   bullet. Nothing retired wholesale; net addition is one bullet and one
   section.
8. **Always-loaded surface** — no floor.md change; card-level only.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
